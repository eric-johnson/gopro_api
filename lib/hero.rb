class Hero
  def initialize io, password
    @io = io
    @password = password
  end

  def power_on!
    @io.get( URI("http://10.5.5.9:80/bacpac/PW?t=#{@password}&p=%01") )
  end
end
