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
    
    // Initialize the counter
    this.optionCounter = this.optionsContainerTarget.querySelectorAll('.answer-option').length || 0
    
    // Get the initial question type
    const initialQuestionType = document.getElementById('question_question_type').value
    console.log("Initial question type:", initialQuestionType)
    
    // Apply the appropriate display logic
    this.toggleQuestionType()
    
    // If multiple choice is selected AND there are no existing options, add 4 default options
    if (initialQuestionType === 'multiple_choice' && this.optionCounter === 0) {
      console.log("Adding 4 initial options")
      this.addDefaultOptions(4)
    }
  }
  
  // Separate method for toggling fields visibility
  toggleFieldsVisibility(questionType) {
    if (questionType === 'multiple_choice') {
      this.longAnswerFieldsTarget.classList.add('d-none')
      this.multipleChoiceFieldsTarget.classList.remove('d-none')
    } else {
      this.longAnswerFieldsTarget.classList.remove('d-none')
      this.multipleChoiceFieldsTarget.classList.add('d-none')
    }
  }
  
  // Method to handle type toggle
  toggleQuestionType() {
    console.log("Toggle question type called")
    const questionType = document.getElementById('question_question_type').value
    
    // Get reference to the difficulty select
    const difficultySelect = document.getElementById('question_difficulty_level')
    
    // Toggle visibility
    this.toggleFieldsVisibility(questionType)
    
    if (questionType === 'multiple_choice') {
      const currentOptions = this.optionsContainerTarget.querySelectorAll('.answer-option').length
      this.setDifficultyToEasy()
      
      // Disable the select for multiple choice
      if (difficultySelect) {
        difficultySelect.disabled = true
        console.log("Disabled difficulty select")
      }
      
      if (currentOptions === 0) {
        this.addDefaultOptions(4)
      }
    } else if (questionType === 'long_answer') {
      // Enable the select for long answer
      if (difficultySelect) {
        difficultySelect.disabled = false
        console.log("Enabled difficulty select")
      }
    }
  }
  
  // Method to add a specific number of options
  addDefaultOptions(count) {
    for (let i = 0; i < count; i++) {
      this.addOption()
    }
    
    // Mark the first option as correct by default
    const firstOptionCheckbox = this.optionsContainerTarget.querySelector('input[type="checkbox"]');
    if (firstOptionCheckbox) {
      firstOptionCheckbox.checked = true;
    }
  }
  
  addOption(event) {
    if (event) event.preventDefault()
    console.log("Adding option")
    
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
    
    // Ensure we maintain at least 4 options for multiple choice
    const visibleOptions = this.optionsContainerTarget.querySelectorAll('.answer-option:not([style*="display: none"])')
    if (visibleOptions.length < 4) {
      this.addOption()
    }
  }
  
  setDifficultyToEasy() {
    const difficultySelect = document.getElementById('question_difficulty_level')
    if (difficultySelect) {
      // Find the 'easy' option
      for (let i = 0; i < difficultySelect.options.length; i++) {
        if (difficultySelect.options[i].value === 'easy') {
          difficultySelect.selectedIndex = i
          
          // Trigger change event to ensure any dependent logic runs
          difficultySelect.dispatchEvent(new Event('change', { bubbles: true }))
          
          console.log("Set difficulty level to easy")
          
          // Also set max_points if that field exists
          const maxPointsField = document.getElementById('question_max_points')
          if (maxPointsField) {
            maxPointsField.value = 1
          }
          
          break
        }
      }
      
      // Disable the difficulty select for multiple choice
      difficultySelect.disabled = true
    }
  }
}