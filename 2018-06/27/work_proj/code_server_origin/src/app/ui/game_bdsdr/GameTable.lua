local GameTable = class("GameTable", require("app.ui.game.GameTable"))

function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))
        
        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                -- if  oldValue ~= vv.real_value then
                    --精牌5分（上13，七65，福129） 
                    if vv.real_value == 0x11 or vv.real_value == 0x41 or vv.real_value == 0x81 then
                        fen_hand = fen_hand + 5
                    end
                -- end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
end

-- 碰牌动画 从展示位到摆牌位 ,这里叫丁
function GameTable:pengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
     self:showActionImg("action_ding")
    AudioUtils.playVoice("action_ding", self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"pengPaiAction")
end

-- 跑牌动画 从展示位到摆牌位 --明杠,这里叫抢
function GameTable:paoPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_mao")
    AudioUtils.playVoice("action_mao", self.gamescene:getSexByIndex(self:getTableIndex()))
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"paoPaiAction")
end

-- 提牌动画 从展示位到摆牌位 --暗杠，这里叫卯
function GameTable:tiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_qiang")
    AudioUtils.playVoice("action_qiang", self.gamescene:getSexByIndex(self:getTableIndex()))

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tiPaiAction")
end

function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 or pai == 0x81 or pai == 0x82 or pai == 0x83 then
        AudioUtils.playVoice("pai_bd_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end

return GameTable