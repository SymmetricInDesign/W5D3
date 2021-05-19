PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
)

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
)

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
)

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  parent_id INTEGER,
  body TEXT NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
)

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
)


INSERT INTO
  users (fname, lname)
VALUES
  ('Donnie', 'Wombough'),
  ('Sammy', 'Huang'),
  ('Arthur', 'Miller');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('ORM', 'What is dis?', (SELECT id FROM users WHERE fname = 'Donnie')),
  ('CSS', 'What is that?', (SELECT id FROM users WHERE fname = 'Sammy'));

INSERT INTO
  question_follows (user_id, questions_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Donnie'), (SELECT id FROM questions WHERE title = 'CSS')),
  ((SELECT id FROM users WHERE fname = 'Sammy'), (SELECT id FROM questions WHERE title = 'ORM'));

INSERT INTO
  replies (author_id, parent_id, questions_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Donnie'), NULL, (SELECT id FROM questions WHERE title = 'CSS'), 'Cool!'),
  ((SELECT id FROM users WHERE fname = 'Sammy'), N);