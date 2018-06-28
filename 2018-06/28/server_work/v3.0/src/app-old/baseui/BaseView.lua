BaseView = class("BaseView",function()
    return cc.Layer:create()
end)
function BaseView:ctor()
    self:initview()
end
function BaseView:initview()

end
return BaseView