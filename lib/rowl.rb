# Protocol Description: http://growl.info/documentation/developer/protocol.php

require 'digest/md5'
require 'socket'
require 'rubygems'
require 'ruby-debug'

module Rowl
  
  GROWL_UDP_PORT          = 9887
  GROWL_PROTOCOL_VERSION  = 1
  GROWL_TYPE_REGISTRATION = 0
  GROWL_TYPE_NOTIFICATION = 1
  REGISTRATION_FORMAT     = "CCnCCa*"   # Growl Network Registration Packet Format
  NOTIFICATION_FORMAT     = "CCnnnnna*" # Growl Network Notification Packet Format
  
  class Registration
    
    attr_accessor :application, :notifications, :host, :password
    
    def initialize(application, notifications, host="localhost", password=nil)      
      @defaults = []
      @application = application
      @notifications = []
      @password = password
      @host = host

      # Register notifications
      notifications.each do |notification|
        add_notification_type(notification[:name], notification[:enabled])
      end
      
      send_registration
    end
    
    def app_name
      chars = ("a".."z").to_a + ("1".."9").to_a 
      Array.new(8, '').collect{chars[rand(chars.size)]}.join
    end
        
    def add_notification_type(notification, enabled)
      if enabled.nil?
        enabled = true
      end
      @notifications << notification
      if enabled
        @defaults << @notifications.length - 1
      end
    end
  
    def send_registration
      socket = UDPSocket.open
      socket.send(payload, 0, @host, 9887)
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
        :priority => 0, 
        :sticky => false,
        :host => "localhost"
      }.merge(opts)
      
      @application = opts[:application]
      @password = opts[:password]
      @host = opts[:host]
      @notification = opts[:notification]
      @title = opts[:title]
      @description = opts[:description]
      @priority = opts[:priority]
      @sticky = opts[:sticky]
      
      send_notification
    end
    
    def send_notification
      socket = UDPSocket.open
      socket.send(payload, 0, @host, 9887)
    end
    
    def payload
      flags = 0
      data = []
      
      packet = [
        GROWL_PROTOCOL_VERSION,
        GROWL_TYPE_NOTIFICATION,
      ]

      flags = 0
      flags |= ((0x7 & @priority) << 1) # 3 bits for priority
      flags |= 1 if @sticky # 1 bit for sticky

      packet << flags
      packet << @notification.length
      packet << @title.length
      packet << @description.length
      packet << @application.length

      data << @notification
      data << @title
      data << @description
      data << @application

      packet << data.join
      packet = packet.pack(NOTIFICATION_FORMAT)

      if @password
        checksum = Digest::MD5.digest(packet+@password)
      else
        checksum = Digest::MD5.digest(packet)
      end
      
      packet << checksum
      @datagram = packet
    end
    
  end
  
end

if __FILE__ == $0
  registration = Rowl::Registration.new("My Application", [{:name => "My Notification", :enabled => true}, {:name => "My Other Notification Type", :enabled => false}])
  Rowl::Notification.new( :application => registration.application, 
							            :notification => registration.notifications.first,
							            :host => "localhost",
							            :password => registration.password,
							            :title => "Title", 
							            :description => "Description" )
end

