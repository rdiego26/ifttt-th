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
