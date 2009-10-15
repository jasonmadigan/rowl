# Protocol Description: http://growl.info/documentation/developer/protocol.php

require 'digest/md5'
require 'socket'

module Rowl
  
  GROWL_UDP_PORT          = 9887
  GROWL_PROTOCOL_VERSION  = 1
  GROWL_TYPE_REGISTRATION = 0
  GROWL_TYPE_NOTIFICATION = 1
  REGISTRATION_FORMAT     = "CCnCCa*"   # Growl Network Registration Packet Format
  NOTIFICATION_FORMAT     = "CCnnnnna*" # Growl Network Notification Packet Format
  
  class Registration
    def initialize(application = "growlnotify", password = nil)
      @notifications = []
      @defaults = []
      @application = application
      @password = password
    end
    
    def add_notification(notification = "Command-Line Growl Notification", enabled = true)
      @notifications << notification
      if enabled
        @defaults << @notifications.length - 1
      end
    end
    
    def payload
      length = 0
      data = []
      data_format = ""
      
      packet = [
        GROWL_PROTOCOL_VERSION, 
        GROWL_TYPE_REGISTRATION
      ]
      
      packet << @application.length
      packet << @notifications.length
      packet << @defaults.length
      
      data << @application
      data_format = "a#{@application.length}"
      
      @notifications.each do |notify|
        data << notify.length
        data << notify
        data_format << "na#{notify.length}"
      end
      
      @defaults.each do |notify|
        data << notify
        data_format << "C"
      end
      
      data = data.pack(data_format)
      
      packet << data
      packet = packet.pack(REGISTRATION_FORMAT)
            
      if @password
        checksum = Digest::MD5.digest(packet+@password)
      else
        checksum = Digest::MD5.digest(packet)
      end
      
      packet << checksum
      
      return packet
    end
  end
  
  class Notification
    def initialize(opts={})
      opts = {
        :application => "growlnotify",
        :notification => "Command-Line Growl Notification",
        :title => "Title",
        :description => "Description",
        :priority => 0, 
        :sticky => false, 
        :password => false
      }.merge(opts)
      
      flags = 0
      data = []
      
      packet = [
        GROWL_PROTOCOL_VERSION,
        GROWL_TYPE_NOTIFICATION,
      ]

      flags = 0
      flags |= ((0x7 & opts[:priority]) << 1) # 3 bits for priority
      flags |= 1 if opts[:sticky] # 1 bit for sticky

      packet << flags
      packet << opts[:notification].length
      packet << opts[:title].length
      packet << opts[:description].length
      packet << opts[:application].length

      data << opts[:notification]
      data << opts[:title]
      data << opts[:description]
      data << opts[:application]

      packet << data.join
      packet = packet.pack(NOTIFICATION_FORMAT)

      if opts[:password]
        checksum = Digest::MD5.digest(packet+opts[:password])
      else
        checksum = Digest::MD5.digest(packet)
      end
      
      packet << checksum
      @datagram = packet
    end
    
    def payload
      return @datagram
    end
  end
  
end
