local BaseTable = class("BaseTable")
local LongCard = require "app.ui.game_base_cdd.base.LongCard"
local DdzcsbAnmation = require "app.ui.game_base_cdd.DdzcsbAnmation"
BASECARDWIDTH = 38 
BASECARDHEIGHT = 42

CHU_CARD_SCALE = 0.72

function BaseTable:ctor(node, gamescene)
    self.node = node
    self.node:setVisible(false)
    self.gamescene = gamescene
    self.lipailist = {}
    self._pokers = {}
    self:initView()
    self:initData()
    self:resetData()
    -- self:refreshView()
    self:initLocalConf()
end

function BaseTable:initData()
    self.cardScale = 44 / 74
    self.tableidx = -1
    self.effectnode = nil
    self.cardwidth = 158
    self.cardheight = 218
    self.cardAnchor = cc.p(0.5,0.5)  
end

function BaseTable:initView()
    self.nodenotbegin = self.node:getChildByName("nodenotbegin")
    -- 开始之前的位置，
    self.nodebegin = self.node:getChildByName("nodebegin")
    -- 开始牌局之后的位置

    self.handcardnode = self.node:getChildByName("handcardnode"):setVisible(false)
    -- 手牌节点
    -- 出牌节点
    self.showcardnode = self.node:getChildByName("showcardnode"):setVisible(false)
    self.buchunode = self.node:getChildByName("buchu"):setVisible(false)
    -- 加倍节点
    self.nodejiabei = self.node:getChildByName("nodejiabei")
    self.node:getChildByName("card"):setVisible(false)
    self.jiaonode = self.node:getChildByName("jiaonode"):setVisible(false)
    self.icon = self.node:getChildByName("icon")

    self.baojin = self.node:getChildByName("baoji")

    -- 听牌节点

    -- self.caicard = self.node:getChildByName("caicard")
    -- -- 玩家信息节点

    self.moPaiPos = cc.p(0, 0)

end

function BaseTable:initLocalConf()
    -- body
end

function BaseTable:resetData()
    self.isbaojing = false
    self.handcardspr = { }
    -- 二维数组
    self.putoutspr = { }
    self.showcardspr = { }
    self.isRunning = false

    if self.effectnode then
        self.effectnode:removeAllChildren()
    end
    self.showcardnode:removeAllChildren()
    self.handcardnode:removeAllChildren()
    self.nodejiabei:removeAllChildren()
    self.baojin:removeAllChildren()
    if  AudioUtils.localmp3 ~= "ddzroombgm" then
        AudioUtils.playMusic("ddzroombgm",true)
    end

    self.icon:setPosition(cc.p(self.nodenotbegin:getPositionX(), self.nodenotbegin:getPositionY()))
end
function BaseTable:gameOver()
    self.lipailist = {}
    self.isbaojing = false
    self._pokers = {}
    self.nodejiabei:removeAllChildren()
    self.baojin:removeAllChildren()

    if  AudioUtils.localmp3 ~= "ddzroombgm" then
        AudioUtils.playMusic("ddzroombgm",true)
    end

    self:showdizhucleanup()
    self.buchunode:setVisible(false)
    if self.node:getChildByName("card") then
        self.node:getChildByName("card"):setVisible(false)
    end
    if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCDDZ then
        self.gamescene.Suanfuc.laizivalue = -1 
        LAIZIVALUE_LOCAL = -1
    end
end
 

-- function BaseTable:refreshView()
-- 	self:refreshSeat()

-- end

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
function BaseTable:refreshShowTile()
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
         
        self.icon:getChildByName("iconbg"):setVisible(true)
        self.icon:getChildByName("head_icon"):setVisible(true)
        
    else
          
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
       
        self.icon:getChildByName("iconbg"):setVisible(true)
        local head = self.icon:getChildByName("headicon")

        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)
        local name = self.icon:getChildByName("name"):setVisible(true)
        local score = self.icon:getChildByName("score"):setVisible(true)
        head:setVisible(true)
        name:setString(ComHelpFuc.getCharacterCountInUTF8String(info.user.nick,9)) 
       
        score:setString("分数: " .. info.total_score)
        local headicon = require("app.ui.common.HeadIcon_Club").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon
        score:setPositionY(-52)
       if info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            ready:setVisible(true)            

        elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then

            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                if info.is_baozi_zhuang then
                   self:showBaoZiDIZhu(false) 
                end
            end
            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HCNG then
                zhuang:setVisible(false)
                 name:setVisible(false)
                 score:setPositionY(-29)
            end

            -- printTable(info)
            if info.hand_cards and self.gamescene:getTableConf().ttype ~= HPGAMETYPE.YCDDZ then
                if self.node:getChildByName("card") then
                    self.node:getChildByName("card"):setVisible(true)
                    self.node:getChildByName("card"):getChildByName("num"):setString(#info.hand_cards)
                end
            else
               if self.node:getChildByName("card") then
                    self.node:getChildByName("card"):setVisible(false)
               end
            end
            if self.isbaojing then
                if self.isbaojingnum then
                    if self.node:getChildByName("card") then
                        self.node:getChildByName("card"):setVisible(true)
                        self.node:getChildByName("card"):getChildByName("num"):setString(self.isbaojingnum)
                    end
                end
            end
            --info.bao_type = 2
            if info.bao_type and info.bao_type > 0 then
                self:showbaojing(info.bao_type,false)
            end
            if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCDDZ then
                if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCDDZ then
                    if info.need_check_double then
                    else
                        if info.double_times == 1 then
                            self:showJiaBei()
                        else
                            self:showBuJiaBei()
                        end
                    end
                end
            else
                self:shuangDoubletip(false)
            end

        else
            print("不存在的玩家状态")
        end
        --排列
        if info.over_you_index then
            self:setrank(info.over_you_index)
        else
            self.icon:getChildByName("rank"):setVisible(false)
        end
        if info.user.is_offline then
            lixiantip:setVisible(true)
        end

        if self.gamescene:getTableCreaterID() == info.user.uid then
            fangzhutip:setVisible(true)
        end

        if self.gamescene:getSeatInfoByIdx(self.tableidx).state ~= 99 then
            headicon:setTouchEnabled(true)
            WidgetUtils.addClickEvent(headicon, function()
                print("-----1111")
                self:clickHeadIcon(info.user)
            end )
        end
        if info.index == self.gamescene:getMyIndex() then
            self.gamescene.UILayer:refreshReadyCancel(info)
        end
       if self.gamescene:getTableConf().ttype == HPGAMETYPE.HCNG then
            self:showniu(info.niu_gui_index)
       end
       if self.gamescene.name == "GameScene" then
            if self.localpos == 1 then
                self:updatastate(info)
            end
       end
    end
end
function BaseTable:setrank(num)
    info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    info.over_you_index = num
    num = num - poker_common_pb.EN_SDR_STYLE_TYPE_Tou_You+1
    self.icon:getChildByName("rank"):getChildByName("icon"):setTexture("cocostudio/animation/xiaotubiao/"..num.."you.png")
    self.icon:getChildByName("rank"):setVisible(true)
end
function BaseTable:showniu(niuvalue)
     
     local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
     
     if niuvalue and niuvalue > 0 and (info.niuvalue == nil or info.niuvalue < niuvalue) then
        AudioUtils.playEffect("niuguimooooo")
        if niuvalue == 5 then
            self:showshuangniu()
        end
     end
     info.niuvalue = niuvalue
     if niuvalue and niuvalue > 0 then
        self.icon:getChildByName("niunode"):setVisible(true)
        self.icon:getChildByName("niuicon"):setVisible(true)
        if niuvalue == 2 then
            self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(true)
            self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(false)
        elseif niuvalue == 3 then
            self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(false)
            self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(true)
        elseif niuvalue == 5 then
            self.icon:getChildByName("niunode"):getChildByName("icon1"):getChildByName("icon"):setVisible(true)
            self.icon:getChildByName("niunode"):getChildByName("icon2"):getChildByName("icon"):setVisible(true)
        end
     else
        self.icon:getChildByName("niunode"):setVisible(false)
        self.icon:getChildByName("niuicon"):setVisible(false)
     end
end
function BaseTable:pass(isan)
    if isan then
        local index = math.random(1, 3)
        local list = {"ddz_buyao","ddz_pass","ddz_yaobuqi"}
        AudioUtils.playVoice(list[index],self.gamescene:getSexByIndex(self.tableidx))
    end
    if self.localpos == 1 then
        self:hideCannotPut()
    end
    self.showcardnode:removeAllChildren()
    self.buchunode:setVisible(true)
end
function BaseTable:updataDoubleTimes()
    -- local times = self.gamescene:getDoublevalue(self.tableidx)
    -- self.icon:getChildByName("score"):setString(times)
end

function BaseTable:shuangDoubletip(isAdd)

    print("BaseTable:shuangDoubletip isAdd = ",isAdd)

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.JDDDZ then
        local doubleTimes = self.gamescene:getDoubleValue(self:getTableIndex()) or 0
        if (doubleTimes >= 1) then
            self:showJiaBei(false)
        end

        return
    end

    local double_times =  self.gamescene:getDoubleValue(self:getTableIndex()) or 0

    print("BaseTable:shuangDoubletip double_times = ",double_times)
    
    if isAdd then
        double_times = double_times+1
        self.gamescene:setDoublevalue(self:getTableIndex(),double_times)
        local node
        if self:getTableIndex() == self.gamescene:getDealerIndex() then
            node = DdzcsbAnmation.tiAndHuiTi(true)
            AudioUtils.playVoice("ddz_huiti",self.gamescene:getSexByIndex(self.tableidx))
        else
            node = DdzcsbAnmation.tiAndHuiTi(false)
            AudioUtils.playVoice("ddz_tipai",self.gamescene:getSexByIndex(self.tableidx))
        end

        local showpos = cc.p(0,self.cardheight*0.6/2)
        showpos = self.showcardnode:convertToWorldSpace(showpos)

        node:setPosition(showpos)
        self.gamescene:addChild(node)
    end
    if double_times == 0 then
        return
    end

    local doubleIcon = self.icon:getChildByName("doubleIcon")
    if doubleIcon then
        if self:getTableIndex() == self.gamescene:getDealerIndex() then
            doubleIcon:setTexture("gameddz/icon_hui.png")
        else
            doubleIcon:setTexture("gameddz/icon_ti.png")
        end
        doubleIcon:setVisible(true)
        doubleIcon:getChildByName("red"):getChildByName("text"):setString(double_times)
    else
        local picpath = "gameddz/icon_ti.png"
        if self:getTableIndex() == self.gamescene:getDealerIndex() then
            picpath = "gameddz/icon_hui.png"
        end
        local doubleIcon = cc.Sprite:create(picpath)
            :setAnchorPoint(cc.p(0,0))
            :setPosition(cc.p(35,-70))
            :setName("doubleIcon")
            :addTo(self.icon,5)

        local red = cc.Sprite:create("gameddz/icon_red.png")
            :setPosition(cc.p(34,34))
            :setName("red")
            :addTo(doubleIcon)

        local text = ccui.Text:create(double_times,FONTNAME_DEF,20)
            :addTo(red)
            :setName("text")
            :setPosition(cc.p(10,11))
    end

end

--包子地主，和赖地主
function BaseTable:showBaoZiDIZhu(isAdd)
    print("shuangDoubletip")

    if self.gamescene:getTableConf().ttype == HPGAMETYPE.JDDDZ then
        return
    end
    
    local baoziIcon = self.icon:getChildByName("baoziIcon")
    if baoziIcon then
        baoziIcon:removeFromParent()
        baoziIcon = nil
    end

    local picpath = "gameddz/icon_baozi.png"
    -- AudioUtils.playVoice("ddz_tipai",self.gamescene:getSexByIndex(self.tableidx))
    local baoziIcon = cc.Sprite:create(picpath)
        :setAnchorPoint(cc.p(0.5,0.5))
        :setPosition(cc.p(35+24,-70+16))
        :setName("baoziIcon")
        :addTo(self.icon,5)
        :setVisible(true)

    if isAdd  then

        -- if self.gamescene:getChildByName("baoZiNode") then
        --     return 
        -- end
        baoziIcon:setVisible(false)
        local effectName = "cocostudio/animation/baozi/baozi.csb"
        local csblayer = cc.CSLoader:createNode(effectName)
        local action = cc.CSLoader:createTimeline(effectName)

        local node = cc.Node:create()
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end

            local str = frame:getEvent()
            if str == "end" then
                node:setVisible(false)
                csblayer:removeFromParent()
                node:removeFromParent()
                self.icon:getChildByName("baoziIcon"):setVisible(true)
            elseif  str == "start"  then
                local baoziIcon = self.icon:getChildByName("baoziIcon")
                local worldpos1 = self.icon:convertToWorldSpace(cc.p(baoziIcon:getPositionX(),baoziIcon:getPositionY()-16))
                local worldpos2 = self.gamescene:convertToNodeSpace(worldpos1)
                node:runAction(cc.MoveTo:create(0.43, worldpos2))
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
        csblayer:runAction(action)
        csblayer:setPosition(cc.p(0,0))
        csblayer:setAnchorPoint(cc.p(0.5, 0.5))
        

        action:gotoFrameAndPlay(0, true)

        self.isbaoziAction = true

        csblayer:setLocalZOrder(1)

        node:addChild(csblayer)
        node:setPosition(cc.p(display.cx,display.cy))
        self.gamescene:addChild(node)

    end
   
end

function BaseTable:showZhuangAction(func,_pos,hidenAnimation)

    if  hidenAnimation  then
        self.icon:getChildByName("zhuang"):setColor(cc.c3b(255, 255, 255))
        self.icon:getChildByName("zhuang"):setVisible(true)
        return
     end

    local effectName = "cocostudio/ui/zuozhuang/zuozhuang_ddz.csb"
    local csblayer = cc.CSLoader:createNode(effectName)

    local action = cc.CSLoader:createTimeline(effectName)
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            csblayer:removeFromParent()
            self.icon:getChildByName("zhuang"):setColor(cc.c3b(255, 255, 255))
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
    node:setPosition(self.gamescene:convertToNodeSpace(move_pos))
    node:addChild(csblayer)
    self.gamescene:addChild(node)

    local zhuang = self.icon:getChildByName("zhuang")
    local worldpos1 = self.icon:convertToWorldSpace(cc.p(zhuang:getPosition()))
    local worldpos2 = self.gamescene:convertToNodeSpace(worldpos1)
    node:runAction(cc.MoveTo:create(0.2, worldpos2))
    
end

function BaseTable:hideZhuang()
    self.icon:getChildByName("zhuang"):setVisible(false)
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
        -- print(uid1)
        -- print(senduid)
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
        self.msgBubbleLayer = layer.new(self.localpos, data)
        :addTo(self.node)

        local x, y = icon:getPosition()
        self.msgBubbleLayer:setPosition(cc.p(self.MsgLayerOffset.posx + x, self.MsgLayerOffset.posy + y))
        if data.ctype == 1 and data.BigFaceChannel == 1 and data.BigFaceID then
            self.msgBubbleLayer.audioHandler = AudioUtils.playVoice(QUICK_EFFECT_LIST[data.BigFaceID], self.gamescene:getSexByUid(data.uid))
        end
    end
end

function BaseTable:clickHeadIcon(data)
    LaypopManger_instance:PopBox("PlayInfoViewforgame", data)
end


function BaseTable:gameStartAction(isbegin)
    print(".....................BaseTable..牌局游戏开始～")
    self.icon:setPosition(cc.p(self.nodebegin:getPositionX(), self.nodebegin:getPositionY()))

    self:refreshSeat(nil, true)

    self:refreshHandTile(isbegin)


    self:refreshShowTile()
    -- 摆牌
    if self.tableidx == self.gamescene:getMyIndex() then
        self.gamescene.UILayer:gameStartAciton()
    end
     print(".....................BaseTable..牌局游戏开始～")
end

function BaseTable:setbgstype(bg_type)

end

function BaseTable:delehandtiles(data)
    local handtiles = self.gamescene:getHandTileByIdx(self.tableidx)
    if self.gamescene.name == "GameScene" then
        for i,v in ipairs(data) do
            for i1,v1 in ipairs(handtiles) do
                if v == v1 then
                    table.remove(handtiles,i1)
                    break
                end
            end
        end
    end
    self:refreshHandTile()
end

function BaseTable:addDizhuCards( cards )
    local handtiles = self.gamescene:getHandTileByIdx(self.tableidx)
    for i,v in ipairs(cards) do
       table.insert(handtiles,v)
    end
    self:refreshHandTile()
end
function BaseTable:refreshcardNum()
    local  hand_cards = self.gamescene:getHandTileByIdx(self.tableidx)
    if self.node:getChildByName("card") then
        self.node:getChildByName("card"):getChildByName("num"):setString(#hand_cards)
    end
end


function BaseTable:bujiaBei(  )
    AudioUtils.playVoice("ddz_buti",self.gamescene:getSexByIndex(self.tableidx))
end
function BaseTable:showjiaodizhu(  )
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(true)
    self.jiaonode:getChildByName("bujiao"):setVisible(false)
    AudioUtils.playVoice("ddz_jiaodizhu",self.gamescene:getSexByIndex(self.tableidx))
end
function BaseTable:showbujiaodizhu(  )
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(false)
    self.jiaonode:getChildByName("bujiao"):setVisible(true)
    AudioUtils.playVoice("ddz_bujiao",self.gamescene:getSexByIndex(self.tableidx))
end
function BaseTable:showdizhucleanup(  )
    self.jiaonode:setVisible(false)
end

-- 真正的叫地主（以前抢地主变成了叫地主）
function BaseTable:showJiaoDiZhu()
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(true)
    self.jiaonode:getChildByName("jiao"):setTexture("cocostudio/ui/game_mj/result/jiaodizhubtn.png")
    self.jiaonode:getChildByName("bujiao"):setVisible(false)
    AudioUtils.playVoice("ddz_jiaodizhu",self.gamescene:getSexByIndex(self.tableidx))
end

function BaseTable:showBuJiaoDiZhu()
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(false)
    self.jiaonode:getChildByName("bujiao"):setVisible(true)
    self.jiaonode:getChildByName("bujiao"):setTexture("cocostudio/ui/game_mj/result/bujiaobtn.png")
    AudioUtils.playVoice("ddz_bujiao",self.gamescene:getSexByIndex(self.tableidx))
end

function BaseTable:showQiangDiZhu()
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(true)
    self.jiaonode:getChildByName("jiao"):setTexture("cocostudio/ui/game_mj/result/btn_qiangdizhu.png")
    self.jiaonode:getChildByName("bujiao"):setVisible(false)
    AudioUtils.playVoice("ddz_qiangdizhu",self.gamescene:getSexByIndex(self.tableidx))
end

function BaseTable:showBuQiangDiZhu()
    self.jiaonode:setVisible(true)
    self.jiaonode:getChildByName("jiao"):setVisible(false)
    self.jiaonode:getChildByName("bujiao"):setVisible(true)
    self.jiaonode:getChildByName("bujiao"):setTexture("cocostudio/ui/game_mj/result/btn_buqiang.png")
    AudioUtils.playVoice("ddz_buqiang",self.gamescene:getSexByIndex(self.tableidx))
end

function BaseTable:showJiaBei(playAudio)
    local spr = cc.Sprite:create("gameddz/icon_jiabei.png")
    self.nodejiabei:addChild(spr)

    if playAudio then
        AudioUtils.playVoice("btn_jiabei",self.gamescene:getSexByIndex(self.tableidx))
    end
end

function BaseTable:showBuJiaBei()
    AudioUtils.playVoice("btn_bujiabei",self.gamescene:getSexByIndex(self.tableidx))
end

function BaseTable:showMingPai()
    AudioUtils.playVoice("ddz_mingpai",self.gamescene:getSexByIndex(self.tableidx))
end

-- EN_POKER_TYPE_UNKONWN           = 0; // 未知
-- EN_POKER_TYPE_SINGLE_CARD       = 1; // 单牌
-- EN_POKER_TYPE_PAIR              = 2; // 对子
-- EN_POKER_TYPE_TRIPLE            = 3; // 三不带
-- EN_POKER_TYPE_TRIPLE_WITH_ONE   = 4; // 三带一
-- EN_POKER_TYPE_TRIPLE_WITH_TWO   = 5; // 三带二
-- EN_POKER_TYPE_STRAIGHT          = 6; // 顺子
-- EN_POKER_TYPE_STRAIGHT_2        = 7; // 双顺
-- EN_POKER_TYPE_STRAIGHT_3        = 8; // 三顺
-- EN_POKER_TYPE_STRAIGHT_3_2      = 9; // 三顺(三带二的顺子)
-- EN_POKER_TYPE_QUADRUPLE_WITH_TWO    = 10; // 四带二
-- EN_POKER_TYPE_SOFT_BOMB         = 20; // 软炸弹
-- EN_POKER_TYPE_SOFT_BOMB_OF_JOKER    = 21; // 软王炸
-- EN_POKER_TYPE_BOMB              = 22; // (硬)炸弹
-- EN_POKER_TYPE_BOMB_OF_JOKER     = 23; // (硬)王炸

local voiceList = 
{
    [poker_common_pb.EN_POKER_TYPE_SINGLE_CARD ]            = "ddz_dan_",           --单牌
    [poker_common_pb.EN_POKER_TYPE_PAIR ]                   = "ddz_dui_",           --对子
    [poker_common_pb.EN_POKER_TYPE_TRIPLE ]                 = "ddz_three",          --三不带
    [poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE ]        = "ddz_threewithone",   --三带一
    [poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO ]        = "ddz_threewithtwo",   --三带二
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT ]               = "ddz_shunzi",         --顺子
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_2 ]             = "ddz_liandui",        --双顺,如：3344,556677
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 ]             = "ddz_feiji",          --三顺，飞机，如：333444＋56
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_1 ]             = "ddz_feiji",          --三顺，飞机，如：333444＋56
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 ]           = "ddz_feiji",          --三顺(三带二的顺子),如，333444+5566
    [poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO ]     = "ddz_fourwithtwo",    --四带二
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB ]              = "ddz_zhadan",         -- 软炸弹
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER ]     = "ddz_huojian",        --软王炸
    [poker_common_pb.EN_POKER_TYPE_BOMB ]                   = "ddz_zhadan",         -- (硬)炸弹
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER ]          = "ddz_huojian",        --(硬)王炸
    

    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_FIVE ]           = "ddz_wulonggzha",         -- ((软)五龙炸
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_FIVE_JOKER ]          = "ddz_wulonggzha",        --(硬)五龙炸 = 三王炸
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_GUN ]           = "ddz_gunlonggzha",         -- (软)滚龙炸
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN ]          = "ddz_gunlonggzha",        --(硬)滚龙炸66667777
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_3A ]          = "ddz_zhadan",            --3A炸弹
    [poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_THREE ]       = "ddz_fourwiththree",     --四带三
    [poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE ]       = "ddz_fourwithone",     --四带一
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_4 ]             = "ddz_feiji",          -- 飞机
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_LAIZI ]             = "ddz_zhadan",          -- 飞机

    [poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE ]             = "ddz_sidaiyi",          -- 飞机
    [poker_common_pb.EN_POKER_TYPE_TONGHUA ]             = "ddz_tonghua",          -- 飞机
    [poker_common_pb.EN_POKER_TYPE_TONGHUASHUN ]             = "ddz_tonghuashun",          -- 飞机
    [poker_common_pb.EN_POKER_TYPE_QUADRUPLE ]          = "ddz_sizhang",        --(硬)王炸


}
local anmationFunc =
{
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT ]           = function() return DdzcsbAnmation.shunzi() end,--顺子
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 ]         = function() return DdzcsbAnmation.feiji() end,--三顺，飞机，如：333444＋56
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_1 ]         = function() return DdzcsbAnmation.feiji() end,--三顺，飞机，如：333444＋56
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 ]       = function() return DdzcsbAnmation.feiji() end,--三顺(三带二的顺子),如，333444+5566
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB ]          =  function() return DdzcsbAnmation.zhadan() end,-- 软炸弹
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER ] =  function() return DdzcsbAnmation.huojian() end,--软王炸
    [poker_common_pb.EN_POKER_TYPE_BOMB ]               = function() return DdzcsbAnmation.zhadan() end,-- (硬)炸弹
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER ]      = function() return DdzcsbAnmation.huojian() end,--(硬)王炸

    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_FIVE ]        = function() return DdzcsbAnmation.zhadan_five() end,-- (硬)五龙炸
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_FIVE_JOKER ]  = function() return DdzcsbAnmation.zhadan_five() end,--(硬)五龙炸＝三王炸
    [poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_GUN ]    = function() return DdzcsbAnmation.zhadan_gun() end,-- (硬)软滚龙炸弹
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN ]         = function() return DdzcsbAnmation.zhadan_gun() end,-- (硬)滚龙炸弹
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_3A ]          = function() return DdzcsbAnmation.zhadan() end,-- (硬)炸弹
    [poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_4 ]         = function() return DdzcsbAnmation.feiji() end,--三顺，飞机
    [poker_common_pb.EN_POKER_TYPE_BOMB_OF_LAIZI ]          = function() return DdzcsbAnmation.zhadan() end,-- (硬)炸弹
    -- [poker_common_pb.EN_POKER_TYPE_QUADRUPLE ]             = "ddz_zhadan",          -- 飞机
    -- [poker_common_pb.EN_POKER_TYPE_TONGHUASHUN ]             = "ddz_zhadan",          -- 飞机
}

function BaseTable:playCardtypeAn(action,showpos)
    self.showcardnode:setScale(1.1)

    -- self.buchunode
    self.showcardnode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,0.95),cc.ScaleTo:create(0.25,1)))
    -- AudioUtils.playEffect("ddz_chupai")
   
    --有音效播放音效
    local function shallPlayYapai(action)
        if action.type ~= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD and 
        action.type ~= poker_common_pb.EN_POKER_TYPE_PAIR and 
        action.type ~= poker_common_pb.EN_POKER_TYPE_BOMB and
        action.type ~= poker_common_pb.EN_POKER_TYPE_BOMB_OF_3A then
            return true
        end
        return false
    end

    if action.isya and shallPlayYapai(action) then
        local index = math.random(1, 2)
        local list = {"ddz_dani","ddz_manshang"}
        AudioUtils.playVoice(list[index],self.gamescene:getSexByIndex(self.tableidx))

    else
        local voice =  voiceList[action.type]
        if action.type == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD or 
            action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
            
            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HCNG then
                if action.real == 16 then
                    voice = voice.."3"
                elseif action.real == 17 then
                    voice = voice.."16"
                elseif action.real == 18 then
                     voice = voice.."17"
                else
                    voice = voice..action.real
                end
            else
                voice = voice..action.real
            end
        end
        AudioUtils.playVoice(voice,self.gamescene:getSexByIndex(self.tableidx))
    end

    --有特效播放特效
    if anmationFunc[action.type] ~= nil then
        local _pos = cc.p(display.cx,display.cy)
        if  action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT or
            action.type == poker_common_pb.EN_POKER_TYPE_SOFT_BOMB or
            action.type == poker_common_pb.EN_POKER_TYPE_BOMB then
            _pos = showpos
        end
        local node =  anmationFunc[action.type]()
        node:setPosition(_pos)
        self.gamescene:addChild(node)
    end
end

function BaseTable:showbaojing(num,isan)

     if self.gamescene:getTableConf().ttype == HPGAMETYPE.YCDDZ  then
        self.isbaojing = true
        self.isbaojingnum = num
    end
    if self.node:getChildByName("card") then
        self.node:getChildByName("card"):setVisible(true)
        self.node:getChildByName("card"):getChildByName("num"):setString(num)
    end
    print("baojing")
    local node = DdzcsbAnmation.jingbao()
    self.baojin:addChild(node)

    if  AudioUtils.localmp3 ~= "ddz_bgm_jingbao" then
        AudioUtils.playMusic("ddz_bgm_jingbao",true)
    end

    if isan then
        if num == 2 then
            AudioUtils.playVoice("ddz_lasttwo",self.gamescene:getSexByIndex(self.tableidx))
            AudioUtils.playVoice("ddz_baojing",self.gamescene:getSexByIndex(self.tableidx))
        elseif num == 1 then
            AudioUtils.playVoice("ddz_lastone",self.gamescene:getSexByIndex(self.tableidx))
            AudioUtils.playVoice("ddz_baojing",self.gamescene:getSexByIndex(self.tableidx))
        end
    end
end

-- 买牌动画，扣着一张牌
function BaseTable:buyOrSellPaiAction(isHong, hidenAnimation)

    print(".......buyOrSellPaiAction")
    printTable(data)
    if hidenAnimation then
        return
    end

    self.showcardnode:setVisible(true)
    self.showcardnode:setScale(0.6)

    local pokerStr = "gameddz/pokercardddz/poker_card_0_0.png"
    if self.tableidx == self.gamescene:getMyIndex() then
        pokerStr = "gameddz/act_sell_hei.png"
        if  isHong then
            pokerStr = "gameddz/act_buy_hong.png"
        end
    end
    local pokerCard = ccui.ImageView:create(pokerStr)
    pokerCard:setName("kou_card")
    pokerCard:setPositionY(self.cardheight/2)
    pokerCard:setPositionX(0)

    if self.localpos == 2 then
        pokerCard:setPositionX(-55*0.4)
    elseif self.localpos == 2 then
        pokerCard:setPositionX(55*0.4)
    end
    self.showcardnode:addChild(pokerCard)


    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    pokerCard:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        -- self:playPaiVoice(value)
        -- self.showcardnode:setScale(1.0)
    end )))
end

-- 买卖的牌翻转开
function BaseTable:showBuyPaiAction(isHong, hidenAnimation)
    if hidenAnimation then
        return
    end

    local _card = self.showcardnode:getChildByName("kou_card")
    if _card then
        if self.tableidx == self.gamescene:getMyIndex() then
            _card:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
                _card:setVisible(false)
                _card:removeFromParent() 
                self.gamescene:deleteAction("showPaiAction")
            end )))

            return
        else
            _card:setVisible(false)
            _card:removeFromParent() 
        end
    else
        return
    end 

    -- local value = data.dest_card
    -- local func = data.func
    local function runAnimation(m_pCardFront, m_pCardBack, call)
        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.4, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(pSpawnBack)

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.4, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    self.showcardnode:setScale(0.6)
    local pokerCard = ccui.ImageView:create("gameddz/pokercardddz/poker_card_0_0.png")
    pokerCard:setPositionY(self.cardheight/2)
    pokerCard:setPositionX(0)
    if self.localpos == 2 then
        pokerCard:setPositionX(-55*0.4)
    elseif self.localpos == 2 then
        pokerCard:setPositionX(55*0.4)
    end
    self.showcardnode:addChild(pokerCard)

    --
    local path = "gameddz/act_sell_hei.png"
    if  isHong then
        path = "gameddz/act_buy_hong.png"
    end
    local card_bei = ccui.ImageView:create(path)
    card_bei:setPositionY(self.cardheight/2)
    card_bei:setPositionX(0)
    if self.localpos == 2 then
        card_bei:setPositionX(-55*0.4)
    elseif self.localpos == 2 then
        card_bei:setPositionX(55*0.4)
    end
    card_bei:setVisible(false)
    self.showcardnode:addChild(card_bei)

    if self.localpos == 2 then 
        print(" os.time() =1=  ",os.time())
    end

    local _delay = 0.3
    card_bei:runAction(cc.Sequence:create( cc.DelayTime:create(_delay), cc.CallFunc:create( function()
             runAnimation(card_bei, pokerCard, function()
                if func then
                    func()
                end
            end )

        end ),cc.DelayTime:create(0.7), cc.CallFunc:create( function()
                card_bei:removeFromParent()
                pokerCard:removeFromParent()
        end)
    ))
   
end


return BaseTable