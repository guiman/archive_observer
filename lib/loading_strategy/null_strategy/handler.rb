module LoadingStrategy
  module NullStrategy
    class Handler
      def method_missing(name)
        nil
      end
    end
  end
end
