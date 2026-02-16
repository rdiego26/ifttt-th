import React, { useState } from "react"
import { client } from "../graphql/client"
import {
  Applet,
  TOGGLE_APPLET,
  ToggleAppletResponse,
  ToggleAppletVariables,
} from "../graphql/queries"

interface AppletListProps {
  initialApplets: Applet[]
}

interface AppletItemState {
  loading: boolean
  error: string | null
}

const AppletList: React.FC<AppletListProps> = ({ initialApplets }) => {
  const [applets, setApplets] = useState<Applet[]>(initialApplets)
  const [appletStates, setAppletStates] = useState<Record<string, AppletItemState>>({})

  const handleToggle = async (appletId: string, event: React.MouseEvent) => {
    event.preventDefault() // Prevent navigation
    event.stopPropagation()

    // Don't allow toggle if already loading
    if (appletStates[appletId]?.loading) {
      return
    }

    // Set loading state
    setAppletStates((prev) => ({
      ...prev,
      [appletId]: { loading: true, error: null },
    }))

    try {
      const response = await client.request<
        ToggleAppletResponse,
        ToggleAppletVariables
      >(TOGGLE_APPLET, { id: appletId })

      // Update the applet in the list
      setApplets((prev) =>
        prev.map((applet) =>
          applet.id === appletId ? response.toggleApplet : applet
        )
      )

      // Clear loading state
      setAppletStates((prev) => ({
        ...prev,
        [appletId]: { loading: false, error: null },
      }))
    } catch (error) {
      // Set error state
      const errorMessage = error instanceof Error ? error.message : "Failed to toggle applet"
      setAppletStates((prev) => ({
        ...prev,
        [appletId]: { loading: false, error: errorMessage },
      }))

      // Clear error after 3 seconds
      setTimeout(() => {
        setAppletStates((prev) => ({
          ...prev,
          [appletId]: { ...prev[appletId], error: null },
        }))
      }, 3000)
    }
  }

  return (
    <div className="applet-list-container">
      {applets.map((applet) => {
        const state = appletStates[applet.id] || { loading: false, error: null }

        return (
          <div key={applet.id} className="applet-item-wrapper">
            <a href={`/applets/${applet.id}`} className="applet-link">
              <div className="applet-preview">
                <div className="applet-preview-header">
                  <strong>{applet.name}</strong>
                  <div className="applet-toggle-container">
                    <button
                      type="button"
                      className={`applet-toggle ${applet.enabled ? "applet-toggle--enabled" : "applet-toggle--disabled"} ${state.loading ? "applet-toggle--loading" : ""}`}
                      onClick={(e) => handleToggle(applet.id, e)}
                      disabled={state.loading}
                      title={applet.enabled ? "Disable applet" : "Enable applet"}
                    >
                      {state.loading ? (
                        <span className="toggle-spinner"></span>
                      ) : (
                        <>
                          <span className="toggle-slider"></span>
                          <span className="toggle-label">
                            {applet.enabled ? "ON" : "OFF"}
                          </span>
                        </>
                      )}
                    </button>
                  </div>
                </div>
                <span className="services">
                  {applet.triggerService.name} → {applet.actionService.name}
                </span>
              </div>
            </a>
            {state.error && (
              <div className="applet-error">
                <span className="error-icon">⚠️</span>
                {state.error}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

export default AppletList

