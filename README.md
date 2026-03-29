# Dayspring IPL Prediction

Rails app for IPL match predictions with:

- email/password signup and login
- daily match view with date selection
- prediction questions per match
- automatic lock once a match starts
- user leaderboard based on correct answers
- simple admin area for adding matches and questions

## Setup

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Open `http://localhost:3000`.

## PostgreSQL

This app is configured for PostgreSQL.

Example local environment:

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USERNAME=postgres
export DB_PASSWORD=your_database_password
export DB_NAME=dayspring_ipl_prediction_development
export DB_TEST_NAME=dayspring_ipl_prediction_test
export SEED_ADMIN_PASSWORD=choose_a_seed_admin_password
export SEED_USER_PASSWORD=choose_a_seed_user_password
```

For production, replace those with your real database credentials.

## Seeded Logins

Seeded users are created with the emails above and the passwords you provide through `SEED_ADMIN_PASSWORD` and `SEED_USER_PASSWORD`.

## Main Screens

- `/` shows today's match by default, or a selected date from the date strip
- `/leaderboards` shows the points table
- `/admin` lets the admin create matches and add prediction questions

## Notes

- Each question can carry its own point value
- Users can submit or update a pick only before the match start time
- After the start time, the pick is locked
- Admins set the correct answer from the question edit page
# Daypring-Cricket-Fantasy
# Dayspring-Cricket-Fantasy
# Dayspring-Cricket-Fantasy
