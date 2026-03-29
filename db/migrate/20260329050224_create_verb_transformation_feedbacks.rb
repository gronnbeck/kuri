class CreateVerbTransformationFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :verb_transformation_feedbacks do |t|
      t.references :verb_transformation_exercise, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
