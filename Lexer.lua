
require "Token"

-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
function lex( input, tokMaps )
    
    local start = 1

    local tokens = {}

    while start <= #input do

        local success = false
        for _, map in ipairs( tokMaps ) do 
            local pattern = "^" ..  map.pattern .. "()"
            local result = { string.match( input, pattern, start ) }

            if result[1] then 

                local tok = map.trans( result ) 

                if tok.type ~= tokenType.ignore then

                    tokens[#tokens + 1] = tok
                 
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

    return tokens

end
        
