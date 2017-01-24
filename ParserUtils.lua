

-- parser function : ( buffer, index ) -> ( successful, buffer, index, value )
-- parser function : ( buffer, index ) -> ( failure, index )

function choice( parsers )
    return function ( buffer, index ) 
        for _, p in ipairs( parsers ) do
            local success, resBuffer, resIndex, value = p( buffer, index )
            if success then
                return true, resBuffer, resIndex, value
            end
        end
        return false, index
    end
end

function unit( value )
    return function ( buffer, index )
        return true, buffer, index, value
    end
end

function bind( parser, gen )
    return function ( buffer, index )
        if index > #buffer then
            return false, index
        end
        local success, resBuffer, resIndex, value = parser( buffer, index )
        if success then
            local nextParser = gen( value )
            return nextParser( resBuffer, resIndex )
        else
            return false, index
        end
    end
end

function match( tokenType, trans )
    return function ( buffer, index )
        if index > #buffer then
            return false, index
        end
        if buffer[index].type == tokenType then
            return true, buffer, index + 1, trans( buffer[index] )
        else
            return false, index
        end
    end
end

function check( tokenType )
    return function ( buffer, index )
        if index > #buffer then
            return false, index
        end
        if buffer[index].type == tokenType then
            return true, buffer, index + 1, nil 
        else
            return false, index
        end
    end
end

function endInput( buffer, index )
    if #buffer < index then
        return true, buffer, index, nil
    else
        return false, index
    end
end

function doThis( action )
    return function ( buffer, index )
        action()
        return true, buffer, index, nil
    end
end

function map( parser, trans )
    return function ( buffer, index )
        local success, resBuffer, resIndex, value = parser( buffer, index )
        if success then
            return true, resBuffer, resIndex, trans( value )
        else
            return false, index
        end
    end
end

