require 'test_helper'

class RowlTest < Test::Unit::TestCase
  context "A Rowl instance" do
  
    setup do
      @rowl   = Rowl::Registration.new
      @rowl.add_notification()
      @socket = UDPSocket.open
    end
    
    should "have a socket" do
      assert_not_nil @socket
    end
    
    should "be able to register" do
      assert_not_nil @socket.send(@rowl.payload, 0, "localhost", 9887)
    end
    
    should "be able to send a notifcation as a registered application" do
      assert_not_nil notification = Rowl::Notification.new(:title => "testy", :description => "description")
      assert_not_nil @socket.send(notification.payload, 0, "localhost", 9887)
    end
    
  end
end
