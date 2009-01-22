require 'hpricot'
require 'fastercsv'

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