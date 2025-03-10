require "net/http"
class OpenaiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def forward
    audio_binario = params[:audioName]

    # checa se o arquivo e o diretorio existem
    if audio_binario.present?
      temp_file_path = Rails.root.join("tmp", "uploads", audio_binario.original_filename)
      FileUtils.mkdir_p(File.dirname(temp_file_path))
      File.open(temp_file_path, "wb") { |f| f.write(audio_binario.read) }

      TranscribeJob.perform_later(temp_file_path.to_s)

      render json: { message: "transcricao pendente adicionada na fila" }
    else
      render json: { error: "ERRO -- Arquivo nao foi encontrado" }, status: :unprocessable_entity
    end
  end
end
