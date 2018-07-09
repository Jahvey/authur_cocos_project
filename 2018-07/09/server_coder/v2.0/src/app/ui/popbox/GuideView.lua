-------------------------------------------------
--   TODO   消息UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local GuideView = class("GuideView",PopboxBaseView)
function GuideView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function GuideView:initData()

end
function GuideView:initView()
	self.widget = cc.CSLoader:createNode("ui/guide/guideView.csb")
	self:addChild(self.widget)

	local mainLayer = self.widget:getChildByName("main")
	local pageview = mainLayer:getChildByName("pageView")

	local pointtable = {}
	local pointnode = mainLayer:getChildByName("pointnode")
	pointnode:removeAllChildren()

	local num = 3
	for i=1,num do
		local point = ccui.ImageView:create("common/blackpoint.png")
	        	:addTo(pointnode)
	        	:setPositionX((-(num-1)/2+i-1)*30)

	    table.insert(pointtable,point)
	end

	local function setPointLight(index)
		for i,v in ipairs(pointtable) do
			if i == index then
				v:loadTexture("common/whitepoint.png")
			else
				v:loadTexture("common/blackpoint.png")
			end
		end
	end

	local function onClickPageViewCallBack()
        local index = pageview:getCurrentPageIndex() + 1
        if index ~= 0 then
        	setPointLight(index)
        end

        if index == 3 then
        	mainLayer:getChildByName("arrow"):setVisible(false)
        	mainLayer:getChildByName("finger"):setVisible(false)
        else
        	mainLayer:getChildByName("arrow"):setVisible(true)
        	mainLayer:getChildByName("finger"):setVisible(true)
        end
    end
    pageview:addEventListener(onClickPageViewCallBack)
	self:scheduleUpdateWithPriorityLua(onClickPageViewCallBack,0)
	setPointLight(1)

	local btn_start = pageview:getChildByName("page_3"):getChildByName("btn_start")
	WidgetUtils.addClickEvent(btn_start, function( )
		print("加入房间")
		LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(pageview:getChildByName("page_3"), function( )
		LaypopManger_instance:back()
	end)

	local finger = mainLayer:getChildByName("finger")
	local beganposx = finger:getPositionX()
	local moveTo = cc.MoveBy:create(0.8,cc.p(-250,0))
	finger:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo,cc.DelayTime:create(0.2),cc.CallFunc:create(function ()
		finger:setPositionX(beganposx)
	end))))

	local arrow = mainLayer:getChildByName("arrow")
	local fadeIn = cc.FadeIn:create(0.8)
	local fadeOut = cc.FadeOut:create(0.5)
	arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeIn,fadeOut)))
end
function GuideView:initEvent()
end
return GuideView