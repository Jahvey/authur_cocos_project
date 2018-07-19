-------------------------------------------------
--   TODO   斗地主的单局结算UI
--   @author xp
--   Create Date 2018.3.6
-------------------------------------------------

local MJSingleResultView = class("MJSingleResultView",PopboxBaseView)
local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
  
function MJSingleResultView:ctor(data,gamescene,opentype)
    print("..............小结算。。。。。opentype ＝ ",opentype)
    -- printTable(data,"xp70")

    -- data = 
    -- {
    --    ["sdr_result"] = {
    --        ["is_finished"] = false,
    --        ["winner_index"] = 0,
    --        ["cards"] =  {
    --         5,
    --         73,
    --         69,
    --         3,
    --         37,
    --         8,
    --         34,
    --         68,
    --         9,
    --         65,
    --         68,
    --         4,
    --         39,
    --         41,
    --         73,
    --         33,
    --         38,
    --         40,
    --         67,
    --         65,
    --         69,
    --         71,
    --         37,
    --         40,
    --         39,
    --         70,
    --         70,
    --         1,
    --         71,
    --         35,
    --         36,
    --         39,
    --         4,
    --         39,
    --         67,
    --         38,
    --         36,
    --         5,
    --         7,
    --         6,
    --         41,
    --         66,
    --       },
    --        ["players"] =  {
    --            {
    --                ["col_info_lsit"] =      {
    --                        {
    --                        ["an_num"] = 0,
    --                        ["col_type"] = 3,
    --                        ["cards"] =          {
    --                         2,
    --                         2,
    --                         2,
    --                       },
    --                        ["dest_card"] = 2,
    --                        ["dest_index"] = 2,
    --                        ["token"] = 1,
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["original_cards"] =          {
    --                         7,
    --                         6,
    --                         8,
    --                       },
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["dest_card"] = 7,
    --                        ["cards"] =          {
    --                         7,
    --                         6,
    --                         8,
    --                       },
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["original_cards"] =          {
    --                         7,
    --                         6,
    --                         8,
    --                       },
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["dest_card"] = 7,
    --                        ["cards"] =          {
    --                         7,
    --                         6,
    --                         8,
    --                       },
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["original_cards"] =          {
    --                         70,
    --                         71,
    --                         72,
    --                       },
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["dest_card"] = 70,
    --                        ["cards"] =          {
    --                         70,
    --                         71,
    --                         72,
    --                       },
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["original_cards"] =          {
    --                         71,
    --                         72,
    --                         73,
    --                       },
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["dest_card"] = 71,
    --                        ["cards"] =          {
    --                         71,
    --                         72,
    --                         73,
    --                       },
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["dest_card"] = 4,
    --                        ["cards"] =          {
    --                         4,
    --                         4,
    --                       },
    --                        ["col_type"] = 1,
    --                        ["score"] = 0,
    --                   },
    --               },
    --                ["dest_card"] = 4,
    --                ["out_cols"] =      {
    --                        {
    --                        ["an_num"] = 0,
    --                        ["col_type"] = 3,
    --                        ["cards"] =          {
    --                         2,
    --                         2,
    --                         2,
    --                       },
    --                        ["dest_card"] = 2,
    --                        ["dest_index"] = 2,
    --                        ["token"] = 1,
    --                        ["score"] = 0,
    --                   },
    --               },
    --                ["hu_num"] = 4,
    --                ["hand_cards_info"] =      {
    --                    ["hand_cards"] =        {
    --                     8,
    --                     73,
    --                     4,
    --                     6,
    --                     72,
    --                     71,
    --                     70,
    --                     72,
    --                     7,
    --                     71,
    --                   },
    --               },
    --                ["uid"] = 31272,
    --                ["win_info"] =      {
    --                    ["styles"] =        {
    --                     77,
    --                     60,
    --                   },
    --               },
    --                ["qiang_num"] = 0,
    --                ["score"] = 360,
    --           },
    --            {
    --                ["hand_cards_info"] =      {
    --                    ["hand_cards"] =        {
    --                     3,
    --                     40,
    --                     34,
    --                     34,
    --                     3,
    --                     40,
    --                     3,
    --                   },
    --               },
    --                ["uid"] = 31084,
    --                ["qiang_num"] = 0,
    --                ["win_info"] =      {
    --                    ["styles"] =        {
    --                     38,
    --                   },
    --               },
    --                ["out_cols"] =      {
    --                        {
    --                        ["an_num"] = 0,
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["cards"] =          {
    --                         33,
    --                         34,
    --                         35,
    --                       },
    --                        ["dest_card"] = 35,
    --                        ["dest_index"] = 0,
    --                        ["token"] = 1,
    --                        ["score"] = 0,
    --                   },
    --                        {
    --                        ["an_num"] = 0,
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["cards"] =          {
    --                         7,
    --                         8,
    --                         9,
    --                       },
    --                        ["dest_card"] = 7,
    --                        ["dest_index"] = 0,
    --                        ["token"] = 2,
    --                        ["score"] = 0,
    --                   },
    --               },
    --                ["score"] = -60,
    --           },
    --            {
    --                ["hand_cards_info"] =      {
    --                    ["hand_cards"] =        {
    --                     6,
    --                     5,
    --                     72,
    --                     8,
    --                     5,
    --                     72,
    --                     70,
    --                     2,
    --                     73,
    --                     68,
    --                   },
    --               },
    --                ["uid"] = 31083,
    --                ["qiang_num"] = 0,
    --                ["win_info"] =      {
    --               },
    --                ["out_cols"] =      {
    --                        {
    --                        ["an_num"] = 0,
    --                        ["is_bi_chi"] = false,
    --                        ["col_type"] = 2,
    --                        ["cards"] =          {
    --                         67,
    --                         68,
    --                         69,
    --                       },
    --                        ["dest_card"] = 69,
    --                        ["dest_index"] = 1,
    --                        ["token"] = 1,
    --                        ["score"] = 0,
    --                   },
    --               },
    --                ["score"] = -60,
    --           },
    --       },
    --   },
    -- }

    self.data = data 
    self.gamescene = gamescene
    if not opentype then
        opentype = 1
    end 
    self.opentype = opentype

    self:initView()
end

function MJSingleResultView:initView()
    self.widget = cc.CSLoader:createNode("ui/game_mj/result/mj_singleResultView.csb")
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

  

  if  self.gamescene then
    if self.data.sdr_result.winner_index == -1 then
        AudioUtils.playEffect("liuju")
        self.liu:setVisible(true)
    else

        for i1,v1 in ipairs(self.gamescene:getSeatsInfo()) do
            if i1 == self.data.sdr_result.winner_index + 1 then
                self.winner_uid  = v1.user.uid
                break
            end
        end

        if self.winner_uid == LocalData_instance.uid then
            AudioUtils.playEffect("mj_win")
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
    self.text_room = self.mainLayer:getChildByName("text_roomNum")

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESMJ then
        self.text_room:setPositionX(-408)
        self.mainLayer:getChildByName("jokerbg"):setVisible(true)
        self.text_room:setString(roomidStr.."  "..jushuStr.."  "..nameStr.."\n("..guizeStr..")")

        --癞子牌
        local joker = self.mainLayer:getChildByName("jokerbg"):getChildByName("joker"):getChildByName("pai")
        local joker_card = self.gamescene:getJokerCard()
        local putoutingma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,joker_card)  
        if putoutingma then 
            local picstr,str = putoutingma:getpicpath(MAJIANGCARDTYPE.BOTTOM,joker_card)
            joker:setTexture("gamemj/card/"..str)
        end
        --痞子牌
        local pizi = self.mainLayer:getChildByName("jokerbg"):getChildByName("pizi"):getChildByName("pai")
        local pizi_card = self.gamescene:getPiziCard()
        local putoutingma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,pizi_card)  
        if putoutingma then 
            local picstr,str = putoutingma:getpicpath(MAJIANGCARDTYPE.BOTTOM,pizi_card)
            pizi:setTexture("gamemj/card/"..str)
        end
    else
        self.text_room:setString(roomidStr.."  "..jushuStr.."  "..nameStr.."("..guizeStr..")")
        self.text_room:setPositionX(-596)
        self.mainLayer:getChildByName("jokerbg"):setVisible(false)
    end

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

function MJSingleResultView:showUI()

  for i,v in ipairs(self.data.sdr_result.players) do
        self.listView:pushBackDefaultItem()

        print(".........MJSingleResultView:showUI() i = ",i)
        printTable(v,"xp10")

        v.index = i

        local item = self.listView:getItem(i-1)
        item:setVisible(true)

        --玩家个人信息
        self:updataPlayerInfo(item,v)

        --玩家分数
        self:updataFen(item,v)

        --tips
        self:createTips(item,v)

        --名堂文字
        self:createTipsText(item,v)

        --生成牌
        self:createCards(item,v)
        
    end
end

function MJSingleResultView:updataPlayerInfo(item,data)

    local iconNode =  item:getChildByName("headbg")
    local headicon = iconNode:getChildByName("headicon")
    local name = iconNode:getChildByName("nameLabel")

    if  self.gamescene then
      --玩家属性，以及是否是庄或者房主

      local playinfo = self.gamescene:getUserInfoByUid(data.uid)
      local headicon = require("app.ui.common.HeadIcon").new(headicon,playinfo.role_picture_url,64).headicon   
       name:setString(ComHelpFuc.getCharacterCountInUTF8String(playinfo.nick,7))
      if self.gamescene:getDealerUid() == data.uid  then
        iconNode:getChildByName("manorImage"):setVisible(true)
      else
        iconNode:getChildByName("manorImage"):setVisible(false)
      end

      if self.gamescene:getTableCreaterID() == data.uid then
        iconNode:getChildByName("isfangzhu"):setVisible(true)
      else
        iconNode:getChildByName("isfangzhu"):setVisible(false)
      end
    end
end

function MJSingleResultView:updataFen(item,data)

    local fenNode = item:getChildByName("fenNode")
    if data.score >= 0 then
        fenNode:getChildByName("num_fenshu"):setString(math.abs(data.score))
        fenNode:getChildByName("add"):setVisible(true)
        fenNode:getChildByName("minus"):setVisible(false)
    else
        fenNode:getChildByName("num_fenshu"):setString(math.abs(data.score))
        fenNode:getChildByName("minus"):setVisible(true)
        fenNode:getChildByName("add"):setVisible(false)
    end

    if data.hu_num and data.hu_num >= 0 then 
      fenNode:getChildByName("hu_num"):setString(math.abs(data.hu_num))
      fenNode:getChildByName("hu_num"):setVisible(true)
      fenNode:getChildByName("hunum"):setVisible(true)
    else
      fenNode:getChildByName("hu_num"):setVisible(false)
      fenNode:getChildByName("hunum"):setVisible(false)
    end

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESMJ then
        fenNode:getChildByName("hu_num"):setVisible(false)
        fenNode:getChildByName("hunum"):setVisible(false)
    end
end

local tipsListCof = 
{
    [1]={sort = 1,img = "game/result/icon_hu.png"},     --1,胡
    [38]={sort = 2,img = "game/result/tips_fangpao.png"},  --38,放炮
    [108]={sort = 2,img = "game/result/icon_jindin.png"},  --101,金顶
    [115]={sort = 2,img = "game/result/icon_fengding.png"},  --108,封顶
}

function MJSingleResultView:createTips(item,data)
  --名堂显示，目前只有春天
  local tipsList = {}
  local wininfo = data.win_info and data.win_info.styles or {}

  print("  data.index = ",data.index)
  print("self.data.winner_index = ",self.winner_index)
  -- if self.winner_uid == data.uid then
  --     table.insert(tipsList,tipsListCof[1])
  -- end

  for k,v in pairs(wininfo) do
    if  tipsListCof[v]  then
      table.insert(tipsList,tipsListCof[v])
    end
  end

  table.sort(tipsList, function (a,b)
    return a.sort > b.sort
  end)

  local tipNode = item:getChildByName("tipNode")
  -- tipNode:setPositionX(1060)
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESMJ then
        tipNode:setPositionX(1040)
    end

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

    -- if v.num and v.num > 0  then
    --   local _size = tips:getContentSize()
    --   local red = cc.Sprite:create("gameddz/icon_red.png")
    --       :setScale(1.2)
    --       :setPosition(cc.p(_size.width/2.0 + 18,_size.height/2.0 - 18))
    --       :addTo(tips)

    --   if self.gamescene and self.gamescene:getTableConf().ttype == HPGAMETYPE.MCDDZ  then  
    --      red:setPositionY(_size.height/2.0 + 18)
    --   end

    --   local text = ccui.Text:create(v.num,FONTNAME_DEF,20)
    --       :addTo(red)
    --       :setPosition(cc.p(10,11))
    -- end
  end

end


local tipsTextCof = 
{   
    [2]={idx = 2, sort = 2,text = "屁胡"},  --2,屁胡
    [37]={idx = 37, sort = 2,text = "自摸"},  --37,自摸
    [60]={idx = 60, sort = 2,text = "清一色"},  --60,清一色
    [75]={idx = 75, sort = 2,text = "拖拉机"},  --75; // 拖拉机
    [76]={idx = 76, sort = 2,text = "硬充"},  --76; // 硬充
    [77]={idx = 77, sort = 2,text = "七对"},  --77; // 七对
    [81]={idx = 81, sort = 2,text = "258将"},  --81; // 258将
    [82]={idx = 81, sort = 2,text = "小血"},  --82; // 小血
    [93]={idx = 93, sort = 2,text = "碰碰胡"},  --93; // 碰碰胡

    [107]={idx = 100, sort = 2,text = "全求人"},  --100; // 全求人
    [109]={idx = 102, sort = 2,text = "抬庄"},  --102; // 抬庄
    [110]={idx = 103, sort = 2,text = "硬屁胡"},  --103; // 硬屁胡
    [111]={idx = 104, sort = 2,text = "硬小血"},  --104; // 硬小血
    [112]={idx = 105, sort = 2,text = "大血"},  --105; // 大血
    [113]={idx = 106, sort = 2,text = "杠上花"},  --106; // 杠上花
    [114]={idx = 107, sort = 2,text = "杠上炮"},  --107; // 杠上炮
}

function MJSingleResultView:createTipsText(item,data)
    local tipsTextList = {}
    local wininfo = data.win_info and data.win_info.styles or {}

    for k,v in pairs(wininfo) do
      if tipsTextCof[v]  then
        table.insert(tipsTextList,tipsTextCof[v])
      end
    end
    item:getChildByName("tipscof"):setVisible(false)
    local ttfConfig = ""
    if #tipsTextList ~= 0 then
        table.sort(tipsTextList, function (a,b)
          return a.sort > b.sort
        end)
        for k,v in pairs(tipsTextList) do
            if k ~= 1 then
                ttfConfig = ttfConfig.."，"
            end
            local str = v.text
            if v.idx == 77 then
                if data.hao_hua_num  and  data.hao_hua_num  > 0 then
                    local _list = {"豪华","双豪华","三豪华","四豪华"}
                    str = _list[data.hao_hua_num] .. "七对"
                end
            elseif v.idx == 102 then --抬庄成功 
                local _taizhang = {[5] = 3,[10] = 5,[25] = 13,[50] = 25}
                local _score = _taizhang[self.gamescene:getTableConf().di_score]
                if self.gamescene:getDealerUid() == data.uid  then--如果我是庄家，
                    _score = _score * (self.gamescene:getTableConf().seat_num - 1)
                    str = str .. "-".._score
                else
                    str = str .. "+".._score
                end 
            end
            ttfConfig = ttfConfig..str
        end
    end 

   

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESMJ then
        if data.lai_zi_num and data.lai_zi_num > 0 then
            if ttfConfig == "" then
                ttfConfig = ttfConfig.."癞子x"..data.lai_zi_num
            else
                ttfConfig = ttfConfig.."，癞子x"..data.lai_zi_num
            end
        end

        if data.pi_zi_num and data.pi_zi_num > 0 then
            if ttfConfig == "" then
                ttfConfig = ttfConfig.."痞子x"..data.pi_zi_num
            else
                ttfConfig = ttfConfig.."，痞子x"..data.pi_zi_num
            end
        end
    end

    item:getChildByName("tipscof"):setString(ttfConfig)
    item:getChildByName("tipscof"):setVisible(true)
end


function MJSingleResultView:createCards(item,data)

    print("..........MJSingleResultView:createCards")
    -- printTable(data,"xp70")

    local maNode = item:getChildByName("cardNode")

    local offx = 0
    if  data.out_cols and #data.out_cols > 0 then
        for k,v in pairs(data.out_cols) do
            -- v.col_type =  poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG
            -- table.insert(v.cards, 0x35)
           if v.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then

                if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                    for _k,_v in pairs(v.cards) do
                        if _v == v.dest_card  then
                            table.remove(v.cards,_k)
                        end
                    end
                    table.insert(v.cards,2,v.dest_card)
                end

                for kk,vv in pairs(v.cards) do
                    if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG and kk == 4 then
                        vv = 0
                    end
                    local _ma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,vv)
                    _ma:setAnchorPoint(cc.p(0,0))
                    _ma:setPositionX(offx)
                    maNode:addChild(_ma)
                    if self.gamescene then
                        if  self.gamescene:getIsJokerCard(vv) then
                            _ma:showJoker()
                        end
                        if self.gamescene:getIsPiziCard(vv) then
                            _ma:showPizi()
                        end
                    end

                    -- if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                    --     if  vv == v.dest_card  then
                    --         _ma:setYellow()
                    --     end
                    -- end
                    if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
                        if  kk == 4  then
                            _ma:setPosition(cc.p(offx-55*2,10))
                        end
                    end
                    if  kk ~= 4  then
                        offx = offx + 55
                    end
                end
                offx = offx + 15
            end
            if k == #data.out_cols then
                offx = offx + 15
            end
        end
    end 

    local handCards = data.hand_cards_info.hand_cards
    table.sort(handCards, function(a, b)
        local _a = a
        local _b = b
        if self.gamescene then
          if self.gamescene:getIsJokerCard(a) then
              _a = _a - 100
          end
          if self.gamescene:getIsJokerCard(b) then
              _b = _b - 100
          end
        end
        return _a < _b
    end)


    if #handCards %3 == 2 then
        --表示胡的那张牌放到手牌里面去了，
        if data.dest_card and data.dest_card ~= 0 then
            for k,v in pairs(handCards) do
                if v == data.dest_card  then
                    table.remove(handCards,k)
                    break
                end
            end
        end
    end

    if handCards then
        for i,v in ipairs(handCards) do
            local _ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,v)
            _ma:setAnchorPoint(cc.p(0,0))
            _ma:setScale(0.8)
            _ma:setPositionX(offx)
            maNode:addChild(_ma)
            if self.gamescene then
                if  self.gamescene:getIsJokerCard(v) then
                    _ma:showJoker()
                end
                if self.gamescene:getIsPiziCard(v) then
                    _ma:showPizi()
                end
            end

            offx = offx + 80*0.8
        end
    end

    if self.winner_uid == data.uid then
        if data.dest_card and data.dest_card ~= 0 then
            offx = offx + 30

            local _ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,data.dest_card)
            _ma:setAnchorPoint(cc.p(0,0))
            _ma:setScale(0.8)
            _ma:setPositionX(offx)
            maNode:addChild(_ma)
            if self.gamescene then
                if  self.gamescene:getIsJokerCard(data.dest_card) then
                    _ma:showJoker()
                end
                if self.gamescene:getIsPiziCard(data.dest_card) then
                    _ma:showPizi()
                end
            end
        end
    end
end

function MJSingleResultView:againBtnCall()
  print("再来一局")
  if  self.gamescene then
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

return MJSingleResultView