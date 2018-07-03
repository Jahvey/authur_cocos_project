-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor(gametype)
	self.gametype = gametype
	self:initData()
	self:initView()
	self:initEvent()
end
function HelpView:initData()

end

function HelpView:initView()
	self.widget = cc.CSLoader:createNode("ui/daikai/joinRoomView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	self.listView = self.mainLayer:getChildByName("listview")
	local item = self.mainLayer:getChildByName("cell")
	item:retain()
	self.listView:setItemModel(item)
	item:removeFromParent()
	item:release()
end
function HelpView:onEndAni(  )
	if self.gametype== 2 then
		Socketapi.getdailikaifforkutong()
	else
		Socketapi.getdailikaif()
	end
end
function HelpView:createcallback(data )
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
		return
	end
	self.listView:removeAllItems()
	for i,v in ipairs(data.roominfoniuniulist) do
		if i%3 == 1 then
			self.listView:pushBackDefaultItem()
		end
		local item = self.listView:getItem(math.floor((i-1)/3))
		local bg = item:getChildByName("bg"..i%3)
		bg:setVisible(true)
		local btn1 = bg:getChildByName("btn1")
		local btn2 = bg:getChildByName("btn2")
		if v.status == 1 then
			btn1:setVisible(false)
			btn2:setVisible(false)
			bg:getChildByName("tip"):setVisible(false)
		else
			bg:getChildByName("tip"):setVisible(true)
			btn1:setVisible(true)
			btn2:setVisible(true)
		end
		bg:getChildByName("1"):setString("房间号:"..v.roomnum)
		if self.gametype == 2 then
			-- self.confstr =""
			-- self.confstr = self.confstr..data.totalGameNums.."局 "
			-- if self.data.gameplaytype == 1 then
			-- 	self.confstr = self.confstr .."普通玩法 "
			-- else
			-- 	self.confstr = self.confstr .."纯比炸 "
			-- end

			-- if self.data.gameplaytype == 1 then
			-- 	self.confstr = self.confstr .."5王算奖 "
			-- else
			-- 	self.confstr = self.confstr .."6王算奖 "
			-- end

			-- if self.data.gamejokertype == 1 then
			-- 	self.confstr = self.confstr .."一奖4桶 "
			-- else
			-- 	self.confstr = self.confstr .."一奖6桶 "
			-- end

			-- if self.data.gamebirdtype == 1 then
			-- 	self.confstr = self.confstr .."对家进鸟王 "
			-- else
			-- 	self.confstr = self.confstr .."3家进鸟王 "
			-- end

			-- if self.data.gameglobaltype == 1 then
			-- 	self.confstr = self.confstr .."全球通 "
			-- end
			local wanfa = {"普通玩法","纯比炸"}
			bg:getChildByName("2"):setString(wanfa[v.gameplaytype].."-("..v.gamenums.."局)")
		else
			local wanfa =  {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
			bg:getChildByName("2"):setString(wanfa[v.gamebankertype].."-("..v.gamenums.."局)")
		end
		bg:getChildByName("3"):setString(v.time or "")
		WidgetUtils.addClickEvent(btn1, function( )
			print("返回大厅")
			if self.gametype == 2 then
				self.confstr =""
				self.confstr = self.confstr..v.gamenums.."局 "
				if v.gameplaytype == 1 then
					self.confstr = self.confstr .."普通玩法 "
				else
					self.confstr = self.confstr .."纯比炸 "
				end

				if v.gamejokertype == 1 then
					self.confstr = self.confstr .."5王算奖 "
				else
					self.confstr = self.confstr .."6王算奖 "
				end

				if v.gamerewardtype == 1 then
					self.confstr = self.confstr .."一奖4桶 "
				else
					self.confstr = self.confstr .."一奖6桶 "
				end

				if v.gamebirdtype == 1 then
					self.confstr = self.confstr .."对家进鸟王 "
				else
					self.confstr = self.confstr .."3家进鸟王 "
				end

				if v.gameglobaltype == 1 then
					self.confstr = self.confstr .."全球通 "
				end
				print(self.confstr)
				CommonUtils.sharedesk(v.roomnum,self.confstr,"大众窟筒")
			else
				local wanfa =  {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
				local configstr = "代开房 "..wanfa[v.gamebankertype].."-("..v.gamenums.."局)"
				CommonUtils.sharedesk(v.roomnum,configstr,"大众牛牛")
			end

		end)

		WidgetUtils.addClickEvent(btn2, function( )
			if self.gametype == 2 then
				
				Socketapi.releasedailikaifforkutong(v.roomid)
			else
				Socketapi.releasedailikaif(v.roomid)
			end
		end)
	end
end
function HelpView:initEvent()
	ComNoti_instance:addEventListener("3;2;1;3",self,self.createcallback)
	ComNoti_instance:addEventListener("3;2;1;4",self,self.releasecall)

	ComNoti_instance:addEventListener("3;3;1;3",self,self.createcallback)
	ComNoti_instance:addEventListener("3;3;1;4",self,self.releasecall)
end

function HelpView:releasecall( data )
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info})
	else
		if self.gametype== 2 then
			Socketapi.getdailikaifforkutong()
		else
			Socketapi.getdailikaif()
		end
	end
end
return HelpView