

require "Token"
require "AST"
require "ParserUtils"
require "Utils"

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )
-- parser function : ( buffer, index ) -> ( failure, index )



function literals( buffer, index )
    return choice { match( tokenType.int,      function ( v ) return { type = astType.int; value = v.value } end )
                  , match( tokenType.float,    
                        function ( v ) 
                            return { type = astType.float 
                                   ; exponent = v.exponent 
                                   ; intValue = v.intValue 
                                   ; floatValue = v.floatValue 
                                   }
                        end ) 
                  , match( tokenType["true"],  function ( v ) return { type = astType.bool; value = true } end )
                  , match( tokenType["false"], function ( v ) return { type = astType.bool; value = false } end )
                  , match( tokenType.string,   function ( v ) return { type = astType.string; value = v.value } end )
                  } ( buffer, index )
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

function typeListTail( buffer, index )
    return bind( check( tokenType.comma ), function ()       return
           bind( typeSig,                  function ( t )    return
           bind( typeListTail,             function ( rest ) return 
           unit( insert( rest, 1, t ) ) end ) end ) end )( buffer, index )
end

function typeList( buffer, index ) 
    return choice { typeListTail
                  , map( nothing, function () return {}  end )
                  } ( buffer, index )
end

-- TODO tuple type is broken
function tupleType( buffer, index )
    return bind( check( tokenType.openParen ),  function ()       return
           bind( typeSig,                       function ( t )    return 
           bind( typeList,                      function ( rest ) return
           bind( check( tokenType.closeParen ), function ()       return
           unit( { type = astType.tupleType; typeList = insert( rest, 1, t ) } ) end ) end ) end ) end )( buffer, index )
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
