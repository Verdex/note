

function fold( c, i, l )
    assert( c ~= nil, "the collector function cannot be nil" )
    assert( i ~= nil, "the initial item cannot be nil" )
    assert( l ~= nil, "the list cannot be nil" )

    local sum = i

    for _, llet in ipairs( l ) do
        sum = c( sum, llet )
    end

    return sum
end

function display( t )
    if type( t ) ~= "table" then
        return tostring( t )
    end
    local records = {}
    for k, v in pairs( t ) do
        if type( k ) ~= "number" then
            table.insert( records, { k, v } )
        end
    end
    local r_part = "" 
    if #records > 0 then
        local r = fold( function( a, b ) return a .. " " .. tostring( b[1] ) .. " = " .. display( b[2] ) end, "", records )
        r_part = "{" .. r .. " }"
    end

    local array = {}
    for _, v in ipairs( t ) do
        table.insert( array, v )
    end
    local a_part = "" 
    if #array > 0 then
        a_part = fold( function( s, v ) return s .. " " .. display( v ) end, "", array ) 
    end
    
    if a_part ~= "" and r_part ~= "" then
        return string.format( "-| %s %s |-", r_part, "[ " .. a_part .. " ]" )
    elseif a_part ~= "" then
        return "[" .. a_part .. " ]"
    elseif r_part ~= "" then
        return r_part 
    else
        return "()"
    end
end

function insert( table, index, value )
    table.insert( table, index, value )
    return table
end

