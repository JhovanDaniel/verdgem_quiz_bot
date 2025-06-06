import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

// Connects to data-controller="slim-select"
export default class extends Controller {
  connect() {
    console.log('slim-select connected yaa')
     const slimSelect = new SlimSelect({
      select: this.element,
      placeholder: 'Placeholder Text Here'
    });
    
    // Find the input element within the div with class "ss-search"
    var inputElement = document.querySelector('.ss-search input[type="search"]');
    
    // Update the placeholder text
    if (inputElement) {
      inputElement.placeholder = "Type to search for categories";
    }
  }
}
