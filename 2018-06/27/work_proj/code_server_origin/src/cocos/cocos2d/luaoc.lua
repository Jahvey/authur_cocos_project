
local luaoc = {}

local callStaticMethod = LuaObjcBridge.callStaticMethod
local methodzhuanhuan = {
    weixinsharepic = "sharepicforweixin",
    weixinshare = "shareforweixin",
    getDistance = "getDistance",
    getBatteryQuantity = "getBatteryQuantityfornew",
    getToken = "getToken",
    weixinInstance = "weixininstall",
    openUrl = "openUrl",
    copyClipboard = "copyClipboard",
    getUUID = "getUUID",
    zDong = "zhengDong",
    closed = "closeGame",
    iosPay = "iosPay",

    weixinLoginAction = "weixinLoginAction",
    getVersion = "getVersionfornew",
    getQuDaoNumber = "getQuDaoNumberfornew",
}
function luaoc.callStaticMethod(className, methodName, args)


    local ok, ret = callStaticMethod(className, methodzhuanhuan[methodName] or methodName, args)
    if not ok then
        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            print(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            print(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            print(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            print(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            print(msg .. "INVALID METHOD SIGNATURE")
        else
            print(msg .. "UNKNOWN")
        end
    end
    return ok, ret
end

return luaoc
