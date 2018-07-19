--新版大厅，花牌＋扑克牌的
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
	print(".......HallView:initView()")
	local kuangUI = cc.CSLoader:createNode("ui/newhall/_kuangUI.csb")
	self:addChild(kuangUI)

	self.mainLayer = kuangUI:getChildByName("main")
	WidgetUtils.setBgScale(kuangUI:getChildByName("bg"))
	WidgetUtils.setScalepos(self.mainLayer)

	self:initTopNode()
	self:initBottomNode()
	self:initLeftNode()
	self:initRightNode()

	self:initMidNode()
end

--初始化顶部各节点，按钮，城市切好，跑马灯...
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
		LaypopManger_instance:PopBox("ShopView")
	end)
	WidgetUtils.addClickEvent(self.roomCardBg:getChildByName("cardImage"), function( )
		print("购卡提示")
		LaypopManger_instance:PopBox("ShopView")
	end)
	WidgetUtils.addClickEvent(self.roomCardBg:getChildByName("addImage"), function( )
		print("购卡提示")
		LaypopManger_instance:PopBox("ShopView")
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
				-- self.msgBtn
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

		LaypopManger_instance:PopBox("CustomerserviceView")
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
--初始化底部各按钮...
function HallView:initBottomNode()
	self.bottomNode = self.mainLayer:getChildByName("bottomNode")
	local itemlist = self.bottomNode:getChildByName("itemlist")
	-- 商店
	local shop = itemlist:getChildByName("shop")
	WidgetUtils.addClickEvent(shop, function()
			LaypopManger_instance:PopBox("ShopView")
		end)
	local bag = itemlist:getChildByName("bag")
	WidgetUtils.addClickEvent(bag,function ()
			LaypopManger_instance:PopBox("BagView")
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
			--LaypopManger_instance:PopBox("SharePromptBoxView")
			LaypopManger_instance:PopBox("InviteCodeActCourtesy")
		end)
	local tip = share:getChildByName("tip")
	-- if tip then
	-- 	tip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.DelayTime:create(1),cc.FadeIn:create(2))))
	-- end
	-- 认证
	local authen = itemlist:getChildByName("authentication")
	WidgetUtils.addClickEvent(authen, function()
		ComHttp.httpPOST(ComHttp.URL.CHECKREALNAME,{uid = LocalData_instance:getUid()},function(data)
			-- 1已经实名认证，0未实名认证
			if data.status == 1 then
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你已经完成实名认证，无需认证了！"})
			elseif data.status == 0 then
				LaypopManger_instance:PopBox("Setrealname")
			end	
		end)	
	end)
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

--初始化左边各活动挂点
function HallView:initLeftNode()
	self.leftnode = self.mainLayer:getChildByName("leftnode")
	for i=1,4 do
		self.leftnode:getChildByName("node"..i):setVisible(false)
	end
	self:dailizhaomu()
end



--初始化右边各活动挂点
function HallView:initRightNode()
	self.rightnode = self.mainLayer:getChildByName("rightnode")
	for i=1,4 do
		self.rightnode:getChildByName("node"..i):setVisible(false)
	end
	self:jubaodianhua()
	if GAME_CITY_SELECT == 1 then
		--试玩场
		self:shiwanchang()
	end
end

--把大厅的中间部分独立出来了
function HallView:initMidNode()

	if GAME_CITY_SELECT == 1 then
		local _middleUi = cc.CSLoader:createNode("ui/newhall/_middleUi_new.csb")
		self.mainLayer:addChild(_middleUi,-1)


		self.midNode = _middleUi:getChildByName("midNode")
		self.midNode:setPosition(display.center)
		-- self.midNode
		WidgetUtils.setScalepos(self.midNode)

		self:initCreateRoomBtnWhole()
		self:initJoinRoomBtnWhole()
		self:initTeaRoomBtnWhole()
		self:initMatchRoomBtnWhole()
		self:refreshCreateBtn()
	else
		self.game_num = 1  --当只有一个的时候，就算是扑克牌，也是放到花牌列表中
		if #CM_INSTANCE:getPOKERGAMESLIST() ~= 0 then --还有扑克牌
			self.game_num = self.game_num + 1
		end
		if #CM_INSTANCE:getMAJIANGGAMESLIST() ~= 0 then --还有麻将
			self.game_num = self.game_num + 1
		end

		print("......self.game_num = ",self.game_num )

		--num表示有几种类型的牌
		local _middleUi = cc.CSLoader:createNode("ui/newhall/_middleUi_"..self.game_num..".csb")
		self.mainLayer:addChild(_middleUi,-1)



		self.midNode = _middleUi:getChildByName("midNode")
		self.midNode:setPosition(display.center)
		-- self.midNode
		WidgetUtils.setScalepos(self.midNode)

		-- 创建房间
		self:initCreateRoomBtn()
		self:initCreateRoomBtn_Poker()
		self:initCreateRoomBtn_MaJiang()
		self:refreshCreateBtn()
		-- 加入房间
		self:initJoinRoomBtn()

		-- 亲友圈
		self:initTeaRoomBtn()
	end


end



function HallView:initCreateRoomBtn()

	local createRoomNode = self.midNode:getChildByName("createRoomNode")

	local btn = createRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = createRoomNode:getChildByName("img")
	local text1 = createRoomNode:getChildByName("text")
	local text2 = createRoomNode:getChildByName("text2")

	function createRoomNode:setJoinVisibe(bool)
		text1:setVisible(not bool)
		text2:setVisible(bool)
		return self
	end

	WidgetUtils.addClickEvent(btn, function( )
		local table_id = glApp:getCurScene().table_id
		local isPoker = glApp:getCurScene().isPoker
		local isMaJiang = glApp:getCurScene().isMaJiang

		if table_id and table_id ~= 0 and isPoker == false and isMaJiang == false then
			print("返回房间")
			local table_id = glApp:getCurScene().table_id 
			Notinode_instance:jointable(table_id)
		else	
			print("创建房间")
			LaypopManger_instance:PopBox("CreateRoomView",1)
		end	
	end)


	if self.game_num == 1 then
		local animationnode1 = createRoomNode:getChildByName("animation1")
		self:runAnimation(animationnode1,"ui/newhall/dating/chuangjian.csb")

		local animationnode3 = createRoomNode:getChildByName("animation2")
		self:runAnimation(animationnode3,"ui/newhall/dating/yellow_chuangjian.csb")

		if GAME_CITY_SELECT == 4 then
			img:loadTexture("ui/newhall/icon_xiaochang.png", ccui.TextureResType.localType)
		end
		if GAME_CITY_SELECT == 6 then
			img:loadTexture("ui/newhall/icon_gzp.png", ccui.TextureResType.localType)
		end
		if GAME_CITY_SELECT == 2 or GAME_CITY_SELECT == 3 then
			img:loadTexture("ui/newhall/icon_create_poker.png", ccui.TextureResType.localType)
		end
	else
		local animationnode = createRoomNode:getChildByName("animation")
		self:runAnimation(animationnode,"ui/newhall/dating/huapai.csb")
	end

end

function HallView:initCreateRoomBtn_Poker()

	local create_poker = self.midNode:getChildByName("createRoom_poker")
	if  create_poker == nil then
		return
	end

	local btn = create_poker:getChildByName("btn"):setTouchEnabled(true)
	local img = create_poker:getChildByName("img")
	-- local img2 = createRoomNode:getChildByName("img2") --桑植96的扑克牌
	local text1 = create_poker:getChildByName("text")
	local text2 = create_poker:getChildByName("text2")

	function create_poker:setJoinVisibe (bool)
		text1:setVisible(not bool)
		text2:setVisible(bool)
		return self
	end

	WidgetUtils.addClickEvent(btn, function( )
		local table_id = glApp:getCurScene().table_id
		local isPoker = glApp:getCurScene().isPoker
		local isMaJiang = glApp:getCurScene().isMaJiang

		if table_id and table_id ~= 0 and isPoker == true and isMaJiang == false then
			print("返回房间")
			local table_id = glApp:getCurScene().table_id 
			Notinode_instance:jointable(table_id)
		else	
			print("创建房间")
			LaypopManger_instance:PopBox("CreateRoomView",2)
		end	
	end)


	local animationnode = create_poker:getChildByName("animation")
	if #CM_INSTANCE:getMAJIANGGAMESLIST() == 0 then --只有花牌和斗地主，是大特效，另外的是小特效
		print("............只有花牌和斗地主")
		self:runAnimation(animationnode,"ui/newhall/dating/pukepai.csb") 
	else
		print("............还有麻将")
		self:runAnimation(animationnode,"ui/newhall/dating/pukepai_new.csb")
	end
	
end

function HallView:initCreateRoomBtn_MaJiang()
	local create_majiang = self.midNode:getChildByName("createRoom_majiang")
	if  create_majiang == nil then
		return
	end

	local btn = create_majiang:getChildByName("btn"):setTouchEnabled(true)
	-- local img = create_majiang:getChildByName("img")
	-- local img2 = create_majiang:getChildByName("img2") --桑植96的扑克牌
	local text1 = create_majiang:getChildByName("text")
	local text2 = create_majiang:getChildByName("text2")

	function create_majiang:setJoinVisibe (bool)
		text1:setVisible(not bool)
		text2:setVisible(bool)
		return self
	end

	WidgetUtils.addClickEvent(btn, function( )
		local table_id = glApp:getCurScene().table_id
		local isPoker = glApp:getCurScene().isPoker
		local isMaJiang = glApp:getCurScene().isMaJiang

		if table_id and table_id ~= 0 and isPoker == false and isMaJiang == true then
			print("返回房间")
			local table_id = glApp:getCurScene().table_id 
			Notinode_instance:jointable(table_id)
		else	
			print("创建房间")
			-- cc.UserDefault:getInstance():setIntegerForKey("game_class_select",3)
			LaypopManger_instance:PopBox("CreateRoomView",3)
		end	
	end)

	local animationnode = create_majiang:getChildByName("animation")
	self:runAnimation(animationnode,"ui/newhall/dating/majiang_new.csb")

end

function HallView:initCreateRoomBtnWhole()
	local createRoomNode = self.midNode:getChildByName("createRoomNode")

	local btn = createRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = createRoomNode:getChildByName("img")
	local text1 = createRoomNode:getChildByName("text")
	local text2 = createRoomNode:getChildByName("text2")

	function createRoomNode:setJoinVisibe(bool)
		text1:setVisible(not bool)
		text2:setVisible(bool)
		return self
	end

	WidgetUtils.addClickEvent(btn, function( )
		local table_id = glApp:getCurScene().table_id

		if table_id and table_id ~= 0 then
			print("返回房间")
			local table_id = glApp:getCurScene().table_id 
			Notinode_instance:jointable(table_id)
		else	
			print("创建房间")
			LaypopManger_instance:PopBox("CreateRoomView",99)
		end	
	end)

	local animationnode = createRoomNode:getChildByName("animation")
	self:runAnimation(animationnode,"ui/newhall/hall_anima_new/dating/chuangjianfangjian.csb")
end

function HallView:refreshCreateBtn()
	local table_id = glApp:getCurScene().table_id
	local isPoker = glApp:getCurScene().isPoker
	local isMaJiang = glApp:getCurScene().isMaJiang

	local createRoomNode = self.midNode:getChildByName("createRoomNode")
	if GAME_CITY_SELECT == 1 then
		createRoomNode = createRoomNode and createRoomNode:setJoinVisibe(table_id and table_id ~= 0)
		return
	end
	createRoomNode = createRoomNode and createRoomNode:setJoinVisibe(table_id and table_id ~= 0 and isPoker == false and isMaJiang == false)

	local createRoom_poker = self.midNode:getChildByName("createRoom_poker")
	createRoom_poker = createRoom_poker and createRoom_poker:setJoinVisibe(table_id and table_id ~= 0 and isPoker == true and isMaJiang == false)

	local create_majiang = self.midNode:getChildByName("createRoom_majiang")
	create_majiang = create_majiang and create_majiang:setJoinVisibe(table_id and table_id ~= 0 and isPoker == false and isMaJiang == true )
end

function HallView:initJoinRoomBtn()
	local joinRoomNode = self.midNode:getChildByName("joinRoomNode")

	local btn = joinRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = joinRoomNode:getChildByName("img")
	local text1 = joinRoomNode:getChildByName("text")

	WidgetUtils.addClickEvent(btn, function( )
		print("加入房间")
		LaypopManger_instance:PopBox("JoinRoomView")
	end)

	if self.game_num == 1 then
		local animationnode = joinRoomNode:getChildByName("animation")
		if  GAME_CITY_SELECT == 2 or GAME_CITY_SELECT == 3 then
			local img2 = joinRoomNode:getChildByName("img2"):setVisible(true)
			img:setVisible(false)
			animationnode:setVisible(false)
		else
			-- animationnode:setPosition(cc.p(60,20))
			self:runAnimation(animationnode,"ui/newhall/dating/pai_saoguang.csb")
		end
	else
		local animationnode = joinRoomNode:getChildByName("animation")
		self:runAnimation(animationnode,"ui/newhall/dating/jiaru.csb")
	end
end

function HallView:initJoinRoomBtnWhole()
	local joinRoomNode = self.midNode:getChildByName("joinRoomNode")

	local btn = joinRoomNode:getChildByName("btn"):setTouchEnabled(true)
	local img = joinRoomNode:getChildByName("img")
	local text1 = joinRoomNode:getChildByName("text")

	WidgetUtils.addClickEvent(btn, function( )
		print("加入房间")
		LaypopManger_instance:PopBox("JoinRoomView")
	end)

	local animationnode = joinRoomNode:getChildByName("animation")
	self:runAnimation(animationnode,"ui/newhall/hall_anima_new/dating/jiarufangjian.csb")
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

	if self.game_num == 1 then
		local animationnode = teaRoomNode:getChildByName("animation")
		self:runAnimation(animationnode,"ui/newhall/dating/zhongguojie.csb")
	end
end

function HallView:initTeaRoomBtnWhole()
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
end

function HallView:initMatchRoomBtnWhole()
	local matchNode = self.midNode:getChildByName("matchNode")

	local btn = matchNode:getChildByName("btn"):setTouchEnabled(true)
	local text1 = matchNode:getChildByName("text")

	WidgetUtils.addClickEvent(btn, function( )
		LaypopManger_instance:PopBox("MatchView")
	end)

	local animationnode = matchNode:getChildByName("animation")
	self:runAnimation(animationnode,"ui/newhall/hall_anima_new/dating/bisaichang_jiangbei.csb")
end

function HallView:refreshView()
	self.cardnumLabel:setString(LocalData_instance:getChips())
	local name = ComHelpFuc.getCharacterCountInUTF8String(LocalData_instance:getNick(),10)
	self.nameLabel:setString(name)
	self.IDLabel:setString("ID:"..LocalData_instance:getUid())
	-- require("app.ui.common.HeadIcon").new(self.headIcon,"http://dev.arthur-tech.com/Uploads/wechat/g3x5qn2lpt2BqKPdrqtqp39hfIvKgaJ7hqaD0a-iapaHa36thJHVmJirm9O6uIeoipyhbw.jpeg")
	local equips = LocalData_instance:get("items_info")
	if equips and equips ~= "" then
		equips = cjson.decode(equips)
	else
		equips = {}
	end
	
	local headframe = require("app.ui.bag.RoomEquip").getHeadFrame(equips)

	if headframe then
		self.headBg:setVisible(false)
	else
		self.headBg:setVisible(true)
	end

	local head = require("app.ui.common.HeadIcon").new(self.headIcon,LocalData_instance:getPic(),nil,headframe).headicon

	WidgetUtils.addClickEvent(head, function( )
		print("点击头像")
		LaypopManger_instance:PopBox("PlayerInfoView")
	end)
end

function HallView:updateChip(data)
	LocalData_instance:setChips(data.cur_chip)
	self.cardnumLabel:setString(LocalData_instance:getChips())
end

function HallView:releaseroomcall()

	glApp:getCurScene().table_id = nil
	glApp:getCurScene().isPoker = nil 

	self:refreshCreateBtn()
end



-- 跑马灯
function HallView:runMarqueen()
    local function action()
	    local width = self.shieldLayer:getContentSize().width
    	local str = Notinode_instance:getPaomadingmsg()
    	if SHENHEBAO or str == nil then
    		str = "欢迎来到今日花牌，祝您玩得高兴！"
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

	self:showActNode(3,"ui/inviteforredpacke/dating_lingxianjin/dating_lingxianjin.csb",function ()
		 LaypopManger_instance:PopBox("IFRPView")
	end,cc.p(0,0))
end

function HallView:showAct3(data)
	print("......showAct3")

	local index = 2
	if GAME_CITY_SELECT == 1 then
		index = 3
	end
	self:showActNode(index,"ui/newcommeract/datinglibao/datinglibao.csb",function ()
	end,cc.p(-10,0),true)

	local actnode = self:getActNode(index,true)
	local acticon =  actnode:getChildByName("img"):getChildByName("acticon")
	local redpoint = acticon:getChildByName("redpoint")
	for i,v in ipairs(data.list) do
		if v.canget == 2 then
			redpoint:setVisible(true)
			break
		end
	end

	local touch = acticon:getChildByName("touch")
	WidgetUtils.addClickEvent(touch,function ()
		LaypopManger_instance:PopBox("NewCommerAct",redpoint)
	end)

	WidgetUtils.addClickEvent(actnode:getChildByName("btn"),function ()
		LaypopManger_instance:PopBox("NewCommerAct",redpoint)
	end)
end

function HallView:showAct4(data)
	
	self:showActNode(2,"ui/invitecodeact/dating_lingfangka/dating_lingfangka.csb",function ()
		local acticon = self:getActNode(2):getChildByName("img"):getChildByName("acticon")
		local redpoint = acticon:getChildByName("redpoint")
		LaypopManger_instance:PopBox("InviteCodeActBox",redpoint)

	end,cc.p(0,0))

	self:runAction(cc.CallFunc:create(function ()
		if cc.UserDefault:getInstance():getStringForKey("PopAct4","") ~= os.date("%m%d",os.time()) then
			LaypopManger_instance:PopBox("InviteCodeActBox")
			cc.UserDefault:getInstance():setStringForKey("PopAct4",os.date("%m%d",os.time()))
		end
	end))
end

function HallView:showAct4RedPoint(data)
	local acticon = self:getActNode(2):getChildByName("img"):getChildByName("acticon")
	local redpoint = acticon:getChildByName("redpoint")
	if data.status == 1 then
		redpoint:setVisible(true)
	else
		redpoint:setVisible(false)
	end

end

function HallView:showAct5(data)

	self:showActNode(4,"ui/newhall/cjhd_denglong/cjhd_denglong.csb",function ()
		local Newyear  = require "app.ui.newyear.NewyearView"
	    local newyear = Newyear.new()
	    cc.Director:getInstance():getRunningScene():addChild(newyear)

	end,cc.p(0,0))
end

function HallView:showAct6(data)

	self:showActNode(2,"ui/recallactvity/gu/gu.csb",function ()
		LaypopManger_instance:PopBox("RecallActivity")
	end,cc.p(0,9))
end


function HallView:runAnimation(node,src)
	local action = cc.CSLoader:createTimeline(src)
	node:runAction(action)
	action:gotoFrameAndPlay(0,true)
end



--违法举报,放右边第一个
function HallView:jubaodianhua()

	self:showActNode(1,"ui/jubaodianhua/jubaodianhua.csb",function ()
		LaypopManger_instance:PopBox("ReportView")
	end,cc.p(-10,0),true)

end

----试玩场放右边第二个
function HallView:shiwanchang()

	self:showActNode(2,"animation/shiwanchang/shiwanchang.csb",function ()
		Socketapi.requestCreateTableForFree({ttype = HPGAMETYPE.HFBH,ztype = 10})
	end,cc.p(-10,0),true)
end

----代理招募放左边第一个
function HallView:dailizhaomu()
	self:showActNode(1,"ui/dailizhaomu/dating_zhaomudaili/dating_zhaomudaili.csb",function ()
		LaypopManger_instance:PopBox("Dailizhaomu")
	end,cc.p(-20,5))
end


function HallView:getActNode(num,isRight)
	if  isRight  then
		return self.rightnode:getChildByName("node"..num)
	end
	return self.leftnode:getChildByName("node"..num)
end

function HallView:showActNode(index,src,func,pos,isRight)
	local actnode = self.leftnode:getChildByName("node"..index)
	if isRight then
		actnode = self.rightnode:getChildByName("node"..index)
	end
	actnode:setVisible(true)

	local acticon = cc.CSLoader:createNode(src)
		:addTo(actnode:getChildByName("img"))
		:setPosition(pos)
		:setName("acticon")

	local action = cc.CSLoader:createTimeline(src)

	acticon:runAction(action)
	action:gotoFrameAndPlay(0,true)

	local touch = acticon:getChildByName("touch")
	if  touch  then
		WidgetUtils.addClickEvent(touch,function ()
			func()
		end)
	end

	WidgetUtils.addClickEvent(actnode:getChildByName("btn"),function ()
		func()
	end)
end


return HallView