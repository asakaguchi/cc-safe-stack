import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('*/health', () => {
    return HttpResponse.json({ status: 'ok', message: 'Backend is running' })
  }),

  http.get('*/api/hello/:name', ({ params }) => {
    const name = String(params.name)
    return HttpResponse.json({
      message: `Hello, ${name}!`,
      timestamp: '2024-01-01T00:00:00.000Z',
    })
  }),
]
