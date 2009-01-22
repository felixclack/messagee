require 'rubygems'
require 'sinatra'
require 'diddies'
require 'httparty'
#require 'hpricot'
require 'fastercsv'
require 'smtp-tls'

class MessageeCsv
  
  attr_accessor :people
  
  def initialize(file)
    @people = []
    FasterCSV.foreach(file[:filename], :headers => true) do |row|
      @people << [row["First Name"], row["Mobile Phone"], row["Email"]]
    end
  end
  
  def format_mobile_phone_number(number)
    number = "+#{number}"
  end
  
end

class Postie
  include HTTParty
  
  attr_reader :username, :password, :sms_recipients, :message
  
  base_uri "http://www.bulksms.co.uk:5567/eapi"
  
  def initialize(u, p)
    @username = u
    @password = p
  end
  
  def send_message(message, sms_recipients)
    @message = url_escape(message)
    @sms_recipients = sms_recipients.is_a?(Array) ? sms_recipients.join(",") : sms_recipients
    send_sms(@message, @sms_recipients)
  end
  
  def send_sms(message, recipients)
    get("/submission/send_sms/2/2.0", :query => {:username=>@username, :password=>@password, :message=>message, :msisdn=>recipients, :routing_group=>2})
  end
  
  def check_credits
    get("/user/get_credits/1/1.1", :query => {:username=>@username, :password=>@password})
  end
  
  def url_escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
  
end

configure do
  Sinatra::Mailer.config = {
    :host => 'smtp.gmail.com',
    :port => '587',
    :user => 'felixclack@gmail.com',
    :pass => 'anniehall',
    :auth => :plain
  }
  
  require 'ostruct'
  Account = OpenStruct.new(
    :password => "xc3ll3nt",
    :admin_cookie_key => 'messagee_admin',
		:admin_cookie_value => '31x03adsa931'
  )
end

get "/" do
  haml :index
end

post "/" do
  set_cookie(Account.admin_cookie_key, Account.admin_cookie_value) if params[:password] == Account.password
  redirect "/start"
end

get "/start" do
  auth
  haml :start
end

post "/upload" do
  auth
  @messagee = MessageeCsv.new(params[:file])
  haml :upload
end

post "/message" do
  auth
  @go_postal = Postie.new(params[:username], params[:password])
  if params[:email_recipients]
    @email_recipients = params[:email_recipients]
    @email_result = email :to => @email_recipients.is_a?(Array) ? @email_recipients.join(",") : @email_recipients, :from => "info@xcelchurch.com", :subject => "A message from Xcel Church", :text => params[:message]
  end
  @sms_result = @go_postal.send_message(params[:message], params[:sms_recipients]) if params[:sms_recipients]
  haml :message
end

post '/bulksms' do
  auth
  @bulksms = Postie.new(params[:username], params[:password])
  @bulksms_result = @bulksms.check_credits
  haml :bulk
end

get "/master.css" do
  content_type 'text/css', :charset => 'utf-8'
  sass :master
end

helpers do
  def link_to(title, href=nil)
    haml_tag :a, {:href => href} do
      puts title
    end
  end
  
  def admin?
		request.cookies[Account.admin_cookie_key] == Account.admin_cookie_value
	end

	def auth
		stop [ 401, 'Not authorized' ] unless admin?
	end
end