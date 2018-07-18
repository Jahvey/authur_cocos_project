local function loadModule()
	HttpManager.regiterHttpUrl("NOVICECONFIG","/Activity2/act_playtogetreward_getconfig")
	HttpManager.regiterHttpUrl("NOVICEGETREWARD","/Activity2/act_playtogetreward_report")
	PopBoxManager.registerPopBox("NoviceGiftPackageView","app.ui.activity.novicegiftpackage.NoviceGiftPackageView")

	ModuleManager.addEnterHallEvent(function ()
		ComHttp.httpPOST(ComHttp.URL.NOVICECONFIG,{uid = LocalData_instance.uid},function(msg)
			print("aaasssddd")
			printTable(msg,"sjp3")

			if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
				return
			end 
			print("aaasssddd")
			
			if msg.status ~= 1 then
				return
			end

			local actnode = ModuleManager.getHallView():getActNode(4)

			actnode:setVisible(true)

			local acticon = cc.CSLoader:createNode("ui/noviceGiftPackage/Entrance/wanpaihongbao/wanpaihongbao.csb")
				:addTo(actnode:getChildByName("img"))
				:setPositionY(-10)

			local action = cc.CSLoader:createTimeline("ui/noviceGiftPackage/Entrance/wanpaihongbao/wanpaihongbao.csb")

			acticon:runAction(action)
			action:gotoFrameAndPlay(0,true)

			local touch = acticon:getChildByName("touch")

			WidgetUtils.addClickEvent(touch,function ()
				LaypopManger_instance:PopBox("NoviceGiftPackageView")
			end)

			local btn = actnode:getChildByName("btn"):setTouchEnabled(true)

			WidgetUtils.addClickEvent(btn,function ()
				LaypopManger_instance:PopBox("NoviceGiftPackageView")
			end)
			LaypopManger_instance:PopBox("NoviceGiftPackageView")

		end)
		print("==========大厅调用")
	end)
end

return loadModule