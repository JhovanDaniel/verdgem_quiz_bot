import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topicSelect", "difficultySelect", "questionTypeSelect"]

  connect() {
    // Initialize the form
    console.log('Eeep')
    this.updateTopics()
    this.handleQuestionTypeChange()
  }

  updateTopics() {
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