-------------------------------------------------
--   TODO   游戏大厅UI
--   @author yc
--   Create Date 2016.10.24
-------------------------------------------------
local HallView = class("HallView",function()
	return cc.Node:create() 
end)
function HallView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function HallView:initData()

end
function HallView:initView()
	-- Notinode_instance.tipsmsg= {"asdfafadsfasdfasfadsf","asdfafadsfasdfasfadsf","asdfafadsfasdfasfadsf"}
	-- Notinode_instance:showtips()
	local widget = cc.CSLoader:createNode("ui/hall/hallView.csb")
	self:addChild(widget)
	
	self.mainLayer = widget:getChildByName("main")
	WidgetUtils.setBgScale(widget:getChildByName("bg"))
	WidgetUtils.setScalepos(self.mainLayer)
	--self.bottomNode = self.mainLayer:getChildByName("bottom")
	self.topNode = self.mainLayer:getChildByName("top")

--PlayerInfoView
	self.shopbtn = self.topNode:getChildByName("shop")
	WidgetUtils.addClickEvent(self.shopbtn, function( )
		print("商店")
		if LocalData_instance.accountid == 0 or  LocalData_instance.accountid == nil then
			LaypopManger_instance:PopBox("CodeView")
		else
			LaypopManger_instance:PopBox("ShopView")
		end
	end)
	-- 设置
	self.setBtn = self.topNode:getChildByName("setbtn")
	WidgetUtils.addClickEvent(self.setBtn, function( )
		print("设置")
		LaypopManger_instance:PopBox("SetView",1)
	end)
	-- 帮助
	-- self.helpBtn = self.topNode:getChildByName("help")
	-- WidgetUtils.addClickEvent(self.helpBtn, function( )
	-- 	print("帮助")
	-- 	LaypopManger_instance:PopBox("HelpView")
	-- end)
	-- self.tuijianma = self.topNode:getChildByName("tuijianma")
	-- WidgetUtils.addClickEvent(self.tuijianma, function( )
	-- 	print("推荐码")
	-- 	LaypopManger_instance:PopBox("CodeView")
	-- end)


	-- -- 战绩
	-- self.zhanjibtn = self.topNode:getChildByName("zhanjibtn")
	-- WidgetUtils.addClickEvent(self.zhanjibtn, function( )
	-- 	print("战绩")
	-- 	LaypopManger_instance:PopBox("HistoryRecordView")
	-- end)

	self.sharebtn = self.topNode:getChildByName("help")
	WidgetUtils.addClickEvent(self.sharebtn, function( )
		LaypopManger_instance:PopBox("ShareView")
	end)


	self.shieldLayer = WidgetUtils.getNodeByWay(self.mainLayer,{"marqueeBg","shieldLayer"})
	-- 跑马灯
	self.content = WidgetUtils.getNodeByWay(self.mainLayer,{"marqueeBg","shieldLayer","content"})
	self.content:setString(LangUtils:getStr("hall_paomadeng_tip"))

	self:runMarqueen()
	-- 名字
	self.nameLabel = self.topNode:getChildByName("namebtn"):getChildByName("name"):setString(ComHelpFuc.getStrWithLengthByJSP(LocalData_instance.nickname))
	self.nameLabel = self.topNode:getChildByName("namebtn"):getChildByName("id"):setString("ID:"..LocalData_instance.playerid)
	-- -- ID
	-- self.IDLabel = self.bottomNode:getChildByName("IDLabel"):setString("")
	--金比
	self.cardnumLabel = self.topNode:getChildByName("goldbtn"):getChildByName("gold"):setString(LocalData_instance.gamecoins)
	WidgetUtils.addClickEvent(self.topNode:getChildByName("goldbtn"), function( )
		if LocalData_instance.accountid == 0 or  LocalData_instance.accountid == nil then
			LaypopManger_instance:PopBox("CodeView")
		else
			LaypopManger_instance:PopBox("ShopView")
		end
	end)
	self.headIcon = self.topNode:getChildByName("icon")
	print(self.headIcon)

	self.headBg = self.topNode:getChildByName("iconbg")

	self.headIcon:setPosition(self.headBg:getPositionX(),self.headBg:getPositionY())
	require("app.ui.common.HeadIcon").new(self.headIcon,LocalData_instance:getPic())
	WidgetUtils.addClickEvent(self.headBg, function( )
		print("点击头像")
		LaypopManger_instance:PopBox("PlayerInfoView")
	end)
	for i=1,4 do
		local btn = self.mainLayer:getChildByName("hallnode"):getChildByName("game"..i)
		WidgetUtils.addClickEvent(btn, function( )
			if i== 3 or i == 2  then
				self:enjoy(i)
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待!",sureCallFunc = function()
					--glApp:enterScene("MainScene",true)
				end})
			end
		end)
	end
 	self.hallnode = self.mainLayer:getChildByName("hallnode")
 	self.node1 = self.mainLayer:getChildByName("node1")
 	self.node1:setPositionX(display.width)
 	self.down1 = self.mainLayer:getChildByName("down1")
 	self.down1:setPositionY(-200)
 	self.returnbtn = self.down1:getChildByName("returnbtn")
 	-- self.returnbtn:setVisible(false)
 	WidgetUtils.addClickEvent(self.returnbtn, function( )
		self:returnhall(  )
		-- self.returnbtn:setVisible(false)
	end)


	self.zhanji = self.down1:getChildByName("zhanji")
 	WidgetUtils.addClickEvent(self.zhanji, function( )
 		if self.gametype == 2 then
 			
 			LaypopManger_instance:PopBox("HistoryRecordViewforkutong")
 		else
			LaypopManger_instance:PopBox("HistoryRecordView")
		end
	end)

	self.wanfabtn = self.down1:getChildByName("wanfabtn")
 	WidgetUtils.addClickEvent(self.wanfabtn, function( )
		LaypopManger_instance:PopBox("HelpView",self.gametype)
	end)
 	self.choujiang = self.down1:getChildByName("choujiang")
 	WidgetUtils.addClickEvent(self.choujiang, function( )
		LaypopManger_instance:PopBox("Zhuanview")
	end)
 	
 	self.tuiguang = self.down1:getChildByName("tuiguang")
 	WidgetUtils.addClickEvent(self.tuiguang, function( )
		LaypopManger_instance:PopBox("NoticeActView",msg)
	end)
	self.renwu = self.down1:getChildByName("renwu")
 	WidgetUtils.addClickEvent(self.renwu, function( )
		LaypopManger_instance:PopBox("Renwu")
	end)

	-- 加入房间
	self.joinBtn   = self.mainLayer:getChildByName("node1"):getChildByName("joinbtn")
	WidgetUtils.addClickEvent(self.joinBtn, function( )
		print("加入房间")
		LaypopManger_instance:PopBox("JoinRoomView")
	end)
	self.createBtn   = self.mainLayer:getChildByName("node1"):getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.createBtn, function( )
		print("创建房间")
		LaypopManger_instance:PopBox("CreateRoomView")
	end)

	self.daikai = self.joinBtn:getChildByName("daikai")
 	WidgetUtils.addClickEvent(self.daikai, function( )
		LaypopManger_instance:PopBox("DaikaifangHelpView")
	end)



 	self.node2 = self.mainLayer:getChildByName("node2")
 	self.node2:setPositionX(display.width)
	-- 加入房间
	self.joinBtn1   = self.mainLayer:getChildByName("node2"):getChildByName("joinbtn")
	WidgetUtils.addClickEvent(self.joinBtn1, function( )
		print("加入房间")
		LaypopManger_instance:PopBox("JoinRoomView",self.gametype)
	end)
	self.createBtn1   = self.mainLayer:getChildByName("node2"):getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.createBtn1, function( )
		print("创建房间")
		LaypopManger_instance:PopBox("CreateRoomView1",self.gametype)
	end)

	self.daikai1 = self.joinBtn1:getChildByName("daikai")
 	WidgetUtils.addClickEvent(self.daikai1, function( )
		LaypopManger_instance:PopBox("DaikaifangHelpView",self.gametype)
	end)





    if GAME_SELECT_TYPE then
    	self:enjoy(GAME_SELECT_TYPE,true)
    else
    	--todo
    end
end
function HallView:enjoy(type,notan)
	self.gametype = type
	if type == 3 then
		if notan then
			--self.returnbtn:setVisible(true)
			self.hallnode:stopAllActions()
			self.node1:stopAllActions()
			self.down1:stopAllActions()
			self.hallnode:setPosition(cc.p(-display.width,0))
			self.node1:setPosition(cc.p(0,0))
			self.down1:setPosition(cc.p(display.cx,0))
		else
			--self.returnbtn:setVisible(true)
			self.hallnode:stopAllActions()
			self.node1:stopAllActions()
			self.down1:stopAllActions()
			self.hallnode:runAction(cc.MoveTo:create(0.5,cc.p(-display.width,0)))
			self.node1:runAction(cc.MoveTo:create(0.5,cc.p(0,0)))
			self.down1:runAction(cc.MoveTo:create(0.5,cc.p(display.cx,0)))
		end
	elseif type == 2 then

		if notan then
			--self.returnbtn:setVisible(true)
			self.hallnode:stopAllActions()
			self.node2:stopAllActions()
			self.down1:stopAllActions()
			self.hallnode:setPosition(cc.p(-display.width,0))
			self.node2:setPosition(cc.p(0,0))
			self.down1:setPosition(cc.p(display.cx,0))
		else
			--self.returnbtn:setVisible(true)
			self.hallnode:stopAllActions()
			self.node2:stopAllActions()
			self.down1:stopAllActions()
			self.hallnode:runAction(cc.MoveTo:create(0.5,cc.p(-display.width,0)))
			self.node2:runAction(cc.MoveTo:create(0.5,cc.p(0,0)))
			self.down1:runAction(cc.MoveTo:create(0.5,cc.p(display.cx,0)))
		end

	end
	-- body
end
function HallView:returnhall(  )
	self.hallnode:stopAllActions()
	self.node1:stopAllActions()
	self.node2:stopAllActions()
	self.down1:stopAllActions()
	self.node1:runAction(cc.MoveTo:create(0.5,cc.p(display.width,0)))
	self.node2:runAction(cc.MoveTo:create(0.5,cc.p(display.width,0)))
	self.hallnode:runAction(cc.MoveTo:create(0.5,cc.p(0,0)))
	self.down1:runAction(cc.MoveTo:create(0.5,cc.p(display.cx,-200)))
end
function HallView:updataview( )
	-- body
	self.cardnumLabel:setString(LocalData_instance:getChips())
end
function HallView:openDuiHuanMa()
	print("弹出邀请码")
	LaypopManger_instance:PopBox("InviteCodeView")
end
-- 分享
function HallView:shareBtnCall()
	print("分享")
	CommonUtils.sharegame()
end
function HallView:refreshView()
	self.cardnumLabel:setString(LocalData_instance:getChips())
	self.nameLabel:setString(LocalData_instance:getNick())
	--self.IDLabel:setString("ID:"..LocalData_instance:getUid())
	-- require("app.ui.common.HeadIcon").new(self.headIcon,"http://dev.arthur-tech.com/Uploads/wechat/g3x5qn2lpt2BqKPdrqtqp39hfIvKgaJ7hqaD0a-iapaHa36thJHVmJirm9O6uIeoipyhbw.jpeg")
	require("app.ui.common.HeadIcon").new(self.headIcon,LocalData_instance:getPic())
end

function HallView:getMarqueenStr()
	local str = "欢迎您来到大众聚友棋牌，祝你游戏愉快"

	return str
end
-- 跑马灯
function HallView:runMarqueen()

	    local function action()
		    local width = self.shieldLayer:getContentSize().width
	    	local str = Notinode_instance:getMsg()
	    	if str == nil then
	    		str = "欢迎您来到大众聚友棋牌，祝你游戏愉快"
	    	end
	    	self.content:setString(str)
	    	self.content:setAnchorPoint(cc.p(0,0.5))
	    	self.content:setPositionX(width)
	    	local contentWidth = self.content:getContentSize().width
	    	local length = width+contentWidth
	    	local time = length/20*0.2
	    	self.content:runAction(cc.Sequence:create(cc.MoveTo:create(time,cc.p(0-contentWidth,self.content:getPositionY())),cc.CallFunc:create(function()
	    		action()
	    	end)))
		end
		action()
end
function HallView:updateChip(data)
	self.cardnumLabel:setString(data.gamecoins)
end
function HallView:rankcall(data )
	-- body
end
-- 事件
function HallView:initEvent()
	ComNoti_instance:addEventListener("3;1;4",self,self.updateChip)
	-- ComNoti_instance:addEventListener("3;1;10",self,self.rankcall)
	-- ComNoti_instance:addEventListener("3;2;3;15",self,self.rankcall)
	ComNoti_instance:addEventListener("cs_notify_chip_change",self,self.updateChip)
end
return HallView
