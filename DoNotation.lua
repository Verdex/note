
require "Utils"
require "ParserUtils"

doN = {}

doN.tokenType = 
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

doN.tokenMaps = 
{
    { 
        pattern = [[//.-%c]];
        trans = function () return { type = doN.tokenType.ignore } end
    },

    { 
        pattern = [[/%*.-%*/]];
        trans = function () return { type = doN.tokenType.ignore } end
    },

    { 
        pattern = "%s";
        trans = function () return { type = doN.tokenType.ignore } end
    },

    {
        pattern = "do";
        trans = function () return { type = doN.tokenType["do"] } end 
    },

    {
        pattern = "unit(.-);";
        trans = function ( s ) return { type = doN.tokenType.unit; value = s[1] } end
    },

    {
        pattern = ",";
        trans = function () return { type = doN.tokenType.comma } end
    },


    {
        pattern = "<%-(.-);";
        trans = function ( s ) return { type = doN.tokenType.arrow; value = s[1] } end
    },

    {
        pattern = "|%-(.-);";
        trans = function ( s ) return { type = doN.tokenType.noArrow; value = s[1] } end
    },

    {
        pattern = "{";
        trans = function () return { type = doN.tokenType.openCurly } end
    },

    {
        pattern = "}";
        trans = function () return { type = doN.tokenType.closeCurly } end
    },

    {
        pattern = "%(";
        trans = function () return { type = doN.tokenType.openParen } end
    },

    {
        pattern = "%)";
        trans = function () return { type = doN.tokenType.closeParen } end
    },

    {
        pattern = "([_%a'][_%w']*)";
        trans = function ( s ) return { type = doN.tokenType.symbol; value = s[1] } end
    },
}


function doN.symbol( buffer, index )
    return match( doN.tokenType.symbol, function ( s ) return s.value end )( buffer, index )
end

function doN.parseUnit( buffer, index )
    return match( doN.tokenType.unit, function ( s ) return s.value end )( buffer, index )
end

function doN.parseArrow( buffer, index )
    return bind( doN.symbol,                                                      function ( name ) return 
           bind( match( doN.tokenType.arrow, function ( s ) return s.value end ), function ( v )    return 
           unit( { type = "arrow"; value = v ; var = name } ) end ) end )( buffer, index )
end

function doN.parseNoArrow( buffer, index )
    return match( doN.tokenType.noArrow, function ( s ) return { type = "noArrow" ; value = s.value } end )( buffer, index )
end

function doN.statement( buffer, index )
    return choice { doN.parseArrow
                  , doN.parseNoArrow
                  } ( buffer, index )
end

function doN.statementList( buffer, index )
    return choice { doN.statementListTail
                  , map( nothing, function () return {} end )
                  } ( buffer, index )
end

function doN.statementListTail( buffer, index )
    return bind( doN.statement,     function ( s )    return
           bind( doN.statementList, function ( rest ) return
           unit( insert( rest, 1, s ) ) end ) end )( buffer, index )
end

function doN.parseDoNotation( buffer, index )
   return bind( check( doN.tokenType["do"] ),      function ()           return
          bind( check( doN.tokenType.openParen ),  function ()           return
          bind( doN.symbol,                        function ( bindName ) return
          bind( check( doN.tokenType.comma ),      function ()           return
          bind( doN.symbol,                        function ( unitName ) return
          bind( check( doN.tokenType.closeParen ), function ()           return
          bind( check( doN.tokenType.openCurly ),  function ()           return
          bind( doN.statementList,                 function ( list )     return
          bind( doN.parseUnit,                     function ( u )        return
          bind( check( doN.tokenType.closeCurly ), function ()           return
          unit( { list = list; unitValue = u; bind = bindName; unit = unitName } ) end ) end ) end ) end ) end ) end ) end ) end ) end ) end )( buffer, index )
end

function doN.nextItem( list, index )
    index = index + 1
    local n = list.list[index]
    if not n then
        return doN.unitGen( list.unit, list.unitValue )
    elseif n.type == "noArrow" then
        return doN.bindNoValGen(  n, list, index )
    elseif n.type == "arrow" then
        return doN.bindGen(  n, list, index )
    end
end

function doN.unitGen( unitName, unitValue )
    return string.format( "%s ( %s )", unitName, unitValue )
end

function doN.bindNoValGen( bNode, list, index )
    return string.format( "%s( %s, function () return\n%s end )", list.bind, bNode.value, doN.nextItem( list, index ) )
end

function doN.bindGen( bNode, list, index)
    return string.format( "%s( %s, function ( %s ) return\n%s end )", list.bind, bNode.value, bNode.var, doN.nextItem( list, index ) )
end


-- Call doNotation [[ blah ]] and then call load on the result
-- unless you want to do weird caching/env stuff loading at point
-- of usage is probably going to go better
function doNotation( str )
    local tokens = doN.lex( str, doN.tokenMaps )
    local pass, buffer, index, value = doN.parseDoNotation( tokens, 1 )
    if not pass then
        error "an error occurred while parsing the do notation"
    end
   
    return string.format( "return function( buffer, index )\n    return %s ( buffer, index )\nend", doN.nextItem( value, 0 ) )
end


-- input : string, tokMap : { pattern : regex; trans : [string] -> tok }
function doN.lex( input, tokMaps )
    
    local start = 1

    local tokens = {}

    while start <= #input do

        local success = false
        for _, map in ipairs( tokMaps ) do 
            local pattern = "^" ..  map.pattern .. "()"
            local result = { string.match( input, pattern, start ) }

            if result[1] then 

                local tok = map.trans( result ) 

                if tok.type ~= doN.tokenType.ignore then

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
        

