class Hero
  def initialize io, password
    @io = io
    @password = password
  end

  def power_on!
    io.get( uri_for( "bacpac", "PW", "%01" ) )
  end

  def power_off!
    io.get( uri_for( "bacpac", "PW", "%00" ) )
  end

  def start_capture
    io.get( uri_for( "camera", "SH", "%01" ) )
  end

  def stop_capture
    io.get( uri_for( "camera", "SH", "%00" ) )
  end

  def start_beep
    io.get( uri_for( "camera", "LL", "%01" ) )
  end

  def stop_beep
    io.get( uri_for( "camera", "LL", "%00" ) )
  end

  def delete_last!
    io.get( uri_for( "camera", "DL" ) )
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
