class GaDataAnalyzer
  class LineParser
    SUB_CATEGORIES = %w(
      ac-cleaning
      ac-office-work
      ac-work
      antena-work
      barrier-free
      bath-leak
      bathroom
      carpenter-work
      carpet-floor
      carport
      caulking
      cooking-stove
      door-exchange
      ecocute
      electric-office-work
      electric-work
      exterior-etc
      extractor-fan
      extractor-fan-cleaning
      faucet-exchange
      fence
      fit-up
      floor-coating
      floor-heating
      gardening
      gas-piping
      gas-water-heater
      gate
      house-cleaning
      house-cloth
      house-dismantling
      house-etc
      house-inspection
      ih
      interior-work
      key-exchange
      kitchen
      kitchen-leak
      landscaping-work
      leak-etc
      office-etc
      office-interior
      padded-floor
      patio-door
      pest-etc
      pv
      quake-resistant
      rats
      renovation
      restoring-office
      roof
      roof-painting
      room-arrangement
      room-painting
      shelf
      shoji
      shutter
      signboard
      sound-isolation-work
      tatami
      termite
      toilet
      toilet-leak
      wall-cleaning
      wall-painting
      wallpaper-replacing
      washroom
      water-etc
      waterworks
      window-glass
      wooddeck
      wooden-floor
      work-etc
    )

    class << self
      def parse(line)
        self.new(line)
      end
    end

    def initialize(line)
      @line = line
    end

    def to_query
      line_to_array.map { |value| "'#{value}'" }.join(',')
    end

    private

    def line_to_array
      [
        duration,
        path,
        page_type,
        sub_category,
        paths[1],
        paths[2],
        paths[3],
        paths[4],
        paths[5],
        session
      ]
    end

    def path
      @line[0]&.sub(/\?.*/, '') || ''
    end

    def paths
      path.split('/')
    end

    def sub_category
      return unless SUB_CATEGORIES.include?(path.split('/')[1])

      path.split('/')[1]
    end

    def page_type
      case path
      when '/'
        :top
      when '/about', '/terms', '/surety'
        :page
      when '/surety/'  # not exist path
        :page
      when '/expenses-list'
        :expense
      when %r{^/accounts}
        :function
      when %r{^/pros/}
        :pros
      when %r{/areas/}
        :area
      when %r{/examples}
        :example
      when %r{/prices}
        :prices
      when %r{/estimate_requests|/inquiry}
        :form
      when %r{/contents/}
        case path
        when %r{/contents/expenses-}
          :expense
        when %r{/contents/diy-}
          :diy
        else
          :content
        end
      when %r{/expenses-}  # before redirect
        :expense
      when %r{/diy-}  # before redirect
        :diy
      when %r{/products/}
        :product
      when %r{/products}
        :products
      when *(SUB_CATEGORIES.map { |slug| "/#{slug}" })
        :category_top
      when %r{^/https?://reform-market.com}
        :null
      when '(not set)', '', '/search'
        :null
      else
        $stderr.puts "Cannot compute page_type: #{path}"
        :null
      end
    end

    def duration
      @line[1]
    end

    def session
      @line[2].gsub(/[^\d]/, '').to_i
    end
  end
end
