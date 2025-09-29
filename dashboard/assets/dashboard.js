const notesKey = 'safe-stack-dashboard-notes'
const notesEl = document.getElementById('notes')
const clearBtn = document.getElementById('clear-notes')
const downloadBtn = document.getElementById('download-notes')
const modeSelect = document.getElementById('aux-mode')
const auxBlocks = document.querySelectorAll('.aux')

function setupVscodeIframe() {
  const vscodeFrame = document.querySelector('[data-service="vscode"]')
  if (!vscodeFrame) {
    return
  }

  const params = new URLSearchParams(window.location.search)
  const token = params.get('vscodeToken') ?? 'changeme'
  const basePath = vscodeFrame.dataset.basePath || '/vscode/'
  const suffix = token ? `?tkn=${encodeURIComponent(token)}` : ''
  vscodeFrame.src = `${basePath}${suffix}`

  const vscodeLink = document.querySelector('[data-service-link="vscode"]')
  if (vscodeLink) {
    vscodeLink.href = `${basePath}${suffix}`
  }
}

function saveNotes(value) {
  try {
    localStorage.setItem(notesKey, value)
  } catch (error) {
    console.warn('メモの保存に失敗しました', error)
  }
}

function loadNotes() {
  try {
    const stored = localStorage.getItem(notesKey)
    if (stored && notesEl) {
      notesEl.value = stored
    }
  } catch (error) {
    console.warn('メモの読み込みに失敗しました', error)
  }
}

function updateAuxMode(mode) {
  auxBlocks.forEach(element => {
    const blockMode = element.dataset.mode
    if (!blockMode) return
    const shouldShow = blockMode === mode
    if (shouldShow) {
      element.removeAttribute('hidden')
    } else {
      element.setAttribute('hidden', 'true')
    }
  })

  const isNotes = mode === 'notes'
  ;[clearBtn, downloadBtn].forEach(btn => {
    if (!btn) return
    btn.disabled = !isNotes
    btn.setAttribute('aria-disabled', String(!isNotes))
  })
}

function downloadNotes(value) {
  const blob = new Blob([value], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
  anchor.href = url
  anchor.download = `dashboard-notes-${timestamp}.txt`
  document.body.appendChild(anchor)
  anchor.click()
  document.body.removeChild(anchor)
  URL.revokeObjectURL(url)
}

function setupFullscreenShortcut() {
  document.addEventListener('keydown', event => {
    const isShortcut = event.code === 'KeyD' && event.ctrlKey && event.shiftKey && event.altKey
    if (!isShortcut) {
      return
    }
    event.preventDefault()
    const isFullscreen = document.fullscreenElement != null
    if (isFullscreen) {
      document.exitFullscreen().catch(() => {})
    } else {
      document.documentElement.requestFullscreen().catch(() => {})
    }
  })
}

if (notesEl) {
  loadNotes()
  let saveTimer
  notesEl.addEventListener('input', event => {
    const { value } = event.target
    clearTimeout(saveTimer)
    saveTimer = setTimeout(() => saveNotes(value), 300)
  })
}

if (clearBtn && notesEl) {
  clearBtn.addEventListener('click', () => {
    if (!window.confirm('メモをすべて削除しますか？')) {
      return
    }
    notesEl.value = ''
    saveNotes('')
  })
}

if (downloadBtn && notesEl) {
  downloadBtn.addEventListener('click', () => {
    downloadNotes(notesEl.value ?? '')
  })
}

if (modeSelect) {
  modeSelect.addEventListener('change', event => {
    updateAuxMode(event.target.value)
  })
  updateAuxMode(modeSelect.value ?? 'notes')
}

setupFullscreenShortcut()
setupVscodeIframe()
