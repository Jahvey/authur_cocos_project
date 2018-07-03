require "app.help.WidgetUtils"
local LongCard = require "app.ui.game.base.LongCard"
local PICWIDTH = 200



local ActionView = class("ActionView", function()
    return cc.Node:create()
end )

function ActionView:ctor(gamescene)
    self.gamescene = gamescene

    self.ACTIONCONF = 
    {
        [poker_common_pb.EN_SDR_ACTION_HUPAI] = { sort = 1, img = "game/btn_hu.png" },
        [poker_common_pb.EN_SDR_ACTION_CHI] = { sort = 2, img = "game/btn_di.png" },
        [poker_common_pb.EN_SDR_ACTION_WAI] = { sort = 2, img = "game/btn_wai.png" },
        [poker_common_pb.EN_SDR_ACTION_PASS] = { sort = 7, img = "game/btn_guo.png" },

        [poker_common_pb.EN_SDR_ACTION_PENG] = { sort = 2, img = "game/btn_peng.png" },

        [poker_common_pb.EN_SDR_ACTION_DENG] = { sort = 2, img = "game/btn_deng.png" },
        [poker_common_pb.EN_SDR_ACTION_ZHAO] = { sort = 2, img = "game/btn_zhao.png" },
        [poker_common_pb.EN_SDR_ACTION_KOU] = { sort = 2, img = "game/btn_qi.png" },
        [poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG] = { sort = 2, img = "game/btn_jie.png" },

        [poker_common_pb.EN_SDR_ACTION_TIAN] = { sort = 2, img = "game/btn_tian.png" },--填
        [poker_common_pb.EN_SDR_ACTION_MAI] = { sort = 2, img = "game/btn_mai.png" },--卖赖子
    }

    self.huazhuangsrc = "game/btn_guo.png"

    self.btnNode = cc.Node:create()
    self:addChild(self.btnNode)
    self:setVisible(false)
    self.btnNode:setPositionY(-35)

    self.selectNode = cc.Node:create()
    self:addChild(self.selectNode)
    self.selectNode:setVisible(false)
    self.selectNode.btn = nil

    self:init()

    self.hiddenBtn = ccui.Button:create("game/button_yinchang.png")
        :addTo(self)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPosition(cc.p(585,-30))

    self.hiddenBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理
            self.btnNode:setVisible(false)
            self.selectNode:setVisible(false)
        end
       
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            self.btnNode:setVisible(true)
            self.selectNode:setVisible(true)
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理zim
            self.btnNode:setVisible(true)
            self.selectNode:setVisible(true)
        end
        
        -- if eventType == ccui.TouchEventType.moved then    --按钮 触摸移动事件处理
        -- end
    end)
end

function ActionView:init()


end

function ActionView:showHiddenBtn()
    self.hiddenBtn:setVisible(true)

    local move_1 = cc.MoveTo:create(0.1, cc.p(580, -30))
    local move_2 = cc.MoveTo:create(0.05, cc.p(587, -30))
    local move_3 = cc.MoveTo:create(0.02, cc.p(585, -30))
    self.hiddenBtn:runAction(cc.Sequence:create(move_1, move_2, move_3))
end


function ActionView:getIsShow()
    return self:isVisible()
end

function ActionView:showAction(choices)
    -- print("..........ActionView:showAction(")
    -- printTable(choices, "xp")

    self:showHiddenBtn()

    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = "game/btn_guo.png"

    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.btnNode:removeAllChildren()
    

    local choices = clone(choices)

    for i = #choices, 1, -1 do
        if not self.ACTIONCONF[choices[i].act_type] then
            table.remove(choices, i)
        end
    end

    if #choices == 0 then
        return
    end

    ------------整合
    local choicesList = { }
    for k, v in pairs(choices) do
        if not choicesList[v.act_type] then
            local _list = { num = 1, act_type = v.act_type, list = { v } }
            choicesList[v.act_type] = _list
        else
            choicesList[v.act_type].num = choicesList[v.act_type].num + 1
            table.insert(choicesList[v.act_type].list, v)
        end
    end

    local endList = { }
    for k, v in pairs(choicesList) do
        table.insert(endList, v)
    end

    table.sort(endList, function(a, b)
        return self.ACTIONCONF[a.act_type].sort > self.ACTIONCONF[b.act_type].sort
    end )
    ------------整合结束
    -- print("..........ActionView: endList ")
    -- printTable(endList, "xp")
    -- 是否有选择坐庄
    for i, v in ipairs(endList) do
        if v.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG then
            self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = self.huazhuangsrc
            break
        end
    end

    self:setVisible(true)
    self.btnNode:removeAllChildren()
    local half =(#endList + 1) / 2.0

    local btnList = { }
    for i, v in ipairs(endList) do

        local btn = ccui.Button:create(self.ACTIONCONF[v.act_type].img)
        :addTo(self.btnNode)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPositionX((half - i) * PICWIDTH)
        :setTag(i)

        v.btn = btn

        table.insert(btnList, btn)
        WidgetUtils.addClickEvent(btn, function()
            self:commonAction(v)
        end )
    end
end


function ActionView:hide()
    self:setVisible(false)
    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.hiddenBtn:setVisible(false)
    self.hiddenBtn:runAction(cc.MoveTo:create(0.01, cc.p(695, -30)))
end

function ActionView:getIsOnlyChoice(data)
     if  data.act_type == poker_common_pb.EN_SDR_ACTION_PASS 
        or data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI 
        or data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG
        or data.act_type == poker_common_pb.EN_SDR_ACTION_KOU --弃
        or data.act_type == poker_common_pb.EN_SDR_ACTION_DA  -- 打
        or data.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA  -- 下抓
        then
        return true
    end
    return false
end

function ActionView:sendAction(_tab)

    self:hide()

    local _index = _tab.seat_index
    local _type = _tab.act_type
    local _card = _tab.dest_card
    local _cards = _tab.col_info and _tab.col_info.cards
    local _token = _tab.action_token
    local _choice_token = _tab.choice_token
    
    Socketapi.request_do_action(_index, _type, _card, _cards, _token, _choice_token)
end

-- 生成某操作下的选择界面
function ActionView:commonAction(data)



    if #data.list == 1 then
        self:sendAction(data.list[1])
    else
        if self.selectNode.btn and data.btn == self.selectNode.btn then
            self.selectNode:removeAllChildren()
            self.selectNode:setVisible(false)
            self.selectNode.btn = nil
            return
        end

        self.selectNode:removeAllChildren()
        self.selectNode:setVisible(true)

        self.selectNode.btn = data.btn

        local mac_cards_num = 0
        for i, v in ipairs(data.list) do
            if mac_cards_num < #v.col_info.cards then
                mac_cards_num = #v.col_info.cards
            end
        end
        -- 生成背景--11项的话，就换成两排
        local bg = ccui.ImageView:create("game/action_bg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(30, 30, 44, 44))
        :setAnchorPoint(cc.p(0.5, 0))
        bg:setLocalZOrder(-1)
        bg:setContentSize(cc.size(56 + 44 + 92 *(data.num - 1), 76 + 76 +(mac_cards_num - 1) * 32))
        self.selectNode:addChild(bg)

        local jiantou = ccui.ImageView:create("game/action_arrow.png")
        jiantou:setAnchorPoint(cc.p(0.5, 1))
        jiantou:setPositionX(bg:getContentSize().width / 2.0)
        bg:addChild(jiantou)

        -- 生成选择项
        for i, v in ipairs(data.list) do
            local node = self:createSelectNode(v)
            node:setPositionX(28 + 22 +(i - 1) * 92)
            node:setPositionY(bg:getContentSize().height / 2.0)
            bg:addChild(node)
        end

        local _x, _y = data.btn:getPosition()
        self.selectNode:setPosition(cc.p(_x, _y + 75 + self.btnNode:getPositionY()))
    end
end

-- 生成某操作下的选择项
function ActionView:createSelectNode(_tab)
    print("........生成某操作下的选择项")
    printTable(_tab, "xp")

    local node = cc.Node:create()
    local btn = ccui.Button:create("common/null.png", "game/action_btn_bg.png", "common/null.png", ccui.TextureResType.localType)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(50, 76 +(#_tab.col_info.cards - 1) * 32))
    btn:setPositionX(0)
    btn:setPositionY(0)

    WidgetUtils.addClickEvent(btn, function()
        self:sendAction(_tab)
    end )
    node:addChild(btn)

     --生成牌
    for i, v in ipairs(_tab.col_info.cards) do
        local pai = LongCard.new(CARDTYPE.MYHAND, v)
        pai:setAnchorPoint(cc.p(0.5, 0.5))
        pai:setPositionX(0)
        pai:setScale(0.5)

        print("....=",(((#_tab.col_info.cards) + 1) / 2.0) - i)

        pai:setPositionY(((#_tab.col_info.cards + 1) / 2.0 - i) * 32)
        -- 牌的高度+上下距离
        pai:addTo(node)

        if self.gamescene:getIsJiangCard(v) then
            pai:showJiang()
        end
        if self.gamescene:getIsJokerCard(v) then
            pai:showJoker()
        end
    end



    return node
end


return ActionView