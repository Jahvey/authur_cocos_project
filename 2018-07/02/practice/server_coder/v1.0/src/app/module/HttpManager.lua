HttpManager = class("HttpManager")

function HttpManager.regiterHttpUrl(name,url)
    ComHttp.URL[name] = url
end

return HttpManager