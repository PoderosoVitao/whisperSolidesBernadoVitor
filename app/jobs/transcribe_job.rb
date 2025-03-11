class TranscribeJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    return unless File.exist?(file_path)

    begin
      puts "Arquivo encontrado1: #{file_path} (#{File.size(file_path)} bytes)"
      ### START - re-escreve o conteudo de um arquivo .opus para um novo arquivo .ogg
      dirname = File.dirname(file_path)
      basename = File.basename(file_path, ".opus")
      extension = File.extname(file_path)

      if extension == ".opus"
        new_file_path = File.join(dirname, "#{basename}.ogg")
        FileUtils.mv(file_path, new_file_path)
        file_path = new_file_path
        puts "Renamed: #{file_path} -> #{new_file_path}"
      else
        puts "No change: #{file_path} is not an .opus file."
      end
      control = OpenaiService.new.cortar_audio(file_path, "Cortado.ogg")
      if control
        File.open("Cortado.ogg", "rb") do |audio_file|
          transcription = OpenaiService.new.transcribe(audio_file)
          Rails.logger.info("Transcription Completed: #{transcription}")
        end
      else 
        File.open(file_path, "rb") do |audio_file|
          transcription = OpenaiService.new.transcribe(audio_file)
          Rails.logger.info("Transcription Completed: #{transcription}")
        end
      end
      ### END - bloco de conversão OPUS -> OGG
    rescue => e
      Rails.logger.error("Error in TranscribeJob: #{e.message}")
    ensure
      if File.exist?(file_path)
        begin
          File.delete(file_path)
        rescue => e
          Rails.logger.error("Failed to delete file: #{e.message}")
        end
      end
    end
  end
end
