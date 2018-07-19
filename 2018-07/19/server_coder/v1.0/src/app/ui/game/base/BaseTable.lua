local BaseTable = class("BaseTable")
local LongCard = require "app.ui.game.base.LongCard"
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
    -- self:refreshView()
    self:initLocalConf()
end

function BaseTable:initData()
    self.record_column_mac = 8
    self.cardScale = 44 / 74
    self.tableidx = -1
    self.effectnode = nil
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
    -- 弃牌节点
    self.qiCardNode = self.node:getChildByName("qicardnode"):setVisible(false)
    
    -- 摆牌节点
    self.showCardNode = self.node:getChildByName("showcardnode"):setVisible(false)
    
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
    self.qicardspr = { }

    self.isRunning = false

    self.nextOutPos = cc.p(self.outCardNode:getPosition())
    self.nextShowPos = cc.p(self.showCardNode:getPosition())
    self.nextDiscardPos = cc.p(20+BASECARDWIDTH, BASECARDHEIGHT/2)

    self.showCardNode:removeAllChildren()
    self.handCardNode:removeAllChildren()
    self.outCardNode:removeAllChildren()
    self.qiCardNode:removeAllChildren()

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
function BaseTable:refreshHandTile()
end
function BaseTable:refreshPutoutTile()
end
function BaseTable:refreshDiscardTile()
end

function BaseTable:refreshShowTile()
end
    
function BaseTable:deleteHandCard(list)

end

function BaseTable:getShowCardList()
    local showCol = clone(self.gamescene:getShowTileByIdx(self.tableidx))

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
       
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        if   GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype) == STYLETYPE.Poker  then
            bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        end
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)
        self.icon:getChildByName("head_icon"):setVisible(true)

    else
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
        headbg:setVisible(true)
        
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        if  GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype) == STYLETYPE.Poker then
            bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        end
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)

        local head = self.icon:getChildByName("headicon")

        local name = self.icon:getChildByName("name"):setVisible(false)
        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        zhuang:setColor(cc.c3b(255, 255, 255))
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)

        local huxitext = self.icon:getChildByName("huxitext"):setVisible(false)
        local fentext = self.icon:getChildByName("fentext"):setVisible(false)
        local xiazhuatext = self.icon:getChildByName("xiazhuatext"):setVisible(false)
        local piao = self.icon:getChildByName("piao"):setVisible(false)
        piao:getChildByName("piaoscore"):setVisible(false)
        piao:getChildByName("redpoint"):setVisible(false)
        local piaopos = cc.p(piao:getPositionX(),piao:getPositionY())
        local bao = self.icon:getChildByName("bao")
        self.icon:getChildByName("huazhuang"):setVisible(false)
        
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
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

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
            huxitext:setVisible(true)
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

        if info.is_piao == true then
            piao:setVisible(true)
        end

        if info.has_kou_pai then
            piao:setVisible(true)
            piao:setTexture("game/icon_qi.png")
        end

        if info.is_after_xiao_hu_continue then
            piao:setVisible(true)
            piao:setTexture("game/icon_xiao.png")
        end

        if info.has_qihu == true or info.is_wait_hu == true then
            bao:setVisible(true)
        end

        self:showzha(info.zha_num)
        

        -- self:updataiconpos()
    end
end
function BaseTable:showzha(zha_num)
    local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    info.zha_num = zha_num
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.SJHP or self.gamescene:getTableConf().ttype == HPGAMETYPE.WJHP then
        if zha_num and zha_num > 0 then
            self.icon:getChildByName("zhanode"):setVisible(true)
            self.icon:getChildByName("zhanode"):getChildByName("text"):setString("扎"..zha_num)
        else
            self.icon:getChildByName("zhanode"):setVisible(false)
        end
    end
end

-- function BaseTable:updataiconpos( )
--     local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
--     local piao = self.icon:getChildByName("piao")
--     local bao = self.icon:getChildByName("bao")
--     local xiaojia = self.icon:getChildByName("xiaojia")
--     local beginpos = cc.p(xiaojia:getPositionX(),xiaojia:getPositionY())
--     local nodetable = {}

--     if self.localpos ~= 2 then
--         if self.gamescene:getXiaoJiaIndex() == self:getTableIndex() then
--             piao:setPosition(cc.p(beginpos.x+39,beginpos.y))
--         else
--             piao:setPosition(cc.p(beginpos.x,beginpos.y))
--         end
--         if info.is_piao then
--             bao:setPosition(cc.p(piao:getPositionX()+39,beginpos.y))
--         end
--     else
--         if self.gamescene:getXiaoJiaIndex() == self:getTableIndex() then
--             piao:setPosition(cc.p(beginpos.x-39,beginpos.y))
--         else
--             piao:setPosition(cc.p(beginpos.x,beginpos.y))
--         end
--         if info.is_piao then
--             bao:setPosition(cc.p(piao:getPositionX()-39,beginpos.y))
--         end
--     end
-- end

--设置票 状态   0 等待 true 飘 false不飘
function BaseTable:setPiao(type)
    -- self:updataiconpos()
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
        self:playActionVoice("nopiao")
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


function BaseTable:showZhuangAction(func,_pos,hidenAnimation)

    if  hidenAnimation then
        self.icon:getChildByName("zhuang"):setVisible(true)
        return
    end

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
    if _pos  then
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.YSGSDR then
            self:playActionVoice("tiao2")
        else
            self:playActionVoice("jiezhuang")
        end
    else
        self:playActionVoice("dangzhuang")
    end
end

function BaseTable:setIsShowHuaZhuang(isShow)
    if isShow then
        self:playActionVoice("huazhuang")
    end
    self.icon:getChildByName("huazhuang"):setVisible(isShow)
end



function BaseTable:addMsgBubble(data)
    if self.tableidx < 0 then
        return
    end

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
            local addnode = cc.Node:create()
            self.gamescene:addChild(addnode)
            addnode:setLocalZOrder(999)
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
        :addTo(self.node)

        local x, y = icon:getPosition()
        self.msgBubbleLayer:setPosition(cc.p(self.MsgLayerOffset.posx + x, self.MsgLayerOffset.posy + y))
        if data.ctype == 1 and data.BigFaceChannel == 1 and data.BigFaceID then

            local _path = "game_talk_"..data.BigFaceID

            local audioPath = self:getVoicePath()

            if  audioPath ~= "" then
                 _path = audioPath.._path
            end
            print(_path)

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.SJHP or self.gamescene:getTableConf().ttype == HPGAMETYPE.WJHP then
                self.msgBubbleLayer.audioHandler = AudioUtils.playVoice("hp/sjhp/msg"..data.BigFaceID, self.gamescene:getSexByUid(data.uid))
            else
                self.msgBubbleLayer.audioHandler = AudioUtils.playVoice(_path, self.gamescene:getSexByUid(data.uid))
            end

        end
    end
end

function BaseTable:clickHeadIcon(data)
    LaypopManger_instance:PopBox("PlayInfoViewforgame", data)
end


function BaseTable:gameStartAction(ischong)
    print(".....................BaseTable..牌局游戏开始～")
    self.icon:setPosition(cc.p(self.nodebegin:getPositionX(), self.nodebegin:getPositionY()))

    if  ischong  then
        self:refreshSeat()
    else
        self:refreshSeat(nil, true)
    end
    
    if ischong and self.tableidx == self.gamescene:getMyIndex() then
        if self.gamescene.name == "GameScene" and self.gamescene:getTableConf().ttype == HPGAMETYPE.TCGZP then
            self.myGrouping = self:getMyGrouping()
            print("..............重连后，读取保存在本地的牌列表！")
        end
    end

    self:refreshHandTile(true)

    self:refreshPutoutTile()
    self:refreshDiscardTile()

    self:refreshShowTile()
    -- 摆牌

    if self.tableidx == self.gamescene:getMyIndex() then
        self.gamescene.UILayer:gameStartAciton()
    end
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
        self.qiCardNode:setVisible(true)
    else
        self.qiCardNode:setVisible(false)
    end
end

function BaseTable:setbgstype(bg_type)

    -- for k, v in pairs(self.outcardspr) do
    --     v:setbgstype(bg_type)
    -- end
    -- for k, v in pairs(self.showcardspr) do
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

function BaseTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        -- printTable(list,"xp")

        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                if  oldValue ~= vv.real_value then
                    if vv.one_value < 4 then
                        if vv.num == 3 then 
                            fen_hand = fen_hand +  6   --绍3张6分
                        elseif vv.num == 4 then
                            fen_hand = fen_hand +  12   --绍4张12分
                        else
                            fen_hand = fen_hand +  vv.num  --其它数量，一个一分
                        end
                    else
                        if vv.num == 3 then
                           fen_hand = fen_hand +  3 --绍3张3分
                        elseif vv.num == 4 then
                           fen_hand = fen_hand +  6  --绍4张6分，
                        end
                    end
                end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
end

--是否显示摆牌的分数，有的暗，或者蹬是需要扣着牌的
function BaseTable:isShowShowTileFen(_list,col)
    --
    print("BaseTable:isShowShowTileFen")
    if  col.score == nil then
        return false
    end

    --不是我自己，没有显示，不是庄家，提的4张牌
    if  self.tableidx ~= self.gamescene:getMyIndex() and 
        self.gamescene:getIsDisplayAnpai() == false and
        self.gamescene:getDealerIndex() ~= self.tableidx and
        col.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        return false
    end

    return true
end

function BaseTable:updataHuXiText()

    local fen_hand = 0
    if  self.gamescene:getTableConf().ttype == HPGAMETYPE.ESCH or 
        self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH or
        self.gamescene:getTableConf().ttype == HPGAMETYPE.JSCH then
    else
        fen_hand = self:getHandCandsFen()
    end
    local fen_show = 0
    local _list = self.gamescene:getShowTileByIdx(self.tableidx)

    for k,v in pairs(_list) do
        --如果是暗，并且没有蹬或者招的牌
        if self:isShowShowTileFen(_list,v) then
            fen_show = fen_show + v.score
        end
    end

    local all = fen_hand + fen_show
    self.icon:getChildByName("huxitext"):setString("点数:" .. all)
    if device.platform ~= "ios"  and  device.platform ~= "android" then
        if self.tableidx == self.gamescene:getMyIndex() then 
            self.icon:getChildByName("huxitext"):setString("点数:" .. fen_show.."+"..fen_hand)
        end
    end
end

function BaseTable:refreshXiaZhua(info)
    -- printInfo("[BaseTable] refreshXiaZhua")
    -- dump(info)

    local xiazhuatext = self.icon:getChildByName("xiazhuatext"):setVisible(false)
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
        xiazhuatext:setVisible(true)
        xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
    end
end

-- CARDTYPE = {
--     MYHAND = 1,  --我自己的手牌
--     ACTIONSHOW = 2, --特效展示，以及小结算界面
--     ONTABLE = 3 --摆在桌面上的牌
-- }
function BaseTable:hideEffectnode()

    for k, v in pairs(self.effectnode:getChildren()) do
        if v.endFunc then
            v.endFunc()
            v.endFunc = nil
        end
    end
    self.effectnode:removeAllChildren()
end

-- 吃牌动画 从展示位到摆牌位
function BaseTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_di")
    self:playActionVoice("di")
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
end
-- 歪牌动画 从展示位到摆牌位
function BaseTable:waiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_wai")
    self:playActionVoice("wai")

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"waiPaiAction")
end
-- 碰牌动画 从展示位到摆牌位
function BaseTable:pengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_peng")
    self:playActionVoice("peng")

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"pengPaiAction")
end
-- 偎牌动画 从展示位到摆牌位
function BaseTable:weiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
   
    self:showActionImg("action_shao")
    self:playActionVoice("shao")

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"weiPaiAction")
end
-- 跑牌动画 从展示位到摆牌位 --明杠
function BaseTable:paoPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    self:playActionVoice("pao")
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"paoPaiAction")
end

-- 提牌动画 从展示位到摆牌位 --暗杠
function BaseTable:tiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    self:playActionVoice("ti")

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tiPaiAction")
end

-- 挎牌动画 从展示位到摆牌位 --需要替换之前的提
function BaseTable:kuaPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_kua")
    if data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PAO then
        self:playActionVoice("pao")
    elseif data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        self:playActionVoice("ti")
    end

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"kuaPaiAction")
end

--招牌动画类似于吃，从展示位到摆牌位
function BaseTable:zhaoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_zhao")
    self:playActionVoice("zhao")

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction")
end

-- 蹬牌动画，从展示位到摆牌位
function BaseTable:dengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)
    self:showActionImg("action_deng")
    self:playActionVoice("deng")
    self:nodeActionToShow(node,"dengPaiAction")
end


-- 翻牌动画 从牌堆位到展示位
function BaseTable:fanPaiAction(data, hidenAnimation)
    if hidenAnimation then
        return
    end

    local value = data.dest_card
    local func = data.func
    local function runAnimation(m_pCardFront, m_pCardBack, call)

        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.2, 1.2)
        local act4 = cc.ScaleTo:create(0.05, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.4, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.25), cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.4, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.3, 0)

        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end

        local act5 = cc.Spawn:create(cc.MoveTo:create(0.3, endpos), rotateTo)

        local midFunc = cc.CallFunc:create( function()
            self:playPaiVoice(value)
        end)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront,midFunc,act5, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)

    -- 要求，自己翻的，是要加黄色背景框
    local cardNode = cc.Node:create()
    self.effectnode:addChild(cardNode)

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
    local path =  "game/mopaikuang.png"
    local diKuang = ccui.ImageView:create(path)
    cardNode:addChild(diKuang, -1)


    local tips = ccui.ImageView:create("game/icon_ban.png")
    local __size = tips:getContentSize()
    tips:setPosition(cc.p((90 - __size.width)/2.0-2,(310 - __size.height)/2.0-2))
    cardNode:addChild(tips)

    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end

    if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
    end

    cardNode:setVisible(false)
    cardNode:setRotation(90)
    cardNode:setPosition(spacepos)
    cardNode:setName("chupai")

    cardNode.beganpos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        cardNode.beganpos = cc.p(0,self:getPosByShowRow().x)
    end
    cardNode.isCanTouched = true
    self:addMoveCardTips(cardNode)
    self:addTileEvent_1(cardNode)

    local card_bei = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(cardNode, card_bei, function()
        if func then
            func()
        end
        if cardNode:getChildByName("tips") then
            cardNode:getChildByName("tips"):setVisible(true)
        end
        self.gamescene:deleteAction("fanPaiAction")
    end )
end
--把翻出来的牌，拿到手上，从展示位到手牌位
function BaseTable:shangShouAction(data,hidenAnimation)
    if hidenAnimation then
        self:refreshHandTile()
        return
    end
    local card = self.effectnode:getChildByName("chupai")
    if card == nil  then
        print(".............出问题了！～！！！没有翻出来的牌")
        return
    end
    card.isCanTouched = false
    card:setPosition(card.beganpos)
     if card:getChildByName("tips") then
            card:getChildByName("tips"):setVisible(false)
        end

    self:nodeActionToHand(card,"shangShouAction")
end

-- 出牌动画 出现在展示位
function BaseTable:chuPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        return
    end
    local value = data.dest_card
    local func = data.func

    local cardNode = cc.Node:create()
    self.effectnode:addChild(cardNode)

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
    local path =  "game/2d_dapaikuang.png"
    local diKuang = ccui.ImageView:create(path)
    cardNode:addChild(diKuang)

    local _size = diKuang:getContentSize()
    local tips = ccui.ImageView:create("game/icon_da.png")
    local __size = tips:getContentSize()
    tips:setPosition(cc.p((90 - __size.width)/2.0-2,(310 - __size.height)/2.0-2))
    cardNode:addChild(tips)

    cardNode:setName("chupai")
    cardNode.isCanTouched = true
    cardNode.beganpos = cc.p(0,0)
    self:addTileEvent_1(cardNode)
    self:addMoveCardTips(cardNode)

    local _pos = cc.p(0,0)
    cardNode:setPosition(_pos)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
     if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
     end

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    cardNode:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        self:playPaiVoice(value)
        if func then
            func()
        end
        if cardNode:getChildByName("tips") then
            cardNode:getChildByName("tips"):setVisible(true)
        end
    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
        self.gamescene:deleteAction("chuPaiAction")
    end )))
end
-- 胡牌动画 出现在展示位
function BaseTable:huPaiAction(data)

    local value = data.dest_card
    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    self.effectnode:addChild(card)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
     if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
     end
    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    card:setPosition(_pos)

    self:showActionImg("action_hu")
    self:playActionVoice("hu")

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    card:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        card:setVisible(false)
    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()

        card:stopAllActions()
        card:removeFromParent()
        self.gamescene:deleteAction("huPaiAction")
    end )))
end

function BaseTable:xiaoHuPaiAction(data,hidenAnimation)
    if hidenAnimation then
        return
    end
    self:playActionVoice("xiaohu")
end
function BaseTable:qiHuPaiAction(data,hidenAnimation)

    for k,v in pairs(self.showcardspr) do
        v:setGray()
    end

    if  hidenAnimation then
        local piao = self.icon:getChildByName("piao"):setVisible(true)
        piao:setTexture("game/icon_qi.png")
    else
        self:setBao(2)  
    end
end



-- 出牌动画，从展示位到出牌位
function BaseTable:outCardAction(data, hidenAnimation)

    if hidenAnimation then
        self:refreshPutoutTile()
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
            self:refreshDiscardTile()
        end

        return
    end

    local card = self.effectnode:getChildByName("chupai")
    if card == nil then
        -- __G__TRACKBACK__RED(".............出问题了！～！！！没有出牌")
        return
    end
    card.isCanTouched = false
    card:setPosition(card.beganpos)

    if card:getChildByName("tips") then
        card:getChildByName("tips"):setVisible(false)
    end
    local isNeedDelay = data.need_delay

    local worldpos1 = self.outCardNode:convertToWorldSpace(self.nextPutPos)
    local rotateTo = cc.RotateTo:create(0.2, self.outCardNode:getRotation())
    -- -- TODO
    -- local rotateTo = cc.RotateTo:create(0.2, 0)

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
        if data.is_napai then 
            worldpos1 = self.outCardNode:convertToWorldSpace(self.nextPutPos)
            rotateTo = cc.RotateTo:create(0.2, self.outCardNode:getRotation())
        else
            worldpos1 = self.qiCardNode:convertToWorldSpace(self.nextDiscardPos)
            rotateTo = cc.RotateTo:create(0.2, self.qiCardNode:getRotation())
        end
    end

    local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)

    
    local scaleTo = cc.ScaleTo:create(0.2, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.2, worldpos2), rotateTo, scaleTo, cc.FadeOut:create(0.2))

    local _delay = 0.3
    if isNeedDelay and self.gamescene.name == "GameScene" then
        -- 在回放界面的时候，不需要延时
        _delay = 1.2
    end
    card.endFunc = function()
        card:setVisible(false)
        self:refreshPutoutTile()
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
            self:refreshDiscardTile()
        end
    end
    card:runAction(cc.Sequence:create(cc.DelayTime:create(_delay), act4, cc.CallFunc:create( function()
        if card.endFunc then
            card.endFunc()
        end
        card.endFunc = nil

    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
        card:stopAllActions()
        card:removeFromParent()
        self.gamescene:deleteAction("outCardAction")
    end )))
end


--生成牌list节点
function BaseTable:createCardsNode(data)
    
    local cardList = clone(data.col_info.cards)
    --不是我自己，没有显示，不是庄家
    if  self.tableidx ~= self.gamescene:getMyIndex() and 
        self.gamescene:getIsDisplayAnpai() == false and
        self.gamescene:getDealerIndex() ~= self.tableidx and
        data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        for kk, vv in pairs(cardList) do
            cardList[kk] = 0
        end
    end
    -- print("........生成牌list节点")
    -- printTable(data,"xp7")

    local node = cc.Node:create()
    for i, v in ipairs(cardList) do
        local card = LongCard.new(CARDTYPE.ACTIONSHOW, v)
        card:setPositionY((1 - i) * 30)
        node:addChild(card)

        if self.gamescene:getIsJiangCard(v) then
            card:showJiang()
        end
        if self.gamescene:getIsJokerCard(v) then
            card:showJoker()
        end
    end

    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    node:setPosition(_pos)
    node.token = data.token
    return node
end

-- 动画统一 从展示位到摆牌位
function BaseTable:nodeActionToShow(node,_str)
    node.endFunc = function()
        node:setVisible(false)
        self:refreshShowTile()
    end
    local showpos = self:getShowPos(node.token)

    
    local worldpos1 = self.showCardNode:convertToWorldSpace(showpos)
    local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)
    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)
    local rotateTo = cc.RotateTo:create(0.25, self.showCardNode:getRotation())
    local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), rotateTo, scaleTo, cc.FadeOut:create(0.225))
    local _endFunc = cc.CallFunc:create( function()
        node.endFunc()
        node.endFunc = nil
    end)
    local _delay = cc.DelayTime:create(0.2)
    local _lastFun = cc.CallFunc:create( function()
        node:stopAllActions()
        node:removeFromParent()
        self.gamescene:deleteAction(_str)
    end )
    node:runAction(cc.Sequence:create(act1, act2, act3, act4, _endFunc, _delay,_lastFun))
end

-- 动画统一 从展示位到手牌位
function BaseTable:nodeActionToHand(node,_str)
    node.endFunc = function()
        node:setVisible(false)
        self:refreshHandTile()
    end

    local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)
    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)
    local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), scaleTo, cc.FadeOut:create(0.225))

    local _endFunc = cc.CallFunc:create( function()
        node:setVisible(false)
        self:refreshHandTile()
    end)
    local _delay = cc.DelayTime:create(0.2)
    local _lastFun = cc.CallFunc:create( function()
        node:stopAllActions()
        node:removeFromParent()
        self.gamescene:deleteAction(_str)
    end )
    node:runAction(cc.Sequence:create(act1, act2, act3, act4, _endFunc, _delay, _lastFun))
end

local baoCof = 
{
    [1] = {img = "game/bao_sanzhang.png",audio = "bao_sanzhang",isBao = false}, --报三张
    [2] = {img = "game/bao_bigua.png",audio = "bao_bigua",isBao = false},--必挂三条口
    [3] = {img = "game/bao_kehubuzhui.png",audio = "bao_kehubuzhui",isBao = false},--可胡不追
    [4] = {img = "game/bao_baodukou.png",audio = "bao_baodukou",isBao = true},--报独口
    [5] = {img = "game/bao_liuwei.png",audio = "bao_liuwei",isBao = false},--报六位
    [6] = {img = "game/bao_houshao.png",audio = "bao_houshao",isBao = false},--后绍
    [7] = {img = "game/bao_haiyou.png",audio = "bao_haiyou",isBao = false},--还有
    [8] = {img = "game/bao_meile.png",audio = "bao_meile",isBao = false},--没了
    [9] = {img = "game/bao_daojin.png",audio = "bao_daojin",isBao = false},--倒进
    
    [10] = {img = "game/bao_guanxiaotou.png",audio = "bao_guanxiaotou",isBao = false},--关小偷
    [11] = {img = "game/bao_liugetuanyuan.png",audio = "bao_liugetuanyuan",isBao = false},--六个团圆
    [12] = {img = "game/bao_qishouwujiang.png",audio = "bao_qishouwujiang",isBao = false},--起手无将

    [100] = {img = "game/bao_lianglong.png",audio = "bao_lianglong",isBao = false},--亮拢
}

--报
function BaseTable:baoPaiAction(data,hidenAnimation)
    if hidenAnimation  then
        for i,v in ipairs(data.bao_info) do
            if  baoCof[v.bao_type].isBao == true  then
                local bao = self.icon:getChildByName("bao"):setVisible(true)
                bao:setTexture("game/icon_bao.png")
            end
        end
        return
    end

    print("........BaseTable:addTipAction name = ",_name)
    local node =  cc.Node:create()
    local bg = ccui.ImageView:create("game/bao_card_back.png")
    bg:setLocalZOrder(-1)
    node:addChild(bg)
    -- bao_info
    local _width = 0
    local list = {data.dest_card}
    for i,v in ipairs(list) do
        local pai = LongCard.new(CARDTYPE.ONTABLE,v)
        pai:getbg():setAnchorPoint(cc.p(0,0.5))
        _width = _width + 5
        pai:setPositionX(_width)
        _width = _width + pai:getbg():getContentSize().width
        pai:setPositionY(29)
        pai:addTo(bg)
    end
    if data.bao_info and #data.bao_info ~= 0 then
        for i,v in ipairs(data.bao_info) do
            local baoType = ccui.ImageView:create(baoCof[v.bao_type].img)
            if baoType then
                baoType:setAnchorPoint(cc.p(0, 0.5))
                baoType:setPosition(cc.p(_width,29))
                _width = _width + baoType:getContentSize().width
                bg:addChild(baoType)
            end
            if v.bao_type == 5 then
                local audioName = "liuwei_"..math.floor(data.dest_card / 16)..data.dest_card % 16
                AudioUtils.playVoice(audioName,self.gamescene:getSexByIndex(self:getTableIndex()))  
            else
                AudioUtils.playVoice(baoCof[v.bao_type].audio,self.gamescene:getSexByIndex(self:getTableIndex()))  
            end
            if  baoCof[v.bao_type].isBao == true  then
                self:setBao(1)
            end
        end
    end  

    _width = _width + 8
    bg:setScale9Enabled(true)
    bg:setCapInsets(cc.rect(15, 15, 17,17))
    bg:setContentSize(cc.size(_width,58))

    local _x,_y = self.icon:getPosition()
    if  self.localpos == 1 then
        bg:setAnchorPoint(cc.p(0,0.5))
        _x = _x - 32
        _y = _y + 138
    elseif  self.localpos == 2 then
        bg:setAnchorPoint(cc.p(1,0.5))
        _x = _x - 40
    elseif  self.localpos == 3 then
        bg:setAnchorPoint(cc.p(1,0.5))
        _x = _x - 40
    elseif self.localpos == 4 then
        bg:setAnchorPoint(cc.p(0,0.5))
        _x = _x + 40
    end

    local worldpos1 = self.node:convertToWorldSpace(cc.p(_x,_y))
    local spacepos = self.effectnode:convertToNodeSpace(worldpos1)
    node:setPosition(spacepos)
    self.effectnode:addChild(node)

    local act1 = cc.ScaleTo:create(0.15,1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075,1)
    node:runAction(cc.Sequence:create(act1,act2,act3,cc.DelayTime:create(2),cc.CallFunc:create(function() 
        node:stopAllActions()
        node:removeFromParent()
    end)))
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

    --acticon:getChildByName("chi"):getChildByName("zi_gx_01"):setTexture("ui/game_action/action_zi/zi_gx/".._img..".png")
    --acticon:getChildByName("chi"):getChildByName("zi_gx_02"):setTexture("ui/game_action/action_zi/zi_gx/".._img..".png")
    acticon:getChildByName("Node_1"):getChildByName("zi"):setTexture("ui/game_action/action_zi/zi/".._img..".png")

    action:setFrameEventCallFunc(onFrameEvent)
    action:gotoFrameAndPlay(0, false)
    acticon:runAction(action)

end

function BaseTable:yangAction(data,hidenAnimation)
    
    self:refreshHandTile()
    if  hidenAnimation then
        local piao = self.icon:getChildByName("piao"):setVisible(true)
        piao:setTexture("game/icon_qi.png")
    else
        self:setBao(2)  
    end

    self.gamescene:deleteAction("仰")
end

-- 偷牌动画，从牌堆位到展示位 再到手牌位
function BaseTable:touPaiAction(data, hidenAnimation)
    if hidenAnimation then
        self:refreshHandTile()
        return
    end

    local value = data.dest_card
    local function runAnimation(m_pCardFront, m_pCardBack, call)

        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.15, 1.2)
        local act4 = cc.ScaleTo:create(0.05, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.3, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.2), cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.3, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.225, 0)
        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end
        local act5 = cc.Spawn:create(cc.MoveTo:create(0.225, endpos), rotateTo)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, act5, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))

    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)
    self:playActionVoice("tou")

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    card:setVisible(false)
    card:setRotation(90)
    card:setPosition(spacepos)
    self.effectnode:addChild(card)

    local card_bei = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(card, card_bei, function()

        local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)

        local act1 = cc.ScaleTo:create(0.15, 1.2)
        local act2 = cc.DelayTime:create(0.15)
        local act3 = cc.ScaleTo:create(0.075, 1)
        local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
        local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), scaleTo, cc.FadeOut:create(0.225))

        card.endFunc = function()
            card:setVisible(false)
            self:refreshHandTile()
        end

        card:runAction(cc.Sequence:create(act1, act2, act3, act4, cc.CallFunc:create( function()
            card.endFunc()
            card.endFunc = nil

        end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
            card:stopAllActions()
            card:removeFromParent()
            -- self.effectnode:removeAllChildren()
            self.gamescene:deleteAction("touPaiAction")
        end )))

    end )
end

--招牌动画类似于吃，从展示位到摆牌位
function BaseTable:tuoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_tuo")
    self:playActionVoice("tuo")

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tuoPaiAction")
end

function BaseTable:getVoicePath()
    if GT_INSTANCE:getIsTwoAudio(self.gamescene:getTableConf().ttype) then
        local audio_type = cc.UserDefault:getInstance():getIntegerForKey("audio_type",1)
        if audio_type == 2 then --普通话
            return "hp/"
        elseif audio_type == 1 then --方言
            local audioPath = GT_INSTANCE:getIsAudioPath(self.gamescene:getTableConf().ttype)
            if  audioPath ~= nil then
                return audioPath.."/"
            end
        end
    end
    return ""
end

function BaseTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function BaseTable:playActionVoice(action)
    AudioUtils.playVoice("action_"..action, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function BaseTable:addTileEvent_1(tile)

    local card = tile:getChildByName("card")
    if card == nil  then
       card = tile
    end

    local oldTouchPoint,newTouchPoint

    -- body
    -- local beganposx, beganposy = tile:getPosition()
    -- tile.beganpos = cc.p(beganposx,beganposy)

    local tilePoint = tile.beganpos

    local function shallResponseEvent()
        if not tolua.cast(tile, "cc.Node") then
            return false
        end
        if  tile.isCanTouched == false then
            return false
        end

        return true
    end


    local function onTouchBegan(touch, event)

        if not shallResponseEvent() then
            return
        end
        local locationInNode = card:getbg():convertToNodeSpace(touch:getLocation())
        local s = card:getbg():getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height);
        if cc.rectContainsPoint(rect, locationInNode) then
            oldTouchPoint = touch:getLocation()
            tilePoint = tile.beganpos
            tile.isTouched = true
            if tile:getChildByName("tips") then
                tile:getChildByName("tips"):setVisible(false)
            end
            return true
        end
    end

    local function onTouchMove(touch, event)
        if not shallResponseEvent() then
         return
        end
        newTouchPoint = touch:getLocation()
        if tile and tile.isCanTouched == true and WidgetUtils:nodeIsExist(tile) then
            local _x = tilePoint.x+(newTouchPoint.x - oldTouchPoint.x)
            local _y = tilePoint.y+(newTouchPoint.y - oldTouchPoint.y)
            tilePoint = cc.p(_x,_y)
            tile:setPosition(tilePoint)
        end
        oldTouchPoint = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        tile.isTouched = false
        if tile and WidgetUtils:nodeIsExist(tile) then
            tile:setPosition(tile.beganpos)
        end
    end

    local function onTouchCancell(touch, event)
        tile.isTouched = false
        if tile and WidgetUtils:nodeIsExist(tile) then
            tile:setPosition(tile.beganpos)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancell, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = card:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tile)
end


--
function BaseTable:addMoveCardTips(cardNode)
    local tipsNum = cc.UserDefault:getInstance():getIntegerForKey("MOVE_CARD_TIPS"..LocalData_instance.uid,0)
    if tipsNum < 5 then

        local label2 = cc.Label:createWithSystemFont("温馨提示：挡住牌了？试试提牌！", FONTNAME_DEF, 18)
        label2:setPosition( cc.p(0, 190))
        label2:setTextColor( cc.c3b( 0xff, 0xff, 0xff))
        label2:enableOutline(cc.c3b( 0x42, 0x23, 0x15),2)
        label2:setVisible(false)
        cardNode:addChild(label2)
        label2:setName("tips")

        tipsNum = tipsNum + 1
        cc.UserDefault:getInstance():setIntegerForKey("MOVE_CARD_TIPS"..LocalData_instance.uid,tipsNum)
    end
end


function BaseTable:addQiShouMaiTips(data)
    local node = cc.Node:create()
    local img = "gameddz/mai_zhong.png"
    if data.is_qi_shou_mai then
        img = "gameddz/mai_qi.png"
    end
    local maiType = ccui.ImageView:create(img)
    if maiType then
        maiType:setPosition(cc.p(0,((#data.cards-1)*36)+35))
        node:addChild(maiType)
    end
    return node
end


return BaseTable
