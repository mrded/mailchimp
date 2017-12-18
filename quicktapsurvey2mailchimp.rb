#!/usr/bin/env ruby
require 'csv'

class MailChimpConverter
  attr_accessor :columns

  COLUMNS_HEADER = {
    :email => 'Email Address',
    :industry => 'Career interests',
    :graduation_year => 'Graduation year',
    :source => 'Source',
  }

  def initialize(options = {})
    @files = options[:files]
    @columns = []
    options[:files].each { |file| fill(file) }
  end

  def save
    CSV.open("output.csv", "wb") do |csv|
      # Add header
      csv << COLUMNS_HEADER.values

      @columns.each { |column| csv << column.values }
    end
  end

  private
  def fill(file)
    CSV.read(file).each do |column|
      email = column[5]

      @columns.push(
        :email => email,
        :industry => fix_industry(column[3]),
        :graduation_year => column[4],
        :source => File.basename(file, ".csv"),
      ) if email_is_valid?(email)
    end
  end

  def email_is_valid?(email)
    !/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/.match(email).nil?
  end

  def fix_industry(value)
    # Escaping commas.
    industries = []
    CSV.parse_line(value).each do |industry|
      industries += [industry.gsub(/\,/, '\,')] # Replace ',' to '\,'
    end

    return industries.join(', ')
  end
end

MailChimpConverter.new(files: ARGV).save
