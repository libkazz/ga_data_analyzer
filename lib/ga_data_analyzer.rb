require 'active_record'
require 'byebug'
require 'csv'
require_relative 'ga_data_analyzer/diff'
require_relative 'ga_data_analyzer/duration_group'
require_relative 'ga_data_analyzer/file_reader'
require_relative 'ga_data_analyzer/importer'
require_relative 'ga_data_analyzer/line'
require_relative 'ga_data_analyzer/line_parser'

class GaDataAnalyzer
  include Importer

  attr_reader :file

  def self.start(file)
    @instance ||= new(file)
  end

  def initialize(file)
    @file = file

    import!(FileReader.open(file).lines)
  end

  def lines
    Line
  end

  def first_duration
    @first_duration_group ||= DurationGroup.new(duration_names.first)
  end

  def second_duration
    @second_duration_group ||= DurationGroup.new(duration_names.last)
  end

  def diff(&block)
    Diff.compare(block.call(first_duration), block.call(second_duration))
  end

  private

  def duration_names
    @duration_names ||= lines.select('DISTINCT duration').pluck(:duration)
  end
end

if __FILE__ == $PROGRAM_NAME
  file = ARGV[0]

  ga = GaDataAnalyzer.start(file)

  p ga.lines.group(:duration, :page_type).sum(:session)
  p ga.first_duration.name
  p ga.first_duration.lines.first
  p ga.first_duration.lines.group(:page_type).sessions

  puts '==========='


  ga.diff { |d| d.lines.group(:page_type).sessions }.each { |w| p w }
  ga.diff { |d| d.lines.where(page_type: 'area').group(:sub_category).sessions }.sort.each { |w| puts w.to_a.to_csv }
  ga.diff { |d| d.lines.where(page_type: 'area').group(:path3, :sub_category).sessions }.sort.each { |w| p w.to_a }

  exit

  ga.categories_of_type(:area).diff.sort.each { |a| p a }

  ga.categories_of_type(:expense).diff.sort.each { |a| p a }
  ga.paths_of_type(:expense).diff.sort.each { |a| p a }
  ga.paths_of_type(:area, 3).diff.sort_by(&:div).reverse.each { |a| p a }
end
