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
                if  oldValue ~= vv.real_value then
                    if self.gamescene:getIsJiangCard(vv.real_value)  then
                        fen_hand = fen_hand + 8*vv.num   --活精，每个8分
                    elseif vv.real_value == 0x11 then 
                         fen_hand = fen_hand + 4*vv.num   --死精，每个4分
                    else
                        if vv.num > 2 then
                            fen_hand = fen_hand + 2*vv.num - 2 
                        end 
                    end
                end
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
    self:playActionVoice("ding")

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"pengPaiAction")
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


return GameTable