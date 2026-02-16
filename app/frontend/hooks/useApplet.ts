import { useState, useEffect } from 'react'
import { fetchApplet, AppletNotFoundError } from '../graphql/client'
import { GET_APPLET, GetAppletResponse, Applet } from '../graphql/queries'

interface UseAppletResult {
  applet: Applet | null
  loading: boolean
  error: Error | null
  isNotFound: boolean
}

export const useApplet = (appletId: string): UseAppletResult => {
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
          setError(err instanceof Error ? err : new Error('Failed to fetch applet'))
        }
      } finally {
        setLoading(false)
      }
    }

    fetchAppletData()
  }, [appletId])

  return { applet, loading, error, isNotFound }
}

