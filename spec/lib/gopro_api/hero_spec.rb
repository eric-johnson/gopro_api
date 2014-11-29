require 'spec_helper'

describe Hero do
  let( :transit ) { Class.new }

  subject {
    described_class.new "abc123", transit
  }

  before :each do
    allow( transit ).to receive( :get )
  end

  operations = {
    :power_on!      => "http://10.5.5.9:80/bacpac/PW?t=abc123&p=%01",
    :power_off!     => "http://10.5.5.9:80/bacpac/PW?t=abc123&p=%00",
    :start_capture  => "http://10.5.5.9:80/camera/SH?t=abc123&p=%01",
    :stop_capture   => "http://10.5.5.9:80/camera/SH?t=abc123&p=%00",
    :start_beep     => "http://10.5.5.9:80/camera/LL?t=abc123&p=%01",
    :stop_beep      => "http://10.5.5.9:80/camera/LL?t=abc123&p=%00",
    :delete_last!   => "http://10.5.5.9:80/camera/DL?t=abc123",
    :next_mode      => "http://10.5.5.9:80/bacpac/PW?t=abc123&p=%02",
    :video_mode     => "http://10.5.5.9:80/camera/CM?t=abc123&p=%00",
    :photo_mode     => "http://10.5.5.9:80/camera/CM?t=abc123&p=%01",
    :burst_mode     => "http://10.5.5.9:80/camera/CM?t=abc123&p=%02",
    :timelapse_mode => "http://10.5.5.9:80/camera/CM?t=abc123&p=%03",
  }

  operations.each do |op,uri|
    it "generates the #{op}" do
      expected_uri = URI( uri )
      subject.send op
      expect( transit ).to have_received( :get ).with( expected_uri )
    end
  end

  timer_seconds = {
    0.5 => "http://10.5.5.9:80/camera/TI?t=abc123&p=%00",
    1   => "http://10.5.5.9:80/camera/TI?t=abc123&p=%01",
    2   => "http://10.5.5.9:80/camera/TI?t=abc123&p=%02",
    5   => "http://10.5.5.9:80/camera/TI?t=abc123&p=%05",
    10  => "http://10.5.5.9:80/camera/TI?t=abc123&p=%0a",
    30  => "http://10.5.5.9:80/camera/TI?t=abc123&p=%1e",
    60  => "http://10.5.5.9:80/camera/TI?t=abc123&p=%3c",
  }

  timer_seconds.each do |seconds, uri|
    it "supports seconds" do
      expected_uri = URI( uri )
      subject.timelapse_seconds( seconds )
      expect( transit ).to have_received( :get ).with( expected_uri )
    end
  end

  it "raises arg error on unsupported time" do
    expect{ subject.timelapse_seconds( 3.14 ) }.to raise_error(ArgumentError)
  end

  describe "#mode" do
    responses = {
      video: "\x00\x00\x00\x01\x00\x02\x00\x00\b\xF3\x00\xFF\x00\x00\x00\x00\x00\x00\x90\x02\x00+\xAA\x03s\x00\xF2\x00\f\x00\x04\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",
      camera: "\x00\x01\x00\x01\x00\x02\x00\x00\b\xF3\x00\xFF\x00\x00\x00\x00\x00\x00\x90\x02\x00\x18\x10\x03s\x00\xF2\x00\f\x00\x04\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",        
    } 

    responses.each do |mode, response|
      it "detects #{mode} mode" do
        uri = URI( "http://10.5.5.9:80/camera/sx?t=abc123")
        allow( transit ).to receive( :get ).with( uri ).
          and_return( response )

        expect( subject.mode ).to eq( mode )
      end
    end
  end

  describe "#capturing?" do
    responses = {
      video_on:  "\x00\x00\x00\x01\x00\x02\x00\x00\b\xF3\x00\xFF\x00\x00\x02\x00\x00\x00\x90\x02\x00+\xA2\x03z\x00\xF1\x00\r\x01\x05\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",
      video_off: "\x00\x00\x00\x01\x00\x02\x00\x00\b\xF3\x00\xFF\x00\x00\x00\x00\x00\x00\x90\x02\x00+\x9C\x03z\x00\xF1\x00\r\x00\x04\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",
      timelapse_on:  "\x00\x03\x00\x01\x00\n\x00\x00\b\xF3\x00\xFF\x00\x00\t\x00\x00\x00\x90\x01\x00\x18\b\x03{\x00\xF1\x00\r\x01\x01\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",
      timelapse_off: "\x00\x03\x00\x01\x00\n\x00\x00\b\xF3\x00\xFF\x00\x00\x00\x00\x00\x00\x90\x01\x00\x18\b\x03z\x00\xF1\x00\r\x00\x04\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x04\x00\x00\x00\x00",
    }

    responses.each do |state, response|
      mode, on = state.to_s.split("_")
      it "detects #{mode} mode when capturing #{on}" do
        uri = URI( "http://10.5.5.9:80/camera/sx?t=abc123")
        allow( transit ).to receive( :get ).with( uri ).
          and_return( response )

        expect( subject.capturing? ).to eq( on == "on" )
      end
    end
  end

end
