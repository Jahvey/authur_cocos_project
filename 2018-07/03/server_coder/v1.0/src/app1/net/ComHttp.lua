-------------------------------------------------
--   TODO   httpÇëÇó
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

ComHttp = {}

ComHttp.HTTP_ADDRESS = "http://47.96.180.57:8090"
---ComHttp.HTTP_ADDRESS = "http://139.224.26.40:8083"
ComHttp.loginadress = ""
--table×ªurl
ComHttp.URL = {
    CHECKRESOURCE = "/ZGameAccountDongXiang/version/getVersionInfo",
    LOGIN = "/ZGameAccountDongXiang/user/weixinlogin",
    GUESTLOGIN = "/ZGameAccountDongXiang/user/touristlogin",
    SHAER= "/ZGameAccountDongXiang/user/sharegetcoin" 
}


function ComHttp.httpPOST( address,table,callback,isencry)

    -- table["channeltype"] = CLIENT_QUDAO
    -- table["osversion"] = device.platform
    -- table["resversion"] = CONFIG_REC_VERSION
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", ComHttp.HTTP_ADDRESS..address)
    print('address:'..ComHttp.HTTP_ADDRESS..address)
    local function responsecallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("success")
            local response   = xhr.response
            local output = cjson.decode(response)
            if output.result == nil then
                Notinode_instance:showLoading(false)
            elseif output.result == 1 then
                if callback then
                    callback(output)
                end
            elseif output.result == 0 then
                print(output.serverinfo)
                Notinode_instance:showLoading(false)
                if callback then
                    callback(output)
                end
                LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = output.resultinfo})
            else
                if callback then
                    callback(output)
                end
                print("不存在的 result")
            end
        else
            print(" HTTP 网页 出错 了, 或者没有网络")
            --网络连接错误
            -- self:popbox(getStr("checkversion_title8"),function()
            --     self:checkversion()
            -- end)
            -- http error
        end
    end 
    local poststr = json.encode(table,1)
    
    xhr:registerScriptHandler(responsecallback)
    print("sd:"..poststr..CryTo:Md5(poststr.."zgameMd5"))
    xhr:send(poststr..CryTo:Md5(poststr.."zgameMd5")) 
    return xhr
end


function ComHttp.shareback()

    ComHttp.httpPOST( ComHttp.URL.SHAER,{userid = LocalData_instance:getUid()},function(data)
        end)
end



