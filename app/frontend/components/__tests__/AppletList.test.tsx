import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import AppletList from '../AppletList'
import { client } from '../../graphql/client'
import { Applet } from '../../graphql/queries'

// Mock the GraphQL client
jest.mock('../../graphql/client')
const mockClient = client as jest.Mocked<typeof client>

describe('AppletList', () => {
  const mockApplets: Applet[] = [
    {
      id: '1',
      name: 'Weather Alert',
      description: 'Get notified about weather changes',
      enabled: true,
      triggerService: {
        id: 'trigger-1',
        name: 'Weather',
        slug: 'weather',
        iconUrl: 'https://example.com/weather.png',
        brandColor: '#FF0000',
      },
      actionService: {
        id: 'action-1',
        name: 'Email',
        slug: 'email',
        iconUrl: 'https://example.com/email.png',
        brandColor: '#00FF00',
      },
    },
    {
      id: '2',
      name: 'Smart Home Automation',
      description: 'Control your smart home',
      enabled: false,
      triggerService: {
        id: 'trigger-2',
        name: 'Motion Sensor',
        slug: 'motion-sensor',
        iconUrl: 'https://example.com/motion.png',
        brandColor: '#0000FF',
      },
      actionService: {
        id: 'action-2',
        name: 'Smart Lights',
        slug: 'smart-lights',
        iconUrl: 'https://example.com/lights.png',
        brandColor: '#FFFF00',
      },
    },
  ]

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render all applets with their names and services', () => {
    render(<AppletList initialApplets={mockApplets} />)

    // Check that both applets are rendered
    expect(screen.getByText('Weather Alert')).toBeInTheDocument()
    expect(screen.getByText('Smart Home Automation')).toBeInTheDocument()

    // Check service names are displayed (using text content matcher for whitespace flexibility)
    expect(screen.getByText((content, element) => {
      return element?.className === 'services' && content.includes('Weather') && content.includes('Email')
    })).toBeInTheDocument()

    expect(screen.getByText((content, element) => {
      return element?.className === 'services' && content.includes('Motion Sensor') && content.includes('Smart Lights')
    })).toBeInTheDocument()
  })

  it('should display correct toggle states for enabled and disabled applets', () => {
    render(<AppletList initialApplets={mockApplets} />)

    const toggleButtons = screen.getAllByRole('button')

    // First applet is enabled
    expect(toggleButtons[0]).toHaveClass('applet-toggle--enabled')
    expect(screen.getByText('ON')).toBeInTheDocument()

    // Second applet is disabled
    expect(toggleButtons[1]).toHaveClass('applet-toggle--disabled')
    expect(screen.getByText('OFF')).toBeInTheDocument()
  })

  it('should toggle applet state when clicking the toggle button', async () => {
    const user = userEvent.setup()

    const updatedApplet: Applet = {
      ...mockApplets[0],
      enabled: false,
    }

    mockClient.request.mockResolvedValueOnce({
      toggleApplet: updatedApplet,
    })

    render(<AppletList initialApplets={mockApplets} />)

    const toggleButtons = screen.getAllByRole('button')
    const firstToggle = toggleButtons[0]

    // Initially enabled
    expect(firstToggle).toHaveClass('applet-toggle--enabled')

    // Click to toggle
    await user.click(firstToggle)

    // Wait for toggle to complete
    await waitFor(() => {
      expect(firstToggle).toHaveClass('applet-toggle--disabled')
      expect(firstToggle).not.toHaveClass('applet-toggle--enabled')
    })

    // Verify GraphQL mutation was called
    expect(mockClient.request).toHaveBeenCalledWith(
      expect.anything(),
      { id: '1' }
    )
  })

  it('should display error message when toggle fails', async () => {
    const user = userEvent.setup()

    mockClient.request.mockRejectedValueOnce(
      new Error('Network error occurred')
    )

    render(<AppletList initialApplets={mockApplets} />)

    const toggleButtons = screen.getAllByRole('button')
    const firstToggle = toggleButtons[0]

    // Click to toggle
    await user.click(firstToggle)

    // Wait for error to appear
    await waitFor(() => {
      expect(screen.getByText('Network error occurred')).toBeInTheDocument()
    })

    // Error should have warning icon
    expect(screen.getByText('⚠️')).toBeInTheDocument()

    // Applet state should remain unchanged
    expect(firstToggle).toHaveClass('applet-toggle--enabled')
  })

  it('should prevent navigation when clicking toggle button', async () => {
    const user = userEvent.setup()

    mockClient.request.mockResolvedValueOnce({
      toggleApplet: { ...mockApplets[0], enabled: false },
    })

    render(<AppletList initialApplets={mockApplets} />)

    const appletLink = screen.getByRole('link', { name: /Weather Alert/ })
    const toggleButtons = screen.getAllByRole('button')

    // Click on toggle button (not the link)
    await user.click(toggleButtons[0])

    // Link should not be followed (href should still be present)
    expect(appletLink).toHaveAttribute('href', '/applets/1')

    // Wait for toggle to complete
    await waitFor(() => {
      expect(mockClient.request).toHaveBeenCalled()
    })
  })
})

