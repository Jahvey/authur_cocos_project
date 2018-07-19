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
function HeadIcon:ctor(icon,path,widthicon,framepath)
	self:initView(icon,path,widthicon,framepath)
end

function HeadIcon:initView(icon,path,widthicon,framepath)
    if widthicon == nil  then
        widthicon = 88
    end
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
        -- self.headicon:setScale(widthicon/88)
        
        self.headicon.downcallback = function(image)
        print("==========下载调用")
        print(image:getContentSize().width)
        print(image:getContentSize().height)
            local size =  image:getContentSize()
            -- image:setScaleX(widthicon/size.width)
            -- image:setScaleY(widthicon/size.height)
            image:setScale9Enabled(true)
            image:setCapInsets(cc.rect(0, 0, size.width,size.height))
            image:setContentSize(cc.size(widthicon,widthicon))
        end
        NetPicUtils.getPic(self.headicon, path )
    else
       	print("path 为空")
       	self.headicon = ccui.ImageView:create("common/head.png")
        self.headicon:setScale9Enabled(true)
        self.headicon:setCapInsets(cc.rect(0, 0, 88,88))
        self.headicon:setContentSize(cc.size(widthicon,widthicon))
    end
    if self.headicon then
    	self.headicon:setTouchEnabled(true)
        self:addChild(self.headicon,1)
    end	

    print("=============这里")
    if framepath then
        print("头像框！！！！！")
        print(framepath)
        local headframe = ccui.ImageView:create(framepath)
            :addTo(self,1)
            :setPosition(cc.p(self.headicon:getPositionX(),self.headicon:getPositionY()))
            :setScale(widthicon/84)
    end
end
function HeadIcon:updataView(path,data)
 	if path and path ~= "" then
        self.headicon = ccui.ImageView:create("heads/head.png")
        self.headicon.downcallback = function(image)
            local size =  image:getContentSize()
            image:setScaleX(widthicon/size.width)
            image:setScaleY(widthicon/size.height)
        end
        NetPicUtils.getPic(self.headicon, path )
    else
       	print("path 为空")
    end
end
return HeadIcon