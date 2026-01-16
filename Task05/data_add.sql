-- SQL commands for adding new data
-- These queries do not depend on specific IDs or record counts

-- Add 5 new users (including yourself and 4 neighbors from group list)
-- Registration date will be set to current system time
BEGIN;

-- User 1: Yourself (replace with your actual name and email)
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES (
    'YourFirstName',
    'YourLastName',
    'your.email@example.com',
    'male',
    date('now'),
    (SELECT id FROM occupations WHERE name = 'student' LIMIT 1)
);

-- User 2: Neighbor 1
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES (
    'Neighbor1FirstName',
    'Neighbor1LastName',
    'neighbor1.email@example.com',
    'male',
    date('now'),
    (SELECT id FROM occupations WHERE name = 'student' LIMIT 1)
);

-- User 3: Neighbor 2
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES (
    'Neighbor2FirstName',
    'Neighbor2LastName',
    'neighbor2.email@example.com',
    'female',
    date('now'),
    (SELECT id FROM occupations WHERE name = 'student' LIMIT 1)
);

-- User 4: Neighbor 3
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES (
    'Neighbor3FirstName',
    'Neighbor3LastName',
    'neighbor3.email@example.com',
    'male',
    date('now'),
    (SELECT id FROM occupations WHERE name = 'student' LIMIT 1)
);

-- User 5: Neighbor 4
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES (
    'Neighbor4FirstName',
    'Neighbor4LastName',
    'neighbor4.email@example.com',
    'female',
    date('now'),
    (SELECT id FROM occupations WHERE name = 'student' LIMIT 1)
);

COMMIT;

-- Add 3 new movies of different genres
BEGIN;

-- Movie 1: Action movie
INSERT INTO movies (title, year)
VALUES ('The Matrix Reloaded', 2003);

-- Movie 2: Comedy movie
INSERT INTO movies (title, year)
VALUES ('The Grand Budapest Hotel', 2014);

-- Movie 3: Drama movie
INSERT INTO movies (title, year)
VALUES ('The Shawshank Redemption', 1994);

COMMIT;

-- Link genres to the new movies
BEGIN;

-- Link Action and Sci-Fi to The Matrix Reloaded
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'The Matrix Reloaded'
  AND g.name IN ('Action', 'Sci-Fi');

-- Link Comedy and Drama to The Grand Budapest Hotel
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'The Grand Budapest Hotel'
  AND g.name IN ('Comedy', 'Drama');

-- Link Drama to The Shawshank Redemption
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'The Shawshank Redemption'
  AND g.name = 'Drama';

COMMIT;

-- Add 3 new reviews from yourself about the added movies
-- Replace 'your.email@example.com' with your actual email
BEGIN;

-- Review 1: The Matrix Reloaded
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.5, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'your.email@example.com'
  AND m.title = 'The Matrix Reloaded';

-- Review 2: The Grand Budapest Hotel
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'your.email@example.com'
  AND m.title = 'The Grand Budapest Hotel';

-- Review 3: The Shawshank Redemption
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'your.email@example.com'
  AND m.title = 'The Shawshank Redemption';

COMMIT;

