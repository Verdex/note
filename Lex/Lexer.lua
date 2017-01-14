
require "Token"

-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
function lex( input, tokMaps )
    
    return coroutine.wrap( function ()
        local start = 1

        local t = {}

        while start <= #input do

            local success = false
            for _, map in ipairs( tokMaps ) do 
                local pattern = "^" ..  map.pattern .. "()"
                local result = { string.match( input, pattern, start ) }

                if result[1] then 

                    local tok = map.trans( result ) 

                    if tok.type ~= tokenType.ignore then

                        coroutine.yield( tok )
                     
                    end

                    start = result[#result]

                    success = true
                    break
                end
            end
            if not success then
                -- TODO add some error reporting
                error(  "failure: " .. string.sub( input,  start - 20, start + 20 ) .. "\n" .. string.sub( input, start, start ))
            end

        end
    end )

end
        
