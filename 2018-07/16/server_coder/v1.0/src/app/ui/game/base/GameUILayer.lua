-- 公用UI
local LongCard = require "app.ui.game.base.LongCard"
local GameUILayer = class("GameUILayer", function()
    return cc.Node:create()
end )

function GameUILayer:ctor(gamescene)
    self.gamescene = gamescene
    self:initView()
end

function GameUILayer:initView()
    
    if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
        self.node = cc.CSLoader:createNode("ui/game/gameUInewforfour.csb")
    else
        self.node = cc.CSLoader:createNode("ui/game/gameUInew.csb")
    end
 
    self.node:addTo(self)

    WidgetUtils.setScalepos(self.node)

    self.bg = self.node:getChildByName("bg")
    WidgetUtils.setBgScale(self.bg)

    self.logo = self.node:getChildByName("Logo")

    self.mainUi = self.node:getChildByName("main")
    WidgetUtils.setScalepos(self.mainUi)

    self.normalbtn = self.mainUi:getChildByName("normalbtn")
    WidgetUtils.setScalepos(self.normalbtn)

    self.readyNode = self.mainUi:getChildByName("readyNode")
    -- WidgetUtils.setScalepos(self.readyNode)

    self.waitnode = self.mainUi:getChildByName("waitnode")
    -- WidgetUtils.setScalepos(self.waitnode)

    self.paijuNode = self.mainUi:getChildByName("paijuNode")
    -- WidgetUtils.setScalepos(self.paijuNode)

    self.topbg = self.normalbtn:getChildByName("topbg")
    --如果4人 2d新牌桌 top分成了两个节点
    self.topbg1 = self.normalbtn:getChildByName("topbg1")

    self.topbg:setPositionY(display.height / 2 - 8)
    if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
        self.topbg1:setPositionY(display.height / 2 - 8)
    end

    self.waitnode:setVisible(false)

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

    self:initNormalBtn()
    self:initPaiJuView()
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
            LaypopManger_instance:PopBox("TestCardH",self.gamescene)
        else
            LaypopManger_instance:PopBox("ChatView")
        end
    end )

    local locationBtn = self.normalbtn:getChildByName("locationBtn")
    WidgetUtils.addClickEvent(locationBtn, function()
        if device.platform ~= "ios"  and  device.platform ~= "android" then
            SocketConnect_instance.socket:close()
        else
            self:openDistanceView(true)
        end
        -- self.gamescene.mytable.actionview:hide()
    end )

    if self.gamescene:getTableConf().seat_num == 2 then
        if device.platform == "ios"  or  device.platform == "android" then
            locationBtn:setVisible(false)
        end
    end

    if SHENHEBAO then
        locationBtn:setVisible(false)
    end

    local roomRuleBtn = self.normalbtn:getChildByName("roomRuleBtn")
    WidgetUtils.addClickEvent(roomRuleBtn, function()



        self:openRoomRuleView()
         -- self.gamescene.mytable:showActionImg("action_deng")
         -- self.gamescene.mytable.actionview:showHiddenBtn()

    end )

end

function GameUILayer:initPaiJuView()
    self.paijuNode:getChildByName("paizuo"):setVisible(false)
    self.clock = self.gamescene.layout:getChildByName("clock"):setVisible(false)

    self.leaveTime = self.clock:getChildByName("leavetime")

    self.fanPaiNode = self.paijuNode:getChildByName("fanpai_node")
    self.fanPaiNode:setPositionY(111)

    if self.gamescene.name == "RecordScene" and (self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2) then
        self.paijuNode:getChildByName("paizuo"):setPositionY(0)
        self.logo:setPositionY(390)
    end

end
function GameUILayer:waitGameStart()
    self.paijuNode:getChildByName("paizuo"):setVisible(false)
    self.clock:setVisible(false)
    self.readyNode:setVisible(true)
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
    if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
        self.net = self.topbg1:getChildByName("net")
    end
    local dianliang
    if  self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
        dianliang = WidgetUtils.getNodeByWay(self.topbg1, { "dian", "bar" })
    else
        dianliang = WidgetUtils.getNodeByWay(self.topbg, { "dian", "bar" })
    end
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
    if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
        self.topbg1:setVisible(true)
    end

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
    self.paijuNode:getChildByName("paizuo"):setVisible(true)
    self.readyNode:setVisible(false)

end

function GameUILayer:hidePlayingInfo()
    self.paijuNode:getChildByName("paizuo"):setVisible(false)
    self.paijuNode:getChildByName("clock"):setVisible(false)
end
function GameUILayer:setJiangCard(card)

    if card == nil or card == 0  then
        if self.jiangCard ~= nil then
            self.jiangCard:setVisible(false)
            self.jiangCard:removeFromParent()
            self.jiangCard = nil
        end
        return
    end

    if self.jiangCard == nil then
        
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.LFSDR then
            local two = card % 16
            if two == 1 then
                card = card + 2
            else
                card = card - 1
            end
        end
        local _card = LongCard.new(CARDTYPE.ONTABLE, card)
        _card:setPosition(cc.p(210,28))
        self.paijuNode:getChildByName("paizuo"):addChild(_card)

        if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.LFSDR then
            _card:showJiang()
        end
        self.jiangCard = _card
    end
end

function GameUILayer:setJokerCard(card)

    print("......设置癞子   card ＝ ",card)
    if card == nil or card == 0  then
        if self.jokerCard ~= nil then
            self.jokerCard:setVisible(false)
            self.jokerCard:removeFromParent()
            self.jokerCard = nil
        end
        return
    end
  
    if self.jokerCard == nil then
        
        local _card = LongCard.new(CARDTYPE.ONTABLE, card)
        _card:setPosition(cc.p(260,28))
        self.paijuNode:getChildByName("paizuo"):addChild(_card)
        _card:showJoker()
        
        self.jokerCard = _card
    end
end



function GameUILayer:refreshInfoNode()
    local resttilenum = self.paijuNode:getChildByName("paizuo"):getChildByName("cardnum")
    local card_num = self.gamescene:getRestTileNum()
    resttilenum:setString(card_num)  
    resttilenum:setVisible(true)
    -- print("refreshInfoNode:"..card_num)
    -- printTable(self.gamescene.table_info,"ssssss")
    if  card_num == 0 then
        resttilenum:setVisible(false)
    else
        local leaveCard = self.paijuNode:getChildByName("paizuo"):getChildByName("leaveCard")
        leaveCard:removeAllChildren()
        if card_num > 24  then
            card_num = 24
        end

        if card_num > 0 then
            for i=1,card_num-1 do
                local newCard = ccui.ImageView:create(leaveCard.img)
                newCard:setAnchorPoint(cc.p(0,0))
                newCard:setPosition(cc.p(0,i*1))
                leaveCard:addChild(newCard)
            end
            resttilenum:setPositionY(35+card_num-1)
            if self.gamescene.name == "RecordScene" and (self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2) then
                self.fanPaiNode:setPositionY(0+card_num-1)
            else
                self.fanPaiNode:setPositionY(111+card_num-1) 
            end      
        end
    end
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
    self.clock:setVisible(true)

    local _node = self.gamescene.tablelist[index + 1].node
    local worldpos = _node:convertToWorldSpace(cc.p(_node:getChildByName("clocknode"):getPosition()))
    local spacepos = self.gamescene.layout:convertToNodeSpace(worldpos)
    self.clock:setPosition(spacepos)

    self.leaveTime:stopAllActions()
    local timelast = 20
    self.leaveTime:setString(tostring(timelast))
    self.leaveTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function(...)
        timelast = timelast - 1
        if timelast < 0 then
            timelast = 0
        end
        if timelast < 5 and timelast > 0 then
            AudioUtils.playEffect("tick")
        end
        self.leaveTime:setString(tostring(timelast))
    end ))))
end

function GameUILayer:getFanPanWorldPos()
    local _x, _y = self.fanPaiNode:getPosition()
    local worldpos1 = self.paijuNode:convertToWorldSpace(cc.p(_x, _y))
    return worldpos1
end
-- 背景 根据设置选择及时更换
function GameUILayer:setbgstype(bg_type)
    -- bg_type_new 牌型摆法
    print("bg_type:"..bg_type)
 

    if  GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype) == STYLETYPE.Poker then
        self.bg:loadTexture("game/xj_bg_"..bg_type..".jpg",ccui.TextureResType.localType)
    else
        self.bg:loadTexture("game/bg_bg_" .. bg_type .. ".jpg", ccui.TextureResType.localType)
    end


    self.logo:setTexture("game/bg_logo/bg_logo_" .. self.gamescene:getTableConf().ttype .. "_" .. bg_type .. ".png")

    local paidui = self.paijuNode:getChildByName("paizuo"):getChildByName("leaveCard")
    if bg_type == 1 then
        paidui:loadTexture("game/bg_paidui_1.png", ccui.TextureResType.localType)
        paidui.img = "game/bg_paidui_1.png"
        self.topbg:loadTexture("game/bg_topbg_1.png", ccui.TextureResType.localType)
        if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
            self.topbg1:loadTexture("game/bg_topbg_1.png", ccui.TextureResType.localType)
        end

    elseif bg_type == 2 then
        paidui:loadTexture("game/bg_paidui_2.png", ccui.TextureResType.localType)
        paidui.img = "game/bg_paidui_2.png"
        self.topbg:loadTexture("game/bg_topbg_2.png", ccui.TextureResType.localType)
        if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
            self.topbg1:loadTexture("game/bg_topbg_2.png", ccui.TextureResType.localType)
        end

    elseif bg_type == 3 then
        -- 因为第三种和第一种都为黄色，logo，paidui 是一样的
        paidui:loadTexture("game/bg_paidui_1.png", ccui.TextureResType.localType)
        paidui.img = "game/bg_paidui_1.png"
        self.topbg:loadTexture("game/bg_topbg_3.png", ccui.TextureResType.localType)
        if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
            self.topbg1:loadTexture("game/bg_topbg_3.png", ccui.TextureResType.localType)
        end

    elseif bg_type == 4 then
        -- 因为第四种和第二种都为绿色，，paidui 是一样的
        paidui:loadTexture("game/bg_paidui_2.png", ccui.TextureResType.localType)
        paidui.img = "game/bg_paidui_2.png"
        self.topbg:loadTexture("game/bg_topbg_3.png", ccui.TextureResType.localType)
        if self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2 then
            self.topbg1:loadTexture("game/bg_topbg_3.png", ccui.TextureResType.localType)
        end
    end
   
    self:refreshInfoNode()
    if (self.gamescene:getTableConf().seat_num == 4 or self.gamescene:getTableConf().seat_num == 2) and self.gamescene.name == "RecordScene" then
        if (bg_type == 3 or bg_type == 4) then
            self.logo:setPositionY(390)
            self.paijuNode:setPositionY(330)
        else
            self.logo:setPositionY(408)
            self.paijuNode:setPositionY(360.00)
        end
    end

end

return GameUILayer