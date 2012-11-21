#!/usr/bin/env ruby
require 'csv'

class MailChimpConvertor
  attr_accessor :columns

  COLUMNS_HEADER = {
    :industry => 'career interests',
    :graduation_year => 'graduation_year',
    :email => 'email',
    :source => 'source',
    :university => 'university',
  }

  INDUSTRIES = [
    'Accounting, Auditing, Tax',
    'Advertising, Marketing & Public Relations',
    'Banking & Financial Services, Trading',
    'Education & Teaching',
    'Engineering',
    'Human Resources',
    'Insurance & Actuarial',
    'IT & Telecomunications',
    'Law & Legal',
    'Management Consulting',
    'Public Sector & Civil Service',
    # 'Government, Public Sector & Civil Service',
    'Recruitment & Sales',
    'Retail, Buying & FMCG',
    'Science & Research',
  ]
  
  GRADES = {
    '1st'         => 'First',
    '2:1'         => 'Upper Second',
    '2:2'         => 'Lower Second',
    '3rd'         => 'Third',
    'Distinction' => 'Masters/PhD',
    'Pass'        => 'Masters/PhD',
    'Merit'       => 'Masters/PhD',
    'Other'       => 'Other',
  }
  
  def initialize(filename, source = '', university = '')
    @columns = []
    CSV.read(filename).each do |column|
      
      @columns.push(
        :industry => self.fix_industry(column[3]),
        :graduation_year => column[4],
        :email => column[5],
        :source => source,
        :university => university,
      )
    end
  end

  def save
    CSV.open("output.csv", "wb") do |csv|
      # COLUMNS_HEADER.delete(:collect)
      csv << COLUMNS_HEADER.values
      
      @columns.each do |column|
        # column.delete(:collect)
        csv << column.values
      end
    end
  end
    
  def fix_industry(value)
    # Escaping commas.
    output = []
    INDUSTRIES.each do |industry|
      if value && value.index(industry)
        output += [industry.gsub(/\,/, '\,')] # Replace ',' to '\,'
      end
    end
    
    return output.join(', ')
  end
  
end

csv_file = ARGV[0]
source = ARGV[1]
university = ARGV[2]

columns = MailChimpConvertor.new(csv_file, source, university)
columns.save

