Where's Waldo? — Backend Design Notes
Status: Planning
Last updated: 2026-11-02

This document records the backend decisions made so far. Items marked Pending still need to be discussed and agreed on. The goal is to keep the backend focused on the project's MVP rather than introduce unnecessary complexity.
1. Project context
The frontend MVP is complete enough to:
- Select a difficulty and start a game.
- Find targets by clicking the game image.
- Track found targets and elapsed time.
- Finish the game when all targets have been found.
- Return to the main menu, including using the exit option before finishing.
The backend will add persistent score submission and leaderboards, with basic server-side validation of game sessions.
2. Planned technology
- Runtime: Node.js
- Framework: Express
- Language: TypeScript
- Database: PostgreSQL
- ORM: Prisma
3. Product scope and decisions
Area	Current decision
Player accounts	No account system required for the MVP.
Player names	Players may enter a name when they finish if they want to submit a leaderboard score.
Score submission	Optional. Players should not be forced to submit a score.
Score storage	Store submitted scores.
Ranking	A lower completion time ranks above a longer completion time.
Difficulty leaderboards	Keep Easy, Medium, and Hard scores in separate tables for straightforwardness and flexibility.
Player data	Use a dedicated players table to keep the design flexible if requirements change.
Payload validation	The server should reject invalid request data.
Anti-cheat	Basic server-side validation is in scope; comprehensive anti-cheat protection is not an MVP goal.


Leaderboard size: Not yet confirmed in this planning record. Confirm the number of entries to display per difficulty before implementing the leaderboard query.
4. Game-session validation
The backend should not blindly trust a completion time or a list of targets supplied by the frontend. It should maintain the authoritative game-session state.
Proposed session flow
1. Start a game: The frontend asks the backend to create a game session and supplies the selected difficulty.
2. Create the session: The backend validates the difficulty, creates a session, and records the server-side start timestamp.
3. Record target discoveries: Each time the player finds a character, the frontend submits that target to the backend for validation.
4. Validate progress: The backend checks that the session is valid and active, and that the target belongs to that session's difficulty.
5. Complete the game: Once every required target has been recorded, the session is eligible to be completed.
6. Calculate the time: The backend uses its own recorded timestamps to calculate the official completion time.
7. Offer score submission: The frontend can offer the player the option to submit their name and score to the leaderboard.
This is a proposed high-level flow. The exact API routes, request/response formats, and session data model are still pending.
Target validation approach — DECIDED
Validate each target individually (Option A).

The frontend sends a request to the backend whenever a player finds a character. The backend validates and records each discovery instead of trusting the frontend to submit a complete list of found targets only at the end.

The backend should check at least:
- The game session exists and is active.
- The target ID is valid.
- The target belongs to the selected difficulty.
- The target has not already been recorded as found in that session.
Duplicate target submissions — DECIDED
Handle duplicates gracefully (Option B).

If the player submits a target that has already been found:
- Do not record it a second time.
- Do not interrupt or invalidate the game.
- Return the current game progress so the frontend can keep its state synchronized.
- The frontend may display or retain a “Found” indication.
Example response shape (illustrative only; not a finalized API contract):
{
  "message": "Target already found",
  "foundTargets": ["waldo", "wenda"]
}
Invalid submissions and session states
The server should reject invalid data and requests that are not allowed for the session. The exact HTTP status codes and error response format have not yet been finalized.

Potential cases to handle:
- Unknown or invalid session ID.
- Unknown target ID.
- Target not associated with the session's difficulty.
- Attempt to submit a target after the session has been completed.
- Attempt to complete a session before all required targets have been found.
- Malformed or otherwise invalid request payload.
5. Database direction
The current design direction includes:
- A dedicated players table.
- Separate score tables for Easy, Medium, and Hard.
The intention is to keep the schema simple and clear while leaving room for future changes.

Still to design: exact columns, primary and foreign keys, Prisma relations, how game sessions and found targets are represented, and how submitted scores relate to players and sessions.
6. Decisions made in the latest planning session
1. Validate target discoveries individually through the backend.
2. Treat duplicate target submissions as harmless: return current progress without recording the target again or disrupting gameplay.
7. Open questions / next planning tasks
Suggested order for the next sessions:
1. Finish the game-session lifecycle: define session states, when a session can be completed, and what happens if a player exits or abandons a game.
2. Define the data model: identify the tables, fields, constraints, and relationships.
3. Plan the API: define endpoints, request bodies, response bodies, and error handling.
4. Define score submission: clarify how an optional player name and completed session become a stored leaderboard entry.
5. Define leaderboard behaviour: confirm the number of displayed scores, tie handling, and sorting.
6. Implement the backend MVP: build incrementally, test each feature, and integrate it with the existing React frontend.
Working principles
- Keep the MVP simple and avoid building features that are not currently needed.
- Validate untrusted input on the server.
- Treat the backend as the source of truth for session progress and official completion time.
- Keep optional leaderboard participation optional.
- Make design decisions explicit before implementing them.