local prime = require 'prime'
local int, huge = math.floor, math.huge
local lookup, psum, phi, P

local function countPi(x)
    P = prime.primes(x)         -- count pi(x) using table P
    P[0] = x
    setmetatable(P, {__index = function(F, i) return huge end})
    return #P
end

-- setup code to make critical tables for m = B-3

countPi(1000)                   -- default size
local B = 8                     -- base prime in phi()
assert(P[#P] > P[B] ^ 2)        -- make sure enough primes
local ka, kb = 1/P[B-2], 1/P[B-1]
local kc = ka * kb

local T, s, k = {[0]=0, 1}, 1, 1
for i = 1, B-3 do s = s * P[i] end
for i = 1, B-3 do               -- mark prime + multiples
    local p = P[i]
    T[p] = true
    for j = p*p, s-1, p do T[j] = true end
end
for i = 2, s-1 do               -- make critical table
    if T[i] == nil then k = k + 1 end
    T[i] = k
end

-- phi(P, x, m) return count in [1, x] co-prime to first m primes
--      it calculates by lookup in critical table and prime table,
--      and by recursion.  To simplify further, it calls psum() or
--      lookup() when Legendre's condition holds.

function phi(P, x, m, psum)
    local s, T, int = s, T, int
    local a, b, c, z = int(x*ka), int(x*kb), int(x*kc), int(x)
    if z < s then
        z = T[z] - T[a] - T[b] + T[c]
    else
        local big, tz = z, z % s
        big = big - tz
        tz = T[tz]
        if a >= s then z = a; a = a % s; big = big - (z-a) end
        if b >= s then z = b; b = b % s; big = big - (z-b) end
        if c >= s then z = c; c = c % s; big = big + (z-c) end
        z = tz - T[a] - T[b] + T[c] + big / s * k
    end
    for i = B, m do
        a = P[i]
        if a^3 > x then return psum(P, x, i, m, z) end
        z = z - phi(P, x/a, i-1, lookup)
    end
    return z
end

-- psum(P, x, i, m, z) == z - Sum(phi(x/P[k], k-1)), k = [i, m]

function psum(P, x, i, m, z)            -- assume x < P[i]^3
    local bound = P[0]
    for k = i, m do
        local y = x/P[k]
        if y <= bound then return lookup(P, x, k, m, z) end
        while y < P[i]*P[i] do i=i-1 end    -- i == pi(sqrt(y))
        z = z - (phi(P, y, i, lookup) + i - k + 1)
    end
    return z
end

-- calculate psum(P, x, i, m, z) by direct lookup of prime table
-- lookup == z + Sum[k] - Sum(pi(x/P[k]) + 2), k = [i, m]
-- NOTE: x/P[m] >= P[m], thus best to sum pi's in reverse

function lookup(P, x, i, m, z)
    z = z + 0.5 * (i+m)*(m-i+1)         -- z += Sum[k]
    for k = m, i, -1 do                 -- sum pi()'s in reverse
        local y = x/P[k]
        while y >= P[m + 8] do m = m + 10 end
        while y >= P[m] do  m = m + 2 end
        if y >= P[m-1] then m = m + 1 end
        z = z - m                       -- z -= Sum[pi(y) + 2]
    end
    return z
end

function prime.bisect(a, x, lo, hi)     -- 1 based python bisect()
    if lo == nil then lo = 1 end
    if hi == nil then hi = #a + 1 end
    while lo < hi do
        local mid = int(0.5 * (lo+hi))
        if x < a[mid] then
            hi = mid
        else
            lo = mid+1
        end
    end
    return lo
end

local function PI(x) return prime.bisect(P, x) - 1 end

function prime.pi(x)                    -- number of primes <= x
    if x <= P[0] then return PI(x) end
    local y = x^0.5
    local m = (y <= P[0]) and PI(y) or countPi(y)
    x = 2 * int(0.5 * (x+1))            -- "round" to even
    return phi(P, x, m, psum) + m - 1
end

if select(1, ...) ~= 'primepi' then     -- test code
    print(prime.pi(tonumber(select(1, ...))))
end
return prime
