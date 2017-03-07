

require "Token"
require "ParserUtils"
require "Utils"

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

function expr( buffer, index )
    return choice { literals
                  , 
                  }
end

