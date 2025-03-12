class CreateTranscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :transcriptions do |t|
      t.string :original_filename
      t.text :transcription

      t.timestamps
    end
    add_index :transcriptions, :original_filename
  end
end
