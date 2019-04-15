local function sqrmod(a, n)         -- a^2 (mod n)
    local b = a*a
    if b < 2^53 then return b%n end
    -- hibits ~ sqrt(2^53) ~ 94906265.6 => 94906266 tested ok
    -- lobits = 2^26-1 = 67108863
    -- max(a) = 94906266*2^26 + 67108863 = 6369051764850687
    if a > 6369051764850687 then a=n-a end
    b = a % 2^26    -- lobits
    a = a - b       -- hibits * 2^26
    a = (a*a)%n - n + (2*a*b)%n
    if a <= 2^53 - (2^26-1)^2 then return (a + b*b) % n end
    return (a - n + b*b) % n
end

local function mulmod(a, b, n)      -- a*b (mod n)
    local m = a*b
    if m < 2^53 then return m%n end
    -- split a*b to (a+a2)(b-b2) = (a b - a2 b2) + (a2 b - a b2)
    -- same sqrmod constant tested ok here ...
    if a > 6369051764850687 then a=n-a; b=n-b end
    if b > 6369051764850687 then
        a = mulmod(a, n-b, n)
        return a==0 and 0 or n-a    -- flip "sign"
    end
    local a2 = a % 2^26
    local b2 = 2^26 - b % 2^26
    a = a - a2
    b = b + b2
    m = a2*b - a*b2
    if m >= 0 then m=m%n else m = n - (-m)%n end
    a = (a*b)%n - (a2*b2)%n         -- a = [-n+1,n-1]
    b = a + m                       -- b = [-n+1,2n-1]
    if b >= n then return a-n+m end
    if b >= 0 then return b else return b+n end
end

local function powmod(a, p, n)      -- a^p (mod n)
    if p < 2 then return a^p end    -- fraction = error
    local r = 1
    while true do
        if p % 2 == 1 then          -- right-to-left
            r = mulmod(r, a, n)
            if p < 2 then return r end
            p = p - 1
        end
        p = 0.5*p
        a = sqrmod(a, n)
    end
end

local function issprp(a, n)         -- a-sprp test
    if n<4 then return n>1 end      -- odd n>3
    if n%2==0 then return false end
    a = a % n
    if a<2 then return true end     -- a=n-1 skipped
    local x = n-1
    local y = x
    while y % 4 == 0 do y=0.5*y end
    a = powmod(a, 0.5*y, n)
    if a==1 then return true end
    while a ~= x do
        if y==x then return false end
        a = sqrmod(a, n)
        y = y+y
    end
    return true
end

local function isprime(n)
    if n < 341531 then
        return issprp((9345883071009581056 % n) + 681, n)
    elseif n < 716169301 then
        return issprp(15, n)
           and issprp((13393019396194700 % n) + 1, n)
    elseif n < 273919523041 then
        return issprp(15, n)
           and issprp(7363882082, n)
           and issprp(992620450144556, n)
    elseif n < 47636622961201 then
        return issprp(2, n)
           and issprp(2570940, n)
           and issprp(211991001, n)
           and issprp(3749873356, n)
    end
    -- Below good for full 53 bits. Other non-witness:
    -- 9049203443108251, 9325578861942661,
    -- 9718260168425581, 10064706355310041, ...
    return issprp(2, n)
       and issprp(4130806001517, n)
       and issprp((149795463772692064 % n) - 4, n)
       and issprp((186635894390467040 % n) - 3, n)
       and issprp((3967304179347716096 % n) - 291, n)
       and n ~= 7999252175582851
end

local function nextprime(n)
    if n<2 then return 2 end
    if n >= 2^53-111 then return 1/0 end
    n = n - (n-1)%2
    repeat n=n+2 until isprime(n)
    return n
end

local function prevprime(n)
    if n<4 then return n==3 and 2 or -1/0 end
    if n >= 2^53 then return 1/0 end
    n = n + (n-1)%2
    repeat n=n-2 until isprime(n)
    return n
end

local function count(a,b)   -- primes count = [a,b]
    local t = 0
    for i=a,b do
        if isprime(i) then t=t+1 end
    end
    return t
end

return {
    sqrmod=sqrmod, mulmod=mulmod, powmod=powmod,
    issprp=issprp, isprime=isprime, count=count,
    prevprime=prevprime, nextprime=nextprime,
}
