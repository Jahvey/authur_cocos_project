local RecordScene = class("RecordScene", require "app.ui.game_base_cdd.RecordScene")

function RecordScene:initTable()
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

    --底牌设置
    if self.table_info.dipai_cards then
        if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then  --只有麻城斗地主是其它玩家能看到底牌
             self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
        else
            if  self:getDealerIndex() == self:getMyIndex () then
                self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
            end
        end
    else
        if  self:getTableConf().ttype == HPGAMETYPE.ESDDZ then --只有恩施斗地主是4张地主牌
            self.mytable:updateDiZhuCards(true,{0,0,0,0})
        else
            self.mytable:updateDiZhuCards(true,{0,0,0})
        end
    end

    if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then
        if self.table_info.laizi_card then
            LocalData_instance:setLaiZiValuer(self.table_info.laizi_card % 16 ) 
            self.mytable:updateLaiZiCards(true,self.table_info.laizi_card)
        else
            self.mytable:updateLaiZiCards(true,nil)
        end
    elseif self:getTableConf().ttype == HPGAMETYPE.ESDDZ then
        LocalData_instance:setLaiZiValuer(18) 
    end

    self:otherInitView()

end

function RecordScene:endplay()

    for i, v in ipairs(self.tablelist) do
        -- v:refreshSeat()
        v:refreshHandTile()
    end

    if self.isendshow == nil then
        self.isendshow = true
        if self.table_info.game_over then
            LocalData_instance:setLaiZiValuer(-2)  
            --LaypopManger_instance:PopBox("SingleResultView", self.table_info.game_over, self, 2)
            LaypopManger_instance:PopBox("PDKSingleResultView", self.table_info.game_over, self,2)
        end
    end
end

return RecordScene