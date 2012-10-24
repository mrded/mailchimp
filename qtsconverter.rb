#!/usr/bin/env ruby
require 'csv'

class MailChimpConvertor
  attr_accessor :columns

  COLUMNS_HEADER = [
    'career interests',
    'gender',
    'degree_subject',
    # 'university',
    'graduation_year',
    'grade',
    'email',
    'source',
    # 'university',
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
    'Imperial'        => "Imperial College",
    'KCL'             => "King's College London",
    'LSE'             => "London School of Economics",
    'Newcastle'       => "Newcastle University",
    'UCL'             => "University College London",
    'Birmingham'      => "University of Birmingham",
    'Bristol'         => "University of Bristol",
    'Edinburgh'       => "University of Edinburgh",
    'Leeds'           => "University of Leeds",
    'Liverpool'       => "University of Liverpool",
    'Manchester'      => "University of Manchester",
    'Nottingham'      => "University of Nottingham",
    'Oxford'          => "University of Oxford",
    'Southampton'     => "University of Southampton",
    'Cardiff'         => "University of Wales: Cardiff",
    'Warwick'         => "University of Warwick",
    'Cambridge'       => "Cambridge University",
    'Sheffield'       => 'University of Sheffield',
    'Glasgow'         => 'Glasgow University',
    "Queen's Belfast" => "Queen's University Belfast",
    # ''             => 'University of Surrey',
    'Westminster'     => 'University of Westminster',
    'SOAS'         => "SOAS",
    'Non-UK University'   => "University Outside UK",
    'Other UK University' => "Other UK University",
  }
  
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
  
  SURVEYS = {
    '2012-09-20' => 'Redbridge Career Fair',
    '2012-09-26' => 'CASS Careers Fair 2012',
    '2012-09-27' => 'CASS Careers Fair 2012',
    '2012-10-03' => "City's Banking & Finance Fair",
    '2012-10-08' => 'SOAS Business & Management Fair 2012',
    '2012-10-10' => 'Science & Technology Fair',
    '2012-10-11' => 'Careers Fair',
    '2012-10-16' => 'Careers Group Fairs',
    '2012-10-17' => 'University of Westminster',
    '2012-10-23' => 'Southampton Banking, Finance & management',
    
    # '' => 'Careers Fairs Responses',
    # '2012-10-10' => "Liverpool Graduate Fair 2012",
    # '' => 'Surrey University Fair',
    # '' => 'London Graduate Fair 2012',
  }

  def initialize(filename)
    @columns = []
    CSV.read(filename).each do |column|
      
      @columns.push(
        :collect => self.fix_date(column[0]), # @TODO: Convert it here!
        :industry => column[3],
        :gender => column[4],
        :degree => column[5],
        :university => column[6],
        :graduation_year => column[7],
        :grade => column[7], 
        :email => column[8],
        # :source => SURVEYS[], # @TODO: Get source here by collect date.
      )
    end
    
    # p @columns
    # @columns_hash = {}
  end

  def save
    CSV.open("output.csv", "wb") do |csv|
      # csv <<  COLUMNS_HEADER # Add header
      # @TODO: Add Header here!
      
      @columns.each do |column|
        csv << column.values
      end
    end
  end
  
  def fix_date(date)
    Date.parse(date).strftime("%Y-%m-%d") if (date && date != 'Date Collected')
  end
  
  def fix_gender
    @columns.each do |column|
      column[:gender].downcase! if column[:gender]
    end
    self
  end
  
  def fix_grade
    @columns.each do |column|
      value = column[:grade]
      
      if value && GRADES[value]
        column[:grade] = GRADES[value] 
      else
        puts "Grade: '#{value}' key is not exist!"
      end
    end
    self
  end

  def fix_university
    @columns.each do |column|
      value = column[:university]
      
      if value && UNIVERSITIES[value]
        column[:university] = UNIVERSITIES[value] 
      else
        puts "University: '#{value}' key is not exist!"
      end
    end
    self
  end

  def clean
    @columns.each do |column|
      # Delete spaces
      column.each do |key, value|
        value.strip if value
      end

      # Delete unused fields
      # column.delete_at(0)
      # column.delete_at(1)
      # column.delete_at(2)
    end
    
    self
  end
  
  def set_event
    @columns.each do |column|
      if (column[:collect] && SURVEYS[column[:collect]])
        column[:source] = SURVEYS[column[:collect]]
      else
        puts "Survey for '#{column[:collect]}' date doesn't exist!"
      end
    end
    self
  end
  
  def add_event(str)
    @columns.each do |column|
      column.push(str)
    end
    self
  end
  
  def add_university(university)
    @columns.each do |column|
      column.push(university)
    end
    self
  end
  
  def split_industry
    @columns.each do |column|
      # Escaping commas.
      output = []
      INDUSTRIES.each do |industry|
        if column[:industry] && column[:industry].index(industry)
          output += [industry.gsub(/\,/, '\,')] # Replace ',' to '\,'
        end
      end
      
      column[:industry] = output.join(', ')
    end
    self
  end
end

columns = MailChimpConvertor.new(ARGV[0])
# .add_university('University of Surrey')
# .fix_university
# .fix_gender
# .add_event

columns
  .split_industry
  .fix_grade
  .fix_gender
  .set_event
  .clean # Do clearing at end only. Because it deletes keys.
  .save

