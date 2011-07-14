class AppConfig
  def self.is?(key, default=false)
    ENV.key?(key) ? truth?(ENV[key]) : default
  end

  def self.set(key, value)
    ENV[key] = value.to_s
  end
  
  def self.truth?(val)
    ['true','yes','on','1'].include? val.to_s.downcase
  end
end