

local PokerCard = class("PokerCard", cc.Node)

function PokerCard:ctor(value)
    -- printInfo("[PokerCard] ctor")

    self:_initData(value)
    self:_showView()
end

function PokerCard:onCleanUp()
    
end

function PokerCard:_initData(value)
    self._data = {}
    self._data.value = value or 0
    self._data.selectedDeltaY = 20
    self._data.selected = false
    -- 打出去的牌是不能被删除的
    self._data.enableCleaned = true
end

function PokerCard:_showView()
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pokercard.plist")

    -- poker
    self._poker = cc.Sprite:create(self:_getPng())
    self.laitip = cc.Sprite:create("gameddz/pokercardddz/lazitip.png")
    self._poker:addChild(self.laitip)
    self.laitip:setAnchorPoint(cc.p(0,0))
    self.laitip:setPosition(cc.p(4,9))
    -- print("laizi")
    -- print(LAIZIVALUE_LOCAL ,self:getPokerValue())
    if self:getPokerValue() == LocalData_instance:getLaiZiValuer() or (LAIZIVALUE_LOCAL == self:getPokerValue() and LAIZIVALUE_LOCAL ~= 0 and self:getPokerType() <=4) then
        self:setisshowLai(true)
    else
        self:setisshowLai(false)
    end
    self:addChild(self._poker)
end

function PokerCard:_getPng()
    -- printInfo("[PokerCard] _getPng value:%d", self._data.value)
    -- printInfo("[PokerCard] _getPng getPokerValue:%d", self:getPokerType())
    -- printInfo("[PokerCard] _getPng getPokerValue:%d", self:getPokerValue())

    local pokerType = self:getPokerType()
    local pokerValue = self:getPokerValue()
    local pokerPng = string.format("gameddz/pokercardddz/poker_card_%d_%d.png", pokerType, pokerValue)
    --print(pokerPng)
    return pokerPng
end

function PokerCard:setisshowLai(boo )
    if LAIZIVALUE_LOCAL == self:getPokerValue() and LAIZIVALUE_LOCAL ~= 0 and self:getPokerType() <=4 then
         self.laitip:setVisible(true)
    else
         self.laitip:setVisible(boo)
    end
   
end
function PokerCard:getPokerType()
    return (math.floor(self._data.value / 16))
end

function PokerCard:getPokerValue()
    return (self._data.value % 16)
end

function PokerCard:getPoker()
    return self._data.value
end

function PokerCard:setDizhutip()
    self.ditip = cc.Sprite:create("gameddz/dicardtip1.png")
    self._poker:addChild(self.ditip)
    self.ditip:setPosition(cc.p(107.87,168.60))
end
function PokerCard:setSelected(status)
    self._data.selected = status
    if status then
        self._poker:setPositionY(self._data.selectedDeltaY)
    else
        self._poker:setPositionY(0)
    end
end

function PokerCard:getSelected()
    return self._data.selected
end
function PokerCard:setgray( bool )
   if bool then
        self._poker:setColor(cc.c3b(191, 191, 191))
   else
        self._poker:setColor(cc.c3b(255, 255, 255))
   end
end

function PokerCard:setCardAnchorPoint(pos)
    self._poker:setAnchorPoint(pos)
    self._poker:setPosition(cc.p(0,0))
end

-- 展示明牌标志
function PokerCard:showMingPai()
    local icon = cc.Sprite:create("gameddz/ddz_mingpai_icon.png")
    self._poker:addChild(icon)
    icon:setPosition(cc.p(icon:getContentSize().width * 0.5 + 2, 
        icon:getContentSize().height * 0.5 + 7))
end

return PokerCard