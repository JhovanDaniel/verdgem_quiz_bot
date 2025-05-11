import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topicSelect"]

  connect() {
    // Initialize the form
    console.log('Eeep')
    this.updateTopics()
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
}