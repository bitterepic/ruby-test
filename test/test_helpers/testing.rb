# typed: strict

module Testing
  class NotInitializedError < StandardError
    extend T::Sig

    sig { params(msg: String).void }
    def initialize(msg = "Value has not been initialized yet.")
      super(msg)
    end
  end

  class IntegrationTest < ActionDispatch::IntegrationTest
    extend T::Sig

    sig { params(arg: T.untyped).void }
    def initialize(arg)
      super(arg)

      @response = T.let(nil, T.nilable(ActionDispatch::TestResponse))
      @request = T.let(nil, T.nilable(ActionDispatch::TestRequest))
    end

    sig { returns(ActionDispatch::TestRequest) }
    def request
      throw NotInitializedError.new if @request == nil

      @request
    end

    sig { returns(ActionDispatch::TestResponse) }
    def response
      throw NotInitializedError.new if @response == nil

      @response
    end
  end
end
