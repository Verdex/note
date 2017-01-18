

--[[

match ( token )
    return \ buffer . if token == buffer[1] 
                      then yield complete

var_assign ( buffer )
    buffer = yield c->ok( match( var, buffer[1] ) )
    ...

    yield complete

or ( ... )
    parsers = { ... }

    for t in tokens do
        buffer.append( t )

        for p in parsers do
            if p.ok then
               res =  coroutine.resume( p, buffer )
               if res == complete then
                   yield complete
                   break
                end
               if res ~= ok then
                   p.ok = false
                end
            end



--]]
local complete = "complete"
local ok = "ok"
local fail = "fail"

local function match( token, item )
    if token.type == item.type and token.value == token.value then
        return complete
    else
        return fail
    end
end

function choice( ... )

end

-- token : seq< token >
function parse( tokens )

end


