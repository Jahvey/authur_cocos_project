local GameTable = class("GameTable", require("app.ui.game_MJ.game_base.base.BaseTable"))

-- 出牌动画，从展示位到出牌位
function GameTable:chuPaiAction(data, hidenAnimation)
    self.isChiPeng = false
    self:refreshHandCards()
    if hidenAnimation then
        return
    end

    local index = data.seat_index
    local value = data.dest_card

    local ma = self:addputout(value)
    ma:setName("chupai")
    self.gamescene:setOutCardTips(true,ma)

    if self.gamescene:getIsHavePlay(3) and self.gamescene:getIsJokerCard(value)  then
        self:showActionImg("action_mj_lainohu") --如果是癞子，而规则上又有打癞禁胡的哈，就需要显示打癞禁胡
    end
    if self.gamescene:getIsHavePlay(4) and self.gamescene:getIsPiziCard(value)  then
        self:showActionImg("action_mj_pinohu") --如果是痞子，而规则上又有打痞禁胡的哈，就需要显示打痞禁胡
    end

    --抬庄
    if self.gamescene.Suanfuc:getIsTaiZhuang(data.seat_index,data.dest_card) == true then
        self:showActionImg("action_mj_taizhuang")
    end

    AudioUtils.playEffect("mj_outpai")
    self:playPaiVoice(value)

    self.gamescene:setRunningAction()
end

-- 吃牌动画
function GameTable:chiPaiAction(data, hidenAnimation)
    self.isChiPeng = true
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)

    if  self:getIsQingOrJiang(true) == false  then
        self:showActionImg("action_mj_chi")
    end
    self:playActionVoice("chi")
    self.gamescene:setRunningAction(0.2)
end

-- 碰牌动画
function GameTable:pengPaiAction(data, hidenAnimation)
    self.isChiPeng = true
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)

    if self:getIsQingOrJiang() == false  then
        self:showActionImg("action_mj_peng")
    end
    self:playActionVoice("peng")

    self.gamescene:setRunningAction(0.2)
end

-- 杠牌动画
function GameTable:gangPaiAction(data, hidenAnimation)
    self.isChiPeng = false
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)

    if self:getIsQingOrJiang() == false  then
        self:showActionImg("action_mj_minggang")
    end
    self:playActionVoice("gang")
    self.gamescene:setRunningAction(0.2)
end

-- 暗杠牌动画
function GameTable:anGangPaiAction(data, hidenAnimation)
    self.isChiPeng = false
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)
    if self:getIsQingOrJiang() == false  then
        self:showActionImg("action_mj_angang")
    end
    self:playActionVoice("angang")
    self.gamescene:setRunningAction(0.2)
end

function GameTable:getIsQingOrJiang(isChi)
    --判断是否是清一色
    if  self.gamescene.Suanfuc:getIsQingYiSe(self:getTableIndex()) then
          self:showActionImg("action_mj_qingyise")
          return true
    end
    if isChi  then
        return false
    end
    --判断是否是将一色
    if  self.gamescene.Suanfuc:getIsJiangYiSe(self:getTableIndex()) then
       self:showActionImg("action_mj_jiangyise")
       return true
    end
   return false
end



-- 痞子癞子杠牌动画
function GameTable:gang2PaiAction(data, hidenAnimation)
    self.isChiPeng = false
    self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self.gamescene:setOutCardTips(false)
 	if self.gamescene:getIsJokerCard(data.dest_card) then 
        local list = {"action_mj_ganglaizi","action_mj_laizigang"}
        local index = math.random(1, 2)

 		self:showActionImg(list[index])
        self:playActionVoice("laizigang")
    elseif self.gamescene:getIsPiziCard(data.dest_card) then
        --判断是否是禁止养痞子
        if self.gamescene.Suanfuc:getIsYangPi(self:getTableIndex()) then
            self:showActionImg("action_mj_nopi")
        else
            self:showActionImg("action_mj_pizigang")
        end
        self:playActionVoice("pizigang")
    end

    self.gamescene:setRunningAction(0.2)
end

-- 胡牌动画
function GameTable:huPaiAction(data, hidenAnimation)
    -- self:refreshHandCards()
    if hidenAnimation then
        return
    end
    self:showActionImg("action_mj_hu")
    if  data.iszimo then
        self:playActionVoice("zimo")
    else
        self:playActionVoice("hu")
    end

    self.gamescene:setRunningAction(0.2)
end

-- function GameTable:playPaiVoice(pai)
--     local index = math.random(1, 2)
--     AudioUtils.playVoice("_mj/es/mj_"..pai.."_"..index, self.gamescene:getSexByIndex(self:getTableIndex()))
-- end

-- function GameTable:playActionVoice(action)
--     local index = math.random(1, 2)
--     AudioUtils.playVoice("_mj/es/mj_action_"..action.."_"..index, self.gamescene:getSexByIndex(self:getTableIndex()))
-- end

--设置倍数
function GameTable:updataHuXiText()
    print(".....updataHuXiText ..........")
    local showCol = clone(self.gamescene:getShowCardsByIdx(self.tableidx))
    local allScore = 1
    -- print("updataHuXiText")
    -- printTable(showCol,"xp10")

    if  showCol and #showCol > 0 then
        for k,v in pairs(showCol) do
            if v.score and v.score > 0 then
                allScore = allScore *v.score
            end
        end
    end
    --癞子4倍，痞子2倍
    local outCol = clone(self.gamescene:getPutoutTileByIdx(self.tableidx))

    if  outCol and #outCol > 0 then
        for k,v in pairs(outCol) do
            if self.gamescene:getIsJokerCard(v) then
                allScore =  allScore * 4
            end
            if self.gamescene:getIsPiziCard(v) then
                allScore =  allScore * 2
            end
        end
    end

    if self.icon:getChildByName("timesNode") == nil then
        local kounode = cc.Sprite:create("gamemj/icon_timesBg.png")
        kounode:setAnchorPoint(cc.p(0,0))
        kounode:setPosition(cc.p(-38,40))
        if LocalData_instance:getbaipai_stype() == 2 then
            local worldpos1 = self.node:convertToWorldSpace(cc.p(self.ankounode:getPositionX(),self.ankounode:getPositionY()))
            self.icon:setPosition(cc.p(self.nodebegin:getPositionX(), self.nodebegin:getPositionY()))
            local spacepos = self.icon:convertToNodeSpace(worldpos1)
            kounode:setPosition(spacepos)
        end
        self.icon:addChild(kounode)
        kounode:setName("timesNode")
        kounode:setVisible(true)

        local num = ccui.TextAtlas:create("/0123456789","gamemj/icon_timesNum.png",14,20,"/")
        num:setAnchorPoint(cc.p(0,0.5))
        num:setString("/8")
        num:setName("num")
        num:setPosition(cc.p(5,17))
        kounode:addChild(num)
    end

    self.icon:getChildByName("timesNode"):setVisible(true)
    self.icon:getChildByName("timesNode"):getChildByName("num"):setString("/"..allScore)
end


return GameTable