import { gql } from "graphql-request"

export const GET_APPLET = gql`
  query GetApplet($id: ID!) {
    applet(id: $id) {
      id
      name
      description
      enabled
      triggerService {
        id
        name
        slug
        iconUrl
        brandColor
      }
      actionService {
        id
        name
        slug
        iconUrl
        brandColor
      }
    }
  }
`

export interface Service {
  id: string
  name: string
  slug: string
  iconUrl: string | null
  brandColor: string | null
}

export interface Applet {
  id: string
  name: string
  description: string | null
  enabled: boolean
  triggerService: Service
  actionService: Service
}

export interface GetAppletResponse {
  applet: Applet
}

export const GET_ACTIVITIES = gql`
  query GetActivities(
    $appletId: ID!
    $page: Int
    $perPage: Int
    $sinceTime: ISO8601DateTime
    $beforeTime: ISO8601DateTime
    $status: String
    $search: String
  ) {
    activities(
      appletId: $appletId
      page: $page
      perPage: $perPage
      sinceTime: $sinceTime
      beforeTime: $beforeTime
      status: $status
      search: $search
    ) {
      activities {
        id
        appletId
        status
        ranAt
        triggerData
        actionData
        errorMessage
      }
      totalCount
      page
      perPage
      totalPages
    }
  }
`

export interface Activity {
  id: string
  appletId: string
  status: "success" | "failed" | "skipped"
  ranAt: string
  triggerData: {
    service: string
    event: string
    details?: Record<string, any>
  }
  actionData: {
    service: string
    result: string
    completed?: boolean
  }
  errorMessage?: string | null
}

export interface ActivityConnection {
  activities: Activity[]
  totalCount: number
  page: number
  perPage: number
  totalPages: number
}

export interface GetActivitiesResponse {
  activities: ActivityConnection
}

export interface GetActivitiesVariables {
  appletId: string
  page?: number
  perPage?: number
  sinceTime?: string
  beforeTime?: string
  status?: "success" | "failed" | "skipped"
  search?: string
}

export const GET_APPLETS = gql`
  query GetApplets($enabled: Boolean) {
    applets(enabled: $enabled) {
      id
      name
      description
      enabled
      triggerService {
        id
        name
        slug
        iconUrl
        brandColor
      }
      actionService {
        id
        name
        slug
        iconUrl
        brandColor
      }
    }
  }
`

export interface GetAppletsResponse {
  applets: Applet[]
}

export interface GetAppletsVariables {
  enabled?: boolean
}

export const TOGGLE_APPLET = gql`
  mutation ToggleApplet($id: ID!) {
    toggleApplet(id: $id) {
      id
      name
      description
      enabled
      triggerService {
        id
        name
        slug
        iconUrl
        brandColor
      }
      actionService {
        id
        name
        slug
        iconUrl
        brandColor
      }
    }
  }
`

export interface ToggleAppletResponse {
  toggleApplet: Applet
}

export interface ToggleAppletVariables {
  id: string
}
