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
-- 吃牌动画 从展示位到摆牌位
function GameTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_chi")
    self:playActionVoice("chi")
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
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


--招牌动画类似于吃，从展示位到摆牌位
function GameTable:zhaoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_mao")
    self:playActionVoice("mao")

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction")
end

function GameTable:playPaiVoice(pai)

    local _str = (math.floor(pai / 16))..(pai % 16)

    local _path = self:getVoicePath()
    local audio_type = cc.UserDefault:getInstance():getIntegerForKey("audio_type",1)
    if audio_type == 1 then 
        _path = _path.."pai_".._str.."_"..math.random(1, 2)
    else
        if pai == 0x43 or pai == 0x73 or pai == 0x81 or pai == 0x82 or pai == 0x83 then
            _path = _path.."pai_bd_".._str
        else
            _path = _path.."pai_".._str   
        end
    end
    AudioUtils.playVoice(_path, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function GameTable:playActionVoice(action)
    local _path = self:getVoicePath()
    local audio_type = cc.UserDefault:getInstance():getIntegerForKey("audio_type",1)
    if audio_type == 1 then 
        AudioUtils.playVoice(_path.."action_"..action.."_"..math.random(1, 2), self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        AudioUtils.playVoice(_path.."action_"..action, self.gamescene:getSexByIndex(self:getTableIndex()))
    end
end


function GameTable:addQiShouMaiTips(data)
    local node = cc.Node:create()
    local img = "game/icon_mao_ming.png"
    if data.is_waichi then
        img = "game/icon_mao_an.png"
    end
    local maiType = ccui.ImageView:create(img)
    if maiType then
        maiType:setPosition(cc.p(0,((#data.cards-1)*36)+35))
        node:addChild(maiType)
    end
    return node
end

return GameTable