-------------------------------------------------
--   TODO   设置UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local SetView = class("SetView",PopboxBaseView)
-- opentype 1 大厅打开 2 牌桌打开
function SetView:ctor(opentype,scene)
	self.scene = scene
	self:initData(opentype)
	self:initView()
	self:initEvent()
end

function SetView:initData(opentype)
	if opentype == nil then
		opentype = 1
	end
	self.opentype = opentype
end

function SetView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/setView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)
	self.layer = self.widget:getChildByName("layer")
	self.Slider_1 = self.mainLayer:getChildByName("Slider_1"):setMaxPercent(100)
	self.Slider_2 = self.mainLayer:getChildByName("Slider_2"):setMaxPercent(100)
	self.voiceOn = self.mainLayer:getChildByName("voiceOn"):setVisible(false)
	self.voiceOff = self.mainLayer:getChildByName("voiceOff"):setVisible(false)
	self.musicOn = self.mainLayer:getChildByName("musicOn"):setVisible(false)
	self.musicOff = self.mainLayer:getChildByName("musicOff"):setVisible(false)

	WidgetUtils.addClickEvent(self.voiceOn, function( )
		self:setIsOpen(1,0)
	end)
	WidgetUtils.addClickEvent(self.voiceOff, function( )
		self:setIsOpen(1,100)
	end)
	WidgetUtils.addClickEvent(self.musicOn, function( )
		self:setIsOpen(2,0)
	end)
	WidgetUtils.addClickEvent(self.musicOff, function( )
		self:setIsOpen(2,100)
	end)

	self.btn1 = self.mainLayer:getChildByName("btn1")
	self.btn2 = self.mainLayer:getChildByName("btn2")
	self.title1 = self.mainLayer:getChildByName("title1")
	self.title2 = self.mainLayer:getChildByName("title2")
	print("self.opentype:"..self.opentype)
	if self.opentype == 1 then
		self.btn1:setVisible(true)
		self.btn2:setVisible(false)
	elseif self.opentype == 2 then
		if self.scene.cctype == 2 then
			self.btn1:setVisible(false)
			self.btn2:setVisible(false)
		else
			self.btn1:setVisible(false)
			self.btn2:setVisible(true)
		end
	end
	WidgetUtils.addClickEvent(self.btn1, function( )
		self:btnCall()
	end)
	WidgetUtils.addClickEvent(self.btn2, function( )
		self.scene:exitbtncall()
	end)

    local function percentChangedEvent(sender,eventType)
        print(eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = (slider:getPercent() / slider:getMaxPercent() * 100)
            if sender.senderType == 1 then
            	self:setIsOpen(1,percent)
            elseif sender.senderType == 2 then	
            	self:setIsOpen(2,percent)
        	end
        elseif eventType == ccui.SliderEventType.slideBallUp then
           print("Slide Ball Up")
        elseif eventType == ccui.SliderEventType.slideBallDown then
            print("Slide Ball Down")
        elseif eventType == ccui.SliderEventType.slideBallCancel then
            print("Slide Ball Cancel")
        end
    end
    self.Slider_1.senderType = 1
    self.Slider_2.senderType = 2
 	self.Slider_1:addEventListener(percentChangedEvent)
 	self.Slider_2:addEventListener(percentChangedEvent)

	self:refreshView()
end
-- 设置音效音乐开关
function SetView:setIsOpen(type,value)
	if type == 1 then
		if value == 0 then
			self.voiceOn:setVisible(false)
			self.voiceOff:setVisible(true)
			self.Slider_1:setPercent(0)
		elseif value > 0 then
			self.voiceOn:setVisible(true)
			self.voiceOff:setVisible(false)
			if value == 100 then
				self.Slider_1:setPercent(100)
			end
		else
			self.Slider_1:setPercent(value)	
		end
		-- value = value / 100
		AudioUtils.setSoundsVolume(value)
	elseif type == 2 then
		if value == 0 then
			self.musicOn:setVisible(false)
			self.musicOff:setVisible(true)
			self.Slider_2:setPercent(0)
		elseif value > 0 then
			self.musicOn:setVisible(true)
			self.musicOff:setVisible(false)
			if value == 100 then
				self.Slider_2:setPercent(100)
			end
		else
			self.Slider_2:setPercent(value)		
		end
 		-- value = value / 100
		AudioUtils.setMusicVolume(value)
	end	
end
function SetView:refreshView()
	local effectValue = tonumber(AudioUtils.getSoundsVolume())
	self.Slider_1:setPercent(effectValue)
	self:setIsOpen(1,effectValue)
	local musicValue = tonumber(AudioUtils.getMusicVolume())
	self.Slider_2:setPercent(musicValue)
	self:setIsOpen(2,musicValue)
end

function SetView:btnCall()
	if self.opentype == 1 then
		print("退出登录")
		LocalData_instance:reset()
		cc.UserDefault:getInstance():setStringForKey("userid","")
		SocketConnect_instance:closeSocket()
		Notinode_instance:setisLogin(false)
		glApp:enterScene("LoginScene",true)
	elseif self.opentype == 2 then
		print("解散房间")
		 Socketapi.sendjiesan()
	end		
end
function SetView:initEvent()

end
return SetView