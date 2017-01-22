

require "Token"
require "AST"
require "ParserUtils"

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )
-- parser function : ( buffer, index ) -> ( failure, index )


function literals( buffer, index )
    if buffer[index].type == tokenType.int then 
        return true, buffer, index + 1, { type = astType.int; value = buffer[index].value }
    elseif buffer[index].type == tokenType.float then  -- TODO test
        return true, buffer, index + 1, { type = astType.float; value = buffer[index].value }
    elseif buffer[index].type == tokenType["true"] then  -- TODO test
        return true, buffer, index + 1, { type = astType.bool; value = true }
    elseif buffer[index].type == tokenType["false"] then  -- TODO test
        return true, buffer, index + 1, { type = astType.bool; value = false }
    elseif buffer[index].type == tokenType.string then  -- TODO test
        return true, buffer, index + 1, { type = astType.string; value = buffer[index].value }
    else 
        return false, index
    end
    -- TODO array literals
end


function constDeclaration( buffer, index )
    if buffer[index].type ~= tokenType.const then return false, index end
    index = index + 1
    if buffer[index].type ~= tokenType.symbol then return false, index end
    local varName = buffer[index].value
    index = index + 1
    if buffer[index].type ~= tokenType.assign then return false, index end
    index = index + 1
    local exprSuccess, exprBuffer, exprIndex, exprValue = expr( buffer, index )
    if not exprSuccess then return false, index end 
    index = exprIndex
    buffer = exprBuffer
    if buffer[index].type ~= tokenType.semicolon then return false, index end
    index = index + 1
    return true, buffer, index, { type = astType.constDeclaration; varName = varName; assignment = exprValue } 
end

function varDeclaration( buffer, index )
    if buffer[index].type ~= tokenType.var then return false, index end
    index = index + 1
    if buffer[index].type ~= tokenType.symbol then return false, index end
    local varName = buffer[index].value
    index = index + 1
    if buffer[index].type ~= tokenType.assign then return false, index end
    index = index + 1
    local exprSuccess, exprBuffer, exprIndex, exprValue = expr( buffer, index )
    if not exprSuccess then return false, index end 
    index = exprIndex
    buffer = exprBuffer
    if buffer[index].type ~= tokenType.semicolon then return false end
    index = index + 1
    return true, buffer, index, { type = astType.varDeclaration; varName = varName; assignment = exprValue } 
end

function symbol( buffer, index )
    if buffer[index].type == tokenType.symbol then 
        return true, buffer, index + 1, buffer[index].value 
    else
        return false, index
    end
end

function indexedTypeSymbol( buffer, index )
    return bind( symbol,                        function ( name )     return
           bind( check( tokenType.openAngle ),  function ()           return
           bind( typeSig,                       function ( indexSig ) return
           bind( check( tokenType.closeAngle ), function ()           return 
           unit( { type = astType.indexedType ; outer = name ; inner = indexSig } ) end ) end ) end ) end )( buffer, index )
end

function typeSymbol( buffer, index )
-- TODO indexedtypeSymbol OR symbol
end

function arrowType( buffer, index )
end

function typeList( buffer, index ) -- for tuple type
end

function tupleType( buffer, index )
end

function typeSig( buffer, index )
    return choice { tupleType
                  , arrowType
                  , typeSymbol
                  } ( buffer, index )
end

local _expr = choice { literals
                     , 
                     }
function expr( buffer, index )
    return _expr( buffer, index )
end

local _stm = choice {
                    }
function stm( buffer, index )
    return _stm( buffer, index )
end
