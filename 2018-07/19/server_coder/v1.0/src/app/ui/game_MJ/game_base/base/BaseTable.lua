local BaseTable = class("BaseTable")
local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
BASECARDWIDTH = 38 
BASECARDHEIGHT = 42

function BaseTable:ctor(node, gamescene)
    self.node = node
    self.node:setVisible(false)
    self.gamescene = gamescene

    WidgetUtils.setScalepos(self.node)

    self:initView()
    self:initData()
    self:resetData()
    self:initLocalConf()
end

function BaseTable:initData()
    self.record_column_mac = 8
    self.cardScale = 44 / 74
    self.tableidx = -1
    self.effectnode = nil
    self.isChiPeng = false
end


function BaseTable:initView()
    self.nodenotbegin = self.node:getChildByName("nodenotbegin")
    -- 开始之前的位置，
    self.nodebegin = self.node:getChildByName("nodebegin")
    -- 开始牌局之后的位置

    -- 手牌节点
    self.handCardNode = self.node:getChildByName("handcardnode"):setVisible(false)
    
    -- 出牌节点
    self.outCardNode = self.node:getChildByName("chucardnode"):setVisible(false)
    -- dump(self.outCardNode:getRotation())
    
    -- 头像节点
    self.icon = self.node:getChildByName("icon")

    self.moPaiPos = cc.p(0, 0)
end

function BaseTable:initLocalConf()
    -- body
end

function BaseTable:resetData()
    self.handcardspr = { }
    -- 二维数组
    self.outcardspr = { }
    self.showcardspr = { }

    self.nextOutPos = cc.p(self.outCardNode:getPosition())
    self.nextShowPos = cc.p(self.handCardNode:getPosition())

    self.handCardNode:removeAllChildren()
    self.outCardNode:removeAllChildren()

    if self.effectnode then
        self.effectnode:removeAllChildren()
    end
    self.icon:setPosition(cc.p(self.nodenotbegin:getPositionX(), self.nodenotbegin:getPositionY()))

end
 

-- 座位的隐藏与显示
function BaseTable:showNode()
    self.node:setVisible(true)
end
function BaseTable:hideNode()
    self.node:setVisible(false)
end

-- 座位对应的服务器位置索引
function BaseTable:setTableIndex(idx)
    self.tableidx = idx or -1
end
function BaseTable:getTableIndex()
    return self.tableidx
end

-- 初始化函数，
function BaseTable:refreshHandCards()
end
function BaseTable:refreshOutCards()
end


function BaseTable:getShowCardList()
    local showCol = clone(self.gamescene:getShowCardsByIdx(self.tableidx))

    -- print("...........BaseTable:getShowCardList()")
    -- printTable(showCol)

    local function settiyong( data )
        local list = {}
        if data.cards then
            for i, v in ipairs(data.cards) do
                if data.card_ti == nil then
                    data.card_ti = {}
                end

                --不是我自己，没有显示，不是庄家
                if  self.tableidx ~= self.gamescene:getMyIndex() and 
                    self.gamescene:getIsDisplayAnpai() == false and
                    self.gamescene:getDealerIndex() ~= self.tableidx and
                    data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
                    v = 0
                end

                if #data.cards < 4 then
                    table.insert(data.card_ti, 1,{card = v})
                else
                    table.insert(data.card_ti, {card = v})
                end
            end
            if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI then
                data.card_ti[3].card = 0
            elseif data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
                data.card_ti[4].card = 0
            end
        end
    end
    for i,v in ipairs(showCol) do
        settiyong( v )
    end
    return showCol
end


function BaseTable:getHandIsShowGray(list,value)
    return true
end

-- 刷新座位信息
function BaseTable:refreshSeat(info, isStart)

    if not info then
        info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    end
    self.icon:setVisible(true)



    local headbg = self.icon:getChildByName("headbg")
    if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
        for i, v in ipairs(self.icon:getChildren()) do
            v:setVisible(false)
        end
        headbg:setVisible(true)
       
        -- local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        -- if   GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype)  == STYLETYPE.Poker then
        --     bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        -- end
        -- headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)
        self.icon:getChildByName("head_icon"):setVisible(true)

    else
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
        headbg:setVisible(true)
        
        -- local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        -- if  GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype)  == STYLETYPE.Poker then
        --     bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        -- end
        -- headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)

        local head = self.icon:getChildByName("headicon")

        local name = self.icon:getChildByName("name"):setVisible(false)
        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        zhuang:setColor(cc.c3b(255, 255, 255))
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)
        local fentext = self.icon:getChildByName("fentext"):setVisible(false)
        
        head:setVisible(true)
        name:setString(ComHelpFuc.getCharacterCountInUTF8String(info.user.nick,9))

        -- local size = headbg:getContentSize()
        local headicon = require("app.ui.common.HeadIcon").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon
        head:setPosition(cc.p(0, 2))

        if info.state == poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME then
            name:setVisible(true)

        elseif info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            ready:setVisible(true)
            name:setVisible(true)
        elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end

            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end

            fentext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()


        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

        elseif info.state == 99 then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end
            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end
            name:setVisible(true)
        else
            print("不存在的玩家状态")
        end

        if info.user.is_offline then
            lixiantip:setVisible(true)
        end

        if self.gamescene:getTableCreaterID() == info.user.uid then
            fangzhutip:setVisible(true)
        end

        if self.gamescene:getSeatInfoByIdx(self.tableidx).state ~= 99 then
            WidgetUtils.addClickEvent(headicon, function()
                self:clickHeadIcon(info.user)
            end )
        end
        if info.index == self.gamescene:getMyIndex() then
            self.gamescene.UILayer:refreshReadyCancel(info)
        end

    end
    -- self:updataHuXiText()
end

function BaseTable:updataHuXiText()

end

--设置票 状态   0 等待 true 飘 false不飘
function BaseTable:setPiao(type)
    self.icon:getChildByName("ok"):setVisible(false)

    if self.icon:getChildByName("piaonode") == nil then
        local piaonode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(piaonode)
        piaonode:setName("piaonode")
        piaonode:setVisible(false)
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
    end

    local piaonode = self.icon:getChildByName("piaonode"):setVisible(true)
    if type == 0 then
        piaonode:getChildByName("dingpiaozhong"):setVisible(true)
        piaonode:getChildByName("piao"):setVisible(false)
    elseif type == true then
        piaonode:setPosition(cc.p(self.icon:getChildByName("piao"):getPosition()))
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
        piaonode:getChildByName("piao"):setVisible(true)
        self:playActionVoice("piao")
    else
        piaonode:setVisible(false)
        AudioUtils.playVoice("action_nopiao",self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    self.icon:getChildByName("piaonode"):stopAllActions()
    if type ~= false then
        local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "end" then
                if type ~= 0 then
                   piaonode:removeFromParent()
                   self.icon:getChildByName("piao"):setVisible(true)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
        self.icon:getChildByName("piaonode"):runAction(action)
        if type == 0 then
            action:gotoFrameAndPlay(0, true)
        else
            action:gotoFrameAndPlay(0, false)
        end
    end
end

--
--设置报，头像右下的报
--1为报，2为弃胡，3为笑胡，
function BaseTable:setBao(_type)
    local target, iconName,voice
    if _type == 1 then
        target = self.icon:getChildByName("bao")
        iconName = "game/icon_bao.png" 
        voice = "action_bao"
    elseif _type == 2 then
        iconName = "game/icon_qi.png" 
        target = self.icon:getChildByName("piao")
        voice = "action_qihu"
        if  self.icon:getChildByName("piao"):isVisible() then
            target = self.icon:getChildByName("bao") 
        end
    elseif _type == 3  then
        iconName = "game/icon_xiao.png" 
        target = self.icon:getChildByName("piao")
        voice = "action_xiao"
    end
    if self.icon:getChildByName("baonode") == nil then
        local baonode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(baonode)
        baonode:setName("baonode")
        baonode:getChildByName("dingpiaozhong"):setVisible(false)

        local bao = baonode:getChildByName("piao")
        bao:getChildByName("Node_2_0"):getChildByName("Image_1"):loadTexture(iconName,ccui.TextureResType.localType)
        bao:getChildByName("Node_2"):getChildByName("Image_1"):loadTexture(iconName,ccui.TextureResType.localType)

        baonode:setPosition(cc.p(target:getPosition()))
    end 

    local baonode = self.icon:getChildByName("baonode"):setVisible(true)
    baonode:stopAllActions()

    local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            baonode:removeFromParent()
            target:setVisible(true)
            target:setTexture(iconName)
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    baonode:runAction(action)
    action:gotoFrameAndPlay(0, false)
    AudioUtils.playVoice(voice,self.gamescene:getSexByIndex(self:getTableIndex()))
end


function BaseTable:showZhuangAction(func,_pos)

    local effectName = "cocostudio/ui/zuozhuang/zuozhuang.csb"

    local csblayer = cc.CSLoader:createNode(effectName)
    local action = cc.CSLoader:createTimeline(effectName)
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end

        local str = frame:getEvent()
        if str == "end" then
            csblayer:removeFromParent()
            self.icon:getChildByName("zhuang"):setVisible(true)
            if func then
                func()
            end
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)
    csblayer:runAction(action)
    csblayer:setPosition(cc.p(0, 0))
    csblayer:setAnchorPoint(cc.p(0.5, 0.5))
    action:gotoFrameAndPlay(0, true)

    csblayer:setLocalZOrder(1)

    local move_pos = _pos or cc.p(display.cx, display.cy)
    local node = cc.Node:create()
    node:setPosition(self.effectnode:convertToNodeSpace(move_pos))
    node:addChild(csblayer)

    local zhuang = self.icon:getChildByName("zhuang")
    local worldpos1 = self.icon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))
    local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)

    node:runAction(cc.MoveTo:create(0.2, worldpos2))

    self.effectnode:addChild(node)
end

function BaseTable:addMsgBubble(data)
    if self.tableidx < 0 then
        return
    end

    print(".......BaseTable:addMsgBubble(")
    printTable(data,"xp69")


  --   {
  --      ["json_msg"] = {
  --              ["page"] = 1,
  --              ["msg"] = "",
  --              ["id"] = 5,
  --       },
  --      ["BigFaceID"] = 5,
  --      ["uid"] = 31273,
  --      ["BigFaceChannel"] = 1,
  --      ["result"] = 0,
  --      ["json_msg_id"] = 1,
  --      ["ctype"] = 1,
  --      ["message"] = "",
  -- }



    local icon = self.icon

    if data.ctype == 1 and data.BigFaceChannel == 3 then
        local uid1 = tonumber(data.message)
        local senduid = data.uid
        local beginpos = nil
        local endpos = nil
        print(uid1)
        print(senduid)
        require "app.help.AnimateUtils"
        for i, v in ipairs(self.gamescene:getSeatsInfo()) do
            local table = self.gamescene.tablelist[v.index + 1]
            if v.user and v.user.uid == uid1 then
                endpos = table.node:convertToWorldSpace(cc.p(table.icon:getPositionX(), table.icon:getPositionY()))
            end

            if v.user and v.user.uid == senduid then
                beginpos = table.node:convertToWorldSpace(cc.p(table.icon:getPositionX(), table.icon:getPositionY()))
            end
        end
        if beginpos and endpos then
            AnimateUtils.playBynum(data.BigFaceID, endpos, beginpos, self.gamescene)
        else
            print("位置信息错误")
        end
        return
    end
    if data.ctype == 1 and data.BigFaceChannel == 2 then
        if not self.addfaceeffectnode then
            self.addfaceeffectnode = cc.Node:create()
            icon:addChild(self.addfaceeffectnode)
        end

        self.addfaceeffectnode:removeAllChildren()
        local spr = WidgetUtils:getFaceeffect(data.BigFaceID or data.json_msg.id)
        local size = icon:getContentSize()
        spr:setPositionX(size.width / 2)
        spr:setPositionY(size.height / 2)
        self.addfaceeffectnode:addChild(spr)
    else
        if self.msgBubbleLayer and tolua.cast(self.msgBubbleLayer, "cc.Node") then
            if self.msgBubbleLayer.audioHandler then
                audio.stopSound(self.msgBubbleLayer.audioHandler)
                self.msgBubbleLayer.audioHandler = nil
            end
            self.msgBubbleLayer:removeFromParent()
            self.msgBubbleLayer = nil
        end

        local layer = require "app.ui.common.MsgBubbleLayer"
        self.msgBubbleLayer = layer.new(self.localpos, data,self.gamescene)
        :addTo(self.gamescene)

        local pos = self.node:convertToWorldSpace(cc.p(icon:getPositionX(), icon:getPositionY()))
        self.msgBubbleLayer:setPosition(cc.p(self.MsgLayerOffset.posx + pos.x, self.MsgLayerOffset.posy + pos.y))
        if data.ctype == 1 and data.BigFaceChannel == 1 and data.BigFaceID then
            local _path = "game_talk_"..data.BigFaceID
            self.msgBubbleLayer.audioHandler = AudioUtils.playVoice(_path, self.gamescene:getSexByUid(data.uid))
        end
    end
end

function BaseTable:clickHeadIcon(data)
    LaypopManger_instance:PopBox("PlayInfoViewforgame", data)
end


function BaseTable:gameStartAction(ischong)
    print(".....................BaseTable..牌局游戏开始～")
    self.icon:setPosition(cc.p(self.nodebegin:getPositionX(), self.nodebegin:getPositionY()))

    if ischong then
        self:refreshSeat()
    else
        self:refreshSeat(nil, true)
    end
  
    -- self:refreshHandCards(true)
    self:refreshOutCards()
    -- 摆牌
    if self.tableidx == self.gamescene:getMyIndex() then
        self.gamescene.UILayer:gameStartAciton()
    end
end

function BaseTable:setbgstype(bg_type)

    -- for k, v in pairs(self.outcardspr) do
    --     v:setbgstype(bg_type)
    -- end
    -- -- 回放界面或者我自己的table
    -- for k, v in pairs(self.handcardspr) do
    --     for kk, vv in pairs(v) do
    --         vv:setbgstype(bg_type)
    --     end
    -- end

    local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
        self.icon:getChildByName("headbg"):loadTexture("cocostudio/ui/game/iconbg.png")
    end

    if bg_type == 1 or bg_type == 3 then
        self.icon:getChildByName("headbg"):loadTexture("game/bg_headbg_1.png", ccui.TextureResType.localType)
    elseif bg_type == 2 or bg_type == 4 then
        self.icon:getChildByName("headbg"):loadTexture("game/bg_headbg_2.png", ccui.TextureResType.localType)
    end

    -- -- 我自己的，有手牌，和操作按钮的改变
    -- if self.localpos == 1 then
    --     if bg_type == 1 or bg_type == 3 then
    --         self.xuxian:loadTexture("game/bg_xuxian_1.png", ccui.TextureResType.localType)
    --     elseif bg_type == 2 or bg_type == 4 then
    --         self.xuxian:loadTexture("game/bg_xuxian_2.png", ccui.TextureResType.localType)
    --     end
    -- end
end

function BaseTable:addputout(value)
end
function BaseTable:showMoPai(value)
end


-------------------------------操作
-- 出牌动画，从展示位到出牌位
function BaseTable:chuPaiAction(data, hidenAnimation)
    self.isChiPeng = false
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    
    local index = data.seat_index
    local value = data.dest_card

    local ma = self:addputout(value)
    ma:setName("chupai")

    self.gamescene:setOutCardTips(true,ma)

    AudioUtils.playEffect("mj_outpai")
    self:playPaiVoice(value)

    self.gamescene:setRunningAction()
end

-- 出牌动画，从展示位到出牌位
function BaseTable:outCardAction(data, hidenAnimation)
    self:updataHuXiText()
    if hidenAnimation then
        self:refreshOutCards()
        return
    end
    self.gamescene:setRunningAction(0.2)
    local chuma = self.outCardNode:getChildByName("chupai")

    if chuma == nil  then
        print(".............出问题了！～！！！没有翻出来的牌")
        return
    else
        chuma:setName("")
        self.gamescene.tipsMa = nil
        table.insert(self.outcardspr,chuma)
        -- setOutCardTips
    end
end

-- --操作的声音和特效
-- local actcof = {
--     [poker_common_pb.EN_SDR_ACTION_HUPAI] = "btn_win",
--     [poker_common_pb.EN_SDR_ACTION_CHI] = "btn_chi",
--     [poker_common_pb.EN_SDR_ACTION_PASS] = "btn_pass" ,
--     [poker_common_pb.EN_SDR_ACTION_PENG] = "action_peng" ,
--     [poker_common_pb.EN_SDR_ACTION_GANG] =  "btn_gang" ,
--     [poker_common_pb.EN_SDR_ACTION_AN_GANG] =  "btn_gang" ,
-- }

function BaseTable:moPaiAction(data, hidenAnimation)
    -- self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self:showMoPai(data.dest_card)

    self.gamescene:setRunningAction(0.2)
    self.gamescene:setOutCardTips(false)
end



-- 碰牌动画
function BaseTable:pengPaiAction(data, hidenAnimation)
    self.isChiPeng = true
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)

    self:showActionImg("action_mj_peng")
    self:playActionVoice("peng")
    self.gamescene:setRunningAction(0.2)
end

-- 杠牌动画
function BaseTable:gangPaiAction(data, hidenAnimation)
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)
    self:showActionImg("action_mj_gang")
    self:playActionVoice("gang")
    self.gamescene:setRunningAction(0.2)
end


-- 杠牌动画
function BaseTable:anGangPaiAction(data, hidenAnimation)
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)
    self:showActionImg("action_mj_gang")
    self:playActionVoice("gang")
    self.gamescene:setRunningAction(0.2)
end

-- 吃牌动画
function BaseTable:chiPaiAction(data, hidenAnimation)
    self.isChiPeng = true
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)
    self:showActionImg("action_mj_chi")
    self:playActionVoice("chi")
    self.gamescene:setRunningAction(0.2)
end

-- 胡牌动画
function BaseTable:huPaiAction(data, hidenAnimation)
    -- self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self:showActionImg("action_mj_hu")

    if  data.iszimo then
        self:playActionVoice("zimo")
    else
        self:playActionVoice("hu")
    end

    self.gamescene:setRunningAction(0.2)
end



function BaseTable:getChuPaiPosWorldSpace()
    local chupai = self.effectnode:getChildByName("chupai")
    local worldpos1 = self.effectnode:convertToWorldSpace(cc.p(chupai:getPositionX(), chupai:getPositionY()))
    return worldpos1
end


function BaseTable:showActionImg(_img)

    local img = ccui.ImageView:create("ui/game_action/action_zi/zi/".._img..".png",ccui.TextureResType.localType)
    if not img then
        return
    end
    local acticon = cc.CSLoader:createNode("ui/game_action/action_zi/action_zi.csb")
    self.effectnode:addChild(acticon,9)

    local action = cc.CSLoader:createTimeline("ui/game_action/action_zi/action_zi.csb")
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            acticon:removeFromParent()
        end
    end

    acticon:getChildByName("Node_1"):getChildByName("zi"):setTexture("ui/game_action/action_zi/zi/".._img..".png")

    action:setFrameEventCallFunc(onFrameEvent)
    action:gotoFrameAndPlay(0, false)
    acticon:runAction(action)

end


function BaseTable:playPaiVoice(pai)
    AudioUtils.playVoice("mj/mj_"..pai, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function BaseTable:playActionVoice(action)
    AudioUtils.playVoice("mj/mj_action_"..action, self.gamescene:getSexByIndex(self:getTableIndex()))
end

-- 寻找牌桌上出现的牌
function BaseTable:seekAndSignTile(value)
    -- 打出去的牌
    for i,v in ipairs(self.outcardspr) do
        if v:getCardValue() == value then
            v:setIsShow()
        end
    end

    -- 手上的牌
    for i,v in ipairs(self.handcardspr) do
        if v:getCardValue() == value then
            v:setIsShow()
        end
    end

     -- 摆出来的牌
    for i,v in ipairs(self.showcardspr) do
        if v:getCardValue() == value then
            v:setIsShow()
        end
    end

    -- 正在处理的牌
    local chuma = self.outCardNode:getChildByName("chupai")
    if chuma ~= nil  then
        if chuma:getCardValue() == value then
            chuma:setIsShow()
        end
    end
end
function BaseTable:resignTile()
    -- 打出去的牌
    for i,v in ipairs(self.outcardspr) do
        if v.hideShow then
            v:hideShow()
        end
    end

    -- 手上的牌
    for i,v in ipairs(self.handcardspr) do
        v:hideShow()
    end
    -- 摆出来的牌
    for i,v in ipairs(self.showcardspr) do
        v:hideShow()
    end

    -- 正在处理的牌
    local chuma = self.outCardNode:getChildByName("chupai")
    if chuma ~= nil  then
        chuma:hideShow()
    end

end

return BaseTable
