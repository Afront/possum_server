require "db"
require "kemal"
require "kemal-session"
require "mysql"

# TODO: Write documentation for `PossumServer`
module PossumServer
  VERSION = "0.1.0"

  # TODO: Put your code here

  Kemal::Session.config do |config|
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes # 2 minutes
  end

  get "/" do
    "Hello World!"
  end

  post "/login" do |env|
    param_hash = env.params.json

    username = param_hash["username"].as(String)
    password = param_hash["password"].as(String)
    env.session.string("username", username) # set the value of "number"
    env.session.string("pasword", password)  # set the value of "number"
    "#{username}'s password is #{password}"
  end

  post "/register" do |env|
    param_hash = env.params.json

    username = param_hash["username"].as(String)
    password = param_hash["password"].as(String)
    env.session.string("username", username) # set the value of "number"
    env.session.string("pasword", password)  # set the value of "number"
    "#{username}'s password is #{password}"
  end

  get

  get "/currencies/physical/{currency}" do |env|
    param_hash = env.params.query
    "Currently not supported."
  end

  get "/currencies/digital/{currency}" do |env|
    param_hash = env.params.query
    "Currently not supported."
  end

  # Creates a WebSocket handler.
  # Matches "ws://host:port/socket"
  DB.open "mysql://no_password@localhost:3306/possum" do |db|
    db.exec "drop table if exists contacts"
    db.exec "create table contacts (name varchar(30), age int)"
    db.exec "insert into contacts values (?, ?)", "John Doe", 30

    args = [] of DB::Any
    args << "Sarah"
    args << 33
    db.exec "insert into contacts values (?, ?)", args: args

    puts "max age:"
    puts db.scalar "select max(age) from contacts" # => 33

    puts "contacts:"
    db.query "select name, age from contacts order by age desc" do |rs|
      puts "#{rs.column_name(0)} (#{rs.column_name(1)})"
      # => name (age)
      rs.each do
        puts "#{rs.read(String)} (#{rs.read(Int32)})"
        # => Sarah (33)
        # => John Doe (30)
      end
    end
  end

  Kemal.run
end
