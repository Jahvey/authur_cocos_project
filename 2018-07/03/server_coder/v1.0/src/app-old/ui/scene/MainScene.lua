
local MainScene = class("MainScene",function()
    return cc.Scene:create()
end)


function MainScene:ctor()
    print("MainScene")
    AudioUtils.playMusic()
    self.table_id = nil
    self:initview()
end

function MainScene:initview()
	local HallView  = require "app.ui.hall.NewHallView"
	-- if GAME_CITY_SELECT == 1 or  GAME_CITY_SELECT == 4 then --第一个城市
	-- 	HallView  = require "app.ui.hall.NewHall_poker"
	-- end
	local HallView = HallView.new(self)
	self.HallView = HallView
	self:addChild(HallView)

	self:registerScriptHandler(function(state)
	    print("--------------"..state)
	    if state == "enter" then
	        self:onEnter()
	    elseif state == "exit" then
	    	self:onExit()
	    end
	end)

	LocalData_instance:setLaiZiValuer(-2) 
	if not SHENHEBAO then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
				ComHttp.httpPOST(ComHttp.URL.GETGAMETIPS,{uid = LocalData_instance.uid},function(msg)
			        local _list = {}
			        if  msg.list then
			        	for k,v in pairs(msg.list) do
			        		table.insert(_list,{gametype = tonumber(v.name),isFee = tonumber(v.tips)})
				        end
				        LocalData_instance:setFeeList(_list) 
			        end
			    end)
		end)))

		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
				ComHttp.httpPOST(ComHttp.URL.FANFKASALE,{uid = LocalData_instance.uid},function(msg)

					printTable(msg,"xp65")

					-- if msg.serverstatus == 1 then
				    	LocalData_instance:setSaleData(msg)
					-- end
			    end)
		end)))
	end


	-- if device.platform ~= "ios"  and  device.platform ~= "android" then
	-- 	return
	-- end

	if not SHENHEBAO then
		if device.platform ~= "windows" then
			self:runAction(cc.CallFunc:create(function(  )
				local msg = {}
				msg.resource = CONFIG_REC_VERSION
				msg.osversion = device.platform
				msg.channeltype = CLIENT_QUDAO
				msg.version = CLIENT_VERSION
				msg.uid = LocalData_instance:getUid()
				msg.areatype = cc.UserDefault:getInstance():getIntegerForKey("CITY_SELECT_SERVER",1)
				print('1')
				ComHttp.httpPOST( "/Tools/updategame",msg,function(msgdata)
					print("............")
					printTable(msgdata,"sjp3")

					if not WidgetUtils:nodeIsExist(self) then
						return
					end
					if msgdata.resource and msgdata.resource[1] then
						LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "游戏版本过低,是否更新游戏？",sureCallFunc = function()
							LocalData_instance:reset()
							SocketConnect_instance:closeSocket()
							Notinode_instance:setisLogin(false)
							glApp:enterScene("LoginScene",msgdata)
						end})
					end
				end)
			end))
		end
		
		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST(ComHttp.URL.GETNOTICEREDPOINT,{uid = LocalData_instance.uid},function(msg)
		        printTable(msg,"sjp3")
		        if not WidgetUtils:nodeIsExist(self) then
					return
				end
		        if msg.redpoint == 1 then
		            HASREDPOINT = true
		        else
		            HASREDPOINT = false
		        end

		        if msg.pop == 1 then
		        	if not POPACT then
		        		LaypopManger_instance:PopBox("NoticeActView",msg)
		        		POPACT = true
		        	end
		        end
		    end)
		end))

		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST(ComHttp.URL.GETSHAREURL,{uid = LocalData_instance.uid},function(msg)
		        printTable(msg)
		        if msg.domain and msg.domain ~= "" then
		        	ComHttp.shareAddress = msg.domain.."/mjapi/index.php"
		        end
		    end)
		end))

		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST(ComHttp.URL.IFRPGETCONF,{uid = LocalData_instance.uid},function(msg)
				printTable(msg)
				if not WidgetUtils:nodeIsExist(self) then
					return
				end 
				if msg.isshow == 1 then
					if not POPACT2 then
						LaypopManger_instance:PopBox("IFRPView")
						POPACT2 = true
					end
					self.HallView:showAct2()
				end
			end)
		end))

		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST(ComHttp.URL.NEWCOMMERGETCONF,{uid = LocalData_instance.uid},function(msg)
				print("==============newconmmeract")
				printTable(msg)
				if not WidgetUtils:nodeIsExist(self) then
					return
				end 
				if msg.canjoin == 1 then
					if cc.UserDefault:getInstance():getStringForKey("PopAct3","") ~= os.date("%m%d",os.time()) then
						LaypopManger_instance:PopBox("NewCommerAct")
						cc.UserDefault:getInstance():setStringForKey("PopAct3",os.date("%m%d",os.time()))
					end
					self.HallView:showAct3(msg)
				end
			end)
		end))

		-- self:runAction(cc.CallFunc:create(function()
		-- 	ComHttp.httpPOST(ComHttp.URL.ICAGETRED,{uid = LocalData_instance.uid},function(msg)
		-- 		printTable(msg,"pbz")
		-- 		if not WidgetUtils:nodeIsExist(self) then
		-- 			return
		-- 		end
		-- 		self.HallView:showAct4RedPoint(msg)

		-- 		end)
		-- end))

		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST("/Dogyear/getcommon",{uid = LocalData_instance.uid},function(msg)
				printTable(msg,"pbz")
				if not WidgetUtils:nodeIsExist(self) then
					return
				end
				if msg.status == 1 then
					-- if cc.UserDefault:getInstance():getStringForKey("PopAct5","") ~= os.date("%m%d",os.time()) then
					-- 	local Newyear  = require "app.ui.newyear.NewyearView"
					--     local newyear = Newyear.new()
					--     cc.Director:getInstance():getRunningScene():addChild(newyear)
					-- 	cc.UserDefault:getInstance():setStringForKey("PopAct5",os.date("%m%d",os.time()))
					-- end
					self.HallView:showAct5(msg)
				end

				end)
		end))

		self:runAction(cc.CallFunc:create(function()
			ComHttp.httpPOST(ComHttp.URL.RECALLGETLIST,{uid = LocalData_instance.uid},function(msg)
				printTable(msg)
				if not WidgetUtils:nodeIsExist(self) then
					return
				end
				if msg.status == 0 then
					return
				end
				self.HallView:showAct6(msg)
				-- if msg.chip > 0 then
				-- 	LaypopManger_instance:PopBox("RecallActivity",msg)
				-- else
				-- 	if cc.UserDefault:getInstance():getStringForKey("PopAct6","") ~= os.date("%m%d",os.time()) then
				-- 		LaypopManger_instance:PopBox("RecallActivity",msg)
				-- 		cc.UserDefault:getInstance():setStringForKey("PopAct6",os.date("%m%d",os.time()))
				-- 	end
				-- end
		    end)
		end))


		-- self:runAction(cc.CallFunc:create(function()
		-- 	ComHttp.httpPOST(ComHttp.URL.GETACTCONFIG2,{uid = LocalData_instance.uid},function(msg)
		-- 			printTable(msg,"sjp3")

		-- 			if not WidgetUtils:nodeIsExist(self) then
		-- 				return
		-- 			end 
		-- 			if msg.show == 1 then
		-- 				if not POPUNION then 
		-- 					LaypopManger_instance:PopBox("UnionActivity",msg)
		-- 					POPUNION = true
		-- 				end
		-- 				if self.HallView.invitebtn and self.HallView.light then
		-- 					self.HallView.invitebtn:setVisible(true)
		-- 					self.HallView.light:setVisible(true)
		-- 				end
		-- 			end
		-- 		end)
		-- 	end))

		-- self:runAction(cc.CallFunc:create(function()
		-- 	ComHttp.httpPOST(ComHttp.URL.GETINVITEACTSTATE,{uid = LocalData_instance.uid},function(msg)
		-- 		printTable(msg)
		-- 		if not WidgetUtils:nodeIsExist(self) then
		-- 			return
		-- 		end 
		-- 		if tonumber(msg.invite_open) == 1 or tonumber(msg.free_open) == 1 then
		-- 			if not INVITEACTPOP then 
		-- 				LaypopManger_instance:PopBox("InviteActivityView",msg)
		-- 				INVITEACTPOP = true
		-- 			end
		-- 			if self.HallView.invitebtn and self.HallView.light then
		-- 				self.HallView.invitebtn:setVisible(true)
		-- 				self.HallView.light:setVisible(true)
		-- 			end
		-- 		end
		-- 	end)
		-- end))
	end

	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
	    if MAINCLUBDATA then
	        LaypopManger_instance:backByName("MainViewclub")
	        LaypopManger_instance:PopBox("MainViewclub",MAINCLUBDATA)
	    end
	end)))
end

function MainScene:onEnter()
	if not SHENHEBAO then
		Notinode_instance:showLoadingByLogined()

		for i,v in ipairs(ModuleManager.getEnterHallEvent()) do
			v()
		end
	end
end

function MainScene:onExit()

end
function MainScene:havecreateTable(tid,type)
	print("已经创建了房间:".. tid)
	-- print("已经创建了房间: type ".. type)

	self.table_id = tid
	self.isPoker = GT_INSTANCE:getIsInThePokerList(type)
	self.isMaJiang = GT_INSTANCE:getIsInTheMaJiangList(type)

	-- 刷新大厅界面
	self.HallView:initMidNode()
end
return MainScene