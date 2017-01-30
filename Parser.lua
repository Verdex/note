

require "Token"
require "AST"
require "ParserUtils"

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )
-- parser function : ( buffer, index ) -> ( failure, index )



-- TODO need to avoid buffer out of bounds (switch to bind)
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
    -- TODO function literals?
end

function constDeclaration( buffer, index )
    return bind( check( tokenType.const ),     function ()            return
           bind( symbol,                       function ( varName )   return
           bind( check( tokenType.assign ),    function ()            return
           bind( expr,                         function ( exprValue ) return
           bind( check( tokenType.semicolon ), function ()            return
           unit( { type = astType.constDeclaration; varName = varName; assignment = exprValue } ) end ) end ) end ) end ) end )( buffer, index )
end

function varDeclaration( buffer, index )
    return bind( check( tokenType.var ),       function ()            return
           bind( symbol,                       function ( varName )   return
           bind( check( tokenType.assign ),    function ()            return
           bind( expr,                         function ( exprValue ) return
           bind( check( tokenType.semicolon ), function ()            return
           unit( { type = astType.varDeclaration; varName = varName; assignment = exprValue } ) end ) end ) end ) end ) end )( buffer, index )
end

function symbol( buffer, index )
    return match( tokenType.symbol, function ( s ) return s.value end )( buffer, index )
end

function indexedTypeSymbol( buffer, index )
    return bind( symbol,                        function ( name )     return
           bind( check( tokenType.openAngle ),  function ()           return
           bind( typeSig,                       function ( indexSig ) return
           bind( check( tokenType.closeAngle ), function ()           return 
           unit( { type = astType.indexedType ; outer = name ; inner = indexSig } ) end ) end ) end ) end )( buffer, index )
end

function typeSymbol( buffer, index )
    return choice { indexedTypeSymbol
                  , map( symbol, function ( s ) return { type = astType.simpleType ; value = s } end )
                  } ( buffer, index )
end

function arrowType( buffer, index )
    return bind( typeSymbol,                    function ( t )    return
           bind( check( tokenType.sub ),        function ()       return
           bind( check( tokenType.closeAngle ), function ()       return
           bind( typeSig,                       function ( rest ) return
           unit( { type = astType.arrowType ; first = t ; rest = rest } ) end ) end ) end ) end )( buffer, index )
end

function tupleType( buffer, index )
    local typeList = function ( buffer, index ) 
    end
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
