module Testing
  class NotInitializedError < StandardError
    def initialize(msg="Value has not been initialized yet.")
      super(msg)
    end
  end

  class IntegrationTest < ActionDispatch::IntegrationTest
    extend T::Sig

    sig { params( args: T.untyped ).void }
    def initialize(*args)
      super(*args)

      @response = T.let(nil, T.nilable(ActionDispatch::TestResponse))
      @request = T.let(nil, T.nilable(ActionDispatch::TestRequest))
    end

    sig { returns(ActionDispatch::TestRequeset) }
    def request
      throw NotInitializedError.new if @request == nil

      return @request
    end

    sig { returns(ActionDispatch::TestResponse) }
    def response
      throw NotInitializedError.new if @response == nil

      return @response
    end
  end
end
