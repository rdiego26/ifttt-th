import React from "react"
import { createRoot } from "react-dom/client"
import AppletDetail from "../components/AppletDetail"
import "../styles/application.css"

document.addEventListener("DOMContentLoaded", () => {
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
})
