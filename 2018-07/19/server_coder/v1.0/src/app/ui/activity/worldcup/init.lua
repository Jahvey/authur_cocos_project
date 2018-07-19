local function loadModule()
	HttpManager.regiterHttpUrl("WCGETCONF","/Activity4/worldcup_main")
	HttpManager.regiterHttpUrl("WCGUESSGETLIST","/Activity4/worldcup_guess_datelist")
	HttpManager.regiterHttpUrl("WCGUESSGETDETAIL","/Activity4/worldcup_guess_gamelist")
	HttpManager.regiterHttpUrl("WCBET","/Activity4/worldcup_guess_bet")
	HttpManager.regiterHttpUrl("WCGUESSGETAWARD","/Activity4/worldcup_guess_getprize")
	HttpManager.regiterHttpUrl("WCTASKGETCONF","/Activity4/worldcup_play_config")
	HttpManager.regiterHttpUrl("WCTASKGETAWARD","/Activity4/worldcup_play_getprize")
	HttpManager.regiterHttpUrl("WCSIGNGETCONF","/Activity4/worldcup_signin_config")
	HttpManager.regiterHttpUrl("WCSIGNGETAWARD","/Activity4/worldcup_signin_getprize")
	HttpManager.regiterHttpUrl("WCSIGNSHARE","/Activity4/worldcup_signin_getshareprize")
	HttpManager.regiterHttpUrl("WCSHOPGETCONF","/Activity4/worldcup_exchange_config")
	HttpManager.regiterHttpUrl("WCSHOPBUY","/Activity4/worldcup_exchange_getprize")
	HttpManager.regiterHttpUrl("WCRANKGETRANKLIST","/Activity4/worldcup_rank_list")
	HttpManager.regiterHttpUrl("WCRANKGETPRIZELIST","/Activity4/worldcup_rank_prize")
	HttpManager.regiterHttpUrl("WCRANKGETPRIZE","/Activity4/worldcup_rank_getprize")
	HttpManager.regiterHttpUrl("WCSHOPGETDETAIL","/Activity4/worldcup_exchange_info")
	HttpManager.regiterHttpUrl("GETUSERINFO","/Activity4/user_contact")
	HttpManager.regiterHttpUrl("SETUSERINFO","/Activity4/user_contact_write")

	PopBoxManager.registerPopBox("WCMainView","app.ui.activity.worldcup.MainView")
	PopBoxManager.registerPopBox("WCBetBox","app.ui.activity.worldcup.BetBox")
	PopBoxManager.registerPopBox("WCTipBox","app.ui.activity.worldcup.TipBox")
	PopBoxManager.registerPopBox("WCConfirmBox","app.ui.activity.worldcup.ConfirmBox")
	PopBoxManager.registerPopBox("WCExchangeDetail","app.ui.activity.worldcup.ExchangeDetailBox")
	PopBoxManager.registerPopBox("WCAdressBox","app.ui.activity.worldcup.Receivingbox")
	PopBoxManager.registerPopBox("WCRuleBox","app.ui.activity.worldcup.RuleBox")
	PopBoxManager.registerPopBox("ShopTipBox","app.ui.activity.worldcup.ShopTipBox")
	PopBoxManager.registerPopBox("ShopTipBox2","app.ui.activity.worldcup.ShopTipBox2")
	PopBoxManager.registerPopBox("RankAwardTip","app.ui.activity.worldcup.RankAwardTip")

	ModuleManager.addEnterHallEvent(function ()
		ComHttp.httpPOST(ComHttp.URL.WCGETCONF,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if not ModuleManager.getHallView() or not WidgetUtils:nodeIsExist(ModuleManager.getHallView()) then
				return
			end 

			if msg.status ~= 1 then
				return
			end

			local actnode = ModuleManager.getHallView():getActNode(4)

			actnode:setVisible(true)

			local acticon = cc.CSLoader:createNode("ui/worldcup/anima/shijiebeirukou/shijiebeirukou.csb")
				:addTo(actnode:getChildByName("img"))
				:setPositionY(6)

			local action = cc.CSLoader:createTimeline("ui/worldcup/anima/shijiebeirukou/shijiebeirukou.csb")

			acticon:runAction(action)
			action:gotoFrameAndPlay(0,true)

			local touch = acticon:getChildByName("touch")

			WidgetUtils.addClickEvent(touch,function ()
				LaypopManger_instance:PopBox("WCMainView")
			end)

			-- local img = ccui.Button:create("ui/worldcup/icon.png")
			-- 	:addTo(actnode:getChildByName("img"))
			-- 	:setPositionY(6)
			-- WidgetUtils.addClickEvent(img,function ()
			-- 	LaypopManger_instance:PopBox("WCMainView")
			-- end)


			local btn = actnode:getChildByName("btn"):setTouchEnabled(true)

			WidgetUtils.addClickEvent(btn,function ()
				LaypopManger_instance:PopBox("WCMainView")
			end)
		end)
		print("==========大厅调用")
	end)
end

return loadModule