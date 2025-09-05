import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('renders the main heading', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: /フルスタック開発環境/i })).toBeInTheDocument()
  })

  it('shows backend status section', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: /バックエンドステータス/i })).toBeInTheDocument()
  })
})
