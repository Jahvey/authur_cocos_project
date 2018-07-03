local BaseView = class("BaseView",function()
    return cc.Node:create()
end)
local perwi = 63
local Card = require "app.ui.kutong.Card"
require "app.ui.kutong.Suanfuc"
function BaseView:ctor(localpos,scene,data)
    self.scene = scene
	self.localpos = localpos
    self.cardnode = cc.Node:create()
    local painode = self.scene.painode:getChildByName("hand"..localpos)
    self.painode = painode
    self.cardnode:setPosition(cc.p(painode:getPositionX(),painode:getPositionY()))
    self:addChild(self.cardnode)
    self.putnode =  cc.Node:create()
    local sceneput = self.scene.painode:getChildByName("node"..self.localpos)
    self.putnode:setPosition(cc.p(sceneput:getPositionX(),sceneput:getPositionY()))
    self:addChild(self.putnode)

	if self.localpos == 1 then
		self.curcards = data.curCards
		-- self:createcards(true)
  --       self:initHandCard()
	else
        print("self.localpos:"..self.localpos)
		-- self.scene.icon[self.localpos]:getChildByName("lastcard"):setVisible(true)
		-- self.lasenum = self.scene.icon[self.localpos]:getChildByName("lastcard"):getChildByName("num")
		-- self.lasenum:setString(#data.curCards)
	end
    --self:chupai({carddatas={8,7,6,5,4,3,2,1,1,2,3,4,5}},false)
end

function BaseView:createcards(isanmate)
    self.iscantouch = true
    self._pokers = {}
    self.cardnode:removeAllChildren()
	-- for i,v in ipairs(Suanfuc.sort1hand(self.curcards)) do
 --         local card = Card.new(v,true)
 --         card:setPosition(cc.p((i - #self.curcards/2 -0.5)*50,0))
 --          self.cardnode:addChild(card)
 --     end 
    local curcards = self.curcards
    if isanmate then
        curcards = self.curcards
    else
         curcards = Suanfuc.sort1hand(self.curcards)
         if cc.UserDefault:getInstance():getIntegerForKey("pailie",1) == 2 then
            curcards = Suanfuc.sort2hand(self.curcards)
         end
    end
     local totall = #self.curcards
     for i=1,totall do
        local card = Card.new(curcards[i],true)
        self.cardnode:addChild(card)
        if totall > 20 then
            if i <= (totall-20) then
                --card:setPosition(cc.p((i - 20/2 -0.5)*(55*20)/21,60))
                card:setPosition(cc.p((i-1)*(perwi*20)/21 - perwi*19/2,60))
            else
                card:setPosition(cc.p(((i+20 - totall) - 20/2 -0.5)*perwi,0))
            end
        else
            card:setPosition(cc.p((i - totall/2 -0.5)*perwi,0))
        end
        table.insert(self._pokers,card)
     end
     if isanmate then
        self.iscantouch = false
        for i,v in ipairs(self._pokers) do
            v:setlocalvalue(v:getValue())
            v:setValue(0)
            v:setRotation(-180)
            v.pos = cc.p(v:getPositionX(),v:getPositionY())
            v:setPosition(cc.p(0,display.height-200-self.painode:getPositionY()))
            v:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function( ... )
                AudioUtils.playEffect("fapai")
                v:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,v.pos),cc.CallFunc:create(function( ... )
                    v:setValue(v:getlocalvalue())
                    if i==#self._pokers then

                        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
                           self:createcards()
                       end)))
                       self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function( ... )
                            self.iscantouch = true
                            STOPSOCEKT = false
                       end)))
                    end
                end)))
                v:runAction(cc.RotateBy:create(0.2,180))
            end)))
        end
     end
end

function BaseView:sortcards( )
    self:createcards()
end
function BaseView:initHandCard()
     -- local pokerPanel = self._seatNode:getChildByName("Panel_Poker")
     -- self._pokerPanel = pokerPanel
     -- self._pokerPanel:setEnabled(false)

    local istouchin = false
    local selectcards = 0
    local function onTouchBegan(touch, event)
        print("touch")
        if not self.iscantouch then
            return false
        end
        selectcards = 0
        AudioUtils.playEffect("ddz_xuanpai")
        -- istouchin = true
        for i,v in ipairs(self._pokers) do
            v.isnotmove = true
        end
        local totall = #self._pokers
       print("x:"..totall)
        for i=1,totall do
            local beginpos = self._pokers[totall - i + 1].valuespr:convertTouchToNodeSpace(touch)
            print("x:"..self._pokers[totall - i + 1]:getValue())
            --print("y:"..beginpos.y)
            local size =self._pokers[totall - i + 1].valuespr:getContentSize()
            if self._pokers[totall - i + 1].isnotmove then
                if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                    --posset(self._pokers[totall - i + 1])
                    self._pokers[totall - i + 1]:setSelected(not self._pokers[totall - i + 1]:getSelected())
                    self._pokers[totall - i + 1].isnotmove = false
                    --print("ture")
                    selectcards = selectcards + 1
                    break
                end
            end
        end
        return true

    end

    local function onTouchMove(touch, event)
        AudioUtils.playEffect("ddz_xuanpai")
        local totall = #self._pokers
        for i=1,totall do
            local beginpos = self._pokers[totall - i + 1].valuespr:convertTouchToNodeSpace(touch)
            local size =self._pokers[totall - i + 1].valuespr:getContentSize()
            if self._pokers[totall - i + 1].isnotmove then
                 -- AudioUtils.playEffect("ddz_xuanpai")
                if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                    self._pokers[totall - i + 1]:setSelected(not self._pokers[totall - i + 1]:getSelected())
                    self._pokers[totall - i + 1].isnotmove = false
                    selectcards = selectcards + 1
                    break
                end
           else
                if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                    
                    break
                end
            end
        end
    end
    local function selectend(  )

       
    end
    local function onTouchEnd(touch, event)
        istouchin =false
        selectend()
    end

    local function onTouchCancell(touch, event)
        istouchin = false
        selectend()
    end

    local  listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function BaseView:actionchu( preAction )
    local chutab = {}
    for i,v in ipairs(self._pokers) do
        if v:getSelected() then
            table.insert(chutab,v:getValue())
        end
    end
    local tab = Suanfuc.getype(chutab)
    print("-------dddd")
    printTable(tab)
    local isaction = false
    if tab and preAction == nil then
        -- Socketapi.doactionforkutong(2,tab.type,chutab,tab.num ,tab.real)
        -- self.scene.actionnode:setVisible(true)
        -- self.scene.actionnode:setVisible(false)
        isaction  =true
    elseif tab then
        printTable(preAction)
        printTable(preAtabction)
        if preAction.cardtype ~= 7 and tab.type == 7 then
            isaction =true
        elseif preAction.cardtype == 7 and tab.type == 7 then
            if preAction.num == tab.num then
                if tab.real > preAction.real then
                   isaction= true
                end
            elseif preAction.num < tab.num then
                isaction= true
            end
        elseif preAction.cardtype == tab.type  then
            if preAction.num and tab.num then
                if preAction.num == tab.num then
                    if tab.real > preAction.real then
                        isaction= true
                    end
                end
            else
                if tab.real > preAction.real then
                    isaction= true
                end
            end
        end

    end
     if isaction then
        local mosttype,mostnum = Suanfuc.getmostzha(self.curcards)
        tab.values = chutab
        if Suanfuc.iscanchu(tab,self.curcards,mosttype,mostnum) then
            self.scene.actionnode:getChildByName("clock"):stopAllActions()
            print("能出")
            Socketapi.doactionforkutong(2,tab.type,chutab,tab.num ,tab.real)
            self.scene.actionnode:setVisible(false)
        else
            print("不能出")
        end
    end


end
function BaseView:chupai(data,isneedshan)
    local totall = #data.carddatas
     self.putnode:removeAllChildren()
    for i,v in ipairs(data.carddatas) do
        local card = Card.new(v)
        self.putnode:addChild(card)
        card:setScale(0.6)
        if self.localpos == 1 then
           card:setPosition(cc.p((i - totall/2 -0.5)*30,0))
        elseif self.localpos == 2 then
            card:setCardAnchorPoint(cc.p(0,0))
            card:setPosition(cc.p(0-0.6*card.valuespr:getContentSize().width-(totall -i)*30,0))
        elseif self.localpos == 3 then
            card:setCardAnchorPoint(cc.p(0,0))
            card:setPosition(cc.p(0-0.6*card.valuespr:getContentSize().width-(totall -i)*30,0))
        elseif self.localpos == 4 then
            card:setCardAnchorPoint(cc.p(0,0))
            card:setPosition(cc.p((i -1)*30,0))
        end
    end
    print(self.localpos)
    print(tostring(isneedshan))
    if self.localpos == 1 and isneedshan then
        for i1,v1 in ipairs(data.carddatas) do
            for i,v in ipairs(self.curcards) do

                if v == v1 then
                    print("dele:"..v)
                    table.remove(self.curcards,i)
                    break
                end
            end
        end
        self:createcards()
    end
end

function BaseView:tips(action)
    if self.tiptab == nil then
        action.type = action.cardtype

        self.tiptab = Suanfuc.tips(self.curcards,action)
    end
    if self.tiptab and self.tiptab[self.tipnum] then
    else
        self.tipnum = 1
    end
    if self.tiptab and self.tiptab[self.tipnum] then
        for i,v in ipairs(self._pokers) do
            v:setSelected(false)
        end
        for i,v in ipairs(self.tiptab[self.tipnum].values) do
            for i1,v1 in ipairs(self._pokers) do
                if v1:getValue() == v and v1:getSelected() == false then
                    v1:setSelected(true)
                    break
                end
            end
        end
    end
end

function BaseView:actionclean( )
     for i1,v1 in ipairs(self._pokers) do
        v1:setSelected(false)
    end
end

function BaseView:showwinlost(value,isfour)
    local node =  cc.CSLoader:createNode("cocostudio/ui/game/goldnode1.csb")
    local win = node:getChildByName("win")
    local lost = node:getChildByName("lost")
    if value >= 0 then
        win:setString("/"..value)
        win:setVisible(true)
        lost:setVisible(false)
        if self.localpos == 1 then
            --AudioUtils.playEffect("niu_yingle")
        end
    elseif value < 0 then
        lost:setString("/"..math.abs(value))
        lost:setVisible(true)
        win:setVisible(false)
        if self.localpos == 1 then
            --AudioUtils.playEffect("niu_shule")
        end
    else
        lost:setVisible(false)
        win:setVisible(false)
    end
    local action = cc.CSLoader:createTimeline("cocostudio/ui/game/goldnode1.csb")
    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    if isfour == nil then
        local iconnode =  self.scene.icon[self.localpos]
        node:setPosition(cc.p(iconnode:getContentSize().width/2, iconnode:getContentSize().height))
        iconnode:addChild(node)
    else
        local iconnode =  self.scene.xiazhu
        node:setPosition(cc.p(iconnode:getContentSize().width/2, iconnode:getContentSize().height))
        iconnode:addChild(node)
      end
end


return BaseView