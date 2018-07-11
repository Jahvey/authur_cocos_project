local function loadModule()
	HttpManager.regiterHttpUrl("RECHARGEGETCONF","/Activity3/playertreasurebox_config")
	HttpManager.regiterHttpUrl("RECHARGEGETPRIZE","/Activity3/playertreasurebox_getprize")
	PopBoxManager.registerPopBox("RechargeView","app.ui.activity.rechargeact.RechargeView")

	ModuleManager.addEnterHallEvent(function ()
		ComHttp.httpPOST(ComHttp.URL.RECHARGEGETCONF,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
				return
			end 

			if msg.status ~= 1 then
				return
			end

			local actnode = ModuleManager.getHallView():getActNode(4)

			actnode:setVisible(true)

			local acticon = cc.CSLoader:createNode("ui/rechargeactivity/chongzhihuikui/chongzhihuikui.csb")
				:addTo(actnode:getChildByName("img"))
				:setPosition(cc.p(-4,6))

			local action = cc.CSLoader:createTimeline("ui/rechargeactivity/chongzhihuikui/chongzhihuikui.csb")

			acticon:runAction(action)
			action:gotoFrameAndPlay(0,true)

			local touch = acticon:getChildByName("touch")

			WidgetUtils.addClickEvent(touch,function ()
				LaypopManger_instance:PopBox("RechargeView")
			end)

			local btn = actnode:getChildByName("btn"):setTouchEnabled(true)

			WidgetUtils.addClickEvent(btn,function ()
				LaypopManger_instance:PopBox("RechargeView")
			end)
		end)
		print("==========大厅调用")
	end)
end

return loadModule