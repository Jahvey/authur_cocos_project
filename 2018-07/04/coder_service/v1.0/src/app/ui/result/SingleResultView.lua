-------------------------------------------------
--   TODO   花牌的单局结算UI
--   @author xp
--   Create Date 2017.11.27
-------------------------------------------------
local SingleResultView = class("SingleResultView",PopboxBaseView)
local LongCard = require "app.ui.game.base.LongCard"
function SingleResultView:ctor(data,owner,opentype)
	self:initData(data,owner,opentype)
	self:initView()
end
-- opentype  1 正常结算 2 回放结算
function SingleResultView:initData(data,owner,opentype)
	print("............SingleResultView 1 正常结算 2 回放结算")
	printTable(data,"xp69")

 	self.gamescene = owner
 	if not opentype then
 		opentype = 1
 	end 
 	if self.gamescene then
 		if opentype == 2 then
 			self.gamescene = owner
 		elseif opentype == 1 then	
			self.gamescene = self.gamescene
		end	
	end	
     self.seatinfo = self.gamescene:getSeatsInfo()
	self.data = data.sdr_result
  	  --  self.data = {
    	-- 	   ["is_finished"] = false,
    	-- 	   ["winner_index"] = 1,
    	-- 	   ["cards"] =  {
     --  			115,
     --  			130,
     --  			67,
     --  			130,
     --  			113,
     --  			113,
     --  			17,
     --  			18,
     --  			113,
     --  			115,
     --  			129,
     --  			97,
     --  			51,
     --  			129,
     --  			99,
     --  			50,
     --  			34,
     --  			99,
     --  			34,
     --  			19,
     --  			50,
     --  			18,
     --  			19,
     --  			81,
     --  			83,
     --  			129,
     --  			49,
     --  			34,
     --  			115,
     --  			99,
     --  			99,
     --  			82,
     --  			67,
     --  			114,
     --  			51,
     --  		},
    	-- 	   ["players"] =  {
     --  			   {
     --    				   ["col_info_lsit"] =      {
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 3,
     --        						   ["token"] = 2,
     --        						   ["dest_index"] = 2,
     --        						   ["dest_card"] = 66,
     --        						   ["cards"] =          {
     --          							66,
     --          							66,
     --          							66,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      					       {
     --        						   ["an_num"] = 2,
     --        						   ["col_type"] = 4,
     --        						   ["token"] = 3,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 35,
     --        						   ["cards"] =          {
     --          							35,
     --          							35,
     --          							35,
     --          						},
     --        						   ["score"] = 6,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = true,
     --        						   ["col_type"] = 2,
     --        						   ["token"] = 4,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 82,
     --        						   ["cards"] =          {
     --          							82,
     --          							81,
     --          							83,
     --          						},
     --        						   ["score"] = 0,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = true,
     --        						   ["is_waichi"] = true,
     --        						   ["dest_card"] = 17,
     --        						   ["token"] = 1,
     --        						   ["dest_index"] = 0,
     --        						   ["col_type"] = 2,
     --        						   ["cards"] =          {
     --          							19,
     --          							18,
     --          							17,
     --          						},
     --        						   ["score"] = 3,
     --        					},
     --      					       {
     --        						   ["dest_card"] = 129,
     --        						   ["col_type"] = 1,
     --        						   ["cards"] =          {
     --          							129,
     --          							131,
     --          							131,
     --          						},
     --        						   ["score"] = 4,
     --        					},
     --      					       {
     --        						   ["dest_card"] = 97,
     --        						   ["col_type"] = 1,
     --        						   ["cards"] =          {
     --          							97,
     --          							97,
     --          							131,
     --          						},
     --        						   ["score"] = 3,
     --        					},
     --      					       {
     --        						   ["dest_card"] = 49,
     --        						   ["col_type"] = 1,
     --        						   ["cards"] =          {
     --          							49,
     --          							51,
     --          							131,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      				},
     --    				   ["dest_card"] = 131,
     --    				   ["out_cols"] =      {
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 3,
     --        						   ["token"] = 2,
     --        						   ["dest_index"] = 2,
     --        						   ["dest_card"] = 66,
     --        						   ["cards"] =          {
     --          							66,
     --          							66,
     --          							66,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      					       {
     --        						   ["an_num"] = 2,
     --        						   ["col_type"] = 4,
     --        						   ["token"] = 3,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 35,
     --        						   ["cards"] =          {
     --          							35,
     --          							35,
     --          							35,
     --          						},
     --        						   ["score"] = 6,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = true,
     --        						   ["col_type"] = 2,
     --        						   ["token"] = 4,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 82,
     --        						   ["cards"] =          {
     --          							82,
     --          							81,
     --          							83,
     --          						},
     --        						   ["score"] = 0,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = true,
     --        						   ["is_waichi"] = true,
     --        						   ["dest_card"] = 17,
     --        						   ["token"] = 1,
     --        						   ["dest_index"] = 0,
     --        						   ["col_type"] = 2,
     --        						   ["cards"] =          {
     --          							19,
     --          							18,
     --          							17,
     --          						},
     --        						   ["score"] = 3,
     --        					},
     --      				},
     --    				   ["hu_num"] = 13,
     --    				   ["hand_cards_info"] =      {
     --      					   ["hand_cards"] =        {
     --        						49,
     --        						51,
     --        						97,
     --        						98,
     --        						129,
     --        					},
     --      				},
     --    				   ["qiang_num"] = 0,
     --    				   ["win_info"] =      {
     --      					   ["styles"] =        {
     --        						1,
     --        						27,
     --        					},
     --      				},
     --    				   ["uid"] = 23399,
     --    				   ["score"] = 8,
     --    			},
     --  			   {
     --    				   ["hand_cards_info"] =      {
     --      					   ["hand_cards"] =        {
     --        						19,
     --        						49,
     --        						50,
     --        						113,
     --        						114,
     --        						115,
     --        					},
     --      				},
     --    				   ["uid"] = 23398,
     --    				   ["win_info"] =      {
     --      					   ["styles"] =        {
     --        						27,
     --        					},
     --      				},
     --    				   ["out_cols"] =      {
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = false,
     --        						   ["col_type"] = 2,
     --        						   ["token"] = 1,
     --        						   ["dest_index"] = 0,
     --        						   ["dest_card"] = 49,
     --        						   ["cards"] =          {
     --          							49,
     --          							50,
     --          							51,
     --          						},
     --        						   ["score"] = 3,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 1,
     --        						   ["token"] = 2,
     --        						   ["dest_index"] = 0,
     --        						   ["dest_card"] = 34,
     --        						   ["cards"] =          {
     --          							34,
     --          							33,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 3,
     --        						   ["token"] = 3,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 65,
     --        						   ["cards"] =          {
     --          							65,
     --          							65,
     --          							65,
     --          						},
     --        						   ["score"] = 0,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["is_bi_chi"] = true,
     --        						   ["col_type"] = 2,
     --        						   ["token"] = 4,
     --        						   ["dest_index"] = 2,
     --        						   ["dest_card"] = 65,
     --        						   ["cards"] =          {
     --          							65,
     --          							66,
     --          							67,
     --          						},
     --        						   ["score"] = 0,
     --        					},
     --      				},
     --    				   ["score"] = -4,
     --    			},
     --  			   {
     --    				   ["hand_cards_info"] =      {
     --      					   ["hand_cards"] =        {
     --        						17,
     --        						33,
     --        						33,
     --        						33,
     --        						35,
     --        						81,
     --        						82,
     --        						83,
     --        						97,
     --        						97,
     --        					},
     --      				},
     --    				   ["uid"] = 23400,
     --    				   ["win_info"] =      {
     --      					   ["styles"] =        {
     --        						27,
     --        					},
     --      				},
     --    				   ["out_cols"] =      {
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 1,
     --        						   ["token"] = 1,
     --        						   ["dest_index"] = 2,
     --        						   ["dest_card"] = 130,
     --        						   ["cards"] =          {
     --          							130,
     --          							131,
     --          						},
     --        						   ["score"] = 0,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 1,
     --        						   ["token"] = 2,
     --        						   ["dest_index"] = 1,
     --        						   ["dest_card"] = 18,
     --        						   ["cards"] =          {
     --          							18,
     --          							17,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      					       {
     --        						   ["an_num"] = 0,
     --        						   ["col_type"] = 3,
     --        						   ["token"] = 3,
     --        						   ["dest_index"] = 0,
     --        						   ["dest_card"] = 98,
     --        						   ["cards"] =          {
     --          							98,
     --          							98,
     --          							98,
     --          						},
     --        						   ["score"] = 2,
     --        					},
     --      				},
     --    				   ["score"] = -4,
     --    			},
     --  		},
    	-- }


	self.opentype = opentype
end

function SingleResultView:initView()
	self.widget = cc.CSLoader:createNode("ui/singleResult/singleResultView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	
	self.againBtn = self.mainLayer:getChildByName("againbtn")
	WidgetUtils.addClickEvent(self.againBtn, function( )
		self:againBtnCall()	
	end)

	self.sharebtn = self.mainLayer:getChildByName("sharebtn")
	WidgetUtils.addClickEvent(self.sharebtn, function( )
		CommonUtils.shareScreen()
	end)

	if SHENHEBAO  then
		self.sharebtn:setVisible(false)
	end
	
	self.win = self.mainLayer:getChildByName("win"):setVisible(false)
	self.lose = self.mainLayer:getChildByName("lose"):setVisible(false)
	self.liu = self.mainLayer:getChildByName("liuju"):setVisible(false)

	if  self.gamescene then
		if self.data.winner_index == -1 then
			AudioUtils.playEffect("liuju")
			self.liu:setVisible(true)
		else
			if self.data.winner_index == self.gamescene:getMyIndex() then
				AudioUtils.playEffect("gamewin")
				self.win:setVisible(true)
			else
				self.lose:setVisible(true)
				AudioUtils.playEffect("gamelost")
			end
		end

		local roomidStr = "房间ID:"..self.gamescene:getTableID()
		local jushuStr = "第"..self.gamescene:getNowRound().."/"..self.gamescene:getTableConf().round.."局"
		local nameStr = GT_INSTANCE:getGameName(self.gamescene:getTableConf().ttype)
		local guizeStr = GT_INSTANCE:getTableDes(self.gamescene:getTableConf(),4)

		self.mainLayer:getChildByName("roomInfo"):setString(roomidStr.."   "..jushuStr)
		self.mainLayer:getChildByName("roomconf"):setString(nameStr.."("..guizeStr..")")
	end

	self.cardItem = self.mainLayer:getChildByName("cardItem")
	self.cardItem:setVisible(false)
	self.cardItem:retain()
	self.cardItem:removeFromParent()

    self:showUI()

    self:showRestCard()

end
function SingleResultView:showUI()
	self:createPlayerInfo()  

	for i,v in ipairs(self.againBtn:getChildren()) do
		v:setVisible(false)
	end
	if  self.gamescene then
		if self.opentype == 2 then
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
end

function SingleResultView:createPlayerInfo()

	self.mainLayer:getChildByName("item_4"):setVisible(false)
  self.mainLayer:getChildByName("item_3"):setVisible(false)

	for k,v in pairs(self.data.players) do

		-- print("SingleResultView:createPlayerInfo()")
		
		-- printTable(v,"xp")

		local item = self.mainLayer:getChildByName("item_"..k)
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

function SingleResultView:updataPlayerInfo(item,data)

	local iconNode =  item:getChildByName("icon")
	local headicon = iconNode:getChildByName("headicon")
	local headbg = iconNode:getChildByName("headbg")
	local name = iconNode:getChildByName("name")

	if  self.gamescene then
		--玩家属性，以及是否是庄或者房主
		local playinfo = self.gamescene:getUserInfoByUid(data.uid)
		local headicon = require("app.ui.common.HeadIcon").new(headicon,playinfo.role_picture_url).headicon
		
		local size =  headicon:getContentSize()
		headicon:setScaleX(84/size.width)
	  headicon:setScaleY(84/size.height)
    name:setString(ComHelpFuc.getCharacterCountInUTF8String(playinfo.nick,7))

		if self.gamescene:getDealerUid() == data.uid  then
			iconNode:getChildByName("zhuang"):setVisible(true)
		else
			iconNode:getChildByName("zhuang"):setVisible(false)
		end

		if self.gamescene:getTableCreaterID() == data.uid then
			iconNode:getChildByName("room"):setVisible(true)
		else
			iconNode:getChildByName("room"):setVisible(false)
		end
	end

end
function SingleResultView:updataFen(item,data)

	local fenNode = item:getChildByName("fenNode")

	--胡数
	local hu_num = fenNode:getChildByName("hu_num")
  local hu_text = fenNode:getChildByName("hunum")

  if not data.hu_num then
      hu_text:setVisible(false)
      hu_num:setVisible(false)
  else
      hu_num:setString(data.hu_num)
  end

  --枪数
  local qiang_num = fenNode:getChildByName("qiang_num")
  local qiang_text = fenNode:getChildByName("qiangnum")
  if not data.qiang_num then
      qiang_text:setVisible(false)
      qiang_num:setVisible(false)
  else
      qiang_num:setString(data.qiang_num)
  end

  --分数
  local fen_num_win = fenNode:getChildByName("fen_num_win"):setVisible(false)
  local fen_num = fenNode:getChildByName("fen_num"):setVisible(false)
  local fen_text = fenNode:getChildByName("fennum")

  if not data.score then
      fen_text:setVisible(false)
  else
      if data.score > 0 then
          fen_num_win:setString("+"..math.abs(data.score))
          fen_num_win:setVisible(true)

          local tipNode = item:getChildByName("tipNode")
          tipNode:setPositionX(tipNode:getPositionX()-100)

      else
          if  self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR then
               local tipNode = item:getChildByName("tipNode")
               tipNode:setPositionX(tipNode:getPositionX()-100)
          end
          fen_num:setString(data.score)
          fen_num:setVisible(true)
      end
  end

  if  self.gamescene then
      if  self.gamescene:getTableConf().ttype == HPGAMETYPE.LCSDR then
         qiang_text:setString("番数")
      elseif  self.gamescene:getTableConf().ttype == HPGAMETYPE.ESCH or 
        self.gamescene:getTableConf().ttype == HPGAMETYPE.JSCH  then
          qiang_text:setVisible(false)
          qiang_num:setVisible(false)

          hu_text:setPositionY(0)
          hu_num:setPositionY(0)
      elseif  self.gamescene:getTableConf().ttype == HPGAMETYPE.BDSDR then
         qiang_text:setString("番数")
         qiang_num:setString(data.qiang_num)
         -- qiang_text:setVisible(true)
         -- qiang_num:setVisible(true)
      elseif  self.gamescene:getTableConf().ttype == HPGAMETYPE.LFSDR then
         qiang_text:setString("倍数")
          if data.qiang_num then
            qiang_num:setString(math.pow(2.0, data.qiang_num))
          end
      elseif self.gamescene:getTableConf().ttype == HPGAMETYPE.XCCH then
          qiang_text:setVisible(false)
          qiang_num:setVisible(false)
      end
  end

end


local tipsListCof = 
{
	[1]={sort = 1,img = "game/result/icon_hu.png"}, 		--1,胡
	[2]={sort = 1,img = "game/result/icon_pihu.png"},		--2,屁胡
	[3]={sort = 1,img = "game/result/icon_yichong.png"},	--3,一冲
	[4]={sort = 1,img = "game/result/icon_laochong.png"},	--4,老冲
	[5]={sort = 1,img = "game/result/icon_dahu.png"},		--5,大胡
	[6]={sort = 1,img = "game/result/icon_xiaohu.png"},		--6,笑胡
	[7]={sort = 1,img = "game/result/icon_shuhu.png"},		--7,数胡
	[8]={sort = 1,img = "game/result/icon_shudahu.png"},	--8,数大胡

	[10]={sort = 2,img = "game/result/icon_kuakuahu.png"},	--10,挎挎胡
	[11]={sort = 2,img = "game/result/icon_pengpenghu.png"},	--11,碰碰胡
	[12]={sort = 2,img = "game/result/icon_sahoshaohu.png"},	--12,绍绍胡
	[13]={sort = 2,img = "game/result/icon_tuotuohu.png"},	--13,拖拖胡
	[14]={sort = 2,img = "game/result/icon_manyuanhua.png"},	--14,满园花
	[15]={sort = 2,img = "game/result/icon_dandiao.png"},	--15,单钓

  [19]={sort = 3,img = "game/result/tips_dihu.png"},    --19,地胡
	[20]={sort = 3,img = "game/result/tips_tianhu.png"},		--20,天胡
	[21]={sort = 3,img = "game/result/icon_20hu.png"},		--21,卡20胡
	[22]={sort = 3,img = "game/result/icon_kahu.png"},		--22,卡胡
	[23]={sort = 3,img = "game/result/icon_banlong.png"},	--23,半龙
	[24]={sort = 3,img = "game/result/icon_manlong.png"},	--24,满龙
	[25]={sort = 3,img = "game/result/icon_sanbangao.png"},	--25,三版高
	[26]={sort = 3,img = "game/result/icon_shuanglong.png"},	--26,双龙保主
	[27]={sort = 3,img = "game/result/tips_piao.png"},	--27,漂
	[28]={sort = 3,img = "game/result/icon_chengdui.png"},	--28,成对

  [29]={sort = 3,img = "game/result/icon_jingsan.png"},  --29,精三版高
  [30]={sort = 3,img = "game/result/icon_quanyouhu.png"},  --30,全有胡
  [31]={sort = 3,img = "game/result/icon_liulongtou.png"},  --31,六头龙
  [32]={sort = 3,img = "game/result/icon_liulongtou2.png"},  --32,六头龙x2

  --巴东
  [33]={sort = 3,img = "game/result/icon_qinghu.png"},  --33,清胡
  [34]={sort = 3,img = "game/result/icon_kuhu.png"},  --34,枯胡
  [35]={sort = 3,img = "game/result/icon_qipeng.png"},  --35,7碰
  [36]={sort = 3,img = "game/result/icon_qingsibei.png"},  --36,清四倍
  [37]={sort = 2,img = "game/result/tips_zimo.png"},  --37,自摸
  [38]={sort = 2,img = "game/result/tips_fangpao.png"},  --38,放炮
  [39]={sort = 2,img = "game/result/icon_chire.png"},  --39,一吃热

  --建始
  [40]={sort = 2,img = "game/result/icon_chang.png"},  --40,厂
  [41]={sort = 2,img = "game/result/icon_chongchang.png"},  --41,一重厂
  [42]={sort = 2,img = "game/result/icon_chongchongchang.png"},  --42,一重重厂
  
  --野三关
  [43]={sort = 2,img = "game/result/icon_pinghu.png"},  --39,一平胡
  [44]={sort = 2,img = "game/result/icon_xiaojia.png"},  --40,--小甲
  [45]={sort = 2,img = "game/result/icon_dajia.png"},  --41,一大甲
  [46]={sort = 2,img = "game/result/icon_chang_ysg.png"},  --42,一场

  --来凤
  [47]={sort = 2,img = "game/result/icon_wushen.png"},  --47,无神
  [48]={sort = 2,img = "game/result/icon_wushenmoshen.png"},  --48,无神摸神
  [49]={sort = 2,img = "game/result/icon_fenhu.png"},  --49,分胡 
  [50]={sort = 2,img = "game/result/icon_yishouhei.png"},  --50,一手黑
  [51]={sort = 2,img = "game/result/icon_yishouhong.png"},  --51,一手红
  [52]={sort = 2,img = "game/result/icon_zahu.png"},  --52,诈胡
  [53]={sort = 2,img = "game/result/icon_bafan.png"},  --53,八番

  [54]={sort = 2,img = "game/result/icon_jianghu.png"},  --54,将胡
  [55]={sort = 2,img = "game/result/icon_qishouwujiang.png"},  --55,起手无将
  [56]={sort = 2,img = "game/result/icon_sishen.png"},  --56,四神

  [57]={sort = 2,img = "game/result/icon_jinquan.png"},  --57,进圈

  [58]={sort = 2,img = "game/result/icon_suhu.png"},  --58,素胡
  [59]={sort = 2,img = "game/result/icon_hunhu.png"},  --59,荤胡
  [60]={sort = 2,img = "game/result/icon_qingyise.png"},  --60,清一色
  [61]={sort = 2,img = "game/result/icon_taihu.png"},  --61,台胡
  [62]={sort = 2,img = "game/result/icon_sudahu.png"},  --62,素大胡
  [63]={sort = 2,img = "game/result/icon_sutaihu.png"},  --63,素台胡
  [64]={sort = 2,img = "game/result/icon_hundahu.png"},  --64,荤大胡
  [65]={sort = 2,img = "game/result/icon_huntaihu.png"},  --65,荤台胡
  [66]={sort = 2,img = "game/result/icon_taitaihu.png"},  --66,台台胡
  [67]={sort = 2,img = "game/result/icon_suqinghu.png"},  --67,素清胡
  [68]={sort = 2,img = "game/result/icon_hunqinghu.png"},  --68,荤清胡
  [69]={sort = 2,img = "game/result/icon_zhuazhu.png"},  --69,抓猪
  
  [71]={sort = 2,img = "game/result/icon_30hu.png"},  --71,卡30胡
  [73]={sort = 2,img = "game/result/icon_bamen.png"},  --73,八门
  [74] = {sort = 2,img = "game/result/icon_heidahu.png"},  --74,黑大胡

  [93]={sort = 2,img = "game/result/icon_pengpenghu.png"},  --11,碰碰胡
  [94]={sort = 2,img = "game/result/icon_jindou.png"},  --71,卡30胡
  [95]={sort = 2,img = "game/result/icon_qidaxia.png"},  --73,八门
  [96] = {sort = 2,img = "game/result/icon_qiubadou.png"},  --74,黑大胡
  [97]={sort = 2,img = "game/result/icon_baihu.png"},  --71,卡30胡
  [98]={sort = 2,img = "game/result/icon_dihu.png"},  --73,八门
  [99] = {sort = 2,img = "game/result/icon_chonghu.png"},  --74,黑大胡
}

function SingleResultView:createTips(item,data)

	local tipsList = {}
	local wininfo = data.win_info and data.win_info.styles or {}
	-- wininfo={1,18,11}
	for k,v in pairs(wininfo) do
 		table.insert(tipsList,tipsListCof[v])
	end

	table.sort(tipsList, function (a,b)
		return a.sort > b.sort
	end)

	local tipNode = item:getChildByName("tipNode")
	
	local _width = 0

  if self.gamescene then
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.LFSDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.SZ96 then
      if data.piao_score and data.piao_score ~= 0  then
          local tips = ccui.ImageView:create("game/result/tips_piao.png")
          if _width == 0 then
            tips:setPositionX(0)
            _width =  - tips:getContentSize().width/2.0
          else
              tips:setPositionX(0-(tips:getContentSize().width/2.0 + _width))
          end
            tipNode:addChild(tips)
            _width = _width + tips:getContentSize().width + 10

          local bg = ccui.ImageView:create("cocostudio/ui/game/red_dot.png")
          bg:setAnchorPoint(0.5,0.5)
          bg:setPosition(cc.p(55,38))
          tips:addChild(bg)

          local label = cc.Label:createWithSystemFont(data.piao_score, FONTNAME_DEF, 20)
          label:setAnchorPoint(0.5,0.5)
          label:setPosition(cc.p(55, 38))
          label:setTextColor( cc.c3b( 0xff, 0xff, 0xff))
          tips:addChild(label,1)
      end
  end
end
     
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
	end


     
end

--特殊的标示
local OTHERTYPE  = {
	NONE 	= 0, --表示没有
	TI 		= 1, --表示被替用了
}

function SingleResultView:getCardList(data)
     printTable(data,"sjp3")
	local cardlist = {}
	local colsName = 
	{
		[poker_common_pb.EN_SDR_COL_TYPE_YI_KOU] = "口",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_CHI] = "抵",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_PENG] = "碰",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_WEI] = "绍",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_PAO] = "跑",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_TI] = "提",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_KAN] = "克子",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_DIAO] = "口",
		[poker_common_pb.EN_SDR_COL_TYPE_YI_DUO_LONG] = "夺龙",
         [poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "招",
         [poker_common_pb.EN_SDR_COL_TYPE_YI_GUA] = "挂",
         [poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_ZI] = "杠子",
         [poker_common_pb.EN_SDR_COL_TYPE_YI_MAI] = "起手",
	}

     if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR then
          colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_CHI] = "绞"
          colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "招"
          colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_KAN] = "恰"
          colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_DUI_ZI] = "口"
          colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_ZI] = "恰"
          -- colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_ZI] = "恰"
          --colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "拱"
          
     end


	local function getColdName(data)
          if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR then
               if data.cards and #data.cards == 5 then
                    if  data.out_card_num ==1 then
                         colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "拱"
                    else
                         colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "招"
                    end
               else
                    colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO] = "招"
               end
          end

	local str = colsName[data.col_type]
     if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.SZ96  then
      colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_KAN] = "坎"
      if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI then
        return "吃"
      elseif data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO or data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI or data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PAO then
        local num = #data.cards
        if num == 4 then
          return "走"
        elseif num == 5 then
          return "半龙"
        elseif num == 6 then
          return "满龙"
        end 
      end
    end
          if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.SZ96 then
               colsName[poker_common_pb.EN_SDR_COL_TYPE_YI_KAN] = "坎"
               if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI then
                    return "吃"
               elseif data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO or data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI or data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PAO then
                    local num = #data.cards
                    if num == 4 then
                         return "走"
                    elseif num == 5 then
                         return "半龙"
                    elseif num == 6 then
                         return "满龙"
                    end 
               end
          end
          if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR then
               if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                    return "绞"
               end
          else
     		if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
     			if data.dest_index == -1 then
     				return "句"
     			else
     				return "抵"
     			end
     		end
          end

          if self.gamescene then
               if  self.gamescene:getTableConf().ttype == HPGAMETYPE.BDSDR then
                   if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
                     return "抢"
                   end
                   if  data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PAO then
                     return "卯"
                   end

                   if  data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PENG then
                     return "丁"
                   end
                   if  data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI then
                       return "吃"
                   end
               elseif self.gamescene:getTableConf().ttype == HPGAMETYPE.YSGSDR then
                   if  data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO and data.out_card_num and data.out_card_num > 1 then
                       return "踏"
                   end
               end
           end

          if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
  			if data.dest_index == -1 then
  				return "句"
  			else
  				return "抵"
  			end
          end
		if 	data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI or 
		    data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PAO then
  			local num = #data.cards
  			if num == 4 then
  				return "抓"
  			elseif num == 5 then
  				return "半挎"
  			else
  				return "满挎"
  			end
		end
          if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_MAI then
               if data.is_qi_shou_mai then
                    return "起手"
               else
                    return "中途"
               end
          end
		return str
	end

	-- optional int32 hu_num = 8;	// 胡数
	-- optional int32 qiang_num = 9;	// 枪数
	-- repeated PBSDRColumnInfo col_info_lsit = 10;	// 赢家胡牌牌型
     if data.dest_card and data.dest_card ~= 0  then
          
          if data.col_info_lsit then 
               local hucard_count = 0
               for k,v in pairs(data.col_info_lsit) do
                    local _data = {}
                    _data.cards = v.cards
                    _data.col_type = v.col_type
                    _data.score = v.score
                    _data.name = getColdName(v)
                    _data.isHu = false
                    _data.isTiList = v.shenpai_card or nil

                    local out_card_num = v.out_card_num or 1
                    _data.ta_Index = #v.cards - out_card_num +1

                    for kk,vv in pairs(v.cards) do
                         if vv == data.dest_card then
                              _data.isHu = true
                              hucard_count = hucard_count + 1
                         end
                    end
                    table.insert(cardlist,_data) 
               end
               --从后往前，第一个就是胡的牌，如果是上大人玩法，如果有多张胡的牌并且最后一个为夺龙的话，再往就找一个
               for i=#cardlist,1,-1 do
                  --小甲--有胡牌
                    if cardlist[i].isHu then 
                         --如果是上大人玩法
                         if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.LCSDR then 
                         --如果为一个为夺龙的话
                              if cardlist[i].col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_DUO_LONG then 
                                  if hucard_count == 1 then 
                                      hucard_count = 0
                                  else
                                      cardlist[i].isHu = false
                                  end
                                  break
                              end
                         end
                         --保证最后一个是胡牌，其它的都不是
                         if hucard_count == 0 then 
                             cardlist[i].isHu = false
                         else
                             hucard_count = 0
                         end
                    end 
               end
               return cardlist
          end
     else
          --摆牌
          if data.out_cols then 
               for k,v in pairs(data.out_cols) do
                    local _data = {}
                    _data.cards = v.cards
                    _data.col_type = v.col_type
                    _data.score = v.score
                    _data.name = getColdName(v)
                    _data.isHu = false
                    _data.isTiList = nil
                    local out_card_num = v.out_card_num or 1
                    _data.ta_Index = #v.cards - out_card_num +1

                    table.insert(cardlist,_data)
               end
          end
           --手牌
          if data.hand_cards_info and data.hand_cards_info.hand_cards then
               if self.gamescene and (self.gamescene:getTableConf().ttype == HPGAMETYPE.SZ96 or self.gamescene:getTableConf().ttype == HPGAMETYPE.XE96) then
                    local handList  = ComHelpFuc.sortPokerHandTile(data.hand_cards_info.hand_cards)
                    for i,v in ipairs(handList) do
                         table.insert(cardlist,{cards = v})
                    end
               else
                    local handList  = ComHelpFuc.sortMyHandTile(data.hand_cards_info.hand_cards)
                    for k,v in pairs(handList) do
                         if v.num > 0 then
                              if v.one_value == 9 then
                                   for kk,vv in pairs(v.valueList) do
                                        table.insert(cardlist,{cards = {vv.real_value}})
                                   end
                              else
                                   local _list = {}
                                   for kk,vv in pairs(v.valueList) do
                                        table.insert(_list,vv.real_value)
                                   end
                                   table.insert(cardlist,{cards = _list})
                              end
                         end
                    end
               end
          end
     end
	return cardlist
end

function SingleResultView:createCards(item,data,tips_w)

     print("........SingleResultView:createCards ")

	local cardNode = item:getChildByName("card_node")
	local cardlist = self:getCardList(data)

	local addW = 0
	local hupailast = nil
	for k,v in pairs(cardlist) do
		local _item = self.cardItem:clone()
		_item:setPositionX(60*(k-1)+15*addW)
		_item:setPositionY(2)
		_item:setVisible(true)
		cardNode:addChild(_item)

		local _cardNode = _item:getChildByName("cardNode")

		if v.score then
			_item:getChildByName("fen"):setString(v.score)
		else
               _item:getChildByName("fen"):setVisible(false)
		end

		if v.name then
			_item:getChildByName("name"):setString(v.name)
		else
			_item:getChildByName("name"):setVisible(false)
		end
		local a_num = #v.cards
          print(".........kk = ",k)
          printTable(v.cards,"xp65")

          local list = {}
          for k,v in pairs(v.cards) do
               if a_num < 4 then
                    table.insert(list,1,v)
               else
                    table.insert(list,v)  
               end 
          end
		for kk,vv in pairs(list) do
			local showIndex = a_num-kk+1
               if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.YSGSDR then
                    if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO and 
                    kk > v.ta_Index then
                         vv = 0
                    end
               end

			local pai = self:createCardSprite(CARDTYPE.ONTABLE,vv)
				:addTo(_cardNode,showIndex)
			pai:setAnchorPoint(cc.p(0, 0))
			pai:setScale(0.8)
			pai:setPositionX(15)
			if a_num < 4 then
				pai:setPositionY(15+(kk-1)*20)
			elseif a_num == 4 then
				pai:setPositionY(15+(kk-1)*12)
			else
				if kk < 5 then
					pai:setPositionY(15+(kk-1)*12)
				else
					addW = addW + 1
					pai:setPositionX(38*0.8*0.5+38*0.8)
					pai:setPositionY(15+(kk-5)*20)
				end
			end

               if  v.isHu  and vv == data.dest_card then
                    pai:getbg():setColor(cc.c3b( 0xf0, 0x9f, 0x99))
                    v.isHu = false
               end

               if  v.isTiList  then
                    for _k,_v in pairs(v.isTiList) do
                         if _v + 1  == kk then
                              pai:showJiang()
                         end
                    end
               end

                if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then 
                    if self.gamescene:getIsJiangCard(vv) then
                         pai:showJiang()
                    end
                    -- if self.gamescene:getIsJokerCard(vv) then
                    --      pai:showJoker()
                    -- end
                end

		end
	end

     if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCSDR then
          for i,v in ipairs(self.seatinfo) do
              if v.user.uid == data.uid then
                    local bg = cc.Sprite:create("game/dingbg.png")
                    bg:setPositionX(855)
                    bg:setPositionY(67)
                    cardNode:addChild(bg)
                    local card = LongCard.new(CARDTYPE.ONTABLE, v.ding_zhang_card)
                    card:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2))
                    bg:addChild(card)
              end
          end
     end



end
function SingleResultView:showRestCard()

  if self.data.cards and #self.data.cards >0 then
  else
    return
  end

	local _cardNode = self.mainLayer:getChildByName("dicard")
  local _max = 17
  if #self.data.cards <= 32 then
    _max = 17
  else
    _max = 26
  end

  local _dicardback = self.mainLayer:getChildByName("dicardback")
  _dicardback:setContentSize(cc.size(_max*30+12,78))

  if #self.data.cards > 50 then

    _dicardback:setContentSize(cc.size(_max*30+12,82))

    local scrollView = ccui.ScrollView:create()
    scrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)--设置方向为垂直
    scrollView:setBounceEnabled(true) --弹回的属性
    scrollView:setScrollBarEnabled(false)

    scrollView:setContentSize(cc.size(_max*30,78))
    scrollView:setAnchorPoint(cc.p(0,0));
    scrollView:setPosition(cc.p(42,-12));

    local gun_h = 35*math.ceil(#self.data.cards/_max)
    scrollView:setInnerContainerSize(cc.size(_max*30,gun_h))
    scrollView:addTo(_cardNode)

    for k,v in pairs(self.data.cards) do
      local pai = self:createCardSprite(CARDTYPE.ONTABLE,v)
        :addTo(scrollView)
      pai:setScale(0.8)

      pai:setPositionX(12+((k-1)%_max)*30)
      pai:setPositionY(gun_h-math.ceil(k/_max)*33.5+15)
    end
  else
    for k,v in pairs(self.data.cards) do
      local pai = self:createCardSprite(CARDTYPE.ONTABLE,v)
        :addTo(_cardNode)
      pai:setScale(0.8)

      if k <= _max then
        pai:setPositionX(26.00+k*30)
        pai:setPositionY(43.5)
      else
        pai:setPositionX(26.00+(k-_max)*30)
        pai:setPositionY(10)
      end
    end
  end
end




function SingleResultView:againBtnCall()
	print("再来一局")
	if  self.gamescene then
		if self.opentype == 2 then
			local owner = self.gamescene
			-- LaypopManger_instance:back()
			cc.Director:getInstance():popScene()
			-- owner:returnHall()
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

function SingleResultView:createCardSprite(typ,value)
  if self.gamescene  then
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.SZ96 or self.gamescene:getTableConf().ttype == HPGAMETYPE.XE96 then
      local PokerCard = require "app.ui.game_poker.PokerCard"
      return PokerCard.new(typ,value)
    end
  end
  return LongCard.new(typ,value)
end

return SingleResultView