local function loadModule()
	HttpManager.regiterHttpUrl("MATCHGETMAINLIST","/Arena/main")
	HttpManager.regiterHttpUrl("MATCHGETMATCHLIST","/Arena/list_info")
	HttpManager.regiterHttpUrl("MATCHGETDETAIL","/Arena/overview")
	HttpManager.regiterHttpUrl("MATCHGETRECORD","/Arena/game_log")
	HttpManager.regiterHttpUrl("MATCHGETAWARDLIST","/Arena/prize_config")
	HttpManager.regiterHttpUrl("MATCHGETAWARD","/Arena/game_getprize")

	PopBoxManager.registerPopBox("MatchView","app.ui.match.MatchView")
	PopBoxManager.registerPopBox("MatchDetailBox","app.ui.match.DetailBox")
	PopBoxManager.registerPopBox("MatchRecordlBox","app.ui.match.RecordBox")
	PopBoxManager.registerPopBox("MatchConfirmBox","app.ui.match.ConfirmBox")
	PopBoxManager.registerPopBox("MatchTipBox","app.ui.match.TipBox")


	-- ModuleManager.addEnterHallEvent(function ()
	-- 	ComHttp.httpPOST(ComHttp.URL.WCGETCONF,{uid = LocalData_instance.uid},function(msg)
	-- 		printTable(msg)
	-- 		if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
	-- 			return
	-- 		end 

	-- 		if msg.status ~= 1 then
	-- 			return
	-- 		end

	-- 		if cc.UserDefault:getInstance():getIntegerForKey("NEW_MAIN",0) == 1 then

	-- 			ModuleManager.getHallView():showActNode(3,"ui/worldcup/anima/shijiebeirukou/shijiebeirukou.csb",function ()
	-- 				LaypopManger_instance:PopBox("WCMainView")
	-- 			end,cc.p(0,-20))
			
	-- 		elseif cc.UserDefault:getInstance():getIntegerForKey("NEW_MAIN",0) == 2 then
	-- 			ModuleManager.getHallView():showActNode(3,"ui/worldcup/anima/shijiebeirukou/shijiebeirukou.csb",function ()
	-- 				LaypopManger_instance:PopBox("WCMainView")
	-- 			end,cc.p(0,6))
	-- 		end
	-- 	end)
	-- 	print("==========大厅调用")
	-- end)
end

return loadModule