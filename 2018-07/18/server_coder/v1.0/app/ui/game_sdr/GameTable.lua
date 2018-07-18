local GameTable = class("GameTable", require("app.ui.game.GameTable"))

function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        -- printTable(list,"xp")

        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                if  oldValue ~= vv.real_value then
                    if vv.one_value < 4 then
                        if vv.num == 3 then 
                            fen_hand = fen_hand +  6   --绍3张6分
                        elseif vv.num == 4 then
                            fen_hand = fen_hand +  12   --绍4张12分
                        else
                            fen_hand = fen_hand +  vv.num  --其它数量，一个一分
                        end
                    else
                        if vv.num == 3 then
                           fen_hand = fen_hand +  4 --绍3张4分
                        elseif vv.num == 4 then
                           fen_hand = fen_hand +  8  --绍4张8分，
                        end
                    end
                end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
end


-- 跑牌动画 从展示位到摆牌位 --明杠
function GameTable:paoPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    if #data.col_info.cards == 5 then
        AudioUtils.playVoice("action_banlong", self.gamescene:getSexByIndex(self:getTableIndex()))
    elseif #data.col_info.cards == 6 then
        AudioUtils.playVoice("action_manlong", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
       AudioUtils.playVoice("action_pao", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"paoPaiAction")
end

-- 提牌动画 从展示位到摆牌位 --暗杠
function GameTable:tiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    if #data.col_info.cards == 5  then
         AudioUtils.playVoice("action_banlong", self.gamescene:getSexByIndex(self:getTableIndex()))
    elseif #data.col_info.cards == 6 then
         AudioUtils.playVoice("action_manlong", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        AudioUtils.playVoice("action_ti", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tiPaiAction")
end

return GameTable