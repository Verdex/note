
-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
function lex( input, tokMaps )

    local start = 1

    local t = {}

    while start <= #input do

        local success = false
        for _, map in ipairs( tokMaps ) do 
            local pattern = "^" ..  map.pattern .. "()"
            local result = { string.match( input, pattern, start ) }

            if result[1] then 
                t[#t+1] = map.trans( result )  
                -- TODO
                --coroutine.yield( map.trans( result ) )

                start = result[#result]

                success = true
                break
            end
        end
        if not success then
            -- TODO need to handle failure by reporting index number
            assert( false, "failure" )
        end

    end

    return t

end

