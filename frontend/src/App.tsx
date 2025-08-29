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
        setBackendMessage('Failed to connect to backend')
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
      setGreeting('Error fetching greeting')
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>Full-Stack Development Environment</h1>
        <p className="subtitle">Python Backend + TypeScript Frontend</p>
      </header>

      <main className="App-main">
        <section className="status-section">
          <h2>Backend Status</h2>
          <p className={backendMessage.includes('running') ? 'status-ok' : 'status-error'}>
            {backendMessage}
          </p>
        </section>

        <section className="interaction-section">
          <h2>API Interaction</h2>
          <div className="input-group">
            <input
              type="text"
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="Enter your name"
              onKeyPress={e => e.key === 'Enter' && handleGreeting()}
            />
            <button onClick={handleGreeting} disabled={!name.trim()}>
              Say Hello
            </button>
          </div>
          {greeting && (
            <div className="greeting-response">
              <p>{greeting}</p>
            </div>
          )}
        </section>

        <section className="tech-stack">
          <h2>Technology Stack</h2>
          <div className="tech-grid">
            <div className="tech-item">
              <h3>Backend</h3>
              <ul>
                <li>Python 3.12+</li>
                <li>FastAPI</li>
                <li>Uvicorn</li>
                <li>Pydantic</li>
              </ul>
            </div>
            <div className="tech-item">
              <h3>Frontend</h3>
              <ul>
                <li>TypeScript</li>
                <li>React 18</li>
                <li>Vite</li>
                <li>ESLint + Prettier</li>
              </ul>
            </div>
            <div className="tech-item">
              <h3>Development</h3>
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
