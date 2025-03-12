class TranscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def show
    original_filename = params[:filename]

    # filename não informado: BAD REQUEST
    unless original_filename.present?
      return render json: { error: "Filename is required" }, status: :bad_request
    end

    transcription_record = Transcription.find_by(original_filename: original_filename)

    # filename informado mas arquivo nao esta logado no sistema.
    if transcription_record.nil?
      return render json: { error: "No transcription request found for #{original_filename}" }, status: :not_found
    end

    # filename informado E arquivo logado no sistema, mas a transcricao ainda nao acabou
    if transcription_record.transcription.nil?
      return render json: { status: "Processing", message: "Transcription is not yet completed" }, status: :found
    end

    # filename encontrado, transcricao encontrada. Retorna transcricao.
    render json: { status: "Completed", transcription: transcription_record.transcription }, status: :ok
  end
end
