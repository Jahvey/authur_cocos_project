local function loadModule()
	HttpManager.regiterHttpUrl("WHEELGETCONF","/Activity3/turntable_config")
	HttpManager.regiterHttpUrl("WHEELGETCHANCE","/Activity3/turntable_getchance")
	HttpManager.regiterHttpUrl("WHEELGETPRIZE","/Activity3/turntable_getprize")
	HttpManager.regiterHttpUrl("WHEELEXCHANGE","/Activity3/turntable_exchange")
	PopBoxManager.registerPopBox("WheelSurfView","app.ui.activity.wheelsurf.WheelView")
	PopBoxManager.registerPopBox("WheelInfoBox","app.ui.activity.wheelsurf.InfoBox")

	ModuleManager.addEnterHallEvent(function ()
		ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
				return
			end 

			if msg.status ~= 1 then
				return
			end

			local actnode = ModuleManager.getHallView():getActNode(2)

			actnode:setVisible(true)

			local acticon = cc.CSLoader:createNode("ui/wheelsurf/dalunpan_rukou/dalunpan_rukou.csb")
				:addTo(actnode:getChildByName("img"))
				:setPositionY(6)

			local action = cc.CSLoader:createTimeline("ui/wheelsurf/dalunpan_rukou/dalunpan_rukou.csb")

			acticon:runAction(action)
			action:gotoFrameAndPlay(0,true)

			local touch = acticon:getChildByName("touch")

			WidgetUtils.addClickEvent(touch,function ()
				LaypopManger_instance:PopBox("WheelSurfView")
			end)

			local btn = actnode:getChildByName("btn"):setTouchEnabled(true)

			WidgetUtils.addClickEvent(btn,function ()
				LaypopManger_instance:PopBox("WheelSurfView")
			end)
		end)
		print("==========大厅调用")
	end)
end

return loadModule