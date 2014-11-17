require 'spec_helper'

describe Hero do
  let( :transit ) { Class.new }

  subject {
    described_class.new transit, "abc123"
  }

  before :each do
    allow( transit ).to receive( :get )
  end

  operations = {
    :power_on!     => "http://10.5.5.9:80/bacpac/PW?t=abc123&p=%01",
    :power_off!    => "http://10.5.5.9:80/bacpac/PW?t=abc123&p=%00",
    :start_capture => "http://10.5.5.9:80/camera/SH?t=abc123&p=%01",
    :stop_capture  => "http://10.5.5.9:80/camera/SH?t=abc123&p=%00",
    :start_beep    => "http://10.5.5.9:80/camera/LL?t=abc123&p=%01",
    :stop_beep     => "http://10.5.5.9:80/camera/LL?t=abc123&p=%00",
    :delete_last!  => "http://10.5.5.9:80/camera/DL?t=abc123"
  }

  operations.each do |op,uri|
    it "generates the #{op}" do
      expected_uri = URI(uri)
      subject.send op
      expect( transit ).to have_received( :get ).with( expected_uri )
    end
  end

end
