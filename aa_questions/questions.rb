require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User

  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    data.map { |data| User.new(data)}
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    data.map { |data| User.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

end



class Question

  attr_accessor :id, :title, :body, :author_id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    data.map { |data| Question.new(data)}
  end

  def self.find_by_author_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    data.map { |data| Question.new(data)}
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

end



class Reply

  attr_accessor :id, :author_id, :questions_id, :parent_id, :body

  def self.find_by_user_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    data.map { |data| Reply.new(data)}
  end

  def self.find_by_question_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        questions_id = ?
    SQL
    data.map { |data| Reply.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @author_id = options['author_id']
    @questions_id = options['questions_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def question
    Question.find_by_id(self.questions_id)
  end

  def parent_reply
    Reply.find_by_user_id(self.parent_id)
  end

  def child_replies
    replies = Reply.find_by_question_id(self.questions_id)
    replies.select { |reply| reply.parent_id == self.id }
  end

end

class QuestionFollow

  attr_accessor :id, :user_id, :questions_id

  def self.followers_for_question_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      JOIN users
        ON users.id = question_follows.user_id
      WHERE
        questions_id = ?
    SQL
    data.map { |data| User.new(data)}
  end

  def self.followed_questions_for_user_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      JOIN questions
        ON questions.id = question_follows.questions_id
      WHERE
        user_id = ?
    SQL
    data.map { |data| Question.new(data)}
  end

  # def self.most_followed_questions(n)
  #   data = QuestionsDatabase.instance.execute(<<-SQL, n)
  #     SELECT
  #       *
  #     FROM
  #       question_follows
  #     JOIN questions
  #       ON questions.id = question_follows.questions_id
  #     GROUP BY questions_id
  #     ORDER BY count(*) desc
  #     LIMIT ?
  #   SQL
  #   # data.map {|data| Question.new(data)}

  # end
  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, title, body, author_id
      FROM
       questions
      JOIN question_follows
        ON questions.id = question_follows.questions_id
      GROUP BY questions_id
      ORDER BY count(*) desc
      LIMIT ?
    SQL
    data.map {|data| Question.new(data)}
  end

  # def initialize(options)
  #   @id = options['id']
  #   @author_id = options['author_id']
  #   @questions_id = options['questions_id']
  #   @parent_id = options['parent_id']
  #   @body = options['body']
  # end

end


class QuestionLike

  def self.likers_for_question_id(questions_id)
    # all users that like the question.
  data = QuestionsDatabase.instance.execute(<<-SQL, questions_id)
    SELECT
      users.id, fname, lname
    FROM
      question_likes
    JOIN  users
      ON question_likes.user_id = users.id
    WHERE
      questions_id = ?
  SQL
  data.map { |data| User.new(data)}
  end

  def self.num_likes_for_question_id(questions_id)
    # num of likes the question.
  data = QuestionsDatabase.instance.execute(<<-SQL, questions_id)
    SELECT
      count(users.id)
    FROM
      question_likes
    JOIN  users
      ON question_likes.user_id = users.id
    WHERE
      questions_id = ?
  SQL
  data.first.values[0]
  end

  def self.liked_questions_for_user_id(user_id)
  data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      
    FROM
      question_likes
    JOIN  users
      ON question_likes.user_id = users.id
    WHERE
      user_id = ?
  SQL
  data.first.values[0]
  end

end
