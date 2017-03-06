
tokenType = 
{
    ignore = "ignore";
    int = "int";
    string = "string";
    symbol = "symbol";
    semicolon = "semicolon";
    equal = "equal";
    leftArrow = "leftArrow";
    rightArrow = "rightArrow";
    openParen = "openParen";
    closeParen = "closeParen";
    openCurly = "openCurly";
    closeCurly = "closeCurly";
    comma = "comma";


    -- keywords
    ["return"] = "return";
    term = "term";
    ["end"] = "end";
    lex = "lex";
    grammar = "grammar";
    main = "main";
    check = "check";
    empty = "empty";
    nothing = "nothing";
    insert = "insert";
    debug = "debug";
    map = "map";
    choice = "choice";
    endInput = "endInput";


}

tokenMaps = 
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
        pattern = [[%"(.-)%"]];
        trans = function ( s ) return { type = tokenType.string; value = s[1] } end
    },

    { 
        pattern = "%s";
        trans = function () return { type = tokenType.ignore } end
    },

    -- keywords

    {
        pattern = "return";
        trans = function () return { type = tokenType["return"] } end 
    },

    {
        pattern = "term";
        trans = function () return { type = tokenType.term } end 
    },

    {
        pattern = "endInput";
        trans = function () return { type = tokenType.endInput } end 
    },

    {
        pattern = "end";
        trans = function () return { type = tokenType["end"] } end 
    },

    {
        pattern = "lex";
        trans = function () return { type = tokenType.lex } end 
    },

    {
        pattern = "grammar";
        trans = function () return { type = tokenType.grammar } end 
    },

    {
        pattern = "main";
        trans = function () return { type = tokenType.main } end 
    },

    {
        pattern = "check";
        trans = function () return { type = tokenType.check } end 
    },

    {
        pattern = "empty";
        trans = function () return { type = tokenType.empty } end 
    },

    {
        pattern = "nothing";
        trans = function () return { type = tokenType.nothing } end 
    },

    {
        pattern = "insert";
        trans = function () return { type = tokenType.insert } end 
    },

    {
        pattern = "debug";
        trans = function () return { type = tokenType.debug } end 
    },

    {
        pattern = "map";
        trans = function () return { type = tokenType.map } end 
    },

    {
        pattern = "choice";
        trans = function () return { type = tokenType.choice } end 
    },

    -- keywords end

    { 
        pattern = "(%d+)";
        trans = function ( d ) 
            return { type = tokenType.int ; value = tonumber( d[1] ) } 
        end
    },

    {
        pattern = ",";
        trans = function () return { type = tokenType.comma } end
    },

    {
        pattern = ";";
        trans = function () return { type = tokenType.semicolon } end
    },

    {
        pattern = "=";
        trans = function () return { type = tokenType.assign } end
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


