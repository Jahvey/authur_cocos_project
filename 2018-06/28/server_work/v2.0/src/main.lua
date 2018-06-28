
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
cjson = require "cjson"
print = release_print  
CONFIG_DEBUG = true
SHENHEBAO = false
-- 是否多开
-- -- 错误上报
if not CONFIG_DEBUG then
    print = function() end
end  
--是否有新的反馈sdk 
if device.platform == "android" then
    IS_NEWFAKUI = true
else
    IS_NEWFAKUI = false
end
function printpos(pos,data)
    if data then
        print(data.."=".."x:"..pos.x.."y:"..pos.y)
    else
        print("x:"..pos.x.."y:"..pos.y)
    end
end
function printTable(obj,str)

    if str == nil or str ~= "sjp3" then
        return
    end
    -- if CONFIG_DEBUG == false then
    --     return
    -- end

    local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        str = string.gsub(str, "[%c\\\"]", {
            ["\t"] = "\\t",
            ["\r"] = "\\r",
            ["\n"] = "\\n",
            ["\""] = "\\\"",
            ["\\"] = "\\\\",
        })
        return '"' .. str .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "   [" .. val .. "]"
        elseif type(val) == "string" then
            return "   [" .. quoteStr(val) .. "]"
        else
            return "   [" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    local isArray = function(arr)
        local count = 0 
        for k, v in pairs(arr) do
            count = count + 1 
        end 
        for i = 1, count do
            if arr[i] == nil then
                return false
            end 
        end 
        return true, count
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local addstr = ""
        for i =1 ,level do
            addstr = addstr.."  "
        end
        local tokens = {}
        tokens[#tokens + 1] = string.sub(addstr,0,-6).."{"
        local ret, count = isArray(obj)
        if ret then
            for i = 1, count do
                tokens[#tokens + 1] = addstr..getIndent(level) .. wrapVal(obj[i], level) .. ","
            end
        else
            for k, v in pairs(obj) do
                tokens[#tokens + 1] = addstr..getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
            end
        end
        tokens[#tokens + 1] = addstr..getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    if forcePrint then
        release_print(dumpObj(obj, 0))
    else
        print(dumpObj(obj, 0))
    end
end
function __G__TRACKBACK__(errorMessage)

    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    
    if CONFIG_DEBUG then
        local errorlabel = cc.Label:createWithSystemFont(tostring(errorMessage)..debug.traceback(), "", 30, cc.size(display.cx*2, display.cy*2), cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        errorlabel:setPosition(display.width/2,display.height/2)
        errorlabel:setColor(cc.c3b(255, 0, 0))
        if cc.Director:getInstance():getNotificationNode() == nil then
            cc.Director:getInstance():setNotificationNode(cc.Node:create())
        end
        cc.Director:getInstance():getNotificationNode():addChild(errorlabel,10)
    end

    if CONFIG_DEBUG == true then
        return 
    end

    require('app.net.ComHttp')
    local crashinfo = tostring(errorMessage) .. "\n" .. tostring(debug.traceback("", 2))
    if LocalData_instance and LocalData_instance.uid then
        ComHttp.httpPOST(ComHttp.URL.REPORT_CRASH,{gameversion = CONFIG_REC_VERSION,crashinfo = crashinfo,uid = LocalData_instance.uid },function()
           print("上报成功")
        end)
    else
        ComHttp.httpPOST(ComHttp.URL.REPORT_CRASH,{gameversion = CONFIG_REC_VERSION,crashinfo = crashinfo},function()
           print("上报成功")
        end)
    end
end
local function main()
    LOCALANDROIDPATH = "com/jrpkhj/arthur/wxapi/WXEntryActivity"
     if  cc.UserDefault:getInstance():getIntegerForKey("isfirstinstall1",0) == 0 then
        local path = cc.FileUtils:getInstance():getWritablePath().."appdata"
        print(path)
        if cc.FileUtils:getInstance():removeDirectory(path) then
            print("remove path")
            --cc.FileUtils:getInstance():removeDirectory(path)
        else
            print("path bu cunzai")
        end
        cc.UserDefault:getInstance():setIntegerForKey("isfirstinstall1",1)
    end

   require "LuaToc++"

    require("app.MyApp").new():run()
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end


