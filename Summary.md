# Summary

## Overview

This document outlines the implementation of an applet detail page with real-time activity feed functionality. The solution encompasses backend services, GraphQL API enhancements, frontend React components, and comprehensive test coverage.

## Implementation Details

### 1. Backend: Activity Feed Service

**File:** `app/services/activity_feed_service.rb`

Created a service class responsible for generating realistic mock activity data for applets. The implementation includes:

- **Pagination Support:** Implements cursor-based pagination using timestamps for efficient data retrieval
- **Activity Generation:** Produces contextual mock data based on applet's trigger and action services
- **Realistic Data:** Activities include trigger/action data relevant to the specific services (e.g., Instagram photos, Dropbox paths, RSS items)
- **Status Distribution:** Randomized status distribution (success: 70%, failed: 20%, skipped: 10%)
- **Error Messages:** Contextual error messages for failed activities

**Key Features:**
- `fetch(limit:, cursor:)` - Returns paginated activity entries with has_more flag
- Deterministic random seeding for consistent data across requests
- Service-specific activity templates for realistic mock data

**Testing:** Comprehensive RSpec test suite covering:
- Basic fetch functionality
- Pagination behavior (cursor-based navigation, limit enforcement)
- Activity status distribution
- Data relevance to applet services
- Edge cases (invalid cursors, different applets)

### 2. GraphQL API Enhancements

**File:** `app/graphql/schema.rb`

Extended the GraphQL schema with:

#### Activity Feed Query
```graphql
activities(appletId: ID!, limit: Int, cursor: String): ActivityConnection
```

**Types Implemented:**
- `ActivityType` - Represents individual activity entries
- `TriggerDataType` / `ActionDataType` - Polymorphic data structures
- `ActivityConnectionType` - Pagination wrapper with edges and pageInfo

#### Toggle Applet Mutation
```graphql
toggleApplet(id: ID!): ToggleAppletPayload
```

**Features:**
- Updates applet enabled/disabled status
- Returns updated applet data
- Error handling for invalid IDs

### 3. Frontend: React Components

#### AppletDetail Component
**File:** `app/frontend/components/AppletDetail.tsx`

Enhanced the main component to display:
- Applet name, description, and enabled status
- Trigger and action service cards with icons and brand colors
- Toggle button for enabling/disabling applets
- Integration with GraphQL mutations
- Comprehensive loading and error states

**Key Features:**
- Real-time status updates via GraphQL mutations
- Optimistic UI updates for better UX
- Responsive design with service card layout

#### ActivityFeed Component
**File:** `app/frontend/components/ActivityFeed.tsx`

Implemented activity feed with advanced filtering capabilities:
- **Pagination:** Server-side pagination with page navigation controls
- **Search Functionality:** Debounced search with minimum 3-character requirement
- **Status Filtering:** Filter activities by success, failed, or skipped status
- **Status Visualization:** Color-coded status badges (success: green, failed: red, skipped: gray)
- **Detailed View:** Expandable activity entries showing trigger/action data
- **Empty States:** User-friendly messages for no activity with clear filters option
- **Loading States:** Loading indicators and error handling with retry functionality

**Technical Highlights:**
- Debounced search (500ms) for optimal performance
- Efficient re-rendering with React hooks
- Graceful error handling with retry mechanism
- Responsive design with formatted timestamps

### 4. GraphQL Integration

**File:** `app/frontend/graphql/queries.ts`

Defined all GraphQL operations:
- `GET_APPLET` - Fetches applet details with services
- `GET_ACTIVITIES` - Retrieves paginated activity feed
- `TOGGLE_APPLET` - Mutation for enabling/disabling applets

**File:** `app/frontend/graphql/client.ts`

Configured GraphQL client with:
- CSRF token authentication
- Error handling middleware
- TypeScript type safety

### 5. Frontend Testing

**Test Coverage:** Comprehensive Jest + React Testing Library test suites

#### AppletDetail Tests
**File:** `app/frontend/components/__tests__/AppletDetail.test.tsx`

Tests covering:
- Loading states and skeletons
- Applet data rendering (name, description, services)
- Toggle functionality
- Error handling
- User interactions

#### ActivityFeed Tests
**File:** `app/frontend/components/__tests__/ActivityFeed.test.tsx`

Tests covering:
- Empty state display
- Activity list rendering with search and filtering
- Status badge colors
- Activity expansion/collapse
- Pagination functionality
- Debounced search behavior
- Error states and retry functionality

#### Custom Hook Tests
**File:** `app/frontend/hooks/__tests__/useApplet.test.ts`

Tests covering:
- Data fetching logic
- Loading states
- Error handling
- Hook return values

**Test Execution:**
```bash
docker-compose up -d
docker compose exec app npm run test:coverage
```

Current coverage metrics demonstrate thorough testing of all frontend components and hooks.

## Technical Decisions & Tradeoffs

### Backend

**Mock Data vs. Database:**
- Chose to generate mock data dynamically rather than persist to database
- Rationale: Simpler implementation for prototype, easier to demonstrate variety of scenarios
- Tradeoff: No persistence means data resets, but suitable for demo purposes

**Cursor-based Pagination:**
- Selected timestamp-based cursors over offset pagination
- Rationale: Better performance, consistent results during real-time updates
- Tradeoff: More complex implementation, but better scalability

### Frontend

**Search and Filtering:**
- Implemented debounced search (500ms) for performance
- Rationale: Reduces unnecessary API calls while typing
- Benefit: Better user experience and reduced server load

**Component Architecture:**
- Separated ActivityFeed from AppletDetail for modularity
- Rationale: Single responsibility, easier testing, reusable components
- Benefit: Clean separation of concerns, maintainable codebase

**GraphQL vs. REST:**
- Leveraged existing GraphQL setup for all data fetching
- Rationale: Type safety, single endpoint, efficient data loading
- Benefit: Reduced over-fetching, better developer experience

## Additional Features Implemented

Beyond the core requirements, I evaluated the user experience from a user's perspective and drew inspiration from the IFTTT website's interface patterns to inform my design decisions:

1. **Toggle Applet Functionality**
   - Full GraphQL mutation implementation
   - Frontend UI with optimistic updates
   - Backend validation and error handling

2. **Advanced Search and Filtering**
   - Debounced search functionality with minimum character requirement
   - Status-based filtering (success, failed, skipped)
   - Clear filters functionality for better UX

3. **Comprehensive Test Coverage**
   - Frontend unit tests for all components and hooks
   - Backend RSpec tests for service layer
   - High code coverage metrics

4. **Enhanced UX**
   - Loading skeletons for better perceived performance
   - Error boundaries and fallback states
   - Responsive design considerations
   - Expandable activity details

## Considerations / Comments

- **Ongoing Data:** Given the current mock data implementation, there was uncertainty about how to handle "ongoing data" in the Activity Feed Service. For a production scenario with real-time activity logs, WebSocket integration (ActionCable) would be the recommended approach to handle continuous data streams as applets execute.
- **Disabled Applets:** The Activity Feed is not rendered when an applet is disabled. This design decision prevents unnecessary API requests for inactive applets and provides a cleaner user experience by only showing relevant data for enabled applets.

## Future Enhancements

Given additional time, the following improvements would be prioritized:

- **Cache Aside Pattern:** Implement cache aside pattern for applet and activity data to reduce database load and improve response times
- **Event-Driven Cache Invalidation:** Control cache invalidation using event-driven architecture to automatically invalidate cached data when applet modifications or additions occur
- **Eventual Consistency for Activity Feed:** Implement eventual consistency pattern for the feed service with a message queue that will be consumed asynchronously and data persisted to the database
- **Enhanced Search UX:** Improve Activity Feed search experience by adding visual feedback during the debounce period (e.g., loading spinner) to provide better user feedback while the search is being processed
- **E2E Testing:** Implement end-to-end testing with tools like Capybara/Selenium, Playwright, or Cypress to validate full user workflows and ensure integration between frontend and backend components
