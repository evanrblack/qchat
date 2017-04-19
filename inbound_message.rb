#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'securerandom'
require 'dotenv'

Dotenv.load('.env.development')

abort 'Requires [FROM] [TO] [TEXT]' unless ARGV.length == 3
from, to, text = ARGV
token = ENV['WEBHOOK_TOKEN']
message_id = "fake-#{SecureRandom.urlsafe_base64}"

Net::HTTP.start('localhost', 3000) do |http|
  params = {
    eventType: 'sms',
    direction: 'in',
    messageId: message_id,
    from: from,
    to: to,
    text: text,
    state: 'sent'
  }

  http.post "/messages?token=#{token}", params.to_json, 
            { 'Content-Type' => 'application/json' } 
end

