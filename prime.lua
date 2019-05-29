local function odd_primes(n)        -- odd prime iterators <= n
    local prev, composite = 1, {}
    local function iter()
        local c, n, x, gap = composite, n
        for p = prev+2, n, 2 do     -- handle odd primes only
            gap = c[p]
            if gap then             -- composite
                x = p + gap
                while c[x] do x = x + gap end
                c[x] = gap          -- mark next composite
                c[p] = nil          -- release memory
            else                    -- prime found
                x = p * p           -- mark next composite
                if x <= n then c[x] = p + p end
                prev = p
                return p
            end
        end
    end
    return iter
end

local function primes(n)            -- array of all primes <=n
    if n < 2 then return {} end
    local a, i = {2}, 1
    for p in odd_primes(n) do
        i = i+1
        a[i] = p
    end
    return a
end

return {odd_primes=odd_primes, primes=primes}
