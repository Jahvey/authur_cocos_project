-------------------------------------------------
--   TODO   历史记录 战绩
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HistoryRecordView = class("HistoryRecordView",PopboxBaseView)
function HistoryRecordView:ctor(data)
	self.localdata= data
	self.addcellindex = 0
	self:initView()

end

function HistoryRecordView:initView()
	self.widget = cc.CSLoader:createNode("ui/historyrecord/historyRecordView2.csb")
	self:addChild(self.widget)
	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	for i=1,6 do
		self.mainLayer:getChildByName("name"..i):setVisible(false)
	end
	printTable(self.localdata)
	for i,v in ipairs(self.localdata.otherinfolist) do
		local name = self.mainLayer:getChildByName("name"..i)
		name:setVisible(true)
		name:setString(ComHelpFuc.getStrWithLengthByJSP(v.nickname))
		if v.playerid == LocalData_instance.playerid then
			name:setTextColor(cc.c3b(0x2a, 0xa4, 0x1a))
		end
	end

	self.listView = self.mainLayer:getChildByName("listView1")
	local item = self.mainLayer:getChildByName("cell")
	item:retain()
	self.listView:setItemModel(item)
	item:removeFromParent()
	item:release()
	self.cell = self.mainLayer:getChildByName("cell1")
	self.cell:setVisible(false)
end
function HistoryRecordView:onEndAni()
	Socketapi.getzhanjiju(self.localdata.roomid)
		ComNoti_instance:addEventListener("3;2;5;2",self,self.callbackju)
end
function HistoryRecordView:callbackju(data)
	if data.result == 0 then
		 Notinode_instance:showLoading(false)
		print("弹框")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return 
	end
		for i,v in ipairs(data.gamedetailinfolist) do
	
			self.listView:pushBackDefaultItem()
	        local item = self.listView:getItem(i-1)
	        for j=1,6 do
	        	item:getChildByName(j):setVisible(false)
	        end
	        item:getChildByName("btn1"):setVisible(true)
	        item:getChildByName("btn2"):setVisible(false)
	        item:getChildByName("num"):setString(i)
	        for j,v1 in ipairs(v.scorelist) do
	        	for j1,v2 in ipairs(self.localdata.otherinfolist) do
	        		print(v2.playid)
	        		print(v1.playid)
	        		if v1.playerid == v2.playerid then
	        			print("j1:"..j1)
			        	local score  =item:getChildByName(j1)
			        	score:setVisible(true)
			        	score:setString(v1.score)
			        	if v1.playerid == LocalData_instance.playerid then
							score:setTextColor(cc.c3b(0x2a, 0xa4, 0x1a))
						end
						break
					end
				end
	        end

	        local function callback(  )
	        	if self.addcellindex~= 0 then
					self.listView:removeItem(self.addcellindex)
					if self.addcellindex == i then
						self.addcellindex = 0
						return 
					end
					self.addcellindex = 0

				end
				local pos = self.listView:getInnerContainerPosition()
				print("pos:"..pos.y)
				local cell  = self.cell:clone()
				self.addcellindex = i
				self.listView:insertCustomItem(cell,i)
				cell:setVisible(true)
				cell:runAction(cc.CallFunc:create(function( ... )
					self.listView:jumpToPercentVertical(i/#data.gamedetailinfolist*100)
				end))
				for j=1,6 do
		        	cell:getChildByName(j):setVisible(false)
		        end
				for j,v1 in ipairs(v.scorelist) do
					for j1,v2 in ipairs(self.localdata.otherinfolist) do
		        		if v1.playerid == v2.playerid then
							cell:getChildByName(j1):setVisible(true)
							if v1.index == v.curbanker then
								cell:getChildByName(j1):getChildByName("xia"):setVisible(false)
								cell:getChildByName(j1):getChildByName("zhuang"):setVisible(true)
							else
								cell:getChildByName(j1):getChildByName("xia"):setVisible(true)
								cell:getChildByName(j1):getChildByName("zhuang"):setVisible(false)
								cell:getChildByName(j1):getChildByName("xia"):getChildByName("text"):setString(v1.betscore)
							end
							local Card = require "app.ui.game.Card"
							local node = cc.Node:create()
							for i2,v2 in ipairs(v1.curCards) do
								local card  = Card.new(v2,true)
								card:setScale(0.5)
								card:setPositionX((i2 - 3)*20)
								node:addChild(card)
								
							end
							node:setPosition(cc.p(78,75))


							local niu = self:createniuan(v1.cardtype)
							niu:setScale(0.5)
							niu:setPositionY(-20)
							node:addChild(niu)
							cell:getChildByName(j1):addChild(node)
							break
						end
					end
				end
	        end
	        WidgetUtils.addClickEvent(item:getChildByName("btn1"), function( )
				callback()
				local items = self.listView:getItems()
				for i1,v1 in ipairs(items) do
					if i1 ~= self.addcellindex then
						if v1:getChildByName("btn1") then
							v1:getChildByName("btn1"):setVisible(true)

							v1:getChildByName("btn2"):setVisible(false)
						end
					else
						if v1:getChildByName("btn1") then
							v1:getChildByName("btn1"):setVisible(false)

							v1:getChildByName("btn2"):setVisible(true)
						end
					end
				end
			end)
			 WidgetUtils.addClickEvent(item:getChildByName("btn2"), function( )
				callback()
				local items = self.listView:getItems()
				for i1,v1 in ipairs(items) do
					if i1 ~= self.addcellindex then
						if v1:getChildByName("btn1") then
							v1:getChildByName("btn1"):setVisible(true)

							v1:getChildByName("btn2"):setVisible(false)
						end
					else
						if v1:getChildByName("btn1") then
							v1:getChildByName("btn1"):setVisible(false)

							v1:getChildByName("btn2"):setVisible(true)
						end
					end
				end
			end)
		end
end


function HistoryRecordView:createniuan(value,bei)
	-- local node =  cc.CSLoader:createNode("Animation/niuniu/niuniu.csb")
	-- local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu/niu"..value..".png")
	-- local action = cc.CSLoader:createTimeline("Animation/niuniu/niuniu.csb")
 --    node:runAction(action)
 --    action:gotoFrameAndPlay(num or 0,false)
 	if bei and bei > 1 then
 		local node =  cc.CSLoader:createNode("Animation/niuniu1/niuniubei1.csb")
		local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu"..value..".png")
		local niubei = node:getChildByName("Node_1"):getChildByName("niubei")
		if  value >= 10 then
			niubei:setTexture("game/bei/"..bei..".png")
		else
			niubei:setTexture("game/bei/x"..bei..".png")
		end
	    action:gotoFrameAndPlay(num or 0,false)

	    if  value >= 10 then
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(true)
		else
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(true)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
		end

	    if value == 0 then
	    	node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
	    end
	    return node 
 	else
	 	local node =  cc.CSLoader:createNode("Animation/niuniu1/niuniu1.csb")
		local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu"..value..".png")
		 if  value >= 10 then
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(true)
		else
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(true)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
		end

	    if value == 0 then
	    	node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
	    end
	    return node
	end
    
end

return HistoryRecordView