class AddSubTopicToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_reference :questions, :sub_topic, type: :uuid, foreign_key: true
  end
end
