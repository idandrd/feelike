require_relative './database'
require 'telegram/bot'
require 'tempfile'
require 'gruff'

module Mood
  class TelegramHandler

    def self.send_question(message:)
      # See more: https://core.telegram.org/bots/api#replykeyboardmarkup

      kb = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '5', callback_data: '5'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '4', callback_data: '4'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '3', callback_data: '3'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '2', callback_data: '2'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '1', callback_data: '1'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '0', callback_data: '0'),
      ]
      answers = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)       

      self.perform_with_bot do |bot|
        for chat in Mood::Database.database[:chats].all
          begin
            bot.api.send_message(
              chat_id: chat[:chat_id],
              text: message,
              reply_markup: answers
            )
           rescue
            # Do nothing
          end
        end
      end
    end

    def self.send_message(message:)
      success_count = 0
      error_count = 0

      self.perform_with_bot do |bot|
        for chat in Mood::Database.database[:chats].all
          begin
            bot.api.send_message(
              chat_id: chat[:chat_id],
              text: message
            )
            success_count = success_count + 1
           rescue
            error_count = error_count + 1
          end
        end
      end

      return success_count, error_count
    end


    def self.listen
      self.perform_with_bot do |bot|
        bot.listen do |message|
          case message
          when Telegram::Bot::Types::CallbackQuery
            user_input = message.data
            this_chat_id = message.from.id
          when Telegram::Bot::Types::Message  
            user_input = message.text
            this_chat_id = message.chat.id
          end

#          begin
#            self.add_chat_id(this_chat_id)
#            bot.api.send_message(chat_id: message.from.id, text: "Received " + user_input.to_s)          
#          rescue
            #do nothing
#          end
          
          begin
            if user_input.to_s.to_i > 0 || user_input.to_s.strip.start_with?("0")
              # As 0 is also a valid value
              rating = user_input.to_i

              if rating >= 0 && rating <= 5
                Mood::Database.database[:moods].insert({
                  time: Time.now,
                  chat_id: this_chat_id,
                  value: rating
                })
                bot.api.send_message(chat_id: this_chat_id, text: "Got it! ("+rating.to_s+") It's marked in the books 📚")

                if rating <= 1
                  bot.api.send_message(chat_id: this_chat_id, text: "Feeling down sometimes is okay. Maybe take 2 minutes to reflect on why you're not feeling better, and optionally add a /note")
                  bot.api.send_message(chat_id: this_chat_id, text: "Sending hugs 🤗🤗🤗")
                end

                if rating == 5
                  bot.api.send_message(chat_id: this_chat_id, text: "💫 Awesome to hear, maybe take 2 minutes to reflect on why you're feeling great, and optionally add a /note")
                end
              else
                bot.api.send_message(chat_id: this_chat_id, text: "Only values from 0 to 5 are allowed")
              end
            else
              self.handle_input(bot, message)
            end          
          #rescue
            # Do nothing
          end
        end
      end 
    end 
        
  #        end
#          when Telegram::Bot::Types::Message
 #           self.add_chat_id(message.chat.id)

 #           if message.text.to_s.to_i > 0 || message.text.to_s.strip.start_with?("0")
              # As 0 is also a valid value
 #             rating = message.text.to_i

  #            if rating >= 0 && rating <= 5
  #              Mood::Database.database[:moods].insert({
   #               time: Time.at(message.date),
    #              chat_id: message.chat.id,
     #             value: rating
      #          })
       #         bot.api.send_message(chat_id: message.chat.id, text: "Got it! It's marked in the books 📚")

#                if rating <= 1
 #                 bot.api.send_message(chat_id: message.chat.id, text: "Feeling down sometimes is okay. Maybe take 2 minutes to reflect on why you're not feeling better, and optionally add a /note")
  #                bot.api.send_message(chat_id: message.chat.id, text: "Sending hugs 🤗🤗🤗")
   #             end
#
 #               if rating == 5
  #                bot.api.send_message(chat_id: message.chat.id, text: "💫 Awesome to hear, maybe take 2 minutes to reflect on why you're feeling great, and optionally add a /note")
   #             end
    #          else
     #           bot.api.send_message(chat_id: message.chat.id, text: "Only values from 0 to 5 are allowed")
      #        end
       #     else
        #      self.handle_input(bot, message)
   #         end
    #      end
     #     rescue
            # Do nothing
  #        end

    def self.handle_input(bot, message)
      kb = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '5: pumped, energized 🤩', callback_data: '5'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '4: happy, excited 😁', callback_data: '4'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '3: good, alright 🙂', callback_data: '3'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '2: down, worried 😕', callback_data: '2'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '1: Sad, unhappy ☹️', callback_data: '1'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: '0: Miserable, nervous 😫', callback_data: '0'),
      ]
      answers = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)     

      case message.text
        # when "/stats"
        #   avg = Mood::Database.database[:moods].where(:chat_id => message.chat.id).avg(:value).to_f.round(2)
        #   total_moods = Mood::Database.database[:moods].where(:chat_id => message.chat.id).count
        #   first_mood = Mood::Database.database[:moods].where(:chat_id => message.chat.id).first[:time]
        #   number_of_months = (Time.now - first_mood) / 60.0 / 60.0 / 24.0 / 30.0
        #   average_number_of_moods = (total_moods / number_of_months) / 30.0

        #   bot.api.send_message(chat_id: message.chat.id, text: "The average mood is: #{avg}")
        #   bot.api.send_message(chat_id: message.chat.id, text: "Total tracked moods: #{total_moods}")
        #   bot.api.send_message(chat_id: message.chat.id, text: "Number of months tracked: #{number_of_months.round(1)}")
        #   bot.api.send_message(chat_id: message.chat.id, text: "Averaging #{average_number_of_moods.round(1)} per day")
        when "/start"
          bot.api.send_message(chat_id: message.chat.id, reply_markup: answers, text: "🙋‍♂️ Welcome to feelike! 🙋‍♀️\nI will help you keep track of your mood.\nThree times a day I will ask you how do you feel at the moment.\nYou can use my special moods keyboard or just type in a 0-5 number (5 being the happiest).\nWhen you want to see your progress just send me '/graph'\n🦋\nSo let's give it a try! how do you feel like right now?")
        when "/graph"
          file = Tempfile.new("graph")
          file_path = "#{file.path}.png"
          moods = Mood::Database.database[:moods].where(:chat_id => message.chat.id)

          g = Gruff::Line.new
          g.title = "Your mood"
          g.hide_legend = true
          g.no_data_message = "There is no data"
          g.reference_lines[:minimum]  = { :value => 0, :color => "red" }
          g.reference_lines[:maximum]  = { :value => 5, :color => "green" }
          # g.reference_lines[:horiz_one] = { :index => 1, :color => 'green' }
          labels_arr = moods.each_with_index.map { |m,i| [i, m[:time]] }
          g.labels = labels_arr.to_h
          g.data(:mood, moods.collect { |m| m[:value] })
          g.write(file_path)

          bot.api.send_photo(
            chat_id: message.chat.id, 
            photo: Faraday::UploadIO.new(file_path, 'image/png')
          )
        when "/notes"
          Mood::Database.database[:notes].where(:chat_id => message.chat.id).each do |n|
            bot.api.send_message(chat_id: message.chat.id, text: "#{n[:time].strftime("%Y-%m-%d")}: #{n[:note]}")
          end
        when /\/note\ /
          note_content = message.text.split("/note ").last
          Mood::Database.database[:notes].insert({
            time: Time.at(message.date),
            chat_id: message.chat.id,
            note: note_content
          })
          bot.api.send_message(chat_id: message.chat.id, text: "Got it! I'll forever remember this note for you 📚")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Sorry, I don't understand what you're saying, #{message.from.first_name}")
        end
    end

    def self.perform_with_bot
      # https://github.com/atipugin/telegram-bot-ruby
      yield self.client
    rescue => ex
      puts "error sending the telegram notification"
      puts ex
      puts ex.backtrace
    end

    def self.client
      return @client if @client
      raise "No Telegram token provided on `TELEGRAM_TOKEN`" if token.to_s.length == 0
      @client = ::Telegram::Bot::Client.new(token)
    end

    def self.add_chat_id(chat_id)
      begin
        Mood::Database.database[:chats].insert(:chat_id => chat_id)
      rescue
        # Do nothing
      end
    end

    def self.token
      ENV["TELEGRAM_TOKEN"]
    end
  end
end