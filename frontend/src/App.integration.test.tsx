import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import App from './App'

describe('App (integration with MSW)', () => {
  it('shows backend health message from /api/health', async () => {
    render(<App />)
    expect(await screen.findByText(/Backend is running/i)).toBeInTheDocument()
  })

  it('greets user via /api/hello/:name', async () => {
    render(<App />)
    const input = screen.getByPlaceholderText(/お名前を入力/i)
    await userEvent.type(input, 'Alice')
    await userEvent.click(screen.getByRole('button', { name: /挨拶する/i }))

    expect(await screen.findByText(/Hello, Alice!/i)).toBeInTheDocument()
  })
})
