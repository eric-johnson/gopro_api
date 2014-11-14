class Hero
  def initialize io, password
    @io = io
    @password = password
  end

  def power_on!
    io.get( URI("http://10.5.5.9:80/bacpac/PW?t=#{@password}&p=%01") )
  end

  def power_off!
    io.get( URI("http://10.5.5.9:80/bacpac/PW?t=#{@password}&p=%00") )
  end

  def start_capture
    io.get( URI("http://10.5.5.9:80/camera/SH?t=#{@password}&p=%01") )
  end

  def stop_capture
    io.get( URI("http://10.5.5.9:80/camera/SH?t=#{@password}&p=%00") )
  end

  def start_beep
    io.get( URI("http://10.5.5.9:80/camera/LL?t=#{@password}&p=%01") )
  end

  def stop_beep
    io.get( URI("http://10.5.5.9:80/camera/LL?t=#{@password}&p=%00") )
  end

  def delete_last!
    io.get( URI("http://10.5.5.9:80/camera/DL?t=#{@password}") )
  end

  private

  def io
    @io
  end
end
