
tokenType = 
{ 
    ignore = "ignore";
    int = "int";
    float = "float";
    string = "string";
    symbol = "symbol";
    dot = "dot";
    semicolon = "semicolon";
    colon = "colon";
    equal = "equal"; 
    notEqual = "notEqual";
    assign = "assign";
    mult = "mult";
    add = "add";
    sub = "sub";
    div = "div";
    openAngle = "openAngle";
    closeAngle = "closeAngle";
    openParen = "openParen";
    closeParen = "closeParen";
    openCurly = "openCurly";
    closeCurly = "closeCurly";
    openSquare = "openSquare";
    closeSquare = "closeSquare";
    typeTick = "typeTick";
    rightArrow = "rightArrow";
    leftArrow = "leftArrow";
    comma = "comma";


    -- keywords
    ["do"] = "do";
    unit = "unit";
    enum = "enum";
    ["or"] = "or";
    ["and"] = "and";
    xor = "xor";
    ["not"] = "not";
    struct = "struct";
    ["return"] = "return";
    yieldBreak = "yieldBreak";
    yieldReturn = "yieldReturn";
    func = "func"; 
    const = "const";
    ["else"] = "else";
    ["elseif"] = "elseif"; 
    ["if"] = "if";
    while = "while";
    break = "break";
    continue = "continue";
    ["in"] = "in";
    var = "var";
    pub = "pub";
    type = "type";
    using = "using";
    module = "module";
    foreach = "foreach"; 
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
