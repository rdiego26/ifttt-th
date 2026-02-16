import { GraphQLClient } from "graphql-request"

export const client = new GraphQLClient("http://localhost:3000/graphql", {
  credentials: "same-origin",
})

export class AppletNotFoundError extends Error {
  constructor(message: string = "Applet not found") {
    super(message)
    this.name = "AppletNotFoundError"
  }
}

export async function fetchApplet<T>(query: string, variables: Record<string, any>): Promise<T> {
  try {
    return await client.request<T>(query, variables)
  } catch (error: any) {
    // Check if it's a GraphQL error about not found
    if (error?.response?.errors?.[0]?.message?.includes("not found")) {
      throw new AppletNotFoundError(error.response.errors[0].message)
    }
    // Re-throw other errors
    throw error
  }
}

