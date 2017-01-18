class GaDataAnalyzer
  class Diff
    class << self
      def compare(first, last)
        first.keys.map { |key| GaDataAnalyzer::Diff.new(key, first[key], last[key]) }
      end
    end

    attr_reader :key, :first, :second

    def initialize(key, first, second)
      @key = key
      @first = first
      @second = second
    end

    def values
      [first, second]
    end

    def div
      first.to_f / second
    end

    def div_p
      (div * 100).round(2)
    end

    def delta
      first - second
    end

    def <=>(other)
      other.delta - delta
    end

    def inspect
      "#{key} => [#{first}, #{second}, #{delta}, #{div_p}%]"
    end

    def to_a
      [*key, first, second, delta, div]
    end
  end
end
