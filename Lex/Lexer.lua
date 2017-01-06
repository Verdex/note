
-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
function lex( input, tokMaps )

    local start = 1

    local t = {}

    while start <= #input do

        local success = false
        for _, map in ipairs( tokMaps ) do 
            local pattern = "^" ..  map.pattern .. "()"
            local x = { string.match( input, pattern, start ) }

            if x[1] then 
                t[#t+1] = map.trans( x )  
                --coroutine.yield( map.trans( x ) )

                start = x[#x]

                success = true
                break
            end
        end
        if not success then
            assert( false, "failure" )
        end

    end

    return t

end

