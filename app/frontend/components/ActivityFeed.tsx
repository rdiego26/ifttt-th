import React, { useEffect, useState } from "react"
import { fetchApplet } from "../graphql/client"
import {
  GET_ACTIVITIES,
  GetActivitiesResponse,
  GetActivitiesVariables,
  Activity,
  ActivityConnection,
} from "../graphql/queries"

interface ActivityFeedProps {
  appletId: string
}

const ActivityFeed: React.FC<ActivityFeedProps> = ({ appletId }) => {
  const [activityData, setActivityData] = useState<ActivityConnection | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<"success" | "failed" | "skipped" | "">("")

  const fetchActivities = async (page: number = 1) => {
    try {
      setLoading(true)
      setError(null)

      const variables: GetActivitiesVariables = {
        appletId,
        page,
        perPage: 20,
      }

      if (searchTerm) {
        variables.search = searchTerm
      }

      if (statusFilter) {
        variables.status = statusFilter
      }

      const data = await fetchApplet<GetActivitiesResponse>(GET_ACTIVITIES, variables)
      setActivityData(data.activities)
      setCurrentPage(page)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch activities"))
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    // Only search if searchTerm is empty or has at least 3 characters
    if (searchTerm === "" || searchTerm.length >= 3) {
      const timer = setTimeout(() => {
        fetchActivities(1)
      }, 500) // Debounce for 500ms

      return () => clearTimeout(timer)
    }
  }, [appletId, searchTerm, statusFilter])

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    fetchActivities(1)
  }

  const handlePageChange = (page: number) => {
    fetchActivities(page)
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000)

    if (diffInSeconds < 60) return "Just now"
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
    if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`

    return date.toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: date.getFullYear() !== now.getFullYear() ? "numeric" : undefined,
    })
  }

  const getStatusIcon = (status: Activity["status"]) => {
    switch (status) {
      case "success":
        return "✓"
      case "failed":
        return "✗"
      case "skipped":
        return "⊘"
      default:
        return "•"
    }
  }

  if (loading && !activityData) {
    return (
      <div className="activity-feed">
        <h2>Activity Feed</h2>
        <div className="activity-feed__loading">
          <p>Loading activities...</p>
        </div>
      </div>
    )
  }

  if (error && !activityData) {
    return (
      <div className="activity-feed">
        <h2>Activity Feed</h2>
        <div className="activity-feed__error">
          <p>{error.message}</p>
          <button onClick={() => fetchActivities(currentPage)} className="btn-retry">
            Try Again
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="activity-feed">
      <div className="activity-feed__header">
        <h2>Activity Feed</h2>
        {activityData && (
          <span className="activity-feed__count">
            {activityData.totalCount} {activityData.totalCount === 1 ? "activity" : "activities"}
          </span>
        )}
      </div>

      <div className="activity-feed__filters">
        <form onSubmit={handleSearch} className="activity-feed__search">
          <input
            type="text"
            placeholder="Search activities... (min 3 characters)"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            disabled={loading}
            className="search-input"
          />
          {searchTerm.length > 0 && searchTerm.length < 3 && (
            <span className="search-hint">Type at least 3 characters to search</span>
          )}
        </form>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as any)}
          disabled={loading}
          className="status-filter"
        >
          <option value="">All statuses</option>
          <option value="success">Success</option>
          <option value="failed">Failed</option>
          <option value="skipped">Skipped</option>
        </select>
      </div>

      {activityData && activityData.activities.length === 0 ? (
        <div className="activity-feed__empty">
          <p>No activities found.</p>
          {(searchTerm || statusFilter) && (
            <button
              onClick={() => {
                setSearchTerm("")
                setStatusFilter("")
              }}
              className="btn-clear-filters"
            >
              Clear filters
            </button>
          )}
        </div>
      ) : (
        <>
          <div className="activity-list">
            {activityData?.activities.map((activity) => (
              <div
                key={activity.id}
                className={`activity-item activity-item--${activity.status}`}
              >
                <div className="activity-item__header">
                  <span className={`activity-status activity-status--${activity.status}`}>
                    <span className="activity-status__icon">{getStatusIcon(activity.status)}</span>
                    <span className="activity-status__text">{activity.status}</span>
                  </span>
                  <span className="activity-time">{formatDate(activity.ranAt)}</span>
                </div>

                <div className="activity-item__body">
                  <div className="activity-trigger">
                    <span className="activity-label">Trigger:</span>
                    <span className="activity-service">{activity.triggerData.service}</span>
                    <span className="activity-event">{activity.triggerData.event}</span>
                  </div>

                  <div className="activity-action">
                    <span className="activity-label">Action:</span>
                    <span className="activity-service">{activity.actionData.service}</span>
                    <span className="activity-result">{activity.actionData.result}</span>
                  </div>

                  {activity.errorMessage && (
                    <div className="activity-error">
                      <span className="activity-error__icon">⚠</span>
                      <span className="activity-error__message">{activity.errorMessage}</span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>

          {activityData && activityData.totalPages > 1 && (
            <div className="activity-feed__pagination">
              <button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1 || loading}
                className="pagination-btn"
              >
                ← Previous
              </button>

              <span className="pagination-info">
                Page {currentPage} of {activityData.totalPages}
              </span>

              <button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === activityData.totalPages || loading}
                className="pagination-btn"
              >
                Next →
              </button>
            </div>
          )}
        </>
      )}
    </div>
  )
}

export default ActivityFeed

