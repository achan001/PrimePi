local function odd_primes(n)        -- odd prime iterators <= n
    local i, odd, composite = 1, 1, {}
    local function iter()
        local c, n, x, gap = composite, n
        for p = odd + 2, n, 2 do    -- handle odd primes only
            gap = c[p]
            if gap then             -- composite
                x = p + gap
                while c[x] do x = x + gap end
                c[x] = gap          -- mark next composite
                c[p] = nil          -- release memory
            else                    -- prime found
                x = p * p           -- mark next composite
                if x <= n then c[x] = p + p end
                odd = p             -- setup next call
                i = i + 1
                return i, p         -- Note: pi(p) = i
            end
        end
    end
    return iter
end

local function primes(n)            -- array of all primes <=n
    if n < 2 then return {} end
    local a = {2}
    for i, p in odd_primes(n) do
        a[i] = p
    end
    return a
end

return {odd_primes=odd_primes, primes=primes}
