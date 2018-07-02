-------------------------------------------------
--   TODO   历史记录 战绩
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HistoryRecordView = class("HistoryRecordView",PopboxBaseView)
function HistoryRecordView:ctor(isju,roomid)
	self.isju = isju
	self.roomid = roomid
	self:initView()
end

function HistoryRecordView:initView()
	self.widget = cc.CSLoader:createNode("ui/historyrecord/historyRecordView.csb")
	self:addChild(self.widget)
	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	self.listView = self.mainLayer:getChildByName("listView1")
	local item = self.widget:getChildByName("cell")
	item:retain()
	self.listView:setItemModel(item)
	item:removeFromParent()
	item:release()
end
function HistoryRecordView:onEndAni()
	Socketapi.getzhanjiforkutong()
	ComNoti_instance:addEventListener("3;3;5;1",self,self.callback)
end
function HistoryRecordView:callbackju(data)
	-- if data.result == 0 then
	-- 	 Notinode_instance:showLoading(false)
	-- 	print("弹框")
	-- 	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
	-- 	end})
	-- 	return 
	-- end
	-- --printTable(data,"sjp")
	-- local jsondata = cjson.decode(data.data)
	-- printTable(jsondata,"sjp")
	-- if jsondata then
	-- 	for i,v in ipairs(jsondata) do
	-- 		self.listView:pushBackDefaultItem()
	--         local item = self.listView:getItem(i-1)
	--         item:getChildByName("bg"):getChildByName("tableid"):setString("第"..i.."局")
	--         item:getChildByName("bg"):getChildByName("time"):setVisible(false)
	--         for i1=1,4 do
	--         	 item:getChildByName("bg"):getChildByName("name"..i1):setVisible(false)
	--         	 item:getChildByName("bg"):getChildByName("jifen"..i1):setVisible(false)
	--         end
	--         for j,k in ipairs(v.gameendinfolist) do
	--          	item:getChildByName("bg"):getChildByName("name"..j):setVisible(true)
	--         	 item:getChildByName("bg"):getChildByName("jifen"..j):setVisible(true)
	--         	item:getChildByName("bg"):getChildByName("name"..j):setString(ComHelpFuc.getStrWithLengthByJSP(k.nickname))
	--        		item:getChildByName("bg"):getChildByName("jifen"..j):setString(k.onescore or "没有数据")
	--         end
	--         local btn = item:getChildByName("bg"):getChildByName("btn")
	--          WidgetUtils.addClickEvent(btn, function( )
	-- 			print("返回大厅")
	-- 			Socketapi.getzhandata(i,self.roomid)
	-- 		end)
	        
	-- 	end
	-- end
end
function HistoryRecordView:callback(data)
	printTable(data,"sjp")
	if data.result == 0 then
		 Notinode_instance:showLoading(false)
		print("弹框")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return
	end
	if data.gameinfolist ~= nil then
		for i,v in ipairs(data.gameinfolist) do

			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3*i-0.3),cc.CallFunc:create(function(  )
				self.listView:pushBackDefaultItem()
		        local item = self.listView:getItem(i-1)
		  --        item:getChildByName("bg"):getChildByName("btn"):setVisible(false)
		        WidgetUtils.addClickEvent(item, function( )
					print("返回大厅")
					--LaypopManger_instance:PopBox("HistoryRecordView1",v)
				end)
		        item:getChildByName("tableid"):setString("房号:"..v.roomnum)
		        item:getChildByName("str1"):setString("局数:"..(v.gamenums or ""))
		        local wanfa = {"普通玩法","纯比炸"}
		        item:getChildByName("str2"):setString("玩法:"..wanfa[(v.gametype or 1)])
		        -- table.insert(v.otherinfolist,1,{nickname = LocalData_instance.nickname,score = v.myscore,headimageurl = LocalData_instance.headimgurl,playerid = LocalData_instance.playerid})
		        for i1=1,6 do
		        		print("i:"..i1)
		        	 item:getChildByName("icon"..i1):setVisible(false)
		        end
		        for j,k in ipairs(v.otherinfolist) do
		        	 item:getChildByName("icon"..j):setVisible(true)
		        	 item:getChildByName("icon"..j):getChildByName("name"):setString(ComHelpFuc.getStrWithLengthByJSP(k.nickname))
		        	 item:getChildByName("icon"..j):getChildByName("id"):setString("ID:"..(k.playerid or ""))
		        	 if k.score >= 0 then
		        	 	 item:getChildByName("icon"..j):getChildByName("win"):setString("/"..k.score)
		        	 	 item:getChildByName("icon"..j):getChildByName("win"):setVisible(true)
		        	 	  item:getChildByName("icon"..j):getChildByName("lost"):setVisible(false)
		        	 else
		        	 	item:getChildByName("icon"..j):getChildByName("lost"):setString("/"..math.abs(k.score))
		        	 	item:getChildByName("icon"..j):getChildByName("lost"):setVisible(true)
		        	 	 item:getChildByName("icon"..j):getChildByName("win"):setVisible(false)
		        	 end
		        	 require("app.ui.common.HeadIcon").new(item:getChildByName("icon"..j):getChildByName("icon"),k.headimageurl)
		        end
		        local datetab = os.date("*t",math.floor(v.createdate/1000))
				local string = datetab.year.."/"..datetab.month.."/"..datetab.day.." "..datetab.hour
				if datetab.min >= 10 then
					string = string..":"..datetab.min
				else
					string = string..":0"..datetab.min
				end
				print(string)
		        item:getChildByName("time"):setString(string)
		    end)))
	    end
	end
end

return HistoryRecordView