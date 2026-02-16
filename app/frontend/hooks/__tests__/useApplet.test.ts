import { renderHook, waitFor } from '@testing-library/react'
import { useApplet } from '../useApplet'
import { fetchApplet, AppletNotFoundError } from '../../graphql/client'
import { Applet } from '../../graphql/queries'

// Mock the GraphQL client
jest.mock('../../graphql/client', () => ({
  fetchApplet: jest.fn(),
  AppletNotFoundError: class AppletNotFoundError extends Error {
    constructor(message = 'Applet not found') {
      super(message)
      this.name = 'AppletNotFoundError'
    }
  },
}))

const mockFetchApplet = fetchApplet as jest.MockedFunction<typeof fetchApplet>

describe('useApplet', () => {
  const mockApplet: Applet = {
    id: '1',
    name: 'Test Applet',
    description: 'Test description',
    enabled: true,
    triggerService: {
      id: 'trigger-1',
      name: 'Trigger Service',
      slug: 'trigger-service',
      iconUrl: 'https://example.com/trigger.png',
      brandColor: '#FF0000',
    },
    actionService: {
      id: 'action-1',
      name: 'Action Service',
      slug: 'action-service',
      iconUrl: 'https://example.com/action.png',
      brandColor: '#00FF00',
    },
  }

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should start with loading state', () => {
    mockFetchApplet.mockImplementation(
      () => new Promise(() => {}) // Never resolves
    )

    const { result } = renderHook(() => useApplet('1'))

    expect(result.current.loading).toBe(true)
    expect(result.current.applet).toBe(null)
    expect(result.current.error).toBe(null)
    expect(result.current.isNotFound).toBe(false)
  })

  it('should fetch and return applet data successfully', async () => {
    mockFetchApplet.mockResolvedValue({ applet: mockApplet })

    const { result } = renderHook(() => useApplet('1'))

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toEqual(mockApplet)
    expect(result.current.error).toBe(null)
    expect(result.current.isNotFound).toBe(false)
    expect(mockFetchApplet).toHaveBeenCalledTimes(1)
    expect(mockFetchApplet).toHaveBeenCalledWith(expect.any(String), { id: '1' })
  })

  it('should handle AppletNotFoundError', async () => {
    const notFoundError = new AppletNotFoundError('Applet not found')
    mockFetchApplet.mockRejectedValue(notFoundError)

    const { result } = renderHook(() => useApplet('1'))

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toBe(null)
    expect(result.current.error).toBe(notFoundError)
    expect(result.current.isNotFound).toBe(true)
  })

  it('should handle generic errors', async () => {
    const genericError = new Error('Network error')
    mockFetchApplet.mockRejectedValue(genericError)

    const { result } = renderHook(() => useApplet('1'))

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toBe(null)
    expect(result.current.error).toBe(genericError)
    expect(result.current.isNotFound).toBe(false)
  })

  it('should handle non-Error exceptions', async () => {
    mockFetchApplet.mockRejectedValue('String error')

    const { result } = renderHook(() => useApplet('1'))

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toBe(null)
    expect(result.current.error).toBeInstanceOf(Error)
    expect(result.current.error?.message).toBe('Failed to fetch applet')
    expect(result.current.isNotFound).toBe(false)
  })

  it('should refetch when appletId changes', async () => {
    const applet2 = { ...mockApplet, id: '2', name: 'Test Applet 2' }
    mockFetchApplet
      .mockResolvedValueOnce({ applet: mockApplet })
      .mockResolvedValueOnce({ applet: applet2 })

    const { result, rerender } = renderHook(({ id }) => useApplet(id), {
      initialProps: { id: '1' },
    })

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toEqual(mockApplet)
    expect(mockFetchApplet).toHaveBeenCalledWith(expect.any(String), { id: '1' })

    // Change the appletId
    rerender({ id: '2' })

    await waitFor(() => {
      expect(result.current.applet).toEqual(applet2)
    })

    expect(mockFetchApplet).toHaveBeenCalledTimes(2)
    expect(mockFetchApplet).toHaveBeenLastCalledWith(expect.any(String), { id: '2' })
  })

  it('should reset error states when refetching', async () => {
    const notFoundError = new AppletNotFoundError('Applet not found')
    mockFetchApplet
      .mockRejectedValueOnce(notFoundError)
      .mockResolvedValueOnce({ applet: mockApplet })

    const { result, rerender } = renderHook(({ id }) => useApplet(id), {
      initialProps: { id: '1' },
    })

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.isNotFound).toBe(true)
    expect(result.current.error).toBe(notFoundError)

    // Trigger refetch by changing appletId
    rerender({ id: '2' })

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.applet).toEqual(mockApplet)
    expect(result.current.error).toBe(null)
    expect(result.current.isNotFound).toBe(false)
  })
})

