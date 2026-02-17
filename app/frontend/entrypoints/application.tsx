import React from "react"
import { createRoot } from "react-dom/client"
import AppletDetail from "../components/AppletDetail"
import AppletList from "../components/AppletList"
import { Applet } from "../graphql/queries"
import "../styles/application.css"
import "../styles/home.css"

document.addEventListener("DOMContentLoaded", () => {
  // Mount AppletDetail component
  const rootElement = document.getElementById("applet-root")

  if (rootElement) {
    const appletId = rootElement.dataset.appletId

    if (appletId) {
      const root = createRoot(rootElement)
      root.render(
        <React.StrictMode>
          <AppletDetail appletId={appletId} />
        </React.StrictMode>
      )
    }
  }

  // Mount AppletList component
  const appletListElement = document.getElementById("applet-list-root")

  if (appletListElement) {
    const appletsData = appletListElement.dataset.applets

    if (appletsData) {
      try {
        const applets: Applet[] = JSON.parse(appletsData)
        const root = createRoot(appletListElement)
        root.render(
          <React.StrictMode>
            <AppletList initialApplets={applets} />
          </React.StrictMode>
        )
      } catch (error) {
        console.error("Failed to parse applets data:", error)
      }
    }
  }
})
