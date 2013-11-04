test("Assertions that helps in writing checks and tests") do

  test("in_delta") do

    test("with default delta value") do

      @t in_delta(1.0, 1.0) == true
      @t in_delta(1.001, 1.0) == true
      @t in_delta(1.01, 1.0) == true
      @t in_delta(1.1, 1.0) == false
      @t in_delta(1.011, 1.0) == false

    end

  end

end