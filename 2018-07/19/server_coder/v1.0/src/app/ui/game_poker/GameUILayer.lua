local GameUILayer = class("GameUILayer", require("app.ui.game.base.GameUILayer"))

function GameUILayer:initView()
    
    -- if self.gamescene:getTableConf().seat_num == 4 then
    --     self.node = cc.CSLoader:createNode("ui/game/gameUInewforfour.csb")
    -- else
    --     self.node = cc.CSLoader:createNode("ui/game/gameUInew.csb")
    -- end
    self.node = cc.CSLoader:createNode("ui/gamexj/gameUI.csb")
 
    self.node:addTo(self)

    WidgetUtils.setScalepos(self.node)

    self.bg = self.node:getChildByName("bg")
    WidgetUtils.setBgScale(self.bg)

    self.mainUi = self.node:getChildByName("main")
    WidgetUtils.setScalepos(self.mainUi)

    self.logo = self.mainUi:getChildByName("Logo"):ignoreContentAdaptWithSize(true)

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
    -- self.topbg1 = self.normalbtn:getChildByName("topbg1")

    self.topbg:setPositionY(display.height / 2 - 8)
    -- if self.gamescene:getTableConf().seat_num == 4  then
    --     self.topbg1:setPositionY(display.height / 2 - 8)
    -- end

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

    local tips_label = cc.Label:createWithSystemFont("仅供娱乐，禁止赌博", FONTNAME_DEF, 18)
    tips_label:setTextColor( cc.c3b( 0x00, 0x00, 0x00))
    tips_label:setOpacity(255*0.5)
    tips_label:setPosition( cc.p(self.logo:getPositionX(), self.logo:getPositionY()-23))
    tips_label:setLocalZOrder(-1)
    self.mainUi:addChild(tips_label)
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
    -- if self.gamescene:getTableConf().seat_num == 4 then
    --     self.net = self.topbg1:getChildByName("net")
    -- end
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
    -- if self.gamescene:getTableConf().seat_num == 4 then
    --     self.topbg1:setVisible(true)
    -- end

end


-- 背景 根据设置选择及时更换
function GameUILayer:setbgstype(bg_type)
	if bg_type> 2 then
		bg_type = 1
	end
	self.bg:loadTexture("game/xj_bg_"..bg_type..".jpg",ccui.TextureResType.localType)
	self.logo:loadTexture("game/bg_logo/bg_logo_"..LocalData_instance:getGameType().."_"..bg_type..".png",ccui.TextureResType.localType)
end

return GameUILayer