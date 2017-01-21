

require "Token"
require "AST"

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )


function choice( parsers )
    return function ( buffer, index ) 
        for _, p in ipairs( parsers ) do
            local success, resBuffer, resIndex, value = p( buffer, index )
            if success then
                return true, resBuffer, resIndex, value
            end
        end
        return false
    end
end

function expr( buffer, index )
    if buffer[index].type == tokenType.int then 
        return true, buffer, index + 1, { type = astType.int; value = buffer[index].value }
    end
end

-- TODO test
function varDeclaration( buffer, index )
    if buffer[index].type ~= tokenType.var then return false end
    index = index + 1
    if buffer[index].type ~= tokenType.symbol then return false end
    local varName = buffer[index].value
    index = index + 1
    if buffer[index].type ~= tokenType.assign then return false end
    index = index + 1
    local exprSuccess, exprBuffer, exprIndex, exprValue = expr( buffer, index )
    if not exprSuccess then return false end 
    index = exprIndex
    buffer = exprBuffer
    if buffer[index].type ~= tokenType.semicolon then return false end
    index = index + 1
    return true, buffer, index, { type = astType.varDeclaration; varName = varName; assignment = exprValue } 
end
