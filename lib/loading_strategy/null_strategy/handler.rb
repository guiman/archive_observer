module LoadingStrategy
  module NullStrategy
    class Handler
      def initialize(data)

      end

      def method_missing(name)
        nil
      end
    end
  end
end
