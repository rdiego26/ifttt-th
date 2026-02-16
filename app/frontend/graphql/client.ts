import { GraphQLClient } from "graphql-request"

export const client = new GraphQLClient("http://localhost:3000/graphql", {
  credentials: "same-origin",
})
