# frozen_string_literal: true

require 'pg'

class DBConnection
  attr_reader :conn

  def initialize
    @conn = PG.connect(dbname: ENV['DB_NAME'], user: ENV['DB_USER'], password: ENV['DB_PASSWORD'])
  end

  def exec_params(query:, params: [])
    @conn.exec_params(query, params)
  end

  def exec(query:)
    @conn.exec(query)
  end
end
