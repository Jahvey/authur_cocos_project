local NoviceGiftPackageView = class("NoviceGiftPackageView" , require "app.module.basemodule.BasePopBox") 

function NoviceGiftPackageView:initView()
	self.widget = cc.CSLoader:createNode("ui/noviceGiftPackage/noviceGift.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")


	self.jushu = self.mainLayer:getChildByName("jushu"):setString("")
	self.reward = self.mainLayer:getChildByName("redpack"):setString("")
	self.time = self.mainLayer:getChildByName("time"):setString("")
	self.content = self.mainLayer:getChildByName("content"):setString("")
	
	self.finishBtn1 = self.mainLayer:getChildByName("toFinish"):setVisible(false)
	self.finishBtn2 = self.mainLayer:getChildByName("shareReceive"):setVisible(false)
	self.finishBtn3 = self.mainLayer:getChildByName("haveFinish"):setVisible(false)
	WidgetUtils.addClickEvent(self.closeBtn,function ()
		-- body
		LaypopManger_instance:back()
	end)
end

--btn1未完成 btn2可领取 btn3已完成
function NoviceGiftPackageView:refreshContent(data)
	print("NoviceGiftPackageView [refreshContent]")
	printTable(data,"sjp3")
	-- body
	

	--领取按钮
	if data and data.type then

		dump(data)
		if data.type == 1 then
			self.finishBtn1:setVisible(true)
			WidgetUtils.addClickEvent(self.finishBtn1,function ()
				-- body
				LaypopManger_instance:backByName("NoviceGiftPackageView")
				ComHttp.httpPOST(ComHttp.URL.NOVICEGETREWARD,{uid = LocalData_instance.uid,type = 1},function(msg)
					print("tetetetett")
					printTable(msg,"sjp3")
					if not WidgetUtils:nodeIsExist(self) then
						return
					end
				end)
				LaypopManger_instance:PopBox("CreateRoomView",1)
			end)
		elseif data.type == 2 then
			self.finishBtn2:setVisible(true)
			local shareImge = ccui.ImageView:create("")
			shareImge:ignoreContentAdaptWithSize(true)  
			shareImge:setOpacity(0)
			shareImge:setVisible(false)
			NetPicUtils.getPic(shareImge, data.shareimg)
			WidgetUtils.addClickEvent(self.finishBtn2,function ()
				-- body
				self.isshareimg = true
				CommonUtils.activity_shareScreen(data.shareimg,1)
			end)
		elseif data.type == 3 then
			self.finishBtn3:setVisible(true)
		end
	end
	--加载局数
	if data.playnum then
		self.jushu:setString(data.playnum)
	end
	--加载红包
	if data.reward then
		self.reward:setString(data.reward)
	end
	--活动时间
	if data.starttime and data.endtime then
		local datetab_start = os.date("*t", data.starttime)
    	local str_start = string.format("%d.%02d.%02d",datetab_start.year,datetab_start.month,datetab_start.day)
    	local datetab_end = os.date("*t", data.endtime)
    	local str_end = string.format("%d.%02d.%02d",datetab_end.year,datetab_end.month,datetab_end.day)

    	self.time:setString(str_start .. "—" .. str_end)
	end
	--活动提示内容
	if data.content then
		self.content:setString(data.content)
	end
end
function NoviceGiftPackageView:onEnter()
	print("NoviceGiftPackageView [onEnter]")
	local eventDispatcher = self:getEventDispatcher()
	--微信分享回调
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			-- print("分享成功")
			if self.isshareimg then
				ComHttp.httpPOST(ComHttp.URL.NOVICEGETREWARD,{uid = LocalData_instance.uid,type = 2},function(msg)
					printTable(msg)
					if not WidgetUtils:nodeIsExist(self) then
						return
					end

					if msg.status == 1 then
						LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "分享成功"})
						self.finishBtn3:setVisible(true)
						elseif msg.status == 2 then
							LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "点击速度过快"})
							elseif msg.status == 3 then
								LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领奖失败未达到目标"})
								elseif msg.status == 4 then
									LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领奖失败"})
									elseif msg.status == 5 then
										LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "已经领过了"})
					end
				end)
			end
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	self:getConf()
end

function NoviceGiftPackageView:getConf()
	-- body
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.NOVICECONFIG,{uid = LocalData_instance.uid},function(msg)
			print("tetetetett")
			printTable(msg,"sjp3")
			if not WidgetUtils:nodeIsExist(self) then
				return
			end

			self:hideSmallLoading()

			if msg.status ~= 1 then
				return
			end
			self:refreshContent(msg)
		end)
end
return NoviceGiftPackageView