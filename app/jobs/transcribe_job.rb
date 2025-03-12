require 'fileutils'

class TranscribeJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    return unless File.exist?(file_path)

    begin
      puts "Arquivo encontrado1: #{file_path} (#{File.size(file_path)} bytes)"
      # pega o nome do diretorio, do arquivo e da extensao.
      dirname = File.dirname(file_path)
      basename = File.basename(file_path, ".opus")
      extension = File.extname(file_path)

      # Loga o pedido de transcricao na base de dados.
      original_filename = "#{basename}.opus"
      transcription_record = Transcription.find_or_create_by(original_filename: original_filename)

      # Bloco que cuida da conversao .opus -> .ogg
      if extension == ".opus"
        new_file_path = File.join(dirname, "#{basename}.ogg")
        FileUtils.mv(file_path, new_file_path)
        file_path = new_file_path
        puts "Renamed: #{file_path} -> #{new_file_path}"
      else
        puts "No change: #{file_path} is not an .opus file."
      end

      # Bloco que cuida dos limites de tamanho do audio e corta-o se necessario.
      transcription = nil
      arquivoCortado = File.basename(file_path, File.extname(file_path)) #Capturando o nome do arquivo sem a extensão
      output_path = arquivoCortado + "Cortado" + File.extname(file_path) #Adicionando a extensão
      control = OpenaiService.new.cortar_audio(file_path, output_path)
      if control
        File.open(output_path, "rb") do |audio_file|
          transcription = OpenaiService.new.transcribe(audio_file)
          Rails.logger.info("Transcription Completed: #{transcription}")
        end
      else
        File.open(file_path, "rb") do |audio_file|
          transcription = OpenaiService.new.transcribe(audio_file)
          Rails.logger.info("Transcription Completed: #{transcription}")
        end
      end

      # Guarda a transcricao na base de dados.
      transcription_record.update(transcription: transcription)

    rescue => e
      Rails.logger.error("Error in TranscribeJob: #{e.message}")
      # loga erro na base de dados
      transcription_record.update(transcription: nil) if transcription_record
    ensure
      if File.exist?(file_path)
        begin
          File.delete(file_path)
          File.delete(output_path)
        rescue => e
          Rails.logger.error("Failed to delete file: #{e.message}")
        end
      end
    end
  end
end
