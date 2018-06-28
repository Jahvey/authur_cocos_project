------------------------------
-- 头像
-- @yc 2016/11/4
------------------------------
local HeadIcon = class("HeadIcon", function()
    return cc.Node:create()
end)

local IconTAG = "65545"
-- icon 头像父节点
-- path 头像路径
-- bgtype 头像外框
-- 所有的数据 包含vip_level
function HeadIcon:ctor(icon,path,bgtype,data)
	self:initView(icon,path,bgtype,data)
end

function HeadIcon:initView(icon,path,bgtype,data)
    self.icon = icon
    if icon:getChildByTag(IconTAG) then
        icon:removeChildByTag(IconTAG)
    end
    self:setTag(IconTAG)
    icon:addChild(self)
    self:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2))
    icon:setOpacity(0)

    if path and path ~= "" then
        self.headicon = ccui.ImageView:create("common/head.png")
        self.headicon.downcallback = function(image)
            local size =  image:getContentSize()
            image:setScaleX(88/size.width)
            image:setScaleY(88/size.height)
        end
        NetPicUtils.getPic(self.headicon, path )
    else
       	--print("path 为空")
       	self.headicon = ccui.ImageView:create("common/head.png")
        local size =  self.headicon:getContentSize()
        self.headicon:setScaleX(88/size.width)
        self.headicon:setScaleY(88/size.height)
    end
    if self.headicon then
    	self.headicon:setTouchEnabled(false)
        self:addChild(self.headicon,1)
    end	
end
function HeadIcon:updataView(path,data)
 	if path and path ~= "" then
        self.headicon = ccui.ImageView:create("heads/head.png")
        self.headicon.downcallback = function(image)
            local size =  image:getContentSize()
            image:setScaleX(88/size.width)
            image:setScaleY(88/size.height)
        end
        NetPicUtils.getPic(self.headicon, path )
    else
       	--print("path 为空")
    end
end
return HeadIcon