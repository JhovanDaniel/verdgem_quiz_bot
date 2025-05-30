import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "container"]
  
  connect() {
    console.log('Active storage is a go')
    this.addEventListeners()
    this.checkExistingImage()
  }

  disconnect() {
    this.removeEventListeners()
  }

  addEventListeners() {
    this.boundInitialize = this.directUploadInitializeListener.bind(this)
    this.boundStart = this.directUploadStartListener.bind(this)
    this.boundProgress = this.directUploadProgressListener.bind(this)
    this.boundError = this.directUploadErrorListener.bind(this)
    this.boundEnd = this.directUploadEndListener.bind(this)

    addEventListener('direct-upload:initialize', this.boundInitialize)
    addEventListener('direct-upload:start', this.boundStart)
    addEventListener('direct-upload:progress', this.boundProgress)
    addEventListener('direct-upload:error', this.boundError)
    addEventListener('direct-upload:end', this.boundEnd)
  }

  removeEventListeners() {
    removeEventListener('direct-upload:initialize', this.boundInitialize)
    removeEventListener('direct-upload:start', this.boundStart)
    removeEventListener('direct-upload:progress', this.boundProgress)
    removeEventListener('direct-upload:error', this.boundError)
    removeEventListener('direct-upload:end', this.boundEnd)
  }

  checkExistingImage() {
    // Check if there's an existing image to show
    const statusDiv = document.getElementById('file-status')
    if (statusDiv && statusDiv.textContent.includes('Current file:')) {
      // You could add logic here to show existing image if you have a URL
    }
  }

  previewImage(event) {
    const file = event.target.files[0]
    const previewContainer = document.getElementById('image-preview-container')
    const previewImg = document.getElementById('image-preview')
    
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        previewImg.src = e.target.result
        previewContainer.style.display = 'block'
        this.updateStatus('Image selected, uploading...')
      }
      
      reader.readAsDataURL(file)
    } else if (file) {
      this.updateStatus('Please select an image file')
      previewContainer.style.display = 'none'
    }
  }

  removePreview(event) {
    event.preventDefault()
    const fileInput = this.element.querySelector('input[type="file"]')
    const previewContainer = document.getElementById('image-preview-container')
    const previewImg = document.getElementById('image-preview')
    
    // Clear the file input
    fileInput.value = ''
    
    // Hide preview
    previewContainer.style.display = 'none'
    previewImg.src = ''
    
    // Update status
    this.updateStatus('No file chosen')
  }

  uploadComplete(event) {
    this.updateStatus('Image uploaded successfully!')
  }

  updateStatus(message) {
    const statusDiv = document.getElementById('file-status')
    if (statusDiv) {
      statusDiv.innerHTML = `<span class="text-success">${message}</span>`
    }
  }

  directUploadInitializeListener(event) {    
    const { target, detail } = event
    const { id, file } = detail
    target.insertAdjacentHTML("beforebegin", `
      <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
        <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
        <span class="direct-upload__filename"></span>
      </div>
    `)
    target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
  }

  directUploadStartListener(event) {
    const { id } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.remove("direct-upload--pending")
    this.updateStatus('Uploading...')
  }

  directUploadProgressListener(event) {
    const { id, progress } = event.detail
    const progressElement = document.getElementById(`direct-upload-progress-${id}`)
    progressElement.style.width = `${progress}%`
  }

  directUploadErrorListener(event) {
    event.preventDefault()
    const { id, error } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.add('direct-upload--error')
    element.setAttribute('title', error)
    this.updateStatus('Upload failed. Please try again.')
  }

  directUploadEndListener(event) {
    const { id } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.add("direct-upload--complete")
  }
}