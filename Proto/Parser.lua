

require "Token"
require "ParserUtils"
require "Utils"
require "AST"

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )
-- parser function : ( buffer, index ) -> ( failure, index )

function literals( buffer, index )
    return choice { match( tokenType.int,      function ( v ) return { type = astType.int; value = v.value } end )
                  , match( tokenType.string,   function ( v ) return { type = astType.string; value = v.value } end )
                  } ( buffer, index )
    -- TODO array literals
    -- TODO function literals?
end

function symbol( buffer, index )
    return match( tokenType.symbol, function ( s ) return s.value end )( buffer, index )
end

function structFieldsTail( buffer, index )
    return bind( check( tokenType.semicolon ), function ()     return
           bind( symbol,                       function ( n )  return
           bind( structFieldList,              function ( ns ) return
           unit( insert( ns, 1, n ) ) end ) end ) end )( buffer, index )
end

function structFieldList( buffer, index )
    return choice { structFieldsTail
                  , map( nothing, function () return {} end )
                  } ( buffer, index )
end

function structFieldsListHead( buffer, index )
    return bind( symbol,          function ( first ) return
           bind( structFieldList, function ( rest )  return
           unit( insert( rest, 1, first ) ) end ) end )( buffer, index )
end

function structFields( buffer, index )
     return choice { structFieldsListHead
                   , map( nothing, function () return {} end )
                   } ( buffer, index )
end

function struct( buffer, index )
    return bind( symbol,                        function ( structType ) return
           bind( check( tokenType.openCurly ),  function ()             return
           bind( structFields,                  function ( fields )     return
           bind( check( tokenType.closeCurly ), function ()             return
           unit( { type = astType.struct ; name = structType ; fields = fields } ) end ) end ) end ) end )( buffer, index )
end

function checkP( buffer, index )
    return bind( check( tokenType.check ),      function ()             return
           bind( check( tokenType.openParen ),  function ()             return
           bind( symbol,                        function ( structType ) return
           bind( check( tokenType.closeParen ), function ()             return
           unit( { type = astType.check ; structType = structType } ) end ) end ) end ) end )( buffer, index )
end

function debugP( buffer, index )
    return bind( check( tokenType.debug ),                       function ()        return
           bind( check( tokenType.openParen ),                   function ()        return
           bind( match( tokenType.string, 
                            function ( s ) return s.value end ), function ( value ) return
           bind( check( tokenType.closeParen ),                  function ()        return
           unit( { type = astType.debug ; message = value } ) end ) end ) end ) end )( buffer, index )
end

function endInputP( buffer, index )
    return bind( check( tokenType.endInput ), function () return
           unit( { type = astType.endInput } ) end )( buffer, index )
end

function nothingP( buffer, index )
    return bind( check( tokenType.nothing ), function () return
           unit( { type = astType.nothing } ) end )( buffer, index )
end

function emptyP( buffer, index )
    return bind( check( tokenType.empty ), function () return
           unit( { type = astType.empty } ) end )( buffer, index )
end


