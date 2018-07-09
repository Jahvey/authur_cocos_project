--新版大厅，只有花牌的
local HallView = class("NewHallView",function()
	return cc.Node:create() 
end)
	
function HallView:ctor()
	self:initView()
	self:initEvent()
end

function HallView:initEvent()
	ComNoti_instance:addEventListener("cs_notify_chip_change",self,self.updateChip)
	
	ComNoti_instance:addEventListener("cs_notify_dissolve_table",self,self.releaseroomcall)
end

function HallView:initView()

	local widget
	if SHENHEBAO then
		widget = cc.CSLoader:createNode("ui/newhall/hallView1.csb")
	else
		widget = cc.CSLoader:createNode("ui/newhall/hallView.csb")
	end
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")
	WidgetUtils.setBgScale(widget:getChildByName("bg"))
	WidgetUtils.setScalepos(self.mainLayer)

	self:initTopNode()
	self:initMidNode()
	self:initBottomNode()

	self:initLeftNode()

	-- local animationnode2 = self.mainLayer:getChildByName("animation2")
	-- self:runAnimation(animationnode2,"ui/newhall/dating/yanhua.csb")

	-- if not SHENHEBAO then
	-- 	self:showAct4()
	-- end
end

function HallView:initTopNode()
	self.topNode = self.mainLayer:getChildByName("topNode")

	self.infoNode = self.topNode:getChildByName("infoNode")
	-- 头像
	self.headIcon = self.infoNode:getChildByName("headIcon"):setScale(70/104)
	self.headBg = self.infoNode:getChildByName("headimgBg")
	self.headIcon:setPosition(self.headBg:getPositionX(),self.headBg:getPositionY()+2)
	WidgetUtils.addClickEvent(self.headBg, function( )
		print("点击头像")
		LaypopManger_instance:PopBox("PlayerInfoView")
	end)
	-- 名字
	self.nameLabel = self.infoNode:getChildByName("nameLabel"):setString("")
	-- ID
	self.IDLabel = self.infoNode:getChildByName("IDLabel"):setString("")
	-- roomCardBg
	self.roomCardBg = self.infoNode:getChildByName("roomCardBg")

	WidgetUtils.addClickEvent(self.roomCardBg, function( )
		print("购卡提示")
		if SHENHEBAO then
			LaypopManger_instance:PopBox("ShopView")
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待"})
		end
	end)
	WidgetUtils.addClickEvent(self.roomCardBg:getChildByName("cardImage"), function( )
		print("购卡提示")
		if SHENHEBAO then
			LaypopManger_instance:PopBox("ShopView")
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待"})
		end
	end)
	WidgetUtils.addClickEvent(self.roomCardBg:getChildByName("addImage"), function( )
		print("购卡提示")
		if SHENHEBAO then
			LaypopManger_instance:PopBox("ShopView")
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待"})
		end
	end)
	-- CD num
	self.cardnumLabel = self.roomCardBg:getChildByName("cardnumLabel"):setString("")

	-- 消息
	self.msgBtn = self.topNode:getChildByName("msgBtn")
	self.msgBtn:getChildByName("redpoint"):setVisible(false)
	if IS_NEWFAKUI then
		local function callcount()
			local count = Qiyousdk.getunReadcount()
			if tonumber(count) >0 then
				-- print("有未读消息")
				self.msgBtn:getChildByName("redpoint"):setVisible(true)
			else
				self.msgBtn:getChildByName("redpoint"):setVisible(false)
				-- print("没有未读消息")
			end
		end
		callcount()
		self.msgBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function( ... )
			callcount()
		end))))
	end
	WidgetUtils.addClickEvent(self.msgBtn, function( )
		print("消息")
		--LaypopManger_instance:PopBox("MessageView",GAME_CITY_SELECT)
		if IS_NEWFAKUI then
			Qiyousdk.showui()
		else
			if device.platform == "ios" then
				LaypopManger_instance:PopBox("MessageView")
			else
				WidgetUtils.addClickEvent(self.msgBtn, function( )
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "当前版本不支持客服反馈，请重新下载游戏更新到最新版本",sureCallFunc = function()
						CommonUtils.downapp()
					end})
				end)
			end
		end
	end)

	-- 设置
	self.setBtn = self.topNode:getChildByName("setBtn")
	WidgetUtils.addClickEvent(self.setBtn, function( )
		print("设置")
		LaypopManger_instance:PopBox("SetView")
	end)
	-- 帮助
	self.helpBtn = self.topNode:getChildByName("helpBtn")
	WidgetUtils.addClickEvent(self.helpBtn, function( )
		print("帮助")
		LaypopManger_instance:PopBox("HelpView")
	end)

	self.shieldLayer = WidgetUtils.getNodeByWay(self.topNode,{"marqueeBg","shieldLayer"})
	-- 跑马灯
	self.content = WidgetUtils.getNodeByWay(self.topNode,{"marqueeBg","shieldLayer","content"})
	self:runMarqueen()

	self.citybtn = self.topNode:getChildByName("citybtn")
	if SHENHEBAO then
		self.citybtn:setVisible(false)
	end
	WidgetUtils.addClickEvent(self.citybtn, function( )
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否切换城市?",sureCallFunc = function()
			Notinode_instance:enterScene("SelectScene",true)
		end,cancelCallFunc = function()
			LaypopManger_instance:back()
		end})	
	end)	

	self.citybtn:getChildByName("citytext"):setTexture("city/city_"..GAME_LOCAL_CITY..".png")

	if SHENHEBAO then
		self.msgBtn:setVisible(false)
		self.helpBtn:setVisible(false)
	end

	self:refreshView()
end

function HallView:initMidNode()
	self.midNode = self.mainLayer:getChildByName("midNode")
	
	-- 创建房间
	self:initCreateRoomBtn()
	
	-- 加入房间
	self:initJoinRoomBtn()

	-- 茶馆
	self:initTeaRoomBtn()

	local animationnode1 = self.midNode:getChildByName("animation1")
	self:runAnimation(animationnode1,"ui/newhall/dating/chuangjian.csb")

	local animationnode3 = self.midNode:getChildByName("animation3")
	self:runAnimation(animationnode3,"ui/newhall/dating/yellow_chuangjian.csb")

	-- self.newBtn = self.midNode:getChildByName("newBtn")
	-- WidgetUtils.addClickEvent(self.newBtn, function( )
	-- 	print("打开新手引导")
	-- 	LaypopManger_instance:PopBox("GuideView")
	-- end)

	-- if not SHENHEBAO then
	-- 	self:showAct4()
	-- end

	if SHENHEBAO then
		local shop = self.midNode:getChildByName("shop")
		WidgetUtils.addClickEvent(shop, function()
				if SHENHEBAO then
					LaypopManger_instance:PopBox("ShopView")
				else
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待"})
				end
			end)
	end


	self.btn_cj = self.midNode:getChildByName("Button_cj")
		WidgetUtils.addClickEvent(self.btn_cj, function()

					LaypopManger_instance:PopBox("mainHallNodeView")

			end)
	
	

end

function HallView:initBottomNode()
	self.bottomNode = self.mainLayer:getChildByName("bottomNode")
	local itemlist = self.bottomNode:getChildByName("itemlist")
	-- 商店
	if SHENHEBAO then
		self.bottomNode:setVisible(false)
	end
	local shop = itemlist:getChildByName("shop")
	WidgetUtils.addClickEvent(shop, function()
			if SHENHEBAO then
				LaypopManger_instance:PopBox("ShopView")
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "敬请期待"})
			end
		end)
	-- 战绩
	local record = itemlist:getChildByName("record")
	WidgetUtils.addClickEvent(record, function()
			LaypopManger_instance:PopBox("HistoryRecordView")
		end)
	-- 排行榜
	local rank = itemlist:getChildByName("rank")
	WidgetUtils.addClickEvent(rank, function()
			LaypopManger_instance:PopBox("RankListView")
		end)
	-- 公告
	local notice = itemlist:getChildByName("notice")
	WidgetUtils.addClickEvent(notice, function()
			LaypopManger_instance:PopBox("NoticeActView")
		end)
	local redpoint = notice:getChildByName("redpoint"):setVisible(false)

	local function animation()
		local action = cc.Sequence:create(cc.CallFunc:create(function ()
			redpoint:setVisible(false)
		end),cc.DelayTime:create(2),cc.CallFunc:create(function ()
			notice:runAction(animation())
		end))
		if HASREDPOINT then
			action = cc.Sequence:create(cc.CallFunc:create(function ()
				redpoint:setVisible(true)
		end),cc.DelayTime:create(2),cc.CallFunc:create(function ()
				notice:runAction(animation())
			end))
		end
		return action
	end

	notice:runAction(animation())
	--分享
	local share = itemlist:getChildByName("share")
	WidgetUtils.addClickEvent(share, function()
			LaypopManger_instance:PopBox("SharePromptBoxView")
		end)
	local tip = share:getChildByName("tip")
	if tip then
		tip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.DelayTime:create(1),cc.FadeIn:create(2))))
	end	
	-- 认证
	-- local authen = itemlist:getChildByName("authentication")
	-- WidgetUtils.addClickEvent(authen, function()
	-- 	ComHttp.httpPOST(ComHttp.URL.CHECKREALNAME,{uid = LocalData_instance:getUid()},function(data)
	-- 		-- 1已经实名认证，0未实名认证
	-- 		if data.status == 1 then
	-- 			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你已经完成实名认证，无需认证了！"})
	-- 		elseif data.status == 0 then
	-- 			LaypopManger_instance:PopBox("Setrealname")
	-- 		end	
	-- 	end)	
	-- end)
	-- 绑定
	local bind = itemlist:getChildByName("bind")
	WidgetUtils.addClickEvent(bind, function()
		LaypopManger_instance:PopBox("InviteCodeView")
	end)

	if SHENHEBAO then
		record:setVisible(false)
		rank:setVisible(false)
		notice:setVisible(false)
		share:setVisible(false)
		bind:setVisible(false)
	end
end

function HallView:initLeftNode()
	self.leftnode = self.mainLayer:getChildByName("leftnode")

	local yueju = self.leftnode:getChildByName("yueju")
	if SHENHEBAO then
		yueju:setVisible(false)
	end
	yueju:setVisible(false)
	local yuejubtn = yueju:getChildByName("btn"):setTouchEnabled(true)
	WidgetUtils.addClickEvent(yuejubtn, function( )
		print("打开新手引导")
		LaypopManger_instance:PopBox("GuideView")
	end)
end

function HallView:initCreateRoomBtn()
	local createRoomNode = self.midNode:getChildByName("createRoomNode")

	local btn = createRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = createRoomNode:getChildByName("img")
	local img2 = createRoomNode:getChildByName("img2")
	local text1 = createRoomNode:getChildByName("text")
	local text2 = createRoomNode:getChildByName("text2")

	WidgetUtils.addClickEvent(btn, function( )
		if glApp:getCurScene().table_id and table_id ~= 0 then
			print("返回房间")
			local table_id = glApp:getCurScene().table_id 
			Notinode_instance:jointable(table_id)
		else	
			print("创建房间")
			LaypopManger_instance:PopBox("CreateRoomView")
		end	
	end)


	if GAME_CITY_SELECT == 4 then
		img:loadTexture("ui/newhall/icon_xiaochang.png", ccui.TextureResType.localType)
	end

	if GAME_CITY_SELECT == 2 or GAME_CITY_SELECT == 3 then
		img2:setVisible(true)
		img:setVisible(false)
	end

	self:refreshCreateBtn()
end

function HallView:initJoinRoomBtn()
	local joinRoomNode = self.midNode:getChildByName("joinRoomNode")

	local btn = joinRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = joinRoomNode:getChildByName("img")
	local img2 = joinRoomNode:getChildByName("img2")
	local text1 = joinRoomNode:getChildByName("text")

	WidgetUtils.addClickEvent(btn, function( )
		print("加入房间")
		LaypopManger_instance:PopBox("JoinRoomView")
	end)

	local animationnode = joinRoomNode:getChildByName("animation")
	animationnode:setVisible(false)

	-- if  GAME_CITY_SELECT == 2 or GAME_CITY_SELECT == 3 then
	-- 	img2:setVisible(true)
	-- 	img:setVisible(false)
	-- 	animationnode:setVisible(false)
	-- else
	-- 	self:runAnimation(animationnode,"ui/newhall/dating/pai_saoguang.csb")
	-- end
end

function HallView:initTeaRoomBtn()
	local teaRoomNode = self.midNode:getChildByName("teaRoomNode")

	local btn = teaRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = teaRoomNode:getChildByName("img")
	local text1 = teaRoomNode:getChildByName("text")

	WidgetUtils.addClickEvent(btn, function( )
		LaypopManger_instance:PopBox("OpenView")
	end)

	if SHENHEBAO then
		teaRoomNode:setVisible(false)
	end

	local animationnode = teaRoomNode:getChildByName("animation")
	self:runAnimation(animationnode,"ui/newhall/dating/zhongguojie.csb")
end

function HallView:refreshView()
	self.cardnumLabel:setString(LocalData_instance:getChips())
	local name = ComHelpFuc.getCharacterCountInUTF8String(LocalData_instance:getNick(),10)
	self.nameLabel:setString(name)
	self.IDLabel:setString("ID:"..LocalData_instance:getUid())
	-- require("app.ui.common.HeadIcon").new(self.headIcon,"http://dev.arthur-tech.com/Uploads/wechat/g3x5qn2lpt2BqKPdrqtqp39hfIvKgaJ7hqaD0a-iapaHa36thJHVmJirm9O6uIeoipyhbw.jpeg")
	require("app.ui.common.HeadIcon").new(self.headIcon,LocalData_instance:getPic())
end

function HallView:updateChip(data)
	LocalData_instance:setChips(data.cur_chip)
	self.cardnumLabel:setString(LocalData_instance:getChips())
end

function HallView:releaseroomcall()
	glApp:getCurScene().table_id = nil

	self:refreshCreateBtn()
end

function HallView:refreshCreateBtn()
	if SHENHEBAO then
	else
		local createRoomNode = self.midNode:getChildByName("createRoomNode")
		local text1 = createRoomNode:getChildByName("text")
		local text2 = createRoomNode:getChildByName("text2")

		if glApp:getCurScene().table_id then
			text1:setVisible(false)
			text2:setVisible(true)
		else
			text2:setVisible(false)
			text1:setVisible(true)
		end
	end
end

-- 跑马灯
function HallView:runMarqueen()
    local function action()
	    local width = self.shieldLayer:getContentSize().width
    	local str = Notinode_instance:getPaomadingmsg()
    	if SHENHEBAO or str == nil then
    		str = "欢迎来到今日扑克，祝您玩得高兴！"
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

function HallView:showAct2()
	local rednode = self:getActNode(3)

	-- local acticon = rednode:getChildByName("img")

	rednode:setVisible(true)

	local acticon = cc.CSLoader:createNode("ui/inviteforredpacke/dating_lingxianjin/dating_lingxianjin.csb")
		:addTo(rednode:getChildByName("img"))
	-- rednode:addChild(acticon)

	local action = cc.CSLoader:createTimeline("ui/inviteforredpacke/dating_lingxianjin/dating_lingxianjin.csb")

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")

	WidgetUtils.addClickEvent(touch,function ()
		LaypopManger_instance:PopBox("IFRPView")
	end)

	local btn = rednode:getChildByName("btn"):setTouchEnabled(true)

	WidgetUtils.addClickEvent(btn,function ()
		LaypopManger_instance:PopBox("IFRPView")
	end)
end

function HallView:showAct3(data)

	local newcommernode = self:getActNode(4)

	-- local acticon = newcommernode:getChildByName("img")
	newcommernode:setVisible(true)

	local acticon = cc.CSLoader:createNode("ui/newcommeract/datinglibao/datinglibao.csb")
		:addTo(newcommernode:getChildByName("img"))
	-- newcommernode:addChild(acticon)

	local action = cc.CSLoader:createTimeline("ui/newcommeract/datinglibao/datinglibao.csb")

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")

	local redpoint = acticon:getChildByName("redpoint")

	for i,v in ipairs(data.list) do
		if v.canget == 2 then
			redpoint:setVisible(true)
			break
		end
	end

	WidgetUtils.addClickEvent(touch,function ()
		LaypopManger_instance:PopBox("NewCommerAct",redpoint)
	end)

	local btn = newcommernode:getChildByName("btn"):setTouchEnabled(true)
	WidgetUtils.addClickEvent(btn,function ()
		LaypopManger_instance:PopBox("NewCommerAct",redpoint)
	end)
end

function HallView:showAct4(data)
	local invitecodenode = self.leftnode:getChildByName("invitecode"):setVisible(true)

	local acticon = cc.CSLoader:createNode("ui/invitecodeact/dating_lingfangka/dating_lingfangka.csb")
		:addTo(invitecodenode:getChildByName("img"))
		:setName("acticon")

	local action = cc.CSLoader:createTimeline("ui/invitecodeact/dating_lingfangka/dating_lingfangka.csb")

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")

	local redpoint = acticon:getChildByName("redpoint")
 
	WidgetUtils.addClickEvent(touch,function ()
		LaypopManger_instance:PopBox("InviteCodeActBox",redpoint)
	end)

	local btn = invitecodenode:getChildByName("btn"):setTouchEnabled(true)

	WidgetUtils.addClickEvent(btn,function ()
		LaypopManger_instance:PopBox("InviteCodeActBox",redpoint)
	end)

	self:runAction(cc.CallFunc:create(function ()
		if cc.UserDefault:getInstance():getStringForKey("PopAct4","") ~= os.date("%m%d",os.time()) then
			LaypopManger_instance:PopBox("InviteCodeActBox")
			cc.UserDefault:getInstance():setStringForKey("PopAct4",os.date("%m%d",os.time()))
		end
	end))
end

function HallView:showAct4RedPoint(data)
	local acticon = self.leftnode:getChildByName("invitecode"):getChildByName("img"):getChildByName("acticon")
	local redpoint = acticon:getChildByName("redpoint")
	if data.status == 1 then
		redpoint:setVisible(true)
	else
		redpoint:setVisible(false)
	end

end

function HallView:showAct5(data)
	local springnode = self.leftnode:getChildByName("spring")

	-- local acticon = springnode:getChildByName("img")

	springnode:setVisible(true)

	local acticon = cc.CSLoader:createNode("ui/newhall/cjhd_denglong/cjhd_denglong.csb")
		:addTo(springnode:getChildByName("img"))
	-- springnode:addChild(acticon)

	local action = cc.CSLoader:createTimeline("ui/newhall/cjhd_denglong/cjhd_denglong.csb")

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")

	WidgetUtils.addClickEvent(touch,function ()
		local Newyear  = require "app.ui.newyear.NewyearView"
	    local newyear = Newyear.new()
	    cc.Director:getInstance():getRunningScene():addChild(newyear)
	end)

	local btn = springnode:getChildByName("btn"):setTouchEnabled(true)

	WidgetUtils.addClickEvent(btn,function ()
		local Newyear  = require "app.ui.newyear.NewyearView"
	    local newyear = Newyear.new()
	    cc.Director:getInstance():getRunningScene():addChild(newyear)
	end)
end

function HallView:showAct6(data)

	local recallnode = self:getActNode(2)

	-- local acticon = recallnode:getChildByName("img")

	recallnode:setVisible(true)

	local acticon = cc.CSLoader:createNode("ui/recallactvity/gu/gu.csb")
		:addTo(recallnode:getChildByName("img"))
		:setPositionY(9)
	-- recallnode:addChild(acticon)

	local action = cc.CSLoader:createTimeline("ui/recallactvity/gu/gu.csb")

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")

	WidgetUtils.addClickEvent(touch,function ()
		LaypopManger_instance:PopBox("RecallActivity")
	end)

	local btn = recallnode:getChildByName("btn"):setTouchEnabled(true)

	WidgetUtils.addClickEvent(btn,function ()
		LaypopManger_instance:PopBox("RecallActivity")
	end)
end

function HallView:runAnimation(node,src)
	local action = cc.CSLoader:createTimeline(src)
	node:runAction(action)
	action:gotoFrameAndPlay(0,true)
end

function HallView:getActNode(num)
	return self.leftnode:getChildByName("node"..num)
end

return HallView