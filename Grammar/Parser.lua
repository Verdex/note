

--[[

match ( token )
    return \ buffer . if token == buffer[1] 
                      then yield complete

var_assign ( buffer )
    buffer = yield c->ok( match( var ) )
    ...

    yield complete

and ( ... )
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
