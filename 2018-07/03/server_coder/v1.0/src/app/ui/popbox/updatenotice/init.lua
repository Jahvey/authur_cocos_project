local function loadModule()
	HttpManager.regiterHttpUrl("GETUPDATENOTICE","/Tools/announcement")
	PopBoxManager.registerPopBox("UpdateNoticeBox","app.ui.popbox.updatenotice.UpdateNoticeBox")


	ModuleManager.addEnterHallEvent(function ()
		ComHttp.httpPOST(ComHttp.URL.GETUPDATENOTICE,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
				return
			end 

			if msg.status ~= 1 then
				return
			end

			LaypopManger_instance:PopBox("UpdateNoticeBox",msg)
		end)
		print("==========大厅调用")
	end)
end

return loadModule