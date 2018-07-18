-- 公用UI
local GameUILayer = class("GameUILayer", function()
    return cc.Node:create()
end )

function GameUILayer:ctor(gamescene)
    self.gamescene = gamescene
    self:initView()
end

function GameUILayer:initView()
    
    self.node = cc.CSLoader:createNode("ui/ddz/gameUI.csb")
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
    self.topbg:setPositionY(display.height / 2 - 8)

    self.waitnode:setVisible(false)

    -- 邀请按钮
    self.invitebtn = self.readyNode:getChildByName("invitebtn")
    WidgetUtils.addClickEvent(self.invitebtn, function()
        -- CommonUtils:prompt("暂未开放，敬请期待", CommonUtils.TYPE_CENTER)
        CommonUtils.sharedesk(self.gamescene:getTableID(), GT_INSTANCE:getTableDes(self.gamescene:getTableConf(), 2),self.gamescene:getTableConf().ttype)
    end )



    local function btncall(bool, isMingPai)
        local index = self.gamescene:getMyIndex()
        if index then
            print("index _位子")
            Socketapi.request_ready(bool, isMingPai)
        else
            print("没有找到自己的位子")
        end
    end
    -- 准备和取消准备
    self.readybtn = self.readyNode:getChildByName("readybtn")
    WidgetUtils.addClickEvent(self.readybtn, function()
        btncall(true, false)
    end )

    self.cancelbtn = self.readyNode:getChildByName("cancelbtn")
    WidgetUtils.addClickEvent(self.cancelbtn, function()
        btncall(false, false)
    end )

    -- 明牌开始按钮
    self._mingPaiReadyBtn = self.readyNode:getChildByName("Button_MingPai_Start")
    WidgetUtils.addClickEvent(self._mingPaiReadyBtn, function()
        btncall(true, true)
    end )
    self._mingPaiReadyBtn:setVisible(self.gamescene:getMingPai())

    if (self.gamescene:getMingPai()) then
        self._readyBtnInitX = self.readybtn:getPositionX()
        self._readyBtnDestX = self._readyBtnInitX + 100
        self._inviteBtnInitX = self.invitebtn:getPositionX()
        self._inviteBtnDestX = self._inviteBtnInitX - 100

        self.readybtn:setPositionX(self._readyBtnDestX)
        self.invitebtn:setPositionX(self._inviteBtnDestX)
    end

    self:initNormalBtn()
    self:initPaiJuView()

    local tips_label = cc.Label:createWithSystemFont("仅供娱乐，禁止赌博", FONTNAME_DEF, 18)
    tips_label:setTextColor( cc.c3b( 0x00, 0x00, 0x00))
    tips_label:setOpacity(255*0.5)
    tips_label:setPosition( cc.p(self.logo:getPositionX(), self.logo:getPositionY()+45))
    tips_label:setLocalZOrder(-1)
    self.mainUi:addChild(tips_label)
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
        -- LaypopManger_instance:PopBox("ChatView")
         -- self.gamescene.tablelist[1]:buyOrSellPaiAction()
         -- self.gamescene.mTestCard:setVisible(true)
        if device.platform ~= "ios"  and device.platform ~= "android" then
            LaypopManger_instance:PopBox("TestCard",self.gamescene)
        else
            LaypopManger_instance:PopBox("ChatView",self.gamescene)
        end
    end )

    local locationBtn = self.normalbtn:getChildByName("locationBtn")
    WidgetUtils.addClickEvent(locationBtn, function()
        if device.platform ~= "ios"  and  device.platform ~= "android"  then
            SocketConnect_instance.socket:close()
        else
            self:openDistanceView(true)
        end
    end )
    if SHENHEBAO then
        locationBtn:setVisible(false)
    end

    local roomRuleBtn = self.normalbtn:getChildByName("roomRuleBtn")
    WidgetUtils.addClickEvent(roomRuleBtn, function()
        self:openRoomRuleView()
        -- self.gamescene.mytable:showBaoZiDIZhu(true)
    end )
end

function GameUILayer:initPaiJuView()
    -- if LocalData_instance:getbaipai_stype() == 2 then
    --     self.clock = self.gamescene.layout:getChildByName("clock"):setVisible(false)
    -- else
    --     self.clock = self.paijuNode:getChildByName("clock"):setVisible(false)
    -- end
    self.clock = self.paijuNode:getChildByName("clock"):setVisible(false)
    self.leaveTime = self.clock:getChildByName("leavetime")

    self.fanPaiNode = self.paijuNode:getChildByName("fanpai_node")
    self.fanPaiNode:setPositionY(111)
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
    print("设置房间号")
    roomid:setString("房号:" ..(tableid or ""))

    local timeinfo = self.topbg:getChildByName("time")
    timeinfo:stopAllActions()
    timeinfo:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create( function()
        local date = os.date("%X")
        timeinfo:setString(date)
    end ), cc.DelayTime:create(1))))

    self.net = self.topbg:getChildByName("net")
    local dianliang = WidgetUtils.getNodeByWay(self.topbg, { "dian", "bar" })
   
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

    if (self.gamescene:getMingPai()) then
        if (self.readybtn:isVisible()) then
            self.readybtn:setPositionX(self._readyBtnDestX)
            self.invitebtn:setPositionX(self._inviteBtnDestX)
            self._mingPaiReadyBtn:setVisible(true)
        else
            self.readybtn:setPositionX(self._readyBtnInitX)
            self.invitebtn:setPositionX(self._inviteBtnInitX)
            self._mingPaiReadyBtn:setVisible(false)
        end
    end

    if self.gamescene:getNowRound() ~= 0 then
        self.invitebtn:setVisible(false)
        self.normalbtn:getChildByName("backbtn"):setVisible(false)
       
        self.readybtn:setPositionX(0)
        self.cancelbtn:setPositionX(0)

        if (self.gamescene:getMingPai()) then
            if (self.readybtn:isVisible()) then
                self._mingPaiReadyBtn:setVisible(true)
                self._mingPaiReadyBtn:setPositionX(self._inviteBtnInitX)
                self.readybtn:setPositionX(self._readyBtnInitX)
                self.cancelbtn:setPositionX(self._readyBtnInitX)
            else
                self.readybtn:setPositionX(0)
                self.cancelbtn:setPositionX(0)
                self._mingPaiReadyBtn:setVisible(false)
            end
        end

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

function GameUILayer:refreshInfoNode()
    --print("-------ssss:"..self)
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
        self.clock:setVisible(false)
        self.leaveTime:stopAllActions()
        return
    end
    self.clock:setVisible(true)

    -- 明牌（经典斗地主）不显示倒计时
    if self.gamescene:getMingPai() then
        self.clock:setVisible(false)
    end

    local _node = self.gamescene.tablelist[index + 1].node
    local worldpos = _node:convertToWorldSpace(cc.p(_node:getChildByName("clocknode"):getPosition()))
    -- if LocalData_instance:getbaipai_stype() == 2 then
    --     local spacepos = self.gamescene.layout:convertToNodeSpace(worldpos)
    --     self.clock:setPosition(spacepos)
    -- else
        local spacepos = self.paijuNode:convertToNodeSpace(worldpos)
        self.clock:setPosition(spacepos)
    --end


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

function GameUILayer:waitGameStart()
    -- self.paijuNode:getChildByName("paizuo"):setVisible(false)
    self.clock:setVisible(false)
    self.readyNode:setVisible(true)
end


function GameUILayer:getFanPanWorldPos()
    local _x, _y = self.fanPaiNode:getPosition()
    local worldpos1 = self.paijuNode:convertToWorldSpace(cc.p(_x, _y))
    return worldpos1
end
-- 背景 根据设置选择及时更换
function GameUILayer:setbgstype(bg_type)
    bg_type = bg_type or 1
    if  GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype)  == STYLETYPE.Poker then
        self.bg:loadTexture("game/xj_bg_"..bg_type..".jpg",ccui.TextureResType.localType)
    else
        self.bg:loadTexture("game/bg_bg_" .. bg_type .. ".jpg", ccui.TextureResType.localType)
    end

    self.logo:setTexture("game/bg_logo/bg_logo_" .. self.gamescene:getTableConf().ttype .. "_" .. bg_type .. ".png")

end

return GameUILayer