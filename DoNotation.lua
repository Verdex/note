
require "Utils"
require "ParserUtils"

local function symbol( buffer, index )
    return match( tokenType.symbol, function ( s ) return s.value end )( buffer, index )
end

local function parseUnit( buffer, index )
    return match( tokenType.unit, function ( s ) return s.value end )( buffer, index )
end

local function parseArrow( buffer, index )
    return bind( symbol,                                                      function ( name ) return 
           bind( match( tokenType.arrow, function ( s ) return s.value end ), function ( v )    return 
           unit( { type = "arrow"; value = v ; var = name } ) end ) end )( buffer, index )
end

local function parseNoArrow( buffer, index )
    return match( tokenType.noArrow, function ( s ) return { type = "noArrow" ; value = s.value } end )( buffer, index )
end

local function statement( buffer, index )
    return choice { parseArrow
                  , parseNoArrow
                  } ( buffer, index )
end

local function statementList( buffer, index )
    return choice { statementListTail
                  , map( nothing, function () return {} end )
                  } ( buffer, index )
end

local function statementListTail( buffer, index )
    return bind( statement,     function ( s )    return
           bind( statementList, function ( rest ) return
           unit( insert( rest, 1, s ) ) end ) end )( buffer, index )
end

local function parseDoNotation( buffer, index )
   return bind( check( tokenType["do"] ),      function ()           return
          bind( check( tokenType.openParen ),  function ()           return
          bind( symbol,                        function ( bindName ) return
          bind( check( tokenType.comma ),      function ()           return
          bind( symbol,                        function ( unitName ) return
          bind( check( tokenType.closeParen ), function ()           return
          bind( check( tokenType.openCurly ),  function ()           return
          bind( statementList,                 function ( list )     return
          bind( parseUnit,                     function ( u )        return
          bind( check( tokenType.closeCurly ), function ()           return
          unit( { list = list; unitValue = u; bind = bindName; unit = unitName } ) end ) end ) end ) end ) end ) end ) end ) end ) end ) end )( buffer, index )
end

local function nextItem( list, index )
    index = index + 1
    local n = list.list[index]
    if not n then
        return unitGen( list.unit, list.unitValue )
    elseif n.type == "noArrow" then
        return bindNoValGen(  n, list, index )
    elseif n.type == "arrow" then
        return bindGen(  n, list, index )
    end
end

local function unitGen( unitName, unitValue )
    return string.format( "%s ( %s )", unitName, unitValue )
end

local function bindNoValGen( bNode, list, index )
    return string.format( "%s( %s, function () return\n%s end )", list.bind, bNode.value, nextItem( list, index ) )
end

local function bindGen( bNode, list, index)
    return string.format( "%s( %s, function ( %s ) return\n%s end )", list.bind, bNode.value, bNode.var, nextItem( list, index ) )
end

function doNotation( str )
    local tokens = lex( str, tokenMaps )
    local pass, buffer, index, value = parseDoNotation( tokens, 1 )
    if not pass then
        error "an error occurred while parsing the do notation"
    end
   
    return string.format( "return function( buffer, index )\n    return %s ( buffer, index )\nend", nextItem( value, 0 ) )
end


-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
local function lex( input, tokMaps )
    
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
        

local tokenType = 
{
    ignore = "ignore";
    symbol = "symbol";
    openParen = "openParen";
    closeParen = "closeParen";
    openCurly = "openCurly";
    closeCurly = "closeCurly";
    comma = "comma";
    arrow = "arrow";
    noArrow = "noArrow";
    ["do"] = "do";
    unit = "unit";
}

local tokenMaps = 
{
    { 
        pattern = [[//.-%c]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        pattern = [[/%*.-%*/]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        pattern = "%s";
        trans = function () return { type = tokenType.ignore } end
    },

    {
        pattern = "do";
        trans = function () return { type = tokenType["do"] } end 
    },

    {
        pattern = "unit(.-);";
        trans = function ( s ) return { type = tokenType.unit; value = s[1] } end
    },

    {
        pattern = ",";
        trans = function () return { type = tokenType.comma } end
    },


    {
        pattern = "<%-(.-);";
        trans = function ( s ) return { type = tokenType.arrow; value = s[1] } end
    },

    {
        pattern = "|%-(.-);";
        trans = function ( s ) return { type = tokenType.noArrow; value = s[1] } end
    },

    {
        pattern = "{";
        trans = function () return { type = tokenType.openCurly } end
    },

    {
        pattern = "}";
        trans = function () return { type = tokenType.closeCurly } end
    },

    {
        pattern = "%(";
        trans = function () return { type = tokenType.openParen } end
    },

    {
        pattern = "%)";
        trans = function () return { type = tokenType.closeParen } end
    },

    {
        pattern = "([_%a'][_%w']*)";
        trans = function ( s ) return { type = tokenType.symbol; value = s[1] } end
    },
}


