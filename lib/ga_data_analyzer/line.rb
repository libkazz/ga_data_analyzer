class GaDataAnalyzer
  class Line < ActiveRecord::Base
    class << self
      def sessions
        sum(:session)
      end
    end

    self.table_name = 'ga_lines'
  end
end
