require "app.help.WidgetUtils"
local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
local PICWIDTH = 180


local ActionView = class("ActionView", function()
    return cc.Node:create()
end )

function ActionView:ctor(gamescene)
    self.gamescene = gamescene

    self.ACTIONCONF = 
    {
        [poker_common_pb.EN_SDR_ACTION_HUPAI] = { sort = 1, img = "gamemj/btn_mj_hu.png" },
        [poker_common_pb.EN_SDR_ACTION_CHI] = { sort = 2, img = "gamemj/btn_mj_chi.png" },
        [poker_common_pb.EN_SDR_ACTION_PASS] = { sort = 7, img = "gamemj/btn_mj_pass.png" },
        [poker_common_pb.EN_SDR_ACTION_PENG] = { sort = 2, img = "gamemj/btn_mj_peng.png" },
        [poker_common_pb.EN_SDR_ACTION_GANG] = { sort = 2, img = "gamemj/btn_mj_gang.png" },
        [poker_common_pb.EN_SDR_ACTION_GANG_2] = { sort = 2, img = "gamemj/btn_mj_gang.png" },

        [poker_common_pb.EN_SDR_ACTION_AN_GANG] = { sort = 2, img = "gamemj/btn_mj_gang.png" },

        -- [poker_common_pb.EN_SDR_ACTION_TIAN] = { sort = 2, img = "game/btn_tian.png" },--填
        -- [poker_common_pb.EN_SDR_ACTION_MAI] = { sort = 2, img = "game/btn_mai.png" },--卖赖子
    }

    self.huazhuangsrc = "gamemj/btn_mj_pass.png"

    self.btnNode = cc.Node:create()
    self:addChild(self.btnNode)
    self:setVisible(false)
    self.btnNode:setPositionY(-160)
    self.btnNode:setPositionX(450)

    self.selectNode = cc.Node:create()
    self:addChild(self.selectNode)
    self.selectNode:setVisible(false)
    self.selectNode.btn = nil

    self.selectNode:setPositionY(-160)
    self.selectNode:setPositionX(450)

    self:init()
end

function ActionView:init()


end


function ActionView:getIsShow()
    return self:isVisible()
end

function ActionView:showAction(choices)
    print("..........ActionView:showAction(")
    printTable(choices, "xp70")

    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.btnNode:removeAllChildren()    

    local choices = clone(choices)
    for i = #choices, 1, -1 do
        if not self.ACTIONCONF[choices[i].act_type] then
            table.remove(choices, i)
        end

        --把杠和暗杠，癞子杠合并 在一起显示成杠
        if choices[i].act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG  then
            choices[i].act_type = poker_common_pb.EN_SDR_ACTION_GANG
            choices[i].real_type = poker_common_pb.EN_SDR_ACTION_AN_GANG
        end

        if choices[i].act_type == poker_common_pb.EN_SDR_ACTION_GANG_2  then
            choices[i].act_type = poker_common_pb.EN_SDR_ACTION_GANG
            choices[i].real_type = poker_common_pb.EN_SDR_ACTION_GANG_2
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
        return self.ACTIONCONF[a.act_type].sort < self.ACTIONCONF[b.act_type].sort
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
    self.btnNode:setVisible(true)

    local btnList = { }

    local pos_x = -PICWIDTH
    for i=#endList,1,-1 do
        
        local v = endList[i]
        local btn = ccui.Button:create(self.ACTIONCONF[v.act_type].img)
        :addTo(self.btnNode)
        :setAnchorPoint(cc.p(0.5, 0.5))
        -- :setPositionX((1-i) * PICWIDTH)
        :setPositionX(-pos_x)
        :setTag(i)

        v.btn = btn

        table.insert(btnList, btn)
     
        local btncall = function()
            self:commonAction(v)
        end
        WidgetUtils.addClickEvent(btn,btncall)
      
        local valuema = nil
        if v.act_type == poker_common_pb.EN_SDR_ACTION_CHI then
            -- if #v.list == 1 then
                valuema = v.list[1].dest_card
            -- end
        elseif v.act_type == poker_common_pb.EN_SDR_ACTION_GANG then
            if #v.list == 1 then
                valuema = v.list[1].dest_card
            end
        end

        if valuema then
            local ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,valuema)
            ma:setAnchorPoint(cc.p(0,0))
            ma:setScale(62/85)
            btn:addChild(ma)

            if self.gamescene:getIsJokerCard(valuema) then
                ma:showJoker()
            end

            if self.gamescene:getIsPiziCard(valuema) then
                ma:showPizi()
            end

            local btn1= WidgetUtils.createnullBtn(cc.size(ma:getSizeforma().width,ma:getSizeforma().height+20))
            btn1:setAnchorPoint(cc.p(0,0))
            ma:addChild(btn1)
            WidgetUtils.addClickEvent(btn1,btncall)

            ma:setPosition(cc.p(btn:getContentSize().width+10,0))

            pos_x = pos_x + PICWIDTH + 62
        else
            pos_x = pos_x + PICWIDTH
        end
        btn:setPositionX(-pos_x)
    end
end


function ActionView:hide()
    self:setVisible(false)
    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil
end

function ActionView:getIsOnlyChoice(data)
     if  data.act_type == poker_common_pb.EN_SDR_ACTION_PASS 
        or data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI 
        or data.act_type == poker_common_pb.EN_SDR_ACTION_PENG 
        then
        return true
    end
    return false
end

function ActionView:sendAction(_tab)

    print(".......sendAction")
    printTable(_tab,"xp69")
    self:hide()

    local _index = _tab.seat_index
    local _type = _tab.real_type or _tab.act_type
    local _card = _tab.dest_card
    local _cards = _tab.col_info and _tab.col_info.cards
    local _token = _tab.action_token
    local _choice_token = _tab.choice_token
    
    Socketapi.request_do_action(_index, _type, _card, _cards, _token, _choice_token)
end

-- 生成某操作下的选择界面
function ActionView:commonAction(data)

    if self:getIsOnlyChoice(data) then
        self:sendAction(data.list[1])
    else

        if #data.list == 1 then
            self:sendAction(data.list[1])
            return
        end

        -- if self.selectNode.btn and data.btn == self.selectNode.btn then
        --     self.selectNode:removeAllChildren()
        --     self.selectNode:setVisible(false)
        --     self.selectNode.btn = nil
        --     return
        -- end

        self.selectNode:removeAllChildren()
        self.selectNode:setVisible(true)
        self.btnNode:setVisible(false)

        self.selectNode.btn = data.btn

        local totall = #data.list
        --取消杠牌
        local btn = ccui.Button:create("gamemj/btn_mj_xiao.png","gamemj/btn_mj_xiao.png", "gamemj/btn_mj_xiao.png", ccui.TextureResType.localType)
         WidgetUtils.addClickEvent(btn, function()
            self.btnNode:setVisible(true)
            self.selectNode:setVisible(false)
        end)
        self.selectNode:addChild(btn)

        local jiange = 98
        --68位 消与牌的间距  3位杠与杠的间距
        --高间隔 120
        for i,v in ipairs(data.list) do
            local node  = self:createSelectNode(v) 
            node:setPositionX(0-(i-1)%4*(161+3) - 68)
            node:setPositionY(math.floor((i-1)/4)*88 -50)
            self.selectNode:addChild(node)
        end

        local bg = ccui.ImageView:create("gamemj/action_bg.png")
            :setScale9Enabled(true)
            :setCapInsets(cc.rect(8, 8, 8,8))
            :setAnchorPoint(cc.p(1,0))
        bg:setLocalZOrder(-1)
        bg:setPositionX(0-(68-5))
        bg:setPositionY(-50-5)
        if totall >4 then
            bg:setContentSize(cc.size((161+3)*4+80,(math.floor((totall-1)/4)+1)*88+8))
        else
            bg:setContentSize(cc.size((161+3)*(totall)+80,(1)*88+8))
        end

        local tips = 
        {
            [poker_common_pb.EN_SDR_ACTION_CHI] = "gamemj/action_chi.png",
            [poker_common_pb.EN_SDR_ACTION_PENG] = "gamemj/action_peng.png",
            [poker_common_pb.EN_SDR_ACTION_GANG] = "gamemj/action_gang.png",
            -- [poker_common_pb.EN_SDR_ACTION_AN_GANG] = "gamemj/action_gang.png",
            -- [poker_common_pb.EN_SDR_ACTION_GANG_2] = "gamemj/action_gang.png",
        }

        local tip = cc.Sprite:create(tips[data.act_type])
        tip:setPosition(cc.p(40,bg:getContentSize().height-40))
        bg:addChild(tip)
        self.selectNode:addChild(bg)

    end
end

-- 生成某操作下的选择项
function ActionView:createSelectNode(tab)
    print(".............")
    printTable(tab,"xp10")

    local cards = clone(tab.col_info.cards)

    if  tab.act_type == poker_common_pb.EN_SDR_ACTION_CHI  then
        print("........吃的牌！！")
        printTable(tab,"xp10")
        for _k,_v in pairs(cards) do
            if _v == tab.dest_card  then
                table.remove(cards,_k)
            end
        end
        table.insert(cards,2,tab.dest_card)
        printTable(tab,"xp10")
    end
    -- table.sort(tab.col_info.cards, function(a, b)
    --     return a > b
    -- end)

    local node =  cc.Node:create()
    for i,v in ipairs(cards) do
        if tab.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG and i == 4 then
            v = 0
        end

        local ma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,v)
        ma:setAnchorPoint(cc.p(0,0))
        ma:setPositionX((i-1)*55 - 160)
        node:addChild(ma)

        if self.gamescene:getIsJokerCard(v) then
            ma:showJoker()
        end

        if self.gamescene:getIsPiziCard(v) then
            ma:showPizi()
        end

        if  tab.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or tab.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
            if i == 4 then
                ma:setPosition(cc.p(55 - 160,15))
            end
        end
        -- if v == chiPai then
        --     ma:setYellow()
        -- end 
    end
    local btn = ccui.Button:create("common/null.png","common/null.png","common/null.png", ccui.TextureResType.localType)
    btn:setScale9Enabled(true)
    btn:setAnchorPoint(cc.p(1,0))
    btn:setContentSize(cc.size(55*3,80))
    WidgetUtils.addClickEvent(btn, function()
        self:sendAction(tab)
    end)
    node:addChild(btn)

    local bg = ccui.ImageView:create("gamemj/action_paibg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(6.5, 42, 1,1))
        :setAnchorPoint(cc.p(1,0))
    bg:setContentSize(cc.size(161,85))
    node:setPositionX(161-14)
    node:setPositionY(5)
    node:setScale(0.85)
    bg:addChild(node)
    return bg
end


return ActionView