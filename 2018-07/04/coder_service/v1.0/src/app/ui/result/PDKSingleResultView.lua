-------------------------------------------------
--   TODO   斗地主的单局结算UI
--   @author xp
--   Create Date 2018.3.6
-------------------------------------------------
local PDKSingleResultView = class("PDKSingleResultView",PopboxBaseView)
local LongCard = require "app.ui.game_base_cdd.base.LongCard"
local Suanfucforddz = require "app.ui.game_base_cdd.base.Suanfucforddz"

function PDKSingleResultView:ctor(data,gamescene,opentype)

	print("..............小结算。。。。。opentype ＝ ",opentype)
	printTable(data,"xp")

  -- data = 
  -- {
  --   ["sdr_result"] = {
  --          ["is_finished"] = false,
  --          ["winner_index"] = 0,
  --          ["bomb_num"] = 5,
  --          ["players"] =  {
  --              {
  --                  ["hand_cards_info"] =      
  --                  {
  --                 },
  --                  ["boom_info"] =      {
  --                          {
  --                          ["cards"] =          {
  --                           102,
  --                           54,
  --                           38,
  --                           22,
  --                         },
  --                          ["boom_type"] = 20,
  --                     },
  --                          {
  --                          ["cards"] =          {
  --                           66,
  --                           50,
  --                           34,
  --                           18,
  --                         },
  --                          ["boom_type"] = 22,
  --                     },
  --                 },
  --                  ["uid"] = 29981,
  --                  ["score"] = 32,
  --                  ["double_times"] = 0,
  --                  ["win_info"] =      {
  --                 },
  --                  ["bomb_num"] = 3,
  --                  ["multiple"] = 0,
  --             },
  --              {
  --                  ["hand_cards_info"] =      {
  --                      ["hand_cards"] =        {
  --                       41,
  --                       53,
  --                       55,
  --                       70,
  --                       74,
  --                     },
  --                 },
  --                  ["boom_info"] =      {
  --                          {
  --                          ["cards"] =          {
  --                           72,
  --                           56,
  --                           40,
  --                           24,
  --                         },
  --                          ["boom_type"] = 22,
  --                     },
  --                 },
  --                  ["uid"] = 29980,
  --                  ["score"] = -16,
  --                  ["double_times"] = 0,
  --                  ["win_info"] =      {
  --                 },
  --                  ["bomb_num"] = 2,
  --                  ["multiple"] = 0,
  --             },
  --              {
  --                  ["hand_cards_info"] =      {
  --                      ["hand_cards"] =        {
  --                       23,
  --                       26,
  --                       36,
  --                       37,
  --                       39,
  --                       42,
  --                       46,
  --                       58,
  --                       59,
  --                       61,
  --                       67,
  --                       68,
  --                       69,
  --                       71,
  --                       75,
  --                     },
  --                 },
  --                  ["uid"] = 29839,
  --                  ["score"] = -16,
  --                  ["double_times"] = 0,
  --                  ["win_info"] =      {
  --                 },
  --                  ["bomb_num"] = 0,
  --                  ["multiple"] = 0,
  --             },
  --         },
  --     },
  --   }


	self.data = data 
	self.gamescene = gamescene
	if not opentype then
		opentype = 1
	end 
	self.opentype = opentype

	self:initView()
end

function PDKSingleResultView:initView()
	self.widget = cc.CSLoader:createNode("ui/ddz/result/ddz_singleResultView.csb")
	self:addChild(self.widget)
	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("shareBtn"), function( )
		CommonUtils.shareScreen()
	end)

	self.againBtn = self.mainLayer:getChildByName("againbtn")
	WidgetUtils.addClickEvent(self.againBtn, function( )
		self:againBtnCall()
		LaypopManger_instance:back()
	end)

	self.win = self.mainLayer:getChildByName("title1"):setVisible(false)
	self.lose = self.mainLayer:getChildByName("title4"):setVisible(false)
	self.liu = self.mainLayer:getChildByName("title2"):setVisible(false)


	if self.gamescene then
		local issucessfulindex= 0
		for i,v in ipairs(self.data.sdr_result.players) do
			for i1,v1 in ipairs(self.gamescene:getSeatsInfo()) do
				if v.uid == v1.user.uid then
					v.user = v1
					if v1.index == self.gamescene:getMyIndex() then
						-- if v.score > 0 then
						-- 	issucessfulindex = 1
						-- elseif v.score < 0 then
						-- 	issucessfulindex = -1
						-- end
						if self.data.sdr_result.winner_index == v1.index then
							issucessfulindex = 1
						else
							issucessfulindex = -1
						end
					end
				end
			end
		end

		if issucessfulindex == 0 then
			AudioUtils.playEffect("liuju")
			self.liu:setVisible(true)
		elseif issucessfulindex > 0 then
			AudioUtils.playEffect("ddz_gamewin")
			self.win:setVisible(true)
		elseif issucessfulindex < 0 then
			self.lose:setVisible(true)
			AudioUtils.playEffect("ddz_gamelost")
		end

		local roomidStr = "房间ID:"..self.gamescene:getTableID()
		local jushuStr = "第"..self.gamescene:getNowRound().."/"..self.gamescene:getTableConf().round.."局"
		local nameStr = GT_INSTANCE:getGameName(self.gamescene:getTableConf().ttype)
		local guizeStr = GT_INSTANCE:getTableDes(self.gamescene:getTableConf(),4)
		self.mainLayer:getChildByName("text_roomNum"):setString(roomidStr.."  "..jushuStr.."  "..nameStr.."("..guizeStr..")")

		self.againBtn:getChildByName("text_play_1"):setVisible(false)
		self.againBtn:getChildByName("text_play_0"):setVisible(false)
		self.againBtn:getChildByName("text_play"):setVisible(false)
		if self.opentype == 2 then
			print(".........确定")
			self.againBtn:getChildByName("text_play_1"):setVisible(true)
		else
			-- 牌局结束，如果 是总体的牌局结算
			if self.gamescene.allResultData ~= nil then
				self.againBtn:getChildByName("text_play_0"):setVisible(true)
			else
				self.againBtn:getChildByName("text_play"):setVisible(true)
			end
    	end
	end

	self.listView = self.mainLayer:getChildByName("listView")
	local cellItem = self.mainLayer:getChildByName("item")
	cellItem:retain()

	self.listView:setItemModel(cellItem)
	cellItem:removeFromParent()

	self:showUI()
end

function PDKSingleResultView:showUI()

	for i,v in ipairs(self.data.sdr_result.players) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)
		item:setVisible(true)

        --玩家个人信息
        self:updataPlayerInfo(item,v)

        --玩家分数
        self:updataFen(item,v)

        --tips
        self:createTips(item,v)

        --生成牌
        self:createCards(item,v)
        
    end
end

function PDKSingleResultView:updataPlayerInfo(item,data)
	local iconNode =  item:getChildByName("headbg")
	local headicon = iconNode:getChildByName("headicon")
	local name = iconNode:getChildByName("nameLabel")

	if self.gamescene then
    	--玩家属性，以及是否是庄或者房主
		print("......data.user.role_picture_url = ",data.user.role_picture_url)

		local playinfo = self.gamescene:getUserInfoByUid(data.uid)
		local headicon = require("app.ui.common.HeadIcon").new(headicon,playinfo.role_picture_url,64).headicon
		name:setString(ComHelpFuc.getStrWithLength(data.user.nick,8))
		-- name:setString(ComHelpFuc.getStrWithLength(playinfo.nick,8))
		name:setString(ComHelpFuc.getCharacterCountInUTF8String(playinfo.nick,7))
		if self.gamescene:getDealerUid() == data.uid  then
			iconNode:getChildByName("manorImage"):setVisible(true)
		else
			iconNode:getChildByName("manorImage"):setVisible(false)
		end

		iconNode:getChildByName("manorImage"):ignoreContentAdaptWithSize(true):loadTexture("gameddz/icon_zhuang.png")

		if self.gamescene:getTableCreaterID() == data.uid then
			iconNode:getChildByName("isfangzhu"):setVisible(true)
		else
			iconNode:getChildByName("isfangzhu"):setVisible(false)
		end
	end
end

function PDKSingleResultView:updataFen(item,data)
	if data.score >= 0 then
		item:getChildByName("num_fenshu"):setString(math.abs(data.score))
		item:getChildByName("num_fenshu"):getChildByName("add"):setVisible(true)
		item:getChildByName("num_fenshu"):getChildByName("minus"):setVisible(false)
	else
		item:getChildByName("num_fenshu"):setString(math.abs(data.score))
		item:getChildByName("num_fenshu"):getChildByName("minus"):setVisible(true)
		item:getChildByName("num_fenshu"):getChildByName("add"):setVisible(false)
	end
end

local tipsListCof = {
	[70]= {sort = 1,img = "gameddz/result/icon_chuntian.png"},  --70,春天
	[83]= {sort = 1,img = "gameddz/result/icon_heiguan.png"},  --黑关
	[84]= {sort = 1,img = "gameddz/result/icon_fangzoubaopei.png"},  -- 包赔

	[1000]= {sort = 2,img = "gameddz/result/icon_yinzha.png"},  --硬炸弹
	[1001]= {sort = 2,img = "gameddz/result/icon_ruanzha.png"},  --软炸弹
	[1002]= {sort = 3,img = "gameddz/result/icon_hui.png"},  --回
	[1003]= {sort = 3,img = "gameddz/result/icon_ti.png"},  --踢
	[1004]= {sort = 3,img = "gameddz/result/icon_boom.png"},  --普通炸弹
}


function PDKSingleResultView:createTips(item,data)
  --名堂显示，目前只有春天
	local tipsList = {}
	local wininfo = data.win_info and data.win_info.styles or {}
	for k,v in pairs(wininfo) do
		table.insert(tipsList,tipsListCof[v])
	end

	if self.gamescene and  self.gamescene:getTableConf().ttype == HPGAMETYPE.MCDDZ  then  
		--处理数据  --炸弹显示
		if data.bomb_num and data.bomb_num > 0  then
			local _bomb = tipsListCof[1000]
			_bomb.num = data.bomb_num
			table.insert(tipsList,_bomb)
		end

		--处理数据  --软炸弹显示
		if data.soft_bomb_num and data.soft_bomb_num > 0  then
			local _bomb = tipsListCof[1001]
			_bomb.num = data.soft_bomb_num
			table.insert(tipsList,_bomb)
		end
	else
		if data.bomb_num and data.bomb_num > 0  then
			local _bomb = tipsListCof[1004]
			_bomb.num = data.bomb_num
			table.insert(tipsList,_bomb)
		end
	end

	--处理数据,踢和回踢显示
	if data.double_times and data.double_times > 0 then
		local _double = tipsListCof[1003]
		if self.gamescene:getDealerUid() == data.uid  then
			_double = tipsListCof[1002]
		end
		_double.num = data.double_times
		table.insert(tipsList,_double)
	end

	table.sort(tipsList, function (a,b)
		return a.sort > b.sort
	end)

	local tipNode = item:getChildByName("tipNode")
	tipNode:setPositionX(1060)
	local _width = 0

	for k,v in pairs(tipsList) do 
		local tips = ccui.ImageView:create(v.img)
		if _width == 0 then
			tips:setPositionX(0)
			_width =  - tips:getContentSize().width/2.0
		else
			tips:setPositionX(0-(tips:getContentSize().width/2.0 + _width))
		end
		tipNode:addChild(tips)
		_width = _width + tips:getContentSize().width + 10

		if v.num and v.num > 0  then
			local _size = tips:getContentSize()
			local red = cc.Sprite:create("gameddz/icon_red.png")
			:setScale(1.2)
			:setPosition(cc.p(_size.width/2.0 + 18,_size.height/2.0 - 18))
			:addTo(tips)

			if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.MCDDZ  then  
				red:setPositionY(_size.height/2.0 + 18)
			end

			local text = ccui.Text:create(v.num,FONTNAME_DEF,20)
			:addTo(red)
			:setPosition(cc.p(10,11))
		end
	end

	--地主牌展示
	if self.gamescene and self.gamescene:getDealerUid() == data.uid  then
		local dizhupai = self.gamescene:getDiZhuCards()
		for i1,v1 in ipairs(dizhupai) do
			local pokerCard = LongCard.new(v1)
			pokerCard:setCardAnchorPoint(cc.p(1,0.5))
			pokerCard:setPositionX(0 -_width + (i1-#dizhupai)*70*0.35)
			pokerCard:setScale(0.35)
			tipNode:addChild(pokerCard)
		end
		_width = _width + #dizhupai * 70*0.35 + 45
	end 

	if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.ESDDZ  then  
		if data.boom_info  then
			for k,v in pairs(data.boom_info) do
				for i1,v1 in ipairs(v.cards) do
					local pokerCard = LongCard.new(v1)
					pokerCard:setCardAnchorPoint(cc.p(1,0.5))
					pokerCard:setPositionX(0 -_width + (i1-#v.cards)*70*0.35)
					pokerCard:setScale(0.35)
					tipNode:addChild(pokerCard)
				end

				local  _back = ccui.ImageView:create("gameddz/result/red_line.png")
				_back:setAnchorPoint(cc.p(1,0.5))
				_back:setContentSize(cc.size(158*0.35+(#v.cards-1)*70*0.35,218*0.35))
				_back:setScale9Enabled(true)
				_back:setCapInsets(cc.rect(10, 10, 30, 30))
				_back:setPositionX(-_width)
				tipNode:addChild(_back)

				_width = _width + #v.cards * 70*0.35 + 45
			end
		end
	end
end

function PDKSingleResultView:createCards(item,data)
	local handCards = data.hand_cards_info.hand_cards
	if handCards then
		Suanfucforddz:sort( handCards )
		for i1,v1 in ipairs(handCards) do
			local pokerCard = LongCard.new(v1)
			pokerCard:setCardAnchorPoint(cc.p(0,0))
			pokerCard:setScale(0.6)
			pokerCard:setPositionX((i1-1)*70*0.6)
			item:getChildByName("cardNode"):addChild(pokerCard)
		end
	end
end

function PDKSingleResultView:againBtnCall()
	print("再来一局")
	if self.gamescene then
		if self.opentype == 2 then
			local owner = self.gamescene
			cc.Director:getInstance():popScene()
		else  
			local data = self.data
			local owner = self.gamescene
			AudioUtils.setMusicVolume(cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") )
			if self.gamescene.allResultData ~= nil  then
				glApp:enterSceneByName("AllResultScene",self.gamescene)
			else  
				Socketapi.request_ready(true)
				owner:waitGameStart()
			end 
			LaypopManger_instance:back()
		end 
	end
end

return PDKSingleResultView