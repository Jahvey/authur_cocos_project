
local ActionView = class("ActionView", require "app.ui.game.ActionView")
local LongCard = require "app.ui.game.base.LongCard"
local PICWIDTH = 200
function ActionView:init()
    --wai  和 chi  都叫吃
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI]= { sort = 2, img = "game/btn_chi.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHAO]= { sort = 2, img = "game/btn_maozhao.png" }

    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIAN]= { sort = 2, img = "game/btn_jian.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_HUA]= { sort = 2, img = "game/btn_hua.png" }  
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_AN_GANG]= { sort = 2, img = "game/btn_guan.png" }  
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_GANG]= { sort = 2, img = "game/btn_zhao.png"  } 
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHUA]= { sort = 2, img = "game/btn_zhua.png" }  
end
function ActionView:showAction(choices)
    print("..........ActionView:showAction(")
    printTable(choices, "xp24")

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
    print("..........ActionView: endList ")
    printTable(endList, "xp11")

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


-- 生成某操作下的选择界面
function ActionView:commonAction(data)

    print("...........生成某操作下的选择界面")
    printTable(data,"xp65")

    if #data.list == 1 or data.act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG then
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
        if  data.act_type ~= poker_common_pb.EN_SDR_ACTION_CHU  then
            for i, v in ipairs(data.list) do
                if mac_cards_num < #v.col_info.cards then
                    mac_cards_num = #v.col_info.cards
                end
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


    local card_num = 1
    if  _tab.act_type ~= poker_common_pb.EN_SDR_ACTION_CHU  then
        card_num = #_tab.col_info.cards
    end

    local node = cc.Node:create()
    local btn = ccui.Button:create("common/null.png", "game/action_btn_bg.png", "common/null.png", ccui.TextureResType.localType)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(50, 76 +(card_num - 1) * 32))
    btn:setPositionX(0)
    btn:setPositionY(0)

    WidgetUtils.addClickEvent(btn, function()
        self:sendAction(_tab)
    end )
    node:addChild(btn)



    if  _tab.act_type ~= poker_common_pb.EN_SDR_ACTION_CHU  then
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
    else

        -- -- 生成选择项
        -- for i=1,5 do
        local btnstr = "game/piaobtn/piao_yellow_".._tab.dest_card..".png"
        local btn = ccui.Button:create(btnstr, btnstr, btnstr, ccui.TextureResType.localType)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:setScale9Enabled(true)
        btn:setPositionX(0)

        WidgetUtils.addClickEvent(btn, function()
            -- self:requestPiao(i)
            self:sendAction(_tab)

        end )
        node:addChild(btn)
    end




    return node
end


-- EN_SDR_ACTION_CHU

return ActionView