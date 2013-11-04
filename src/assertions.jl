# Should no longer be needed since I found isapprox... ;)
in_delta(a, e, delta = 0.01) = isapprox(a, e; atol = delta)
