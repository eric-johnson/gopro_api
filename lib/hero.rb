
HeroCommand = Struct.new(:api, :action, :value)

class Hero
  def initialize io, password
    @io = io
    @password = password
  end

  COMMANDS = {
    power_on!:     HeroCommand.new("bacpac", "PW", "%01"),
    power_off!:    HeroCommand.new("bacpac", "PW", "%00"),
    start_capture: HeroCommand.new("camera", "SH", "%01"),
    stop_capture:  HeroCommand.new("camera", "SH", "%00"),
    start_beep:    HeroCommand.new("camera", "LL", "%01"),
    stop_beep:     HeroCommand.new("camera", "LL", "%00"),
    delete_last!:  HeroCommand.new("camera", "DL"),
  }

  COMMANDS.each do |k, v|
    define_method("#{k}") {
      io.get( uri_for( v.api, v.action, v.value  ) )
    }
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