local p = require 'nextprime'
local sqrmod = p.sqrmod
local mulmod = p.mulmod
local isprime = p.isprime
local abs = math.abs
local floor = math.floor
local random = math.random

local function gcd(a, b)        -- optimized for speed
    while b ~= 0 do
        a = a % b
        if a == 0 then return b end
        b = b % a
    end
    return a
end

local function prho(n)          -- n composite, factors >= 5
    local u, v, a, g = 63, 63, 63-n         -- seed
    while true do
        u = (sqrmod(u, n) + a) % n
        v = (sqrmod(abs(sqrmod(v, n) + a), n) + a) % n
        g = abs(u - v)                      -- 1st delta

        u = (sqrmod(u, n) + a) % n
        v = (sqrmod(abs(sqrmod(v, n) + a), n) + a) % n
        g = mulmod(g, abs(u - v), n)        -- 2nd delta

        u = (sqrmod(u, n) + a) % n
        v = (sqrmod(abs(sqrmod(v, n) + a), n) + a) % n
        g = mulmod(g, abs(u - v), n)        -- 3rd delta

        g = gcd(n, g)
        if g > 1 then
            if g ~= n then return g end     -- factor found
            a = -3 - floor((n-3)*random())  -- [-n+1, -3]
            u = floor(n*random())           -- [0, n-1]
            v = u
        end
    end
end

local function recursive_prho(n, t)
    if isprime(n) then t[#t+1]=n; return end
    local x = prho(n)
    recursive_prho(n/x, t)
    recursive_prho(x, t)
end

local function factor(n)
    n = floor(n)
    local t = {}
    if n < 2 then return t end
    while n%2 == 0 do n=n/2; t[#t+1]=2 end  -- required
    while n%3 == 0 do n=n/3; t[#t+1]=3 end  -- required
    while n%5 == 0 do n=n/5; t[#t+1]=5 end
    while n%7 == 0 do n=n/7; t[#t+1]=7 end
    if n > 1 then recursive_prho(n, t) end
    table.sort(t)
    return t
end

p.gcd = gcd
p.factor = factor
return p
