import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["levelContainer"]

  connect() {
    console.log('Level Controller go')
    this.buttons = this.element.querySelectorAll('[data-difficulty]')
  }

  filterLevels(event) {
    const difficulty = event.target.dataset.difficulty
    const levelCards = this.levelContainerTarget.querySelectorAll('.level-card')
    
    // Update active button
    this.buttons.forEach(btn => btn.classList.remove('active'))
    event.target.classList.add('active')
    
    // Filter level cards
    levelCards.forEach(card => {
      if (difficulty === 'all' || card.dataset.difficulty === difficulty) {
        card.style.display = 'block'
        card.classList.remove('fade-out')
        card.classList.add('fade-in')
      } else {
        card.classList.remove('fade-in')
        card.classList.add('fade-out')
        setTimeout(() => {
          if (card.classList.contains('fade-out')) {
            card.style.display = 'none'
          }
        }, 300)
      }
    })
  }
}