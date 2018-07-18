local GameScene = class("GameScene", require "app.ui.game_base_cdd.GameScene")
local LongCard = require "app.ui.game_base_cdd.base.LongCard"

function GameScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")

    local bottomtable = require("app.ui.game_jdpdk.TableBottom").create(require("app.ui.game_base_cdd.base.TableBottom").create(tableBase, gameAction),gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_base_cdd.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_jdpdk.TableLeft").create(require("app.ui.game_base_cdd.base.TableLeft").create(tableBase)).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_jdpdk.TableRight").create(require("app.ui.game_base_cdd.base.TableRight").create(tableBase)).new(self.layout:getChildByName("rightnode"), self)

    -- 初始化策略
    local maps = {
        [2] =
        {
            [0] = { bottomtable, toptable },
            [1] = { toptable, bottomtable },
        },
        [3] =
        {
            [0] = { bottomtable, righttable, lefttable },
            [1] = { lefttable, bottomtable, righttable },
            [2] = { righttable, lefttable, bottomtable },
        },
        [4] =
        {
            [0] = { bottomtable, righttable, toptable, lefttable },
            [1] = { lefttable, bottomtable, righttable, toptable },
            [2] = { toptable, lefttable, bottomtable, righttable },
            [3] = { righttable, toptable, lefttable, bottomtable },
        },
    }

    self.tablelist = maps[self:getTableConf().seat_num][self:getMyIndex()]

    for i, v in ipairs(self.tablelist) do
        v:showNode()
        v:setTableIndex(i - 1)
    end

    self.mytable = bottomtable

    self:otherInitView()

end

-- function GameScene:otherInitView()
--     local btn = ccui.Button:create("gameddz/ddz_btn_yellow.png")
--         :addTo(self.layout)
--         :setPosition(display.cx,display.height - 50)

--     WidgetUtils.addClickEvent(btn,function ()
--         LaypopManger_instance:PopBox("TestCard")
--     end)
-- end

-- 显示单局结算
function GameScene:showpeiResult(data)

    local ischunindex = 0
    
    for i,v in ipairs(data.sdr_result.players) do
        if v.win_info and v.win_info.styles then
            for i1,v1 in ipairs(v.win_info.styles) do
                if v1 == poker_common_pb.EN_SDR_STYLE_TYPE_Chun_Tian then
                    ischunindex = 1
                elseif v1 == poker_common_pb.EN_SDR_STYLE_TYPE_Fan_Chun_Tian then
                    ischunindex = 2
                end
            end
        end
    end
    for i,v in ipairs(self.tablelist) do
        v:gameOver()
    end

    printTable(data,"xp66")

    if ischunindex ~= 0 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( ... )
            self:deleteAction("小结算")
            LaypopManger_instance:PopBox("PDKSingleResultView", data, self, 1)
        end)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function( ... )
            local DdzcsbAnmation = require "app.ui.game_base_cdd.DdzcsbAnmation"
            local node
            if ischunindex == 1 then
                node = DdzcsbAnmation.chuntianfordizhi()
            else
                node = DdzcsbAnmation.chuntianfornongming()
            end
            node:setPosition(cc.p(display.cx,display.cy))
            self:addChild(node)
        end)))
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
            self:deleteAction("小结算")
            LaypopManger_instance:PopBox("PDKSingleResultView", data, self, 1)
        end)))
    end
end

function GameScene:NotifyGameStart(data)
    self.super.NotifyGameStart(self,data)
    if self:getNowRound() == 1 or self:getTableConf().is_last_winner_dealer then
        self:addAction( { act_type = ACTIONTYPEBYMYSELF.BIPAI, data = data })
    end
end 

function GameScene:priorityAction(data)
    if data.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
        print(".........过，不需要动画")
        local delaytime = 0

        if self:getTableConf().you_da_bi_chu then
            delaytime = 1
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
                self.tablelist[data.seat_index + 1]:pass(true)
                if data.is_single_over then
                    self.table_info.sdr_total_action_flows = {}
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                        for i,v in ipairs(self.tablelist) do
                            v.showcardnode:removeAllChildren()
                            v.buchunode:setVisible(false)
                        end
                        self:deleteAction("过")
                    end )))
                else
                    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create( function()
                        self:deleteAction("过")
                    -- end )))
                    -- self:deleteAction("过")
                end
            end)))
        return true
    elseif  data.act_type == ACTIONTYPEBYMYSELF.BIPAI then
        local pokerCard = LongCard.new(0x43)
            :addTo(self.layout)
            :setPosition(cc.p(display.cx,display.cy))
            :setScale(0.5)

        local icon = self.tablelist[self:getDealerIndex()+1].icon
        local targetpos = icon:getParent():convertToWorldSpace(cc.p(icon:getPositionX(),icon:getPositionY()))

        local x = targetpos.x - pokerCard:getPositionX()
        local y = targetpos.y - pokerCard:getPositionY()

        local rotation = math.atan(math.abs(x)/y)

        rotation = math.deg(rotation)*(math.abs(x)/x)

        pokerCard:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.Spawn:create(cc.RotateBy:create(0.1,rotation),cc.MoveTo:create(0.3,targetpos)),cc.CallFunc:create(function ()
            pokerCard:removeFromParent()
            self:deleteAction("定庄")
        end)))
        return true
    end
    return false
end

function GameScene:deleteHandTile(valuelist, seat_index)

    -- if self.name == "GameScene" then
    if self.name == "GameScene" and not self:isMingPaiByIdx(seat_index) then
        if seat_index ~= self:getMyIndex() then 
            for i, v in ipairs(self.table_info.sdr_seats) do
                if v.index == seat_index then
                   for i1,v1 in ipairs(valuelist) do
                       table.remove(v.hand_cards,1)
                   end
                end
            end
            return
        end
    end


    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")

        if v.index == seat_index then

            print("................我的手牌！！！数量 ",#v.hand_cards)
            for ii, vv in ipairs(valuelist) do
                for iii, vvv in ipairs(v.hand_cards) do
                    if vvv == vv then
                        table.remove(v.hand_cards, iii)
                        break
                    end
                end
            end
            print(".....删除后....我的手牌！！！数量 ",#v.hand_cards)
            return
        end
    end
end

return GameScene