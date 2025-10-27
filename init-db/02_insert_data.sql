INSERT INTO users (name, email, role) VALUES
('Gabby Settles', 'gabby@umbc.edu', 'organizer'),
('Sydney Minor', 'sydney@umbc.edu', 'attendee'),
('Fiza Saleem', 'fiza@umbc.edu', 'attendee');

INSERT INTO venues (name, building, room, address, capacity) VALUES
('Sherman Hall Auditorium', 'Sherman Hall', 'AUD', '1000 Hilltop Circle, Baltimore, MD', 250),
('ITE Lab 456', 'ITE Building', '456', '1000 Hilltop Circle, Baltimore, MD', 40);

INSERT INTO events (title, description, start_time, end_time, capacity, status, organizer_id, venue_id) VALUES
('Intro to SQL', 'Hands-on session for SQL basics.', NOW(), NOW() + INTERVAL '2 HOURS', 40, 'published', 1, 2),
('Career Night with Alumni', 'Panel and networking with alumni.', NOW() + INTERVAL '1 DAY', NOW() + INTERVAL '1 DAY 3 HOURS', 200, 'published', 1, 1);

INSERT INTO registrations (user_id, event_id, status) VALUES
(2, 1, 'registered'),
(3, 1, 'registered');

INSERT INTO event_feedback (user_id, event_id, rating, comments) VALUES
(2, 1, 5, 'Great intro!'),
(3, 1, 4, 'Helpful session.');
