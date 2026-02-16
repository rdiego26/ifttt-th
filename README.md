# Applet Detail Page

Build an applet detail page that helps users understand what their applet does
and whether it's working.

## Quick Start

```bash
docker compose up
```

Visit http://localhost:3000/applets/1

## Tech Stack

- **Backend:** Ruby 4, Rails 8, PostgreSQL
- **Frontend:** React 18, TypeScript, Vite 7
- **API:** GraphQL (graphql-ruby + graphql-request)
- **Container:** Docker Compose

## Starting Point

- Rails 8 app with Applet and Service models
- Seed data: 5 sample applets with connected services
- GraphQL endpoint at `/graphql` with applet query
- React app mounted on the applet show page
- Hot reloading enabled for both Rails and React

## The Problem

Users want to see:
- What their applet does (which services, trigger → action)
- Recent activity showing when the applet ran and what happened

## Your Task

### 1. Applet Detail Component (Frontend)

Improve the `AppletDetail` component in `app/frontend/components/`:

- Display the applet name and description
- Show trigger and action services with their icons and brand colors
- Show enabled/disabled status
- Handle loading and error states gracefully
- Make it look good!

### 2. Activity Feed Service (Backend)

Create an `ActivityFeedService` class that generates mock activity data.
Support pagination, search, websocket, or some way for the client to fetch older and ongoing activity

```ruby
# Example usage:
service = ActivityFeedService.new(applet_id: 1)
activities = service.fetch
```

Each activity should include:
- Unique ID
- Timestamp (when it ran)
- Status (success, failed, skipped)
- Trigger data (what triggered it)
- Action data (what action was taken)
- Error message (if failed)

Generate realistic mock data based on the applet's trigger and action services.

### 3. Activity Feed UI (Frontend)

Display the activity feed below the applet details:

- Show recent activity entries
- Component should update to show ongoing activity
- Handle empty, loading, and error states
- Style consistently with the applet card

### 4. Tests (Backend)

Write RSpec tests for `ActivityFeedService`:

- Test fetch works correctly
- Test different activity statuses are generated
- Test data relates to the applet's services

## Project Structure

```
app/
├── controllers/
│   ├── applets_controller.rb    # Show action
│   └── graphql_controller.rb    # GraphQL endpoint
├── graphql/
│   └── schema.rb                # All GraphQL types
├── models/
│   ├── applet.rb                # Belongs to trigger/action services
│   └── service.rb               # Has many applets
├── services/                    # Create this folder
│   └── activity_feed_service.rb # You create this
└── frontend/
    ├── entrypoints/
    │   └── application.tsx      # React entry point
    ├── components/
    │   └── AppletDetail.tsx     # Improve this component
    └── graphql/
        ├── client.ts            # graphql-request client
        └── queries.ts           # GraphQL queries
```

## GraphQL

Query the applet endpoint:

```graphql
query GetApplet($id: ID!) {
  applet(id: $id) {
    id
    name
    description
    enabled
    triggerService {
      name
      iconUrl
      brandColor
    }
    actionService {
      name
      iconUrl
      brandColor
    }
  }
}
```

Test at http://localhost:3000/graphiql

## Commands

```bash
# Start everything
docker compose up

# Run Rails console
docker compose exec app bin/rails console

# Run RSpec tests
docker compose exec app bin/rspec

# Run specific test file
docker compose exec app bin/rspec spec/services/activity_feed_service_spec.rb
```

## Deliverable

- Working code
- Summary.md writeup explaining your approach and tradeoffs
- Tests for backend logic
- You have 5 days to complete the project and send the result back in a zip
- This project will be used in a 2nd round session as the foundation
- You can use AI but we want to know more about you, not the AI

## Time

This exercise is designed to be completed in an afternoon or a couple short sessions.
Focus on demonstrating your skills rather than building everything perfectly. If you
run out of time, document what you would do differently or add with more time.

## Sample Applets

The database is seeded with 5 applets:

1. Save Instagram photos to Dropbox
2. Email me new RSS items
3. Tweet my new blog posts
4. Save Spotify tracks to a spreadsheet
5. Backup phone photos to Google Drive

Each applet connects two services (trigger → action) that you can use to
generate realistic activity data.

---

Good luck! We're excited to see what you build.
