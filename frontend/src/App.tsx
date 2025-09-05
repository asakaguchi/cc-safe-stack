import { useState, useEffect } from 'react'
import './App.css'

interface ApiResponse {
  message: string
  timestamp: string
}

function App() {
  const [backendMessage, setBackendMessage] = useState<string>('Loading...')
  const [name, setName] = useState<string>('')
  const [greeting, setGreeting] = useState<string>('')

  // Fetch message from backend on component mount
  useEffect(() => {
    fetch('/api/health')
      .then(response => response.json())
      .then((data: { message: string }) => {
        setBackendMessage(data.message)
      })
      .catch(error => {
        console.error('Error fetching from backend:', error)
        setBackendMessage('バックエンドへの接続に失敗しました')
      })
  }, [])

  const handleGreeting = async () => {
    if (!name.trim()) return

    try {
      const response = await fetch(`/api/hello/${encodeURIComponent(name)}`)
      const data: ApiResponse = await response.json()
      setGreeting(data.message)
    } catch (error) {
      console.error('Error fetching greeting:', error)
      setGreeting('挨拶の取得に失敗しました')
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>フルスタック開発環境</h1>
        <p className="subtitle">Python バックエンド + TypeScript フロントエンド</p>
      </header>

      <main className="App-main">
        <section className="status-section">
          <h2>バックエンドステータス</h2>
          <p className={backendMessage.includes('running') ? 'status-ok' : 'status-error'}>
            {backendMessage}
          </p>
        </section>

        <section className="interaction-section">
          <h2>API操作</h2>
          <div className="input-group">
            <input
              type="text"
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="お名前を入力"
              onKeyPress={e => e.key === 'Enter' && handleGreeting()}
            />
            <button onClick={handleGreeting} disabled={!name.trim()}>
              挨拶する
            </button>
          </div>
          {greeting && (
            <div className="greeting-response">
              <p>{greeting}</p>
            </div>
          )}
        </section>

        <section className="tech-stack">
          <h2>技術スタック</h2>
          <div className="tech-grid">
            <div className="tech-item">
              <h3>バックエンド</h3>
              <ul>
                <li>Python 3.12+</li>
                <li>FastAPI</li>
                <li>Uvicorn</li>
                <li>Pydantic</li>
              </ul>
            </div>
            <div className="tech-item">
              <h3>フロントエンド</h3>
              <ul>
                <li>TypeScript</li>
                <li>React 18</li>
                <li>Vite</li>
                <li>ESLint + Prettier</li>
              </ul>
            </div>
            <div className="tech-item">
              <h3>開発環境</h3>
              <ul>
                <li>VS Code DevContainers</li>
                <li>Claude Code CLI</li>
                <li>Git + GitHub CLI</li>
                <li>Multiple Package Managers</li>
              </ul>
            </div>
          </div>
        </section>
      </main>
    </div>
  )
}

export default App
