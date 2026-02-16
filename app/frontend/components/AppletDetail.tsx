import React, { useEffect, useState } from "react"
import { client } from "../graphql/client"
import { GET_APPLET, GetAppletResponse, Applet } from "../graphql/queries"

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

  useEffect(() => {
    const fetchApplet = async () => {
      try {
        setLoading(true)
        const data = await client.request<GetAppletResponse>(GET_APPLET, { id: appletId })
        setApplet(data.applet)
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch applet"))
      } finally {
        setLoading(false)
      }
    }

    fetchApplet()
  }, [appletId])

  if (loading) {
    return (
      <div className="applet-detail applet-detail--loading">
        <p>Loading applet...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="applet-detail applet-detail--error">
        <p>Error loading applet: {error.message}</p>
      </div>
    )
  }

  if (!applet) {
    return (
      <div className="applet-detail applet-detail--not-found">
        <p>Applet not found</p>
      </div>
    )
  }

  return (
    <div className="applet-detail">
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

        <div className="applet-status">
          Status: {applet.enabled ? "Enabled" : "Disabled"}
        </div>
      </div>

      <div className="activity-feed-placeholder">
        <h2>Activity Feed</h2>
      </div>
    </div>
  )
}

export default AppletDetail
