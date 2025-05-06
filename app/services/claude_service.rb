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
          system: system_prompt, # This is the correct way to provide a system prompt
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
        
        # Extract score from the feedback text using regex
        score_match = feedback.match(/(\d+)\/(\d+)/)
        score = score_match ? score_match[1].to_i : nil
        
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
      
      1. Compare the student's answer against the model answer and key concepts. Examples that 
      students give in their answers do not have to be exact to model answer but should still be
      a correct example. Answers do not have to be the same as model answers so never take off marks because the answer given is not the same as the model answer.
      Once answers are correct and reasonable they can be awarded marks.
      2. Assign a fair score based on the marking criteria provided. Do not take off marks for simple spelling mistakes
      3. Provide specific feedback on what the student did well
      4. Point out any misconceptions or areas for improvement
      5. Include relevant CSEC curriculum references where appropriate
      6. Be encouraging and educational in your feedback
      7. Start your response with the score in the format: "Score: X/Y points"
      8. IMPORTANT: When providing a breakdown of points, always double-check that the individual points add up to the total score you assign. Count each point awarded carefully.
      9. Always include a clear "Total: X/Y" at the end of your breakdown that accurately sums all points awarded.
      
      Remember that there may be multiple valid approaches to answering the question. 
      Evaluate the substance of the student's understanding rather than expecting exact 
      wording from the model answer.
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
      
      Please evaluate this answer, assign a score out of #{question.max_points} points, and provide detailed feedback. Make sure the final score
      you give adds up with the points you have awarded for each part of a question.
    MESSAGE
  end
end