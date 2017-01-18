class GaDataAnalyzer
  class FileReader
    class << self
      def open(file)
        new(file)
      end
    end

    def initialize(file)
      @file = file
      @body ||= []
      @header ||= []

      File.open(@file).each do |line|
        case line
        when /^#/
          # skip
        when /^$/
          if @body.length > 0
            return true
          else
            # skip
          end
        else
          if @header.length > 0
            @body << CSV.parse(line).first
          else
            @header << CSV.parse(line).first
          end
        end
      end
    end

    def lines
      @body
    end
  end
end
