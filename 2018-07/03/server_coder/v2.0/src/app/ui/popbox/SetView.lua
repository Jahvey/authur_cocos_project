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
	--牌桌打开
	if opentype and opentype == 2 then
		self:initView_2()
	else
		self:initView()
	end
	self:initEvent()
end

function SetView:initData(opentype)

end

--大厅打开
function SetView:initView()
	self.widget = cc.CSLoader:createNode("ui/setView/setView.csb")

	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)
	
	self:initSliderEvent()

 	--按钮
 	local btn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(btn, function( )
		Notinode_instance:cancelGame(1)
	end)

end

--牌桌打开
function SetView:initView_2()
	self.widget = cc.CSLoader:createNode("ui/setView/setViewForGame.csb")

	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	--音乐，音效设置
	self:initSliderEvent()


	local btn = self.mainLayer:getChildByName("btn")
 	--按钮
	WidgetUtils.addClickEvent(btn, function( )
		Socketapi.request_releaseroom(true,true)
	end)

	local fixbtn = self.mainLayer:getChildByName("fixbtn")
	WidgetUtils.addClickEvent(fixbtn, function( )
		Notinode_instance:cancelGame(2)
	end)

	--切换桌布
	self.boxList = {}
 	local index = 1
	local box = self.mainLayer:getChildByName("changeBg"):getChildByName("CheckBox_"..index)
	while(box) do
		table.insert(self.boxList,box)
		box:setVisible(true)

	   	index = index +1
	   	box = self.mainLayer:getChildByName("changeBg"):getChildByName("CheckBox_"..index)
	end

	local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type",3)

	print("...........self.scene:getTableConf().ttype = ",self.scene:getTableConf().ttype)
	-- print(GT_INSTANCE:getGameStyle(self.scene:getTableConf().ttype))

	if 	GT_INSTANCE:getGameStyle(self.scene:getTableConf().ttype) == STYLETYPE.Poker then
		
		self.boxList[3]:setVisible(false)
		self.boxList[4]:setVisible(false)

		self.boxList[1]:getChildByName("label"):setString("清新绿")
		self.boxList[2]:getChildByName("label"):setString("深海蓝")

		bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker",1)

	elseif GT_INSTANCE:getGameStyle(self.scene:getTableConf().ttype) == STYLETYPE.MaJiang then
		
		self.boxList[4]:setVisible(false)
		self.boxList[1]:getChildByName("label"):setString("深海蓝")
		self.boxList[2]:getChildByName("label"):setString("清新绿")
		self.boxList[3]:getChildByName("label"):setString("舒适黄")

		bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_majiang",1)
	end

	for i,v in ipairs(self.boxList) do
		if  i == bg_type  then
			v:setSelected(true)
		else
			v:setSelected(false)
		end
		v.index = i
		v:addEventListener(function(sender)
			if sender:isSelected() then
				self:setbgstype(sender.index)
			end
		end)
	end


	-- 板式

	local styleboxes = {}-- checkbox
	local touchlayers = {}-- 点击层

	local stylemaps = {1,2,3}
	local style_type = LocalData_instance:getbaipai_stype()
	print("style_type:"..style_type)
	if GAME_CITY_SELECT ~= 5 then
		self.mainLayer:getChildByName("style"):getChildByName("CheckBox_"..2):setVisible(false)
		self.mainLayer:getChildByName("style"):getChildByName("touch_"..2):setVisible(false)
		self.mainLayer:getChildByName("style"):getChildByName("CheckBox_"..3):setVisible(false)
		self.mainLayer:getChildByName("style"):getChildByName("touch_"..3):setVisible(false)
	else
		self.mainLayer:getChildByName("style"):getChildByName("CheckBox_"..3):setVisible(false)
		self.mainLayer:getChildByName("style"):getChildByName("touch_"..3):setVisible(false)
	end
	--style_type = 1
	for i=1,3 do
		table.insert(styleboxes,self.mainLayer:getChildByName("style"):getChildByName("CheckBox_"..i))
		table.insert(touchlayers,self.mainLayer:getChildByName("style"):getChildByName("touch_"..i))
	end

	for i,v in ipairs(styleboxes) do
		if stylemaps[i] == style_type  then
			print("stylemaps:"..i)
			print("style_type:"..style_type)
			v:setSelected(true)
		else
			v:setSelected(false)
		end
		v.index = i
		if touchlayers[i] then
			touchlayers[i]:setTouchEnabled(true)
			WidgetUtils.addClickEvent(touchlayers[i],function ()
				print("===========================点击")
				LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "切换版式需要重连游戏，确认是否要切换版式？",sureCallFunc = function()
					for m,n in ipairs(styleboxes) do
						if m == i then
							n:setSelected(true)
						else
							n:setSelected(false)
						end
					end
					self:changeStyle(stylemaps[i])

                    end,cancelCallFunc = function()
                        -- body
                    end})
			end)
		end
	end


end
--设置
function SetView:initSliderEvent()
	--音乐，音效设置
	local voice = self.mainLayer:getChildByName("voice")
	self.voice_slider = voice:getChildByName("slider"):setMaxPercent(100)

	local music = self.mainLayer:getChildByName("music")
	self.music_slider = music:getChildByName("slider"):setMaxPercent(100)

    local function percentChangedEvent(sender,eventType)
        print(eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = (slider:getPercent() / slider:getMaxPercent() * 100)
            if sender.senderType == 1 then
            	self.voice_slider:setPercent(percent)	
				AudioUtils.setSoundsVolume(percent)
            elseif sender.senderType == 2 then	
            	self.music_slider:setPercent(percent)		
				AudioUtils.setMusicVolume(percent)
        	end
        elseif eventType == ccui.SliderEventType.slideBallUp then
           print("Slide Ball Up")
        elseif eventType == ccui.SliderEventType.slideBallDown then
            print("Slide Ball Down")
        elseif eventType == ccui.SliderEventType.slideBallCancel then
            print("Slide Ball Cancel")
        end
    end
    self.voice_slider.senderType = 1
    self.music_slider.senderType = 2
 	self.voice_slider:addEventListener(percentChangedEvent)
 	self.music_slider:addEventListener(percentChangedEvent)


 	local effectValue = tonumber(AudioUtils.getSoundsVolume())
	self.voice_slider:setPercent(effectValue)

	local musicValue = tonumber(AudioUtils.getMusicVolume())
	self.music_slider:setPercent(musicValue)
end

function SetView:setbgstype(index)

	if 	GT_INSTANCE:getGameStyle(self.scene:getTableConf().ttype) == STYLETYPE.Poker then
		cc.UserDefault:getInstance():setIntegerForKey("bg_type_poker",index)
	elseif GT_INSTANCE:getGameStyle(self.scene:getTableConf().ttype) == STYLETYPE.MaJiang then
		cc.UserDefault:getInstance():setIntegerForKey("bg_type_majiang",index)
	else
		cc.UserDefault:getInstance():setIntegerForKey("bg_type",index)
	end

	cc.UserDefault:getInstance():flush()
	for i,v in ipairs(self.boxList) do
		if  i == index  then
			v:setSelected(true)
			v:setTouchEnabled(false)
		else
			v:setSelected(false)
			v:setTouchEnabled(true)
		end
	end
	if self.scene then
		self.scene:setbgstype()
	end
end

function SetView:changeStyle(idx)
	print("---------changeStyle:"..idx)
	LocalData_instance:setbaipai_stype( idx )
	if SocketConnect_instance and SocketConnect_instance.socket then
		SocketConnect_instance.socket:close()
    end
end

function SetView:initEvent()

end
return SetView