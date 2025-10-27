CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE venues (
    venue_id SERIAL PRIMARY KEY,
    name VARCHAR(120),
    building VARCHAR(100),
    room VARCHAR(50),
    address VARCHAR(200),
    capacity INT
);

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    title VARCHAR(160),
    description TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    capacity INT,
    status VARCHAR(20),
    organizer_id INT REFERENCES users(user_id),
    venue_id INT REFERENCES venues(venue_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registrations (
    registration_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    event_id INT REFERENCES events(event_id),
    status VARCHAR(20),
    waitlist_position INT,
    checked_in BOOLEAN,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_feedback (
    feedback_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    event_id INT REFERENCES events(event_id),
    rating INT,
    comments TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
