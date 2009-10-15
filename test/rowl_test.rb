require 'test_helper'

class RowlTest < Test::Unit::TestCase
  context "A Rowl instance" do
  
    setup do
      @registration = Rowl::Registration.new("My Application", [{:name => "My Notification", :enabled => true}, {:name => "My Other Notification Type", :enabled => false}])
    end
    
    should "have registered" do
      assert_not_nil @registration
    end
    
    should "be able to send a notifcation as a registered application" do
      assert_not_nil Rowl::Notification.new( :application => @registration.application, 
    							            :notification => @registration.notifications.first,
    							            :host => "localhost",
    							            :password => @registration.password,
    							            :title => "Title", 
    							            :description => "Description" )
    end
    
  end
end
