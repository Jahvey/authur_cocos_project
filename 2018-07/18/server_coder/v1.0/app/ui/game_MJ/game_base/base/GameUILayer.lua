-- 公用UI
local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
local GameUILayer = class("GameUILayer", function()
    return cc.Node:create()
end )

function GameUILayer:ctor(gamescene)
    self.gamescene = gamescene
    self:initView()
end

function GameUILayer:initView()
    
    self.node = cc.CSLoader:createNode("ui/game_mj/gameUInew.csb")
 
    self.node:addTo(self)

    WidgetUtils.setScalepos(self.node)

    self.bg = self.node:getChildByName("bg")
    WidgetUtils.setBgScale(self.bg)

    self.logo = self.node:getChildByName("Logo")

    self.mainUi = self.node:getChildByName("main")
    WidgetUtils.setScalepos(self.mainUi)

    self.normalbtn = self.mainUi:getChildByName("normalbtn")
    WidgetUtils.setScalepos(self.normalbtn)

    self.readyNode = self.mainUi:getChildByName("readyNode") --准备模块

    self.waitnode = self.mainUi:getChildByName("waitnode"):setVisible(false)--等待模块

    self.paijuNode = self.mainUi:getChildByName("paijuNode")--中间牌局信息模块
    self.jokerCard = self.mainUi:getChildByName("jokerBg"):setVisible(false)--癞子牌模块
    self.piziCard = self.mainUi:getChildByName("piziBg"):setVisible(false)--痞子牌模块


    self.topbg = self.normalbtn:getChildByName("topbg")--顶部信息模块
    self.topbg:setPositionY(display.height / 2 - 8)

    self:initReadyBtn()
    self:initNormalBtn()
    self:initPaiJuView()

    local tips_label = cc.Label:createWithSystemFont("仅供娱乐，禁止赌博", FONTNAME_DEF, 18)
    tips_label:setTextColor( cc.c3b( 0x00, 0x00, 0x00))
    tips_label:setOpacity(255*0.5)
    tips_label:setPosition( cc.p(self.logo:getPositionX(), self.logo:getPositionY()+45))
    tips_label:setLocalZOrder(-1)
    self.mainUi:addChild(tips_label)
end



function GameUILayer:initReadyBtn()
    -- 邀请按钮
    self.invitebtn = self.readyNode:getChildByName("invitebtn")
    WidgetUtils.addClickEvent(self.invitebtn, function()
        -- CommonUtils:prompt("暂未开放，敬请期待", CommonUtils.TYPE_CENTER)
        CommonUtils.sharedesk(self.gamescene:getTableID(), GT_INSTANCE:getTableDes(self.gamescene:getTableConf(), 2),self.gamescene:getTableConf().ttype)
    end)

    local function btncall(bool)
        local index = self.gamescene:getMyIndex()
        if index then
            print("index _位子")
            Socketapi.request_ready(bool)
        else
            print("没有找到自己的位子")
        end
    end
    -- 准备和取消准备
    self.readybtn = self.readyNode:getChildByName("readybtn")
    WidgetUtils.addClickEvent(self.readybtn, function()
        btncall(true)
    end )

    self.cancelbtn = self.readyNode:getChildByName("cancelbtn")
    WidgetUtils.addClickEvent(self.cancelbtn, function()
        btncall(false)
    end )

end
function GameUILayer:initNormalBtn()
    local backbtn = self.normalbtn:getChildByName("backbtn")
    WidgetUtils.addClickEvent(backbtn, function()
        Socketapi.requestLogoutTable()
    end )

    local voicebtn = self.normalbtn:getChildByName("voiceBtn")
    require('app.ui.common.VoiceView').new(voicebtn)


    local setbtn = self.normalbtn:getChildByName("setbtn")
    WidgetUtils.addClickEvent(setbtn, function()
        LaypopManger_instance:PopBox("SetView", 2, self.gamescene)
    end )

    local switchingbtn = self.normalbtn:getChildByName("switching"):setVisible(false)
    WidgetUtils.addClickEvent(switchingbtn, function()
        LaypopManger_instance:PopBox("SwitchingView",self.gamescene)
    end )

    local talkbtn = self.normalbtn:getChildByName("chatBtn")
    WidgetUtils.addClickEvent(talkbtn, function()
         if device.platform ~= "ios"  and device.platform ~= "android" then
            LaypopManger_instance:PopBox("TestCardMJ",self.gamescene)
        else
            LaypopManger_instance:PopBox("ChatView",self.gamescene)
        end
    end )

    local locationBtn = self.normalbtn:getChildByName("locationBtn")
    WidgetUtils.addClickEvent(locationBtn, function()
        if device.platform ~= "ios"  and  device.platform ~= "android" then
            SocketConnect_instance.socket:close()
        else
            self:openDistanceView(true)
        end
    end )

    if self.gamescene:getTableConf().seat_num == 2 then
        if device.platform == "ios"  or  device.platform == "android" then
            locationBtn:setVisible(false)
        end
    end

    if SHENHEBAO then
        locationBtn:setVisible(false)
    end

    local huInfoBtn = self.normalbtn:getChildByName("huInfoBtn"):setVisible(false)
    WidgetUtils.addClickEvent(huInfoBtn, function()
        self.gamescene.mytable:setHuViewIsShow(true)
    end )


    local roomRuleBtn = self.normalbtn:getChildByName("roomRuleBtn")
    WidgetUtils.addClickEvent(roomRuleBtn, function()
        self:openRoomRuleView()
    end )

end

function GameUILayer:initPaiJuView()

    self.paijuNode:setVisible(false)
    self.midspr = self.paijuNode:getChildByName("midspr")
    self.midinfo = self.paijuNode:getChildByName("infonode")


    -- :getChildByName("paizuo"):setVisible(false)
    -- self.clock = self.gamescene.layout:getChildByName("clock"):setVisible(false)

    -- self.leaveTime = self.clock:getChildByName("leavetime")

end
function GameUILayer:waitGameStart()
    self.paijuNode:setVisible(false)
    -- self.clock:setVisible(false)
    self:setJokerCard(-2)
    self:setPiZiCard(-2)
    self.readyNode:setVisible(true)
    self.normalbtn:getChildByName("huInfoBtn"):setVisible(false)
end
 

function GameUILayer:openDistanceView(isbtn)
    if SHENHEBAO then
        return
    end
    local seatlist = { }
    for i, v in ipairs(self.gamescene:getSeatsInfo()) do
        if v.user then
            if v.user.uid ~= LocalData_instance.uid then
                table.insert(seatlist, v.user)
            end
        end
    end
    if #seatlist >= 2 or isbtn then
        LaypopManger_instance:backByName("DistanceView")
        LaypopManger_instance:PopBox("DistanceView", self.gamescene)
    end
end

function GameUILayer:openRoomRuleView()
    if self.gamescene:getTableConf() then
        local layer = require "app.ui.common.RoomRuleLayer"
        layer = layer.new(self.gamescene:getTableConf())
        self.gamescene:addChild(layer, 9)
    end
end

function GameUILayer:initTopInfo(tableid)
    local roomid = self.topbg:getChildByName("roomid")
    roomid:setString("房号:" ..(tableid or ""))

    local timeinfo = self.topbg:getChildByName("time")
    timeinfo:stopAllActions()
    timeinfo:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create( function()
        local date = os.date("%X")
        timeinfo:setString(date)
    end ), cc.DelayTime:create(1))))

    self.net = self.topbg:getChildByName("net")

    local dianliang
 
        dianliang = WidgetUtils.getNodeByWay(self.topbg, { "dian", "bar" })
    dianliang:stopAllActions()
    local function doaction()
        CommonUtils.getDianliangLevel( function(value)
            dianliang:setPercent(value)
        end )
    end
    doaction()
    dianliang:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(10), cc.CallFunc:create( function()
        doaction()
    end ))))
    -- 后去网络信息
    local function doaction()
        CommonUtils.getDianliangLevel( function(value)
            dianliang:setPercent(value)
        end )
    end
    dianliang:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(10), cc.CallFunc:create( function()
        doaction()
    end ))))

    self.ruledesc = self.topbg:getChildByName("ruledesc")
    self.ruledesc:setString("第" .. self.gamescene:getNowRound() .. "/" .. self.gamescene:getTableConf().round .. "局")

end


function GameUILayer:hideNormalBtn()
    for i, v in ipairs(self.normalbtn:getChildren()) do
        v:setVisible(false)
    end
    self.normalbtn:getChildByName("roomRuleBtn"):setVisible(true)
     self.normalbtn:getChildByName("switching"):setVisible(true)
    self.topbg:setVisible(true)
end


function GameUILayer:setNetState(info)
    if self.net.state and self.net.state == Notinode_instance.netstate then
        return
    end

    self.net:setVisible(true)
    self.net:setTexture("cocostudio/ui/game/wifi_" .. Notinode_instance.netstate .. ".png")
    self.net.state = Notinode_instance.netstate

    print("设置 网络连接！！！Notinode_instance.netstate ＝ ", Notinode_instance.netstate)
end

function GameUILayer:refreshReadyCancel(info)

    if info.state == poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME then
        self.invitebtn:setVisible(true)
        self.readybtn:setVisible(true)
        self.cancelbtn:setVisible(false)
    elseif info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
        self.invitebtn:setVisible(true)
        self.readybtn:setVisible(false)
        self.cancelbtn:setVisible(true)
    elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
        self.invitebtn:setVisible(false)
        self.readybtn:setVisible(false)
        self.cancelbtn:setVisible(false)

        self:gameStartAciton()

    elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
        self.invitebtn:setVisible(false)
        self.readybtn:setVisible(false)
        self.cancelbtn:setVisible(false)
    else
        print("不存在的玩家状态")
        self.invitebtn:setVisible(false)
        self.readybtn:setVisible(false)
        self.cancelbtn:setVisible(false)
    end

    if self.gamescene:getNowRound() ~= 0 then
        self.invitebtn:setVisible(false)
        self.normalbtn:getChildByName("backbtn"):setVisible(false)
        self.readybtn:setPositionX(0)
        self.cancelbtn:setPositionX(0)
    end

    if SHENHEBAO then
        self.invitebtn:setVisible(false)
        self.readybtn:setPositionX(0)
        self.cancelbtn:setPositionX(0)
    end
end

function GameUILayer:showPlayingInfo()
    self.readyNode:setVisible(false)

end

function GameUILayer:hidePlayingInfo()
    self.paijuNode:getChildByName("clock"):setVisible(false)
end

function GameUILayer:setJokerCard(card)


    print("......GameUILayer:setJokerCard = ",card)
    if card and card ~= -1  then
        self.jokerCard:setVisible(true)
    else
        self.jokerCard:setVisible(false)
        return
    end

    local cardsSpr = self.jokerCard:getChildByName("jokerBgNumberFrame")
    local joker_bg = self.jokerCard:getChildByName("jokerB_bg")
    self.jokerCard:getChildByName("jokerTxt"):setString("癞子牌")

    if self.gamescene:getTableConf().seat_num == 2 then
        self.jokerCard:setPositionX(160)
    else
        self.jokerCard:setPositionX(218)
    end

    if card == -2 then
        joker_bg:setTexture("gamemj/card/pai/front_back.png")
        cardsSpr:setVisible(false)
        return
    end

    local Majiangcard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
    local putoutingma = Majiangcard.new(MAJIANGCARDTYPE.BOTTOM,card)
    --癞子牌
    if putoutingma then 
        local picstr,str = putoutingma:getpicpath(MAJIANGCARDTYPE.BOTTOM,card)
        if str == nil then
            joker_bg:setTexture("gamemj/card/pai/front_back.png")
            cardsSpr:setVisible(false)
        else
            joker_bg:setTexture("gamemj/card/pai/front_show_big.png")
            cardsSpr:setTexture("gamemj/card/"..str)
            cardsSpr:setVisible(true)
            self.gamescene:setJokerCard(card)
        end
        local showTips = ccui.ImageView:create("gamemj/card/laizi/wang_front_show_big.png")
        cardsSpr:addChild(showTips)
        showTips:setPosition(cc.p(23,25))
    else
        joker_bg:setTexture("gamemj/card/pai/front_back.png")
        cardsSpr:setVisible(false)
    end
end

function GameUILayer:setPiZiCard(card)


    print("......GameUILayer:setJokerCard = ",card)
    if card and card ~= -1  then
        self.piziCard:setVisible(true)
    else
        self.piziCard:setVisible(false)
        return
    end

    if self.gamescene:getTableConf().seat_num == 2 then
        self.piziCard:setPositionX(250)
    else
        self.piziCard:setPositionX(300)
    end

    local cardsSpr = self.piziCard:getChildByName("jokerBgNumberFrame")
    local joker_bg = self.piziCard:getChildByName("jokerB_bg")
    self.piziCard:getChildByName("jokerTxt"):setString("痞子牌")

    if card == -2 then
        joker_bg:setTexture("gamemj/card/pai/front_back.png")
        cardsSpr:setVisible(false)
        return
    end

    local Majiangcard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
    local putoutingma = Majiangcard.new(MAJIANGCARDTYPE.BOTTOM,card)
    --癞子牌
    if putoutingma then 
        local picstr,str = putoutingma:getpicpath(MAJIANGCARDTYPE.BOTTOM,card)
        if str == nil then
            joker_bg:setTexture("gamemj/card/pai/front_back.png")
            cardsSpr:setVisible(false)
        else
            joker_bg:setTexture("gamemj/card/pai/front_show_big.png")
            cardsSpr:setTexture("gamemj/card/"..str)
            cardsSpr:setVisible(true)
            self.gamescene:setPiziCard(card)
        end

        local showTips = ccui.ImageView:create("gamemj/card/pizi/wang_front_show_big.png")
        cardsSpr:addChild(showTips)
        showTips:setPosition(cc.p(23,25))
    else
        joker_bg:setTexture("gamemj/card/pai/front_back.png")
        cardsSpr:setVisible(false)
    end
end


function GameUILayer:refreshInfoNode()
    local resttilenum = self.paijuNode:getChildByName("infonode"):getChildByName("zhang")
    local card_num = self.gamescene:getRestTileNum()
    resttilenum:setString(card_num)  
    resttilenum:setVisible(true)
    -- print("refreshInfoNode:"..card_num)
    -- printTable(self.gamescene.table_info,"ssssss")
    -- if  card_num == 0 then
    --     resttilenum:setVisible(false)
    -- else
    --     local leaveCard = self.paijuNode:getChildByName("paizuo"):getChildByName("leaveCard")
    --     leaveCard:removeAllChildren()
    --     if card_num > 24  then
    --         card_num = 24
    --     end

    --     if card_num > 0 then
    --         for i=1,card_num-1 do
    --             local newCard = ccui.ImageView:create(leaveCard.img)
    --             newCard:setAnchorPoint(cc.p(0,0))
    --             newCard:setPosition(cc.p(0,i*1))
    --             leaveCard:addChild(newCard)
    --         end
    --         resttilenum:setPositionY(35+card_num-1)      
    --     end
    -- end
    self.ruledesc:setString("第" .. self.gamescene:getNowRound() .. "/" .. self.gamescene:getTableConf().round .. "局")
end

function GameUILayer:gameStartAciton()
    self:showPlayingInfo()
    self:refreshInfoNode()
    self.normalbtn:getChildByName("backbtn"):setVisible(false)
    -- self.normalbtn:getChildByName("chatBtn"):setPositionY(-206)
    -- self.normalbtn:getChildByName("voiceBtn"):setPositionY(-299)
end



-- 设置当前操作的玩家
function GameUILayer:setOpertip(index)

    if index == nil or self.gamescene.tablelist[index + 1] == nil then
        return
    end
    if self.Opertip and self.Opertip == index then
        return
    end
    self.Opertip = index
    self.paijuNode:setVisible(true)
    self.midspr:setVisible(true)

   
    local _pos = self.gamescene.Suanfuc:getSeatPosByIndex(index)


    for i=1,4 do
        if _pos == i then
            self.midspr:getChildByName(tostring(i)):setVisible(true)
        else
            self.midspr:getChildByName(tostring(i)):setVisible(false)
        end
    end

    local timelast = 10

    local leaveTime = self.midspr:getChildByName("time_1")
    leaveTime:stopAllActions()
    
    leaveTime:setString(tostring(timelast))
    self.midspr:getChildByName("time_2"):setString(tostring(timelast))
    self.midspr:getChildByName("time_3"):setString(tostring(timelast))

    leaveTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function(...)
        timelast = timelast - 1
        if timelast < 0 then
            timelast = 0
        end
        if timelast < 3 and timelast > 0 then
            AudioUtils.playEffect("tick")
        end
        leaveTime:setString(tostring(timelast))
        self.midspr:getChildByName("time_2"):setString(tostring(timelast))
        self.midspr:getChildByName("time_3"):setString(tostring(timelast))
    end ))))
end

-- 背景 根据设置选择及时更换
function GameUILayer:setbgstype(bg_type)
    -- bg_type_new 牌型摆法
    print("bg_type:"..bg_type)
    if  bg_type > 3 then
        bg_type = 1
    end
    
    self.bg:loadTexture("gamemj/bgstype/tablebg_" .. bg_type .. ".jpg", ccui.TextureResType.localType)
    self.logo:setTexture("gamemj/bg_logo/bg_logo_" .. self.gamescene:getTableConf().ttype .. "_" .. bg_type .. ".png")

    self.midspr:setTexture("gamemj/bgstype/midsprbg_" .. bg_type .. ".png")

    for i =1,4 do
        local spr = self.midspr:getChildByName(tostring(i))
        spr:setTexture("gamemj/bgstype/time_arrow_" .. bg_type .. ".png")
    end

    self.midspr:getChildByName("time_1"):setVisible(false)
    self.midspr:getChildByName("time_2"):setVisible(false)
    self.midspr:getChildByName("time_3"):setVisible(false)

    self.midspr:getChildByName("time_"..bg_type):setVisible(true)

    if bg_type == 1 then

        self.midinfo:getChildByName("zhang"):setTextColor(cc.c3b( 0xf0, 0xe8, 0x76))
        self.midinfo:getChildByName("ju"):setTextColor(cc.c3b( 0xf0, 0xe8, 0x76))
        for i=1,3 do
            self.midinfo:getChildByName("title"..i):setTextColor(cc.c3b( 0x22, 0xda, 0x78))
        end
    elseif bg_type == 2 then

        self.midinfo:getChildByName("zhang"):setTextColor(cc.c3b( 0xf0, 0xe8, 0x76))
        self.midinfo:getChildByName("ju"):setTextColor(cc.c3b( 0xf0, 0xe8, 0x76))
        for i=1,3 do
             self.midinfo:getChildByName("title"..i):setTextColor(cc.c3b( 0x22, 0xda, 0x78))
        end

    elseif bg_type == 3 then

        self.midinfo:getChildByName("zhang"):setTextColor(cc.c3b( 0xfd, 0xe8, 0x3b))
        self.midinfo:getChildByName("ju"):setTextColor(cc.c3b( 0xfd, 0xe8, 0x3b))
        for i=1,3 do
            self.midinfo:getChildByName("title"..i):setTextColor(cc.c3b( 0x61, 0x3f, 0x20))
        end
    end
end

return GameUILayer