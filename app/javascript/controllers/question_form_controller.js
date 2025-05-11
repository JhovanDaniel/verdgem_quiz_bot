// app/javascript/controllers/question_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "longAnswerFields", 
    "multipleChoiceFields", 
    "optionsContainer", 
    "optionTemplate"
  ]
  
  connect() {
    console.log("Question form controller connected!")
    this.optionCounter = this.optionsContainerTarget.querySelectorAll('.answer-option').length || 0
    this.toggleQuestionType()
  }
  
  toggleQuestionType() {
    console.log("Toggle question type called") // Debugging line
    const questionType = document.getElementById('question_question_type').value
    
    if (questionType === 'multiple_choice') {
      this.longAnswerFieldsTarget.classList.add('d-none')
      this.multipleChoiceFieldsTarget.classList.remove('d-none')
      
      // Ensure we have at least 2 options for multiple choice
      if (this.optionCounter < 2) {
        this.addOption()
        this.addOption()
      }
    } else {
      this.longAnswerFieldsTarget.classList.remove('d-none')
      this.multipleChoiceFieldsTarget.classList.add('d-none')
    }
  }
  
  addOption(event) {
    if (event) event.preventDefault()
    
    // Clone the template
    const template = this.optionTemplateTarget.innerHTML
    const newOption = template.replace(/INDEX/g, this.optionCounter++)
    
    // Add to the container
    const tempElement = document.createElement('div')
    tempElement.innerHTML = newOption
    this.optionsContainerTarget.appendChild(tempElement.firstElementChild)
  }
  
  removeOption(event) {
    event.preventDefault()
    
    const optionElement = event.target.closest('.answer-option')
    
    // If this is an existing option, mark it for destruction instead of removing from DOM
    const destroyInput = optionElement.querySelector('.destroy-flag')
    
    if (destroyInput) {
      destroyInput.value = "1"
      optionElement.style.display = 'none'
    } else {
      // Otherwise just remove it from the DOM
      optionElement.remove()
    }
    
    // Check if we need to ensure at least 2 options
    const visibleOptions = this.optionsContainerTarget.querySelectorAll('.answer-option:not([style*="display: none"])')
    if (visibleOptions.length < 2) {
      this.addOption()
    }
  }
}