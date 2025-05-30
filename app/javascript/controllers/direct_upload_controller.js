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
    const fileInput = this.element.querySelector('input[type="file"]')
    const existingImageUrl = fileInput.dataset.existingImage
    const existingFilename = fileInput.dataset.existingFilename
    
    if (existingImageUrl && existingImageUrl.trim() !== '') {
      this.showPreview(existingImageUrl, existingFilename)
    }
  }

  showPreview(imageSrc, filename = null) {
    const previewContainer = document.getElementById('image-preview-container')
    const previewImg = document.getElementById('image-preview')
    
    previewImg.src = imageSrc
    previewContainer.style.display = 'block'
    
    if (filename) {
      this.updateStatus(`Current file: ${filename}`)
    }
  }

  previewImage(event) {
    const file = event.target.files[0]
    
    // Reset the remove flag when a new file is selected
    this.setRemoveFlag(false)
    
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        this.showPreview(e.target.result)
        this.updateStatus('New image selected, uploading...')
      }
      
      reader.readAsDataURL(file)
    } else if (file) {
      this.updateStatus('Please select an image file')
      this.hidePreview()
    }
  }

  hidePreview() {
    const previewContainer = document.getElementById('image-preview-container')
    const previewImg = document.getElementById('image-preview')
    
    previewContainer.style.display = 'none'
    previewImg.src = ''
  }

  removeImage(event) {
    event.preventDefault()
    
    const fileInput = this.element.querySelector('input[type="file"]')
    
    // Clear the file input
    fileInput.value = ''
    
    // Set the remove flag
    this.setRemoveFlag(true)
    
    // Hide preview
    this.hidePreview()
    
    // Update status
    this.updateStatus('Image will be removed when you save')
  }

  setRemoveFlag(shouldRemove) {
    const removeInput = this.element.querySelector('input[name*="remove_question_image"]')
    if (removeInput) {
      removeInput.value = shouldRemove ? "1" : "0"
    }
  }

  uploadComplete(event) {
    this.updateStatus('Image uploaded successfully!')
    // Reset remove flag since we have a new image
    this.setRemoveFlag(false)
  }

  updateStatus(message) {
    const statusDiv = document.getElementById('file-status')
    if (statusDiv) {
      statusDiv.innerHTML = `<span class="text-info">${message}</span>`
    }
  }

  // ... rest of the direct upload event listeners remain the same ...
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