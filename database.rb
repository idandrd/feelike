require "sequel"

module Mood
  class Database
    def self.database
      @_db ||= Sequel.connect(ENV["DATABASE_URL"])

      unless @_db.table_exists?("moods")
        @_db.create_table :moods do
          primary_key :id
          Integer :chat_id
          DateTime :time
          Integer :value
        end
      end

      unless @_db.table_exists?("notes")
        @_db.create_table :notes do
          primary_key :id
          Integer :chat_id
          DateTime :time
          String :note
        end
      end

      unless @_db.table_exists?("chats")
        @_db.create_table :chats do
          primary_key :id
          Integer :chat_id, :unique => true
        end
      end

      return @_db
    end
  end
end