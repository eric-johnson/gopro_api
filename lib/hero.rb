
HeroCommand = Struct.new(:api, :action, :value)

class Hero
  def initialize( password, io=nil )
    require 'net/http' unless io
    @io = io || ::Net::HTTP
    
    @password = password
  end

  COMMANDS = {
    power_on!:      HeroCommand.new("bacpac", "PW", "%01"),
    power_off!:     HeroCommand.new("bacpac", "PW", "%00"),
    start_capture:  HeroCommand.new("camera", "SH", "%01"),
    stop_capture:   HeroCommand.new("camera", "SH", "%00"),
    start_beep:     HeroCommand.new("camera", "LL", "%01"),
    stop_beep:      HeroCommand.new("camera", "LL", "%00"),
    delete_last!:   HeroCommand.new("camera", "DL"),
    next_mode:      HeroCommand.new("bacpac", "PW", "%02"),
    video_mode:     HeroCommand.new("camera", "CM", "%00"),
    photo_mode:     HeroCommand.new("camera", "CM", "%01"),
    burst_mode:     HeroCommand.new("camera", "CM", "%02"),
    timelapse_mode: HeroCommand.new("camera", "CM", "%03"),
  }

  COMMANDS.each do |k, v|
    define_method("#{k}") {
      io.get( uri_for( v.api, v.action, v.value  ) )
    }
  end

  # order matters
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

  private

  def io
    @io
  end

  def uri_for( api, action, value=nil )
    p_param = value ? "&p=#{value}" : ""
    puts( "http://10.5.5.9:80/#{api}/#{action}?t=#{@password}#{p_param}" )
    URI( "http://10.5.5.9:80/#{api}/#{action}?t=#{@password}#{p_param}" )
  end
end