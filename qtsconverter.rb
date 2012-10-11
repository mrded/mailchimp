#!/usr/bin/env ruby
require 'csv'

class MailChimpConvertor
  attr_accessor :columns, :event
  
  INDUSTRY_KEY = 3
  
  COLUMNS_HEADER = [
    'unused1',
    'unused2',
    'unused3',
    'career interests', 
    'gender', 
    'degree_subject', 
    'university', 
    'graduation_year', 
    'grade', 
    'email', 
    'source'
  ]
  
  INDUSTRIES = [
    'Accounting, Auditing, Tax',
    'Banking & Financial Services, Trading',
    'Education & Teaching',
    'Engineering',
    'Insurance & Actuarial',
    'IT & Telecomunications',
    'Law & Legal',
    'Management Consulting',
    'Public Sector & Civil Service',
    'Recruitment & Sales',
    'Retail, Buying & FMCG',
    'Science & Research',
  ]
  
  UNIVERSITIES = {
    'Imperial'     => "Imperial College",
    'KCL'          => "King's College London",
    # 'LSE'          => "",
    'Newcastle'    => "Newcastle University",
    'UCL'          => "University College London",
    'Birmingham'   => "University of Birmingham",
    'Bristol'      => "University of Bristol",
    # ''             => "University of Edinburgh",
    'Leeds'        => "University of Leeds",
    # ''             => "University of Liverpool",
    'Manchester'   => "University of Manchester",
    # ''             => "University of Nottingham",
    # ''             => "University of Oxford",
    'Southampton'  => "University of Southampton",
    'Cardiff'      => "University of Wales: Cardiff",
    'Warwick'      => "University of Warwick",
    'Non-UK University'   => "University Outside UK",
    'Other UK University' => "Other UK University",
  }
  
  def initialize(filename, event = 'new event')
    @columns = CSV.read(filename)
    @event = event
  end
  
  def save
    # Create dir
    directory_name = Dir::pwd + "/output"
    Dir::mkdir(directory_name) if !FileTest::directory?(directory_name)
    
    # Save files
    INDUSTRIES.each do |industry|
      file_name = industry.gsub(/\W/, '') + ".csv"
      file_path = directory_name + "/" + file_name
      
      CSV.open(file_path, "wb") do |csv|
        csv <<  COLUMNS_HEADER # Add header
        
        @columns.each do |column|
          csv << column if (column[INDUSTRY_KEY] == industry)
        end
      end
    end
  end
  
  def fix_university(str)
    if UNIVERSITIES[str] 
      UNIVERSITIES[str]
    else
      puts "university: '#{str}' key is not exist!" 
    end
  end
  
  def clean
    @columns.each_with_index do |column, x|
      column.each_with_index do |row, y|
        @columns[x][y] = row.is_a?(CSV::Cell) ? row.strip : nil
      end
      
      column[6] = self.fix_university(column[6]) if column[6]
      
      # Delete unused fields
      column[0] = nil
      column[1] = nil
      column[2] = nil
      
      # Male field is downcase
      column[4] = column[4].downcase if column[4]
    end
    self
  end
    
  def split_industry(industry_list)
    output = []
    
    INDUSTRIES.each do |industry|
      if industry_list && industry_list.index(industry)
        output += [industry]
      end
    end
    
    output
  end
  
  def add_event
    @columns.each do |column|
      column.push(@event)
    end
    self
  end
    
  def split
    new_columns = []
    
    @columns.each do |column|
      self.split_industry(column[INDUSTRY_KEY]).each do |industry|
        column[INDUSTRY_KEY] = industry
        new_columns.push(column.clone)
      end
    end
    
    @columns = new_columns
    self
  end
end

columns = MailChimpConvertor.new(ARGV[0], ARGV[1])
columns.clean.split.add_event.save
