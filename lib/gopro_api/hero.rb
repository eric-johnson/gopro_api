class Hero

  Command = Struct.new(:api, :action, :value)

  def initialize( password, io=nil )
    require 'net/http' unless io
    @io = io || ::Net::HTTP

    @password = password
  end

  COMMANDS = {
    power_on!:      Command.new("bacpac", "PW", "%01"),
    power_off!:     Command.new("bacpac", "PW", "%00"),
    start_capture:  Command.new("camera", "SH", "%01"),
    stop_capture:   Command.new("camera", "SH", "%00"),
    start_beep:     Command.new("camera", "LL", "%01"),
    stop_beep:      Command.new("camera", "LL", "%00"),
    delete_last!:   Command.new("camera", "DL"),
    next_mode:      Command.new("bacpac", "PW", "%02"),
    video_mode:     Command.new("camera", "CM", "%00"),
    photo_mode:     Command.new("camera", "CM", "%01"),
    burst_mode:     Command.new("camera", "CM", "%02"),
    timelapse_mode: Command.new("camera", "CM", "%03"),
  }

  COMMANDS.each do |k, v|
    define_method("#{k}") {
      io.get( uri_for( v.api, v.action, v.value  ) )
    }
  end

  TIMELAPSE_SECONDS = {
    0.5 => "00",
    1   => "01",
    2   => "02",
    5   => "05",
    10  => '0a',
    30  => '1e',
    60  => '3c',
  }

  def timelapse_seconds( seconds )
    arg = TIMELAPSE_SECONDS[seconds]
    raise ArgumentError.new("Only supports #{TIMELAPSE_SECONDS.keys}") unless arg

    io.get( uri_for( "camera", "TI", "%#{arg}" ) )
  end

  def on?
    io.get( uri_for( "bacpac", "se" ) )[15] == "\x01"
  end

  MODE_BYTE = {
    video:  "\x00",
    camera: "\x01",
    burst:  "\x02",
    timelapse: "\x03",
  }

  def mode
    response = io.get( uri_for( "camera", "sx" ) )
    MODE_BYTE.key( response[1] )
  end

  def capturing?
    io.get( uri_for( "camera", "sx" ) )[29] == "\x01"
  end

  private

  def io
    @io
  end

  def uri_for( api, action, value=nil )
    p_param = value ? "&p=#{value}" : ""
    URI( "http://10.5.5.9:80/#{api}/#{action}?t=#{@password}#{p_param}" )
  end
end