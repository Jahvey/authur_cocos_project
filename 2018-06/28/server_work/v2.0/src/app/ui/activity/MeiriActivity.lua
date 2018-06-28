local MeiriActivity = class("MeiriActivity",PopboxBaseView)

function MeiriActivity:ctor()
	self:initView()

	self:showSmallLoading()

end

function MeiriActivity:initView()

	print("............ MeiriActivity:initView() 。。。。。。")

	self.widget = cc.CSLoader:createNode("ui/activity/meiri/meiriActivtyview.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
		-- :setPosition(cc.p(display.width/2-40,display.height/2-40))

	-- self.scrollview = self.mainLayer:getChildByName("scrollView")
		-- :setContentSize(cc.size(display.width,display.height))
		-- :setPosition(cc.p(-display.width/2,-display.height/2))

	
	self.bg = self.mainLayer:getChildByName("bg") 
	--self.bg:setContentSize(cc.size(display.width,display.height))
	WidgetUtils.setBgScale(self.bg)
	WidgetUtils.setScalepos(self.mainLayer)
	self.bg:setPosition(cc.p(0,0))
	
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
		CommonUtils.requsetRedPoint()
		--self:openbox(self.box[1],1)
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("jilvbtn"), function( )
		LaypopManger_instance:PopBox("MeiriActivityjilv")
	end)

	self.time = self.mainLayer:getChildByName("timebg"):getChildByName("text")
	self.time:setVisible(false)
	self.kuang = {}
	self.kuang[1] = self.mainLayer:getChildByName("kuang1")
	self.kuang[2] = self.mainLayer:getChildByName("kuang2")
	self.kuang[3] = self.mainLayer:getChildByName("kuang3")
	self.box = {}
	self.box[1] = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/baoxiang_all.csb")
	self.box[1]:setPositionX(105.5)
	self.box[1]:setPositionY(60)
	self.kuang[1]:addChild(self.box[1])
	self.box[2] = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/baoxiang_all.csb")
	self.box[2]:setPositionX(105.5)
	self.box[2]:setPositionY(60)
	self.kuang[2]:addChild(self.box[2])
	self.box[3] = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/baoxiang_all.csb")
	self.box[3]:setPositionX(105.5)
	self.box[3]:setPositionY(60)
	self.kuang[3]:addChild(self.box[3])
	for i=1,3 do
		self.kuang[i]:setVisible(false)
	end
	self.kuang[1].box = self.box[1]
	self.kuang[2].box = self.box[2]
	self.kuang[3].box = self.box[3]
end

function MeiriActivity:setboxtype(box,index,type)
	box:stopAllActions()
	--type 1 为完成 2 完成为打开 3 已经打开 4 打开
	local chilren = box:getChildren()
	for i,v in ipairs(chilren) do
		v:setVisible(false)
	end
	if type == 1 then
		box:getChildByName("an1"):setVisible(true)
	elseif type == 2 then
		box:getChildByName("dianji_qian"):setVisible(true)
		box:getChildByName("dianji_qian"):getChildByName("xiangzi"):loadTexture("cocostudio/ui/activity/meiri/box"..index..".png", ccui.TextureResType.localType)
		local action = cc.CSLoader:createTimeline("ui/activity/meiri/baoxiang/baoxiang_all.csb")
		--AudioUtils.playEffect("zhuoji")
		local function onFrameEvent(frame)
	    	--print("action111")
	        -- if nil == frame then
	        --     return
	        -- end
	        -- local str = frame:getEvent()
	        -- if str == "end" then
	        -- 		node:removeFromParent()
	        -- end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		box:runAction(action)
		action:gotoFrameAndPlay(20,200,true)
	elseif type == 3 then
		box:getChildByName("an2"):setVisible(true)
		box:getChildByName("an2"):getChildByName("Image_8"):loadTexture("cocostudio/ui/activity/meiri/boxopen"..index..".png", ccui.TextureResType.localType)

	end
end
-- function MeiriActivity:openview(msg)
-- 	local node = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/zhanshi.csb")
-- 	self:addChild(node)
-- 	node:getChildByName("node"):setVisible(false)
-- 	local image = node:getChildByName("zhanshi"):getChildByName("Node_6"):getChildByName("Image_5")
-- 	if msg.type == 1 then
-- 		image:loadTexture("cocostudio/ui/activity/meiri/baoxiang/images/fangka_big.png", ccui.TextureResType.localType)
-- 		image:setContentSize(cc.size(377,224))
-- 	end
-- 	--image:updateSizeAndPosition()
-- 	local text = node:getChildByName("node"):getChildByName("di"):getChildByName("text")
-- 	text:setString(msg.content)
-- 	local action = cc.CSLoader:createTimeline("ui/activity/meiri/baoxiang/zhanshi.csb")
-- 		--AudioUtils.playEffect("zhuoji")
-- 		local function onFrameEvent(frame)
-- 	    	--print("action111")
-- 	        if nil == frame then
-- 	            return
-- 	        end
-- 	        local str = frame:getEvent()
-- 	        if str == "end" then
-- 	        	node:stopAllActions()
-- 	        	local action = cc.CSLoader:createTimeline("ui/activity/meiri/baoxiang/zhanshi.csb")
-- 	        	node:runAction(action)
-- 				action:gotoFrameAndPlay(105,187,true)
-- 			elseif str == "mid" then
-- 				node:getChildByName("node"):setVisible(true)
-- 	        end
-- 	    end
-- 	    action:setFrameEventCallFunc(onFrameEvent)

-- 		node:runAction(action)
-- 		action:gotoFrameAndPlay(0,105,false)

-- 	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("closeBtn"), function( )
-- 		node:removeFromParent()
-- 	end)
-- 	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("btn"), function( )
-- 		CommonUtils.shareScreen_2()
--     	ISFENXIANGMEIRIACTIVIEY = true
-- 	end)
-- end

function MeiriActivity:openview(msg)
	local node = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/zhanshi.csb")
	self:addChild(node)
	-- node:getChildByName("node"):setVisible(false)

	local actionnode = node:getChildByName("zhanshi")

	local image = actionnode:getChildByName("Node_1"):getChildByName("Node_24_0"):getChildByName("images")
	image:ignoreContentAdaptWithSize(true)
	if msg.type == 1 then
		image:loadTexture("cocostudio/ui/activity/meiri/hongbaohuodong/images/fangka_big.png", ccui.TextureResType.localType)
	else
		image:loadTexture("cocostudio/ui/activity/meiri/hongbaohuodong/images/hongbao_big.png", ccui.TextureResType.localType)
	end

	local text = node:getChildByName("node"):getChildByName("di"):getChildByName("text")
	text:setString(msg.content)

	local lightnode = node:getChildByName("light")

	local action1 = cc.CSLoader:createTimeline("ui/activity/meiri/hongbaohuodong/hongbaohuodong.csb")
	actionnode:runAction(action1)
	action1:gotoFrameAndPlay(0,false)

	local action2 = cc.CSLoader:createTimeline("ui/activity/meiri/hongbaohuodong/light.csb")
	lightnode:runAction(action2)
	action2:gotoFrameAndPlay(0,true)


	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("closeBtn"), function( )
		node:removeFromParent()
	end)
	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("btn"), function( )
		CommonUtils.shareScreen_2()
    	ISFENXIANGMEIRIACTIVIEY = true
	end)
end

function MeiriActivity:openbox(box,index,msg)
	box:stopAllActions()
	local chilren = box:getChildren()
	for i,v in ipairs(chilren) do
		v:setVisible(false)
	end
	box:getChildByName("dianji_hou"):setVisible(true)
	box:getChildByName("dianji_hou"):getChildByName("xiangzi"):loadTexture("cocostudio/ui/activity/meiri/box"..index..".png", ccui.TextureResType.localType)

	local action = cc.CSLoader:createTimeline("ui/activity/meiri/baoxiang/baoxiang_all.csb")
	--AudioUtils.playEffect("zhuoji")
	local times = 1
	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "mid" then
        	print("mid")
        	box:getChildByName("dakai"):setVisible(true)
        	box:getChildByName("dakai"):getChildByName("dianji_hou_0"):getChildByName("xiangzi_kai"):loadTexture("cocostudio/ui/activity/meiri/boxopen"..index..".png", ccui.TextureResType.localType)
        elseif str == "end" then
        	self:showreward(msg)
        end
	end
    action:setFrameEventCallFunc(onFrameEvent)

	box:runAction(action)
	action:gotoFrameAndPlay(200,270,false)
end

function MeiriActivity:showreward(data)

	local widget = cc.CSLoader:createNode("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p((display.cx-640)/2,0))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")

	if data.type == 1 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.content)
		icon:loadTexture("cocostudio/ui/wheelsurf/gongxihuode/icon_fangka.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.type == 2 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.content)
		icon:loadTexture("cocostudio/ui/wheelsurf/gongxihuode/icon_hongbao.png", ccui.TextureResType.localType)
		-- icon:setScale(0.7)
		icon:ignoreContentAdaptWithSize(true)
		-- if data.tipstr then
		-- 	widget:getChildByName("final"):getChildByName("info"):setString(data.tipstr)
		-- end
		-- self.needupdate = true
	end

	WidgetUtils.addClickEvent(btn, function( )
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")

    widget:runAction(action)
    action:gotoFrameAndPlay(0,false)

    local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/xuanzhuanguang.csd.csb")

    widget:getChildByName("FileNode_1"):runAction(action)
    action:gotoFrameAndPlay(0,true)
end

function MeiriActivity:openbox(box,index,msg)
	box:stopAllActions()
	local chilren = box:getChildren()
	for i,v in ipairs(chilren) do
		v:setVisible(false)
	end
	box:getChildByName("dianji_hou"):setVisible(true)
	box:getChildByName("dianji_hou"):getChildByName("xiangzi"):loadTexture("cocostudio/ui/activity/meiri/box"..index..".png", ccui.TextureResType.localType)

	local action = cc.CSLoader:createTimeline("ui/activity/meiri/baoxiang/baoxiang_all.csb")
	--AudioUtils.playEffect("zhuoji")
	local times = 1
	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "mid" then
        	print("mid")
        	box:getChildByName("dakai"):setVisible(true)
        	box:getChildByName("dakai"):getChildByName("dianji_hou_0"):getChildByName("xiangzi_kai"):loadTexture("cocostudio/ui/activity/meiri/boxopen"..index..".png", ccui.TextureResType.localType)
        elseif str == "end" then
        	self:showreward(msg)
        end
	end
    action:setFrameEventCallFunc(onFrameEvent)

	box:runAction(action)
	action:gotoFrameAndPlay(200,270,false)

end
--0不可领取，1已经领取，2待领取
function MeiriActivity:updatebox( kuang,index)

	print("玩局完成度.............")
	printTable(kuang.data,"sjp3")



	kuang:getChildByName("btn"):setVisible(false)
	if kuang.data.status == 0 then
		self:setboxtype(kuang.box,index,1)
		kuang:getChildByName("text"):setString(kuang.data.num.."/"..kuang.data.total)
	elseif kuang.data.status == 1 then
		self:setboxtype(kuang.box,index,3)
		kuang:getChildByName("text"):setString("已领取"):setPositionY(34)
		kuang:getChildByName("text_0"):setVisible(false)
	elseif kuang.data.status == 2 then
		self:setboxtype(kuang.box,index,2)
		kuang:getChildByName("text"):setString(kuang.data.num.."/"..kuang.data.total)
		kuang:getChildByName("btn"):setVisible(true)

		WidgetUtils.addClickEvent(kuang:getChildByName("btn"), function( )
			if ISFENXIANGMEIRIACTIVIEY then
				self:showSmallLoading()
				
				ComHttp.httpPOST(ComHttp.URL.DINGDIANWANPAIGET,{uid = LocalData_instance.uid,bid=kuang.data.bid},function(msg)
					
					print("sjp3.....................")

					if not WidgetUtils:nodeIsExist(self) then
						return
					end
					kuang:getChildByName("btn"):setVisible(false)
					printTable(msg,"sjp3")
					self:openbox(kuang.box,kuang.data.bid,msg)
					self:hideSmallLoading()

				end,nil,self.loadingView)
			else
				LaypopManger_instance:PopBox("MeiriActivitybox")
			end
		end)
			
	end
end
function MeiriActivity:onEndAni()
	ComHttp.httpPOST(ComHttp.URL.DINGDIANWANPAI,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end

			self:hideSmallLoading()
			printTable(msg,"sjp3")
			for i=1,3 do
				--msg.list[i].status = 2
				self.kuang[i].data = msg.list[i]
				self.kuang[i]:setVisible(true)
				self:updatebox( self.kuang[i],i)
			end
			self.time:setVisible(true)
			if msg.status == 1 then
				local datetab = os.date("*t", (msg.endtime - msg.servertime))
				print('time:'..(msg.endtime - msg.servertime))
       			local str = string.format("%02d:%02d:%02d",datetab.hour-8,datetab.min,datetab.sec)
       			self.time:setString(str)
       			self.time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
       				msg.servertime =  msg.servertime + 1
       				if (msg.endtime - msg.servertime) <= 0 then
       					self.time:setString("已结束")
       					self.time:stopAllActions()
       				else
	       				local datetab = os.date("*t", (msg.endtime - msg.servertime))
	       				local str = string.format("%02d:%02d:%02d",datetab.hour-8,datetab.min,datetab.sec)
	       				self.time:setString(str)
	       			end
       			end))))
			else
				self.time:setString("未开始")
				self.time:setAnchorPoint(cc.p(0.5,0.5))
				self.time:setPosition(cc.p(self.time:getParent():getContentSize().width/2,self.time:getParent():getContentSize().height/2))
			end


			
		end,nil,self.loadingView)
end
return MeiriActivity