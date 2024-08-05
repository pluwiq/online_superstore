# frozen_string_literal: true

require 'pg'

class DBConnection
  attr_reader :conn

  def initialize
    @conn = PG.connect(dbname: ENV.fetch('DB_NAME'), user: ENV.fetch('DB_USER'), password: ENV.fetch('DB_PASSWORD'))
  end

  def exec_params(query:, params: [])
    @conn.exec_params(query, params)
  end

  def exec(query:)
    @conn.exec(query)
  end

  def self.with_connection
    db = new
    yield db.conn
  ensure
    db.conn.close if db.conn
  end
end
