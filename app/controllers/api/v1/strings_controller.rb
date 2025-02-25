class Api::V1::StringsController < ApplicationController
  protect_from_forgery with: :null_session

  def transform
    input_string = params[:input]
    output_string = process_string(input_string)
    render json: { output: output_string }
  end

  private
  def process_string(input)
    input.reverse
  end
end
