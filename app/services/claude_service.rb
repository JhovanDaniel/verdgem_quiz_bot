require 'httparty'

class ClaudeService
  include HTTParty
  base_uri 'https://api.anthropic.com'
  
  def initialize
    @api_key = ENV['CLAUDE_API_KEY']
    @headers = {
      'Content-Type' => 'application/json',
      'x-api-key' => @api_key,
      'anthropic-version' => '2023-06-01'
    }
  end
  
  def evaluate_answer(question, student_answer)
    # Prepare system prompt
    system_prompt = build_system_prompt(question)
    
    # Prepare user message with the student's answer
    user_message = build_user_message(question, student_answer)
    
    # Make the API call
    begin
      response = self.class.post(
        '/v1/messages',
        body: {
          model: "claude-3-5-haiku-20241022",
          max_tokens: 1000,
          system: system_prompt,
          messages: [
            { role: "user", content: user_message }
          ]
        }.to_json,
        headers: @headers,
        timeout: 150 # 150 seconds timeout
      )
      
      if response.success?
        # Extract the response text
        feedback = response.parsed_response["content"].first["text"]
        
        # Extract score from the beginning of the feedback
        initial_score_match = feedback.match(/^Score:\s*(\d+\.?\d*)\/(\d+)/i)
        
        # Extract total from the end of the feedback
        total_score_match = feedback.match(/Total:\s*(\d+\.?\d*)\/(\d+)/i)
        
        # Extract individual points from breakdown
        point_matches = feedback.scan(/\((\d+\.?\d*)\/\d+\s*points?\)/i)
        points = point_matches.flatten.map(&:to_f)
        
        # Calculate the sum of individual points
        calculated_total = points.sum.round(1)
        
        # Determine the final score
        if initial_score_match
          reported_score = initial_score_match[1].to_f
          max_points = initial_score_match[2].to_i
        elsif total_score_match
          reported_score = total_score_match[1].to_f
          max_points = total_score_match[2].to_i
        else
          reported_score = nil
          max_points = question.max_points
        end
        
        # If there's a mismatch between calculated and reported scores
        if reported_score && (calculated_total - reported_score).abs > 0.01 && points.length > 0
          # Correct the score in the feedback text
          feedback = feedback.gsub(/^Score:\s*\d+\.?\d*\/\d+/i, "Score: #{calculated_total}/#{max_points}")
          feedback = feedback.gsub(/Total:\s*\d+\.?\d*\/\d+/i, "Total: #{calculated_total}/#{max_points}")
          
          # Log the correction
          Rails.logger.info("Score corrected from #{reported_score} to #{calculated_total} based on breakdown")
          
          # Use the calculated score
          score = calculated_total
        else
          # Use the reported score if it exists, otherwise use calculated
          score = reported_score || calculated_total
        end
        
        return {
          success: true,
          feedback: feedback,
          score: score
        }
      else
        Rails.logger.error("Claude API error: #{response.code} - #{response.body}")
        return {
          success: false,
          error: "API responded with error code #{response.code}",
          feedback: "We're having trouble evaluating your answer. A teacher will review it soon.",
          score: nil
        }
      end
    rescue => e
      Rails.logger.error("Claude API exception: #{e.message}")
      return {
        success: false,
        error: e.message,
        feedback: "We're having trouble connecting to our evaluation service. Your answer has been saved and will be reviewed soon.",
        score: nil
      }
    end
  end
  
  private
  
  def build_system_prompt(question)
    <<~PROMPT
      You are an expert CSEC #{question.topic.subject.name} teacher with extensive knowledge of the Caribbean Secondary Education Certificate syllabus. 
      
      Your task is to evaluate a student's answer to a question and provide detailed, constructive feedback.
      
      Follow these evaluation guidelines:
      
      1. Compare the student's answer against the model answer and key concepts.
      2. Assign a fair score based on the marking criteria provided. Do not take off marks for minor spelling errors
      3.Remember that there may be multiple valid approaches to answering the question. 
      Evaluate the substance of the student's understanding rather than expecting exact 
      wording from the model answer.
      4. Provide specific feedback on what the student did well.
      5. Point out any misconceptions or areas for improvement.
      6. Be encouraging and educational in your feedback
      
      IMPORTANT: You must format your response exactly as follows:
      
      SCORE: [Total points awarded]/[Maximum points]
      
      BREAKDOWN:
      - Part (a): [Points awarded]/[Maximum for this part] - [Brief explanation]
      - Part (b): [Points awarded]/[Maximum for this part] - [Brief explanation]
      - Part (c): [Points awarded]/[Maximum for this part] - [Brief explanation]
      
      FEEDBACK:
      [Your detailed feedback here]
      
      TOTAL: [Same exact number as SCORE above]/[Maximum points]
      
      Before submitting your evaluation, mathematically verify that your BREAKDOWN points sum to the exact value in SCORE and TOTAL.
    PROMPT
  end
  
  def build_user_message(question, student_answer)
    <<~MESSAGE
      Question: #{question.content}
      
      Topic: #{question.topic.name}
      
      Key Concepts: #{question.key_concepts}
      
      Marking Criteria (#{question.max_points} points total): 
      #{question.marking_criteria}
      
      Model Answer (for your reference only): 
      #{question.model_answer}
      
      Student's Answer:
      #{student_answer}
      
      Please evaluate this answer carefully. First break down points for each part, then add them up for the total score.
      
      1. Start with "Score: X/#{question.max_points} points" where X is the sum of all awarded points
      2. Provide a breakdown of points for each part
      3. End with "Total: X/#{question.max_points} points" that must match your initial score
      4. Double-check your math before submitting
    MESSAGE
  end
end