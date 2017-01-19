$: << './lib'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'ga_data_analyzer'
file = $ARGV[0]

# Usage
#   % ruby app.rb some_file.csv
#
# And access i.e.
#   http://localhost:4567/?group=path3&where[page_type]=area&where[sub_category]=kitchen&where[sub_category]=bathroom
#

get '/' do
	valid_sort_key = %w(key first second delta div)
  @ga = GaDataAnalyzer.start(file)
  @where = params[:where]
  @group = params[:group] || 'sub_category'
	@sort = 'delta'
  @sort_direction = 'desc'

  @diffs = @ga.diff { |d| d.lines.where(@where).group(@group).sessions }
              .sort_by { |d| d.send(@sort) * (@sort_direction =~ /\Aasc\z/i ? 1 : -1) }

  erb :index
end

get '/style.css' do
  content_type 'text/css', charset: 'utf-8'
  sass :style
end
