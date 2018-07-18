local OpenView = class("OpenView",require "app.module.basemodule.BasePopBox")

function OpenView:initData(data,fuc)
	self.data = data
	self.num = 1
	self.minnum = 1
	self.maxnum = data.num
end

function OpenView:initView(data,fuc)
	self.widget = cc.CSLoader:createNode("ui/bag/openbox/openbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	local img = self.mainLayer:getChildByName("img"):ignoreContentAdaptWithSize(true)
	local name = self.mainLayer:getChildByName("name")
	local ownnum = self.mainLayer:getChildByName("ownnum")
	local totalnum = self.mainLayer:getChildByName("totalnum")

	name:setString(data.name)
	NetPicUtils.getPic(img, data.img)
	ownnum:setString(data.num)
	totalnum:setString("/"..data.num)
	
	local slider = self.mainLayer:getChildByName("slider")
	local btnminus = self.mainLayer:getChildByName("minus")
	local btnplus = self.mainLayer:getChildByName("plus")

	local function percentChangedEvent(sender,eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local slider = sender
			local percent = (slider:getPercent() / slider:getMaxPercent() * 100)
			self.num = math.ceil(percent*(self.maxnum-1)/100) + 1
			self:refreshNum()
		elseif eventType == ccui.SliderEventType.slideBallUp then
			print("Slide Ball Up")
			
		elseif eventType == ccui.SliderEventType.slideBallDown then
		    print("Slide Ball Down")
		elseif eventType == ccui.SliderEventType.slideBallCancel then
		    print("Slide Ball Cancel")
		end
    end

 	slider:addEventListener(percentChangedEvent)

 	WidgetUtils.addClickEvent(btnminus,function ()
 		self.num = math.max(self.num - 1,self.minnum)
 		self:setSlider()
 		self:refreshNum()
 	end)

 	WidgetUtils.addClickEvent(btnplus,function ()
 		self.num = math.min(self.num + 1,self.maxnum)
 		self:setSlider()
 		self:refreshNum()
 	end)

	local surebtn = self.mainLayer:getChildByName("surebtn")
	WidgetUtils.addClickEvent(surebtn,function ()
		fuc(self.num)
		LaypopManger_instance:backByName("BagOpenBox")
	end)

	self:setSlider()
	self:refreshNum()
end

function OpenView:setSlider()
	local slider = self.mainLayer:getChildByName("slider")
	if self.minnum == self.maxnum then
		slider:setPercent(100)
	else
		slider:setPercent((self.num-1)/(self.maxnum-1)*100)
	end
end

function OpenView:refreshNum()
	local nownum = self.mainLayer:getChildByName("nownum")
	local totalnum = self.mainLayer:getChildByName("totalnum")
	nownum:setString(self.num)
	totalnum:setPositionX(nownum:getPositionX()+nownum:getContentSize().width)
end

function OpenView:onEnter()
end

function OpenView:onExit()
end

return OpenView