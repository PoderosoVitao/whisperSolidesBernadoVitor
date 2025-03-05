require "net/http"

class OpenaiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def forward
    audio_binario = params["audioName"]

    transcricao = TranscribeJob.perform_now(audio_binario)
    render json: { transcription: transcricao }
  end
end
