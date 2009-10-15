Rowl
====
Rowl is a simple [Growl] notifcation sender for Ruby.

Installation
============

As a RubyGem
	
	sudo gem install rowl
	
Since Rowl is tiny (and has no dependencies), you may just want to drop it into an existing project

	git clone git://github.com/jasonmadigan/rowl
	mv rowl/lib/rowl.rb <location>

Then require it

	require 'rowl'
	
Usage
=====

Before using Rowl, it's probably worth noting some things:

* Applications need to register themselves with Growl before they can send notifications
* Applications can have a number of different types of notifications associated with them
* Registration requires you to include any types of notifications you'll wish to use later on
* These notification types are user configurable - they can be enabled/disabled, styled etc. how a user wants
* You only need to send a register your application once, but you'll want to store the application name you registered, along with any notification types, for future reference

So, sending a notification is a little more involved than it might first seem. This reason why the API here is a little less terse than I'd like. Anyway.

Load it (as a gem)

	require 'rubygems'
	require 'rowl'
	
Use it like so
	
	registration = Rowl::Registration.new("My Application", [{:name => "My Notification", :enabled => true}, {:name => "My Other Notification Type", :enabled => false}])
	Rowl::Notification.new( :application => registration.application, 
								            :notification => registration.notifications.first,
								            :host => "localhost",
								            :password => registration.password,
								            :title => "Title", 
								            :description => "Description" )
							
Patches, Bugs & Hatemail
========================

* Feel free to fork the project and send me a pull request with any changes if you come any bugs or general nastiness
* All that I ask is that you don't touch the rakefile, version, or history (I'll update these and push out gem updates)
* Tests would be nice, but I'm not going to reject a perfectly good fix if they're missing

Copyright & Licensing
=====================
Copyright (c) 2009 Jason Madigan. MIT license, see LICENSE for details.

[Growl]: http://growl.info
