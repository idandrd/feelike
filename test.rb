# require 'telegramAPI'
require_relative "./telegram_handler"

# token = "693114275:AAGEMEqduI70tyPDF1B_DSDklzVgQQDh5I4"
# api = TelegramAPI.new(token)
# bot = api.getChats()
# p bot
# puts bot

Mood::TelegramHandler.send_weekly_report