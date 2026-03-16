import { h, render } from 'vue'

let toastContainer = null

const createToastContainer = () => {
  if (!toastContainer) {
    toastContainer = document.createElement('div')
    toastContainer.className = 'toast-container'
    document.body.appendChild(toastContainer)
  }
  return toastContainer
}

const Toast = {
  show(message, options = {}) {
    const container = createToastContainer()
    const toastEl = document.createElement('div')
    toastEl.className = `toast toast-${options.type || 'info'}`
    toastEl.innerHTML = `
      <div class="toast-content">
        <span class="toast-message">${message}</span>
      </div>
    `

    container.appendChild(toastEl)

    // 触发动画
    requestAnimationFrame(() => {
      toastEl.classList.add('show')
    })

    // 自动关闭
    setTimeout(() => {
      toastEl.classList.remove('show')
      toastEl.addEventListener('transitionend', () => {
        toastEl.remove()
      })
    }, options.duration || 3000)
  },

  success(message, options = {}) {
    this.show(message, { ...options, type: 'success' })
  },

  error(message, options = {}) {
    this.show(message, { ...options, type: 'error' })
  },

  warning(message, options = {}) {
    this.show(message, { ...options, type: 'warning' })
  },

  info(message, options = {}) {
    this.show(message, { ...options, type: 'info' })
  }
}

export default Toast

// CSS 样式将在 main.js 中引入
