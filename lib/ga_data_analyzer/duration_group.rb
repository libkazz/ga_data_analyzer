class GaDataAnalyzer
  class DurationGroup
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def lines
      Line.where(duration: name)
    end

    def duration
      name.split(/-/).map(&:strip)
    end
  end
end
