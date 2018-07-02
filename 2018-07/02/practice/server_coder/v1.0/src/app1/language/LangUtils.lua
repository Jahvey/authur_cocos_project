-------------------------------------------------
--   TODO   语言工具
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
LangUtils = {}
local Words 
Words = require("app.language.LangWords")
function LangUtils:getStr( key )
    if Words[key] then
        return Words[key]
    else
        return "@"..key
    end
end
return LangUtils