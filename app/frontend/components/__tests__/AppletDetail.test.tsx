import React from 'react'
import { render, screen } from '@testing-library/react'
import AppletDetail from '../AppletDetail'
import { useApplet } from '../../hooks/useApplet'
import { Applet } from '../../graphql/queries'

// Mock the custom hook
jest.mock('../../hooks/useApplet')
const mockUseApplet = useApplet as jest.MockedFunction<typeof useApplet>

// Mock ActivityFeed component
jest.mock('../ActivityFeed', () => {
  return function MockActivityFeed({ appletId }: { appletId: string }) {
    return <div data-testid="activity-feed">Activity Feed for {appletId}</div>
  }
})

describe('AppletDetail', () => {
  const mockApplet: Applet = {
    id: '1',
    name: 'Test Applet',
    description: 'This is a test applet description',
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

  describe('Loading state', () => {
    it('should display loading message when loading is true', () => {
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: true,
        error: null,
        isNotFound: false,
      })

      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Loading applet...')).toBeInTheDocument()
    })

    it('should have loading class when loading', () => {
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: true,
        error: null,
        isNotFound: false,
      })

      const { container } = render(<AppletDetail appletId="1" />)

      expect(container.querySelector('.applet-detail--loading')).toBeInTheDocument()
    })
  })

  describe('Not found state', () => {
    it('should display not found message when applet is not found', () => {
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: false,
        error: new Error('Applet not found'),
        isNotFound: true,
      })

      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Applet Not Found')).toBeInTheDocument()
      expect(
        screen.getByText("The applet you're looking for doesn't exist or may have been removed.")
      ).toBeInTheDocument()
    })

    it('should display back to home link when not found', () => {
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: false,
        error: new Error('Applet not found'),
        isNotFound: true,
      })

      render(<AppletDetail appletId="1" />)

      const backLink = screen.getByRole('link', { name: /back to home/i })
      expect(backLink).toBeInTheDocument()
      expect(backLink).toHaveAttribute('href', '/')
    })
  })

  describe('Error state', () => {
    it('should display error message when there is a generic error', () => {
      const errorMessage = 'Network error occurred'
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: false,
        error: new Error(errorMessage),
        isNotFound: false,
      })

      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Error Loading Applet')).toBeInTheDocument()
      expect(screen.getByText(errorMessage)).toBeInTheDocument()
    })

    it('should display retry button on error', () => {
      mockUseApplet.mockReturnValue({
        applet: null,
        loading: false,
        error: new Error('Error'),
        isNotFound: false,
      })

      render(<AppletDetail appletId="1" />)

      expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument()
    })
  })

  describe('Success state', () => {
    beforeEach(() => {
      mockUseApplet.mockReturnValue({
        applet: mockApplet,
        loading: false,
        error: null,
        isNotFound: false,
      })
    })

    it('should display applet name', () => {
      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Test Applet')).toBeInTheDocument()
    })

    it('should display applet description', () => {
      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('This is a test applet description')).toBeInTheDocument()
    })

    it('should display trigger service name', () => {
      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Trigger Service')).toBeInTheDocument()
      expect(screen.getByText('If')).toBeInTheDocument()
    })

    it('should display action service name', () => {
      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Action Service')).toBeInTheDocument()
      expect(screen.getByText('Then')).toBeInTheDocument()
    })

    it('should display enabled status when applet is enabled', () => {
      render(<AppletDetail appletId="1" />)

      const statusElement = screen.getByText('Enabled')
      expect(statusElement).toBeInTheDocument()
      expect(statusElement).toHaveClass('applet-status--enabled')
    })

    it('should display disabled status when applet is disabled', () => {
      mockUseApplet.mockReturnValue({
        applet: { ...mockApplet, enabled: false },
        loading: false,
        error: null,
        isNotFound: false,
      })

      render(<AppletDetail appletId="1" />)

      const statusElement = screen.getByText('Disabled')
      expect(statusElement).toBeInTheDocument()
      expect(statusElement).toHaveClass('applet-status--disabled')
    })

    it('should display back to applets link', () => {
      render(<AppletDetail appletId="1" />)

      const backLink = screen.getByRole('link', { name: /back to applets/i })
      expect(backLink).toBeInTheDocument()
      expect(backLink).toHaveAttribute('href', '/')
    })

    it('should render ActivityFeed component with correct appletId', () => {
      render(<AppletDetail appletId="1" />)

      const activityFeed = screen.getByTestId('activity-feed')
      expect(activityFeed).toBeInTheDocument()
      expect(activityFeed).toHaveTextContent('Activity Feed for 1')
    })

    it('should display service arrow between trigger and action', () => {
      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('→')).toBeInTheDocument()
    })
  })

  describe('Applet without description', () => {
    it('should handle applet with null description', () => {
      const appletWithoutDescription = { ...mockApplet, description: null }
      mockUseApplet.mockReturnValue({
        applet: appletWithoutDescription,
        loading: false,
        error: null,
        isNotFound: false,
      })

      render(<AppletDetail appletId="1" />)

      expect(screen.getByText('Test Applet')).toBeInTheDocument()
      // Description element should still be in DOM but empty
      const descriptionElement = screen
        .getByText('Test Applet')
        .parentElement?.querySelector('.applet-description')
      expect(descriptionElement).toBeInTheDocument()
    })
  })
})

