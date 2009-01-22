require 'httparty'

class Bulksms
  include HTTParty
  
  attr_reader :username, :password
  
  base_uri "http://www.bulksms.co.uk:5567/eapi/submission/send_sms/2/2.0"
  
  def initialize(u, p)
    @username = u
    @password = p
  end
  
  def send_sms(message, recipients)
    @message = url_escape(message)
    @recipients = url_escape(recipients)
    self.class.get("?username=#{@username]}&password=#{@password}&message=#{@message)}&msisdn=#{@recipients}")
  end
  
  def url_escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
  
end