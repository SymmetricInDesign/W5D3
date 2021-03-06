PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);



CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);



CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);



CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  parent_id INTEGER,
  body TEXT NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);


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
  ('CSS', 'What is that?', (SELECT id FROM users WHERE fname = 'Sammy')),
  ('Question3', 'What is dog?', (SELECT id FROM users WHERE fname = 'Sammy')),
  ('Question4', 'What is cat?', (SELECT id FROM users WHERE fname = 'Sammy'));

INSERT INTO
  question_follows (user_id, questions_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Donnie'), (SELECT id FROM questions WHERE title = 'CSS')),
  ((SELECT id FROM users WHERE fname = 'Donnie'), (SELECT id FROM questions WHERE title = 'Question3')),
  ((SELECT id FROM users WHERE fname = 'Donnie'), (SELECT id FROM questions WHERE title = 'Question4')),
  ((SELECT id FROM users WHERE fname = 'Arthur'), (SELECT id FROM questions WHERE title = 'Question3')),
  ((SELECT id FROM users WHERE fname = 'Sammy'), (SELECT id FROM questions WHERE title = 'Question3')),
  ((SELECT id FROM users WHERE fname = 'Sammy'), (SELECT id FROM questions WHERE title = 'Question4')),
  ((SELECT id FROM users WHERE fname = 'Sammy'), (SELECT id FROM questions WHERE title = 'ORM'));

INSERT INTO
  replies (author_id, questions_id, parent_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Donnie'), (SELECT id FROM questions WHERE title = 'CSS'), NULL, 'Cool!');

INSERT INTO
  replies (author_id, questions_id, parent_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Sammy'), (SELECT id from questions WHERE title = 'CSS'), (SELECT id FROM replies WHERE body = 'Cool!'), 'Dope!');

INSERT INTO
  replies (author_id, questions_id, parent_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Arthur'), (SELECT id from questions WHERE title = 'CSS'), (SELECT id FROM replies WHERE body = 'Dope!'), 'Rad!');

INSERT INTO
  question_likes (questions_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'ORM'), (SELECT id FROM users WHERE fname = 'Arthur')),
  ((SELECT id FROM questions WHERE title = 'ORM'), (SELECT id FROM users WHERE fname = 'Donnie'));