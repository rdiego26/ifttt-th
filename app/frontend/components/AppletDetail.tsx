import React, { useEffect, useState } from "react"
import { fetchApplet, AppletNotFoundError } from "../graphql/client"
import { GET_APPLET, GetAppletResponse, Applet } from "../graphql/queries"
import ActivityFeed from "@/components/ActivityFeed.tsx";

interface AppletDetailProps {
  appletId: string
}

/**
 * AppletDetail Component
 *
 * This is a placeholder component for candidates to build out.
 *
 * Requirements:
 * 1. Display the applet name and description
 * 2. Show the trigger and action services with their icons and brand colors
 * 3. Show the applet's enabled/disabled status
 * 4. Handle loading and error states gracefully
 * 5. Style the component to be visually appealing
 *
 * The GraphQL query is already set up for you in ../graphql/queries.ts
 */
const AppletDetail: React.FC<AppletDetailProps> = ({ appletId }) => {
  const [applet, setApplet] = useState<Applet | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [isNotFound, setIsNotFound] = useState(false)

  useEffect(() => {
    const fetchAppletData = async () => {
      try {
        setLoading(true)
        setError(null)
        setIsNotFound(false)
        const data = await fetchApplet<GetAppletResponse>(GET_APPLET, { id: appletId })
        setApplet(data.applet)
      } catch (err) {
        if (err instanceof AppletNotFoundError) {
          setIsNotFound(true)
          setError(err)
        } else {
          setError(err instanceof Error ? err : new Error("Failed to fetch applet"))
        }
      } finally {
        setLoading(false)
      }
    }

    fetchAppletData()
  }, [appletId])

  if (loading) {
    return (
      <div className="applet-detail applet-detail--loading">
        <p>Loading applet...</p>
      </div>
    )
  }

  if (isNotFound) {
    return (
      <div className="applet-detail applet-detail--not-found">
        <div className="error-box">
          <h2>Applet Not Found</h2>
          <p>The applet you're looking for doesn't exist or may have been removed.</p>
          <a href="/" className="btn-back">← Back to Home</a>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="applet-detail applet-detail--error">
        <div className="error-box">
          <h2>Error Loading Applet</h2>
          <p>{error.message}</p>
          <button onClick={() => window.location.reload()} className="btn-retry">
            Try Again
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="applet-detail">
      <a href="/" className="btn-back-to-list">← Back to Applets</a>

      <div className="applet-card">
        <h1 className="applet-name">{applet.name}</h1>
        <p className="applet-description">{applet.description}</p>

        <div className="applet-services">
          <div className="service trigger-service">
            <span className="service-label">If</span>
            <span className="service-name">{applet.triggerService.name}</span>
          </div>
          <div className="service-arrow">→</div>
          <div className="service action-service">
            <span className="service-label">Then</span>
            <span className="service-name">{applet.actionService.name}</span>
          </div>
        </div>

        <div className={`applet-status ${applet.enabled ? 'applet-status--enabled' : 'applet-status--disabled'}`}>
          {applet.enabled ? "Enabled" : "Disabled"}
        </div>
      </div>

      <ActivityFeed appletId={appletId} />
    </div>
  )
}

export default AppletDetail
