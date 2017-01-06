
tokenType = 
{ 
    ignore = "ignore";
    int = "int";
}

tokenMaps = 
{
    { 
        pattern = "%s";
        trans = function () return { type =  tokenType.ignore } end
    },

    { 
        pattern = "(%d+)";
        trans = function ( d ) 
            return { type = tokenType.int ; value = tonumber( d[1] ) } 
        end
    },



}
