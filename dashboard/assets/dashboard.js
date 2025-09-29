import { marked } from 'https://cdn.jsdelivr.net/npm/marked@12.0.2/+esm'
import DOMPurify from 'https://cdn.jsdelivr.net/npm/dompurify@3.1.6/+esm'

const notesKey = 'safe-stack-dashboard-notes'
const notesModeKey = 'safe-stack-dashboard-notes-mode'
const previewUrlKey = 'safe-stack-dashboard-preview-url'
const logsServiceKey = 'safe-stack-dashboard-logs-service'
const logsTailKey = 'safe-stack-dashboard-logs-tail'
const logsAutoKey = 'safe-stack-dashboard-logs-auto'

const defaultPreviewUrl = '/preview/'
const defaultLogTail = '200'
const logRefreshIntervalMs = 5000
const defaultNotesMode = 'edit'

const notesEl = document.getElementById('notes')
const notesHint = document.querySelector('.notes__hint')
const notesPreview = document.getElementById('notes-preview')
const notesModeButtons = document.querySelectorAll('[data-notes-mode]')
const clearBtn = document.getElementById('clear-notes')
const downloadBtn = document.getElementById('download-notes')
const modeSelect = document.getElementById('aux-mode')
const auxBlocks = document.querySelectorAll('.aux')

const previewForm = document.getElementById('preview-controls')
const previewInput = document.getElementById('preview-url')
const previewReloadBtn = document.getElementById('reload-preview')
const previewIframe = document.querySelector('[data-preview-frame]')
const previewLink = document.querySelector('[data-preview-link]')
const terminalIframe = document.querySelector('[data-terminal-frame]')

const logsContainer = document.querySelector('[data-mode="logs"]')
const logsOutput = document.getElementById('logs-output')
const logsStatus = document.getElementById('logs-status')
const logsServiceSelect = document.getElementById('logs-service')
const logsTailSelect = document.getElementById('logs-tail')
const logsAutoCheckbox = document.getElementById('logs-auto-refresh')
const logsRefreshButton = document.getElementById('logs-refresh')

const logLabels = new Map([
  ['frontend', 'フロントエンド'],
  ['backend', 'バックエンド'],
  ['streamlit', 'Streamlit'],
])

let logsAutoTimer = null
let logsAbortController = null
let isLogsActive = false
let currentNotesMode = defaultNotesMode

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

function normalizePreviewUrl(raw) {
  if (!raw) {
    return defaultPreviewUrl
  }
  const value = raw.trim()
  if (!value) {
    return defaultPreviewUrl
  }
  if (/^https?:\/\//i.test(value)) {
    return value
  }
  if (value.startsWith('/')) {
    return value
  }
  return `/${value}`
}

function getStoredValue(key) {
  try {
    return localStorage.getItem(key)
  } catch (error) {
    return null
  }
}

function setStoredValue(key, value) {
  try {
    localStorage.setItem(key, value)
  } catch (error) {
    console.warn('ローカルストレージの更新に失敗しました', key, error)
  }
}

marked.setOptions({
  gfm: true,
  breaks: true,
})

function renderNotesPreview(value) {
  if (!notesPreview) {
    return
  }
  const content = value ?? ''
  if (!content.trim()) {
    notesPreview.innerHTML = ''
    return
  }
  try {
    const html = DOMPurify.sanitize(marked.parse(content))
    notesPreview.innerHTML = html
  } catch (error) {
    console.warn('Markdownプレビューの生成に失敗しました', error)
    notesPreview.innerHTML = ''
  }
}

function updateNotesModeControls(mode) {
  notesModeButtons.forEach(button => {
    const isActive = button.dataset.notesMode === mode
    button.setAttribute('aria-pressed', String(isActive))
  })
}

function applyNotesMode(mode) {
  if (!notesEl) {
    return
  }
  const normalized = mode === 'preview' ? 'preview' : 'edit'
  currentNotesMode = normalized
  updateNotesModeControls(normalized)
  const isPreview = normalized === 'preview'

  if (isPreview) {
    notesEl.setAttribute('hidden', 'true')
    notesEl.setAttribute('aria-hidden', 'true')
  } else {
    notesEl.removeAttribute('hidden')
    notesEl.setAttribute('aria-hidden', 'false')
  }

  if (notesHint) {
    if (isPreview) {
      notesHint.setAttribute('hidden', 'true')
      notesHint.setAttribute('aria-hidden', 'true')
    } else {
      notesHint.removeAttribute('hidden')
      notesHint.setAttribute('aria-hidden', 'false')
    }
  }

  if (notesPreview) {
    if (isPreview) {
      notesPreview.removeAttribute('hidden')
      notesPreview.setAttribute('aria-hidden', 'false')
      renderNotesPreview(notesEl.value ?? '')
    } else {
      notesPreview.setAttribute('hidden', 'true')
      notesPreview.setAttribute('aria-hidden', 'true')
    }
  }

  if (!isPreview) {
    try {
      notesEl.focus({ preventScroll: true })
    } catch (error) {
      // フォーカス取得に失敗しても無視
    }
  }
}

function setNotesMode(mode, { save = true } = {}) {
  applyNotesMode(mode)
  if (save) {
    setStoredValue(notesModeKey, currentNotesMode)
  }
}

function initNotesMode() {
  const storedMode = getStoredValue(notesModeKey)
  if (storedMode === 'preview' || storedMode === 'edit') {
    applyNotesMode(storedMode)
  } else {
    applyNotesMode(defaultNotesMode)
  }
}

function applyPreviewUrl(inputValue, { save = true, updateIframe = true } = {}) {
  const normalized = normalizePreviewUrl(inputValue)
  if (previewInput) {
    previewInput.value = normalized
  }
  if (previewLink) {
    previewLink.href = normalized
  }
  if (previewIframe && updateIframe) {
    previewIframe.src = normalized
  }
  if (save) {
    setStoredValue(previewUrlKey, normalized)
  }
  return normalized
}

function reloadPreview() {
  if (!previewIframe) {
    return
  }
  try {
    const frameWindow = previewIframe.contentWindow
    if (frameWindow) {
      frameWindow.location.reload()
      return
    }
  } catch (error) {
    // クロスオリジンの場合はフォールバックで src を再設定
  }
  const currentSrc = previewIframe.src
  previewIframe.src = currentSrc
}

function initPreviewControls() {
  const stored = getStoredValue(previewUrlKey)
  const initialUrl = stored || defaultPreviewUrl
  applyPreviewUrl(initialUrl, { save: false })

  if (previewForm && previewInput) {
    previewForm.addEventListener('submit', event => {
      event.preventDefault()
      const previousSrc = previewIframe ? previewIframe.getAttribute('src') : null
      const normalized = applyPreviewUrl(previewInput.value)
      if (previousSrc && previewIframe && normalizePreviewUrl(previousSrc) === normalized) {
        reloadPreview()
      }
    })
  }

  if (previewReloadBtn) {
    previewReloadBtn.addEventListener('click', () => {
      reloadPreview()
    })
  }
}

function setupTerminalClipboard() {
  if (!terminalIframe) {
    return
  }

  const installHandlers = () => {
    const frameWindow = terminalIframe.contentWindow
    if (!frameWindow) {
      return
    }
    if (frameWindow.__safeStackClipboardReady) {
      return
    }
    const frameDocument = frameWindow.document
    if (!frameDocument) {
      return
    }

    frameWindow.__safeStackClipboardReady = true

    const clipboardApi = frameWindow.navigator?.clipboard ?? navigator.clipboard

    const getTerm = () => {
      try {
        const candidate = frameWindow.term
        if (candidate && typeof candidate === 'object') {
          return candidate
        }
      } catch (error) {
        // ignore access errors
      }
      return null
    }

    const focusTerminal = term => {
      try {
        if (term && typeof term.focus === 'function') {
          term.focus()
        }
      } catch (error) {
        // ignore focus errors
      }
    }

    const getSelectionText = () => {
      try {
        const term = getTerm()
        if (term && typeof term.getSelection === 'function') {
          const selection = term.getSelection()
          if (selection) {
            return selection
          }
        }
      } catch (error) {
        // ignore selection errors
      }
      try {
        return frameWindow.getSelection()?.toString() || ''
      } catch (error) {
        return ''
      }
    }

    const pasteText = text => {
      if (!text) {
        return
      }
      const term = getTerm()
      if (term && typeof term.paste === 'function') {
        term.paste(text)
        focusTerminal(term)
      } else if (term && typeof term.write === 'function') {
        term.write(text)
        focusTerminal(term)
      }
    }

    const handleKeydown = event => {
      if (event.defaultPrevented) {
        return
      }
      const isModifier = event.ctrlKey || event.metaKey
      if (!isModifier || event.altKey) {
        return
      }

      const key = (event.key || '').toLowerCase()
      if (key === 'c' && !event.shiftKey) {
        const selectionText = getSelectionText()
        if (!selectionText) {
          return
        }

        event.preventDefault()

        const term = getTerm()

        const fallbackExecCommand = () => {
          try {
            return frameDocument.execCommand('copy')
          } catch (error) {
            return false
          }
        }

        const handleFailure = err => {
          console.warn('ターミナルのコピーに失敗しました', err)
          fallbackExecCommand()
        }

        if (clipboardApi && typeof clipboardApi.writeText === 'function') {
          clipboardApi.writeText(selectionText).catch(handleFailure)
        } else {
          fallbackExecCommand()
        }

        focusTerminal(term)
        return
      }

      if (key === 'v' && !event.shiftKey) {
        if (!clipboardApi || typeof clipboardApi.readText !== 'function') {
          return
        }

        event.preventDefault()
        clipboardApi
          .readText()
          .then(text => pasteText(text))
          .catch(err => {
            console.warn('ターミナルへの貼り付けに失敗しました', err)
          })
      }
    }

    const handlePasteEvent = event => {
      if (!event.clipboardData) {
        return
      }
      const text = event.clipboardData.getData('text')
      if (!text) {
        return
      }
      event.preventDefault()
      pasteText(text)
    }

    const handleCopyEvent = event => {
      const selectionText = getSelectionText()
      if (!selectionText) {
        return
      }
      if (event.clipboardData) {
        event.clipboardData.setData('text/plain', selectionText)
        event.preventDefault()
      }
      if (clipboardApi && typeof clipboardApi.writeText === 'function') {
        clipboardApi.writeText(selectionText).catch(err => {
          console.warn('ターミナルのコピーに失敗しました', err)
        })
      }
    }

    frameDocument.addEventListener('keydown', handleKeydown, true)
    frameDocument.addEventListener('paste', handlePasteEvent, true)
    frameDocument.addEventListener('copy', handleCopyEvent, true)
  }

  const scheduleInstall = () => {
    window.setTimeout(() => {
      try {
        installHandlers()
      } catch (error) {
        console.warn('ターミナルのクリップボード初期化に失敗しました', error)
      }
    }, 0)
  }

  terminalIframe.addEventListener('load', scheduleInstall)

  if (terminalIframe.contentDocument && terminalIframe.contentDocument.readyState === 'complete') {
    scheduleInstall()
  }
}

function updateAuxMode(mode) {
  auxBlocks.forEach(element => {
    const blockMode = element.dataset.mode
    if (!blockMode) return
    const shouldShow = blockMode === mode
    if (shouldShow) {
      element.removeAttribute('hidden')
      if (blockMode === 'notes') {
        applyNotesMode(currentNotesMode)
      }
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

  const isLogs = mode === 'logs'
  handleLogsVisibility(isLogs)
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

function updateLogsStatus(message, isError = false) {
  if (!logsStatus) {
    return
  }
  logsStatus.textContent = message
  logsStatus.classList.toggle('is-error', Boolean(isError))
}

function renderLogsContent(text) {
  if (!logsOutput) {
    return
  }
  const trimmed = text.trim()
  if (!trimmed) {
    logsOutput.textContent = 'ログ出力はまだありません。'
    logsOutput.classList.add('is-empty')
  } else {
    logsOutput.textContent = text
    logsOutput.classList.remove('is-empty')
  }
}

function formatTimestamp(date) {
  try {
    return date.toLocaleString('ja-JP', { hour12: false })
  } catch (error) {
    return date.toISOString()
  }
}

async function refreshLogs({ showStatus = true } = {}) {
  if (!logsServiceSelect || !logsOutput) {
    return
  }
  const service = logsServiceSelect.value
  if (!service) {
    renderLogsContent('')
    updateLogsStatus('ログ種別が選択されていません', true)
    return
  }
  const tail = logsTailSelect ? logsTailSelect.value : defaultLogTail
  if (logsAbortController) {
    logsAbortController.abort()
  }
  const controller = new AbortController()
  logsAbortController = controller

  if (showStatus) {
    updateLogsStatus('取得中…')
  }

  try {
    const response = await fetch(
      `/api/logs/${encodeURIComponent(service)}?tail=${encodeURIComponent(tail)}`,
      {
        cache: 'no-store',
        signal: controller.signal,
      }
    )
    if (!response.ok) {
      throw new Error(`Unexpected status: ${response.status}`)
    }
    const text = await response.text()
    renderLogsContent(text)
    updateLogsStatus(`最終更新: ${formatTimestamp(new Date())}`)
  } catch (error) {
    if (error.name === 'AbortError') {
      return
    }
    console.warn('ログの取得に失敗しました', error)
    renderLogsContent('')
    updateLogsStatus('ログの取得に失敗しました', true)
  } finally {
    if (logsAbortController === controller) {
      logsAbortController = null
    }
  }
}

function startLogsAutoRefresh() {
  if (!isLogsActive) {
    return
  }
  stopLogsAutoRefresh()
  logsAutoTimer = window.setInterval(() => {
    refreshLogs({ showStatus: false })
  }, logRefreshIntervalMs)
}

function stopLogsAutoRefresh() {
  if (logsAutoTimer) {
    clearInterval(logsAutoTimer)
    logsAutoTimer = null
  }
}

function handleLogsVisibility(isVisible) {
  isLogsActive = isVisible
  if (isVisible) {
    refreshLogs()
    if (logsAutoCheckbox && logsAutoCheckbox.checked) {
      startLogsAutoRefresh()
    }
  } else {
    stopLogsAutoRefresh()
  }
}

function populateLogServiceOptions(services) {
  if (!logsServiceSelect || !Array.isArray(services) || services.length === 0) {
    return
  }
  const currentValue = logsServiceSelect.value
  const storedValue = getStoredValue(logsServiceKey)

  logsServiceSelect.innerHTML = ''
  services.forEach(service => {
    const option = document.createElement('option')
    option.value = service
    option.textContent = logLabels.get(service) ?? service
    logsServiceSelect.appendChild(option)
  })

  const preferred = services.includes(storedValue)
    ? storedValue
    : services.includes(currentValue)
      ? currentValue
      : services[0]
  if (preferred) {
    logsServiceSelect.value = preferred
    setStoredValue(logsServiceKey, preferred)
  }
}

async function fetchAvailableLogs() {
  if (!logsServiceSelect) {
    return
  }
  try {
    const response = await fetch('/api/logs', { cache: 'no-store' })
    if (!response.ok) {
      return
    }
    const data = await response.json()
    if (Array.isArray(data) && data.length > 0) {
      populateLogServiceOptions(data)
    }
  } catch (error) {
    console.warn('ログ一覧の取得に失敗しました', error)
  }
}

function initLogsControls() {
  if (!logsContainer) {
    return
  }

  const storedTail = getStoredValue(logsTailKey)
  if (logsTailSelect && storedTail) {
    const optionExists = Array.from(logsTailSelect.options).some(
      option => option.value === storedTail
    )
    if (optionExists) {
      logsTailSelect.value = storedTail
    }
  }

  const storedAuto = getStoredValue(logsAutoKey)
  if (logsAutoCheckbox) {
    logsAutoCheckbox.checked = storedAuto === 'true'
  }

  fetchAvailableLogs().then(() => {
    const storedService = getStoredValue(logsServiceKey)
    if (logsServiceSelect && storedService) {
      const optionExists = Array.from(logsServiceSelect.options).some(
        option => option.value === storedService
      )
      if (optionExists) {
        logsServiceSelect.value = storedService
      }
    }
  })

  if (logsServiceSelect) {
    logsServiceSelect.addEventListener('change', event => {
      const value = event.target.value
      setStoredValue(logsServiceKey, value)
      if (isLogsActive) {
        refreshLogs()
      }
    })
  }

  if (logsTailSelect) {
    logsTailSelect.addEventListener('change', event => {
      const value = event.target.value
      setStoredValue(logsTailKey, value)
      if (isLogsActive) {
        refreshLogs()
      }
    })
  }

  if (logsRefreshButton) {
    logsRefreshButton.addEventListener('click', () => {
      refreshLogs()
    })
  }

  if (logsAutoCheckbox) {
    logsAutoCheckbox.addEventListener('change', event => {
      const checked = Boolean(event.target.checked)
      setStoredValue(logsAutoKey, checked ? 'true' : 'false')
      if (checked) {
        if (isLogsActive) {
          refreshLogs()
          startLogsAutoRefresh()
        }
      } else {
        stopLogsAutoRefresh()
      }
    })
  }

  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      stopLogsAutoRefresh()
    } else if (isLogsActive && logsAutoCheckbox && logsAutoCheckbox.checked) {
      startLogsAutoRefresh()
      refreshLogs({ showStatus: false })
    }
  })
}

if (notesEl) {
  loadNotes()
  renderNotesPreview(notesEl.value ?? '')
  let saveTimer
  notesEl.addEventListener('input', event => {
    const { value } = event.target
    clearTimeout(saveTimer)
    renderNotesPreview(value)
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
    renderNotesPreview('')
  })
}

if (downloadBtn && notesEl) {
  downloadBtn.addEventListener('click', () => {
    downloadNotes(notesEl.value ?? '')
  })
}

initPreviewControls()
initLogsControls()

if (modeSelect) {
  modeSelect.addEventListener('change', event => {
    updateAuxMode(event.target.value)
  })
  updateAuxMode(modeSelect.value ?? 'notes')
}

if (notesModeButtons.length > 0) {
  notesModeButtons.forEach(button => {
    button.addEventListener('click', () => {
      const mode = button.dataset.notesMode
      if (mode) {
        setNotesMode(mode)
      }
    })
  })
}

initNotesMode()
setupVscodeIframe()
setupTerminalClipboard()
setupFullscreenShortcut()
