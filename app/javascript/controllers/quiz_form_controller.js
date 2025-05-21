import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topicSelect", "subTopicSelect", "difficultySelect", "questionTypeSelect"]

  connect() {
    // Initialize the form
    
    this.updateTopics()
    this.updateSubTopics()
    this.handleQuestionTypeChange()
  }

  updateTopics() {
    console.log('Eeep')
    const subjectSelect = this.element.querySelector('select[name="subject_id"]')
    const subjectId = subjectSelect.value
    const topicSelect = this.topicSelectTarget
    
    // Reset and disable the topic select if no subject is selected
    if (!subjectId) {
      topicSelect.innerHTML = '<option value="">All Topics</option>'
      topicSelect.disabled = true
      return
    }
    
    // Fetch topics for the selected subject
    fetch(`/subjects/${subjectId}/topics.json`)
      .then(response => response.json())
      .then(data => {
        // Clear current options
        topicSelect.innerHTML = '<option value="">All Topics</option>'
        
        // Add new options
        data.forEach(topic => {
          const option = document.createElement('option')
          option.value = topic.id
          option.textContent = topic.name
          topicSelect.appendChild(option)
        })
        
        // Enable the select
        topicSelect.disabled = false
      })
      .catch(error => {
        console.error('Error fetching topics:', error)
        topicSelect.innerHTML = '<option value="">All Topics</option>'
        topicSelect.disabled = true
      })
  }
  
  // app/javascript/controllers/quiz_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topicSelect", "subTopicSelect", "difficultySelect", "questionTypeSelect"]
  
  connect() {
    console.log("Quiz form controller connected")
    this.handleQuestionTypeChange()
  }
  
  updateTopics() {
    console.log('updateTopics called')
    const subjectSelect = this.element.querySelector('select[name="subject_id"]')
    const subjectId = subjectSelect.value
    const topicSelect = this.topicSelectTarget
    
    console.log('Subject ID:', subjectId)
    
    // Reset and disable the topic select if no subject is selected
    if (!subjectId) {
      topicSelect.innerHTML = '<option value="">All Topics</option>'
      topicSelect.disabled = true
      
      // Also reset sub-topics
      this.subTopicSelectTarget.innerHTML = '<option value="">All Sub-Topics</option>'
      this.subTopicSelectTarget.disabled = true
      return
    }
    
    // Fetch topics for the selected subject
    fetch(`/subjects/${subjectId}/topics.json`)
      .then(response => {
        console.log('Response status:', response.status)
        return response.json()
      })
      .then(data => {
        console.log('Topics data:', data)
        
        // Clear current options
        topicSelect.innerHTML = '<option value="">All Topics</option>'
        
        // Add new options
        if (data && Array.isArray(data)) {
          data.forEach(topic => {
            const option = document.createElement('option')
            option.value = topic.id
            option.textContent = topic.name
            topicSelect.appendChild(option)
          })
        } else {
          console.warn('No topics data or not in expected format:', data)
        }
        
        // Enable the select
        topicSelect.disabled = false
        
        // Reset sub-topics when subject changes
        this.subTopicSelectTarget.innerHTML = '<option value="">All Sub-Topics</option>'
        this.subTopicSelectTarget.disabled = true
      })
      .catch(error => {
        console.error('Error fetching topics:', error)
        topicSelect.innerHTML = '<option value="">All Topics</option>'
        topicSelect.disabled = true
      })
  }
  
  updateSubTopics() {
    console.log('updateSubTopics called')
    const topicSelect = this.element.querySelector('select[name="topic_id"]')
    const topicId = topicSelect.value
    const subTopicSelect = this.subTopicSelectTarget
    
    console.log('Topic ID:', topicId)
    
    // Reset and disable the sub-topic select if no topic is selected
    if (!topicId) {
      subTopicSelect.innerHTML = '<option value="">All Sub-Topics</option>'
      subTopicSelect.disabled = true
      return
    }
    
    // Use the same URL pattern as topics, just replacing "topics" with "sub_topics"
    // This should match the pattern of your nested resources
    const url = `/topics/${topicId}/sub_topics.json`
    console.log('Fetching from URL:', url)
    
    // Fetch sub-topics for the selected topic
    fetch(url)
      .then(response => {
        console.log('Sub-topics response status:', response.status)
        if (!response.ok) {
          throw new Error(`Server responded with ${response.status}: ${response.statusText}`)
        }
        return response.json()
      })
      .then(data => {
        console.log('Sub-topics data:', data)
        
        // Clear current options
        subTopicSelect.innerHTML = '<option value="">All Sub-Topics</option>'
        
        // Check if data is not null and is an array
        if (data && Array.isArray(data)) {
          // Add new options
          data.forEach(subTopic => {
            const option = document.createElement('option')
            option.value = subTopic.id
            option.textContent = subTopic.name
            subTopicSelect.appendChild(option)
          })
          
          // Only enable if we actually have sub-topics
          if (data.length > 0) {
            subTopicSelect.disabled = false
          } else {
            console.log('No sub-topics available for this topic')
          }
        } else {
          console.warn('No sub-topics data or not in expected format:', data)
        }
      })
      .catch(error => {
        console.error('Error fetching sub-topics:', error)
        subTopicSelect.innerHTML = '<option value="">All Sub-Topics</option>'
        subTopicSelect.disabled = true
      })
  }
  
  questionTypeChanged() {
    this.handleQuestionTypeChange()
  }
  
  handleQuestionTypeChange() {
    const questionTypeValue = this.questionTypeSelectTarget.value
    
    if (questionTypeValue === "multiple_choice") {
      // If multiple choice is selected, force difficulty to easy
      this.difficultySelectTarget.value = "easy"
      this.difficultySelectTarget.disabled = true
    } else {
      // For other question types, enable the difficulty selection
      this.difficultySelectTarget.disabled = false
    }
  }
}