namespace :questions do
  desc "Export questions from the current environment"
  task export: :environment do
    questions = Question.includes(:topic).all
    
    data = {
      questions: questions.map do |q|
        {
          id: q.id,
          content: q.content,
          model_answer: q.model_answer,
          key_concepts: q.key_concepts,
          marking_criteria: q.marking_criteria,
          max_points: q.max_points,
          difficulty_level: q.difficulty_level,
          topic_id: q.topic_id,
          topic_name: q.topic.name,
          topic_subject_id: q.topic.subject_id,
          topic_subject_name: q.topic.subject.name,
          created_at: q.created_at,
          updated_at: q.updated_at
        }
      end
    }
    
    File.write(Rails.root.join('db', 'questions_export.json'), JSON.pretty_generate(data))
    puts "Exported #{questions.count} questions to db/questions_export.json"
  end

  desc "Import questions from export file"
  task import: :environment do
    file_path = Rails.root.join('db', 'questions_export.json')
    unless File.exist?(file_path)
      puts "Error: export file not found at #{file_path}"
      next
    end
    
    data = JSON.parse(File.read(file_path))
    imported = 0
    skipped = 0
    
    data['questions'].each do |q_data|
      # Check if the question already exists
      if Question.exists?(id: q_data['id'])
        skipped += 1
        next
      end
      
      # Find or create the topic
      topic = Topic.find_by(name: q_data['topic_name'])
      
      unless topic
        # Find or create the subject
        subject = Subject.find_by(name: q_data['topic_subject_name'])
        unless subject
          subject = Subject.create!(name: q_data['topic_subject_name'])
          puts "Created subject: #{subject.name}"
        end
        
        # Create the topic
        topic = Topic.create!(
          name: q_data['topic_name'],
          subject_id: subject.id
        )
        puts "Created topic: #{topic.name}"
      end
      
      # Create the question
      Question.create!(
        id: q_data['id'],
        content: q_data['content'],
        model_answer: q_data['model_answer'],
        key_concepts: q_data['key_concepts'],
        marking_criteria: q_data['marking_criteria'],
        max_points: q_data['max_points'],
        difficulty_level: q_data['difficulty_level'],
        topic_id: topic.id,
        created_at: q_data['created_at'],
        updated_at: q_data['updated_at']
      )
      imported += 1
    end
    
    puts "Imported #{imported} questions (#{skipped} skipped as they already exist)"
  end
end