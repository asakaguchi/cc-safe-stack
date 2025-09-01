import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('renders the main heading', () => {
    render(<App />)
    expect(
      screen.getByRole('heading', { name: /Full-Stack Development Environment/i })
    ).toBeInTheDocument()
  })

  it('shows backend status section', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: /Backend Status/i })).toBeInTheDocument()
  })
})
