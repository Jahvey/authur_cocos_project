local TestCard = class("TestCard",require "app.module.basemodule.BasePopBox")

local LongCard = require "app.ui.game_base_cdd.base.LongCard"

function TestCard:initData()
    
end

function TestCard:initView()
	self.widget = cc.CSLoader:createNode("ui/ddz/testcard.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.scrollviews = {}
	self:initHand()
    self:initDeck()

    for i,v in ipairs(self.scrollviews) do
        self:refreshScrollview(v)
    end

    local okbtn = self.mainLayer:getChildByName("ok")
    WidgetUtils.addClickEvent(okbtn,function ()
        self:ok()
    end)

    local savebtn = self.mainLayer:getChildByName("save")
    WidgetUtils.addClickEvent(savebtn,function ()
        self:save()
    end)

    local loadbtn = self.mainLayer:getChildByName("load")
    WidgetUtils.addClickEvent(loadbtn,function ()
        self:load()
    end)

end

function TestCard:initDeck()
	local deckcard = {}
    for i=1,4 do
        for m=2,14 do
            table.insert(deckcard,i*16+m)
        end
    end

    table.insert(deckcard,81)
    table.insert(deckcard,82)
    table.insert(deckcard,102)

	self.deckview = self.mainLayer:getChildByName("deck")
	self.deckview.data = deckcard
	self.deckview.cards = {}
    self.deckview.label = self.mainLayer:getChildByName("label1")
    self.deckview.tag = 10

    -- self.handviews[i].tag = i
    -- self.handviews[i].data = {}
    -- self.handviews[i].cards = {}
    -- self.handviews[i]

    table.insert(self.scrollviews,self.deckview)
    self:refreshScrollview(self.deckview,true)
end

function TestCard:initHand()
	self.handviews = {}

	for i=0,5 do
		self.handviews[i] = self.mainLayer:getChildByName("player_"..i)
        self.handviews[i].tag = i
		self.handviews[i].data = {}
		self.handviews[i].cards = {}
        self.handviews[i].label = self.mainLayer:getChildByName("player_lael_"..i)

		table.insert(self.scrollviews,self.handviews[i])
	end
end

function TestCard:initEvent()
    ComNoti_instance:addEventListener("cs_response_set_next_round_hand_cards", self, self.responseHandCards)
    ComNoti_instance:addEventListener("cs_response_set_next_card", self, self.responseNextCard)
end

local SCALE = 0.4
function TestCard:refreshScrollview(scrollview,typ)
    if scrollview.label then
        if scrollview.tag == 10 then
            scrollview.label: setString("desk："..#scrollview.data.."张")
        else
            scrollview.label: setString(scrollview.tag.."号位："..#scrollview.data.."张")
        end
    end

	scrollview:removeAllChildren()

    local function getWeight(value)
        -- local weight = value%16
        -- if weight == 2 then
        --     return 15
        -- end
        return value
    end 

    table.sort(scrollview.data,function (a,b)
        return getWeight(a) == getWeight(b) and math.floor(a/16) < math.floor(b/16) or getWeight(a) < getWeight(b)
    end)

	for i,v in ipairs(scrollview.data) do
        -- print(".......v = ",v)
		local pokerCard = LongCard.new(v)
            :addTo(scrollview)
            :setPosition(cc.p((i-1)*50 + 79*SCALE,scrollview:getContentSize().height/2))
            :setScale(SCALE)

        if typ then
            self:addCardEvent2(pokerCard)
        else
            self:addCardEvent(pokerCard)
        end
	end

    scrollview:setInnerContainerSize(cc.size(50*#scrollview.data,scrollview:getContentSize().height))
end

function TestCard:addCardToScrollview(card,scrollview,notdelete)

    local _oldValue = 0
    if scrollview.tag == 4 then
        _oldValue = scrollview.data[1]
        scrollview.data = {}
    end

    table.insert(scrollview.data,card:getPoker())

    local oldscrollview = card:getParent():getParent()

    if not notdelete then
        for i,v in ipairs(oldscrollview.data) do
            if v == card:getPoker() then
                table.remove(oldscrollview.data,i)
                if  _oldValue ~= 0 then
                    table.insert(oldscrollview.data,_oldValue)
                end
                self:refreshScrollview(oldscrollview)
                break
            end
        end
    end
    self:refreshScrollview(scrollview)
end

function TestCard:addCardEvent(tile)
        -- body
    local beganposx,beganposy = tile:getPosition()

    local function shallResponseEvent()
        if not tolua.cast(tile,"cc.Node") then
            return false
        end

        return true
    end

    local function tileBack()
        if not tolua.cast(tile,"cc.Node") then
            return
        end

        local orginposx,orginposy = beganposx,beganposy

        tile:stopAllActions()
        tile.isbacking = true
        tile.isselect = false
        tile:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3,cc.p(orginposx,orginposy))),cc.CallFunc:create(function()
                tile:setLocalZOrder(1)
                tile.isbacking = false
                end)))

        -- self.gamescene:resignTile()
    end
    tile.tileBack = tileBack

    -- local function chuPai()
    --     if not self:tryChupai(tile) then
    --         tileBack()
    --     end
    -- end

    local function onTouchBegan(touch, event)
        if not shallResponseEvent() then
            return
        end
        beganposx,beganposy = tile:getPosition()
        local locationInNode = tile._poker:convertToNodeSpace(touch:getLocation())
        local s = tile._poker:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            return true
        end
    end

    local function onTouchMove(touch, event)
        if not shallResponseEvent() then
            return
        end

        local target = event:getCurrentTarget()
        target:setPosition(cc.p(target:getPositionX() + touch:getDelta().x,target:getPositionY() + touch:getDelta().y))
    end

    local function onTouchEnd(touch, event)
        -- tile.istouching = false
        if not shallResponseEvent() then
            return
        end
        local curposx,curposy = tile:getPosition()

        for i,v in ipairs(self.scrollviews) do
            local locationInNode = v:convertToNodeSpace(touch:getLocation())
            local s = v:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            if cc.rectContainsPoint(rect,locationInNode) then
                self:addCardToScrollview(tile,v)
                return
            end
        end

        local scrollview = tile:getParent():getParent()
        for i,v in ipairs(scrollview.data) do
            if v == tile:getPoker() then
                table.remove(scrollview.data,i)
                break
            end
        end
        self:refreshScrollview(scrollview)

        -- tile.tileBack()
    end

    local function onTouchCancell(touch, event)
        tile.istouching = false
        print("onTouchCancel======")
        if not shallResponseEvent() then
            return
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = tile:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,tile)
end

function TestCard:addCardEvent2(tile)
        -- body
    local beganposx,beganposy = tile:getPosition()
    local moveCard = nil

    local function setMoveCardPos(pos)
        if moveCard and WidgetUtils:nodeIsExist(moveCard) then
            moveCard:setPosition(self:convertToNodeSpace(pos))
        end
    end

    local function shallResponseEvent()
        if not tolua.cast(tile,"cc.Node") then
            return false
        end

        return true
    end

    local function tileBack()
        if not tolua.cast(tile,"cc.Node") then
            return
        end

        local orginposx,orginposy = beganposx,beganposy

        tile:stopAllActions()
        tile.isbacking = true
        tile.isselect = false
        tile:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3,cc.p(orginposx,orginposy))),cc.CallFunc:create(function()
                tile:setLocalZOrder(1)
                tile.isbacking = false
                end)))

        -- self.gamescene:resignTile()
    end
    tile.tileBack = tileBack

    -- local function chuPai()
    --     if not self:tryChupai(tile) then
    --         tileBack()
    --     end
    -- end

    local function onTouchBegan(touch, event)
        if not shallResponseEvent() then
            return
        end
        beganposx,beganposy = tile:getPosition()
        local locationInNode = tile._poker:convertToNodeSpace(touch:getLocation())
        local s = tile._poker:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            moveCard =  LongCard.new(tile:getPoker())
                :addTo(self)
                :setScale(SCALE)
            setMoveCardPos(touch:getLocation())
            return true
        end
    end

    local function onTouchMove(touch, event)
        if not shallResponseEvent() then
            return
        end

        -- local target = event:getCurrentTarget()
        -- target:setPosition(cc.p(target:getPositionX() + touch:getDelta().x,target:getPositionY() + touch:getDelta().y))
        setMoveCardPos(touch:getLocation())
    end

    local function onTouchEnd(touch, event)
        -- tile.istouching = false
        if not shallResponseEvent() then
            return
        end
        local curposx,curposy = tile:getPosition()

        moveCard:removeFromParent()
        moveCard = nil

        for i,v in ipairs(self.scrollviews) do
            local locationInNode = v:convertToNodeSpace(touch:getLocation())
            local s = v:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            if cc.rectContainsPoint(rect,locationInNode) then
                self:addCardToScrollview(tile,v,true)
                return
            end
        end

        

        -- tile.tileBack()
    end

    local function onTouchCancell(touch, event)
        tile.istouching = false
        print("onTouchCancel======")
        moveCard:removeFromParent()
        moveCard = nil
        if not shallResponseEvent() then
            return
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = tile:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,tile)
end

function TestCard:ok()
    self:request()
end

function TestCard:save()
    local cards = {}

    for i,v in ipairs(self.scrollviews) do
        cards[i] = v.data
    end

    local str = cjson.encode(cards)
    print("Save+++++++++++++++++++++++",str)
    self:saveFile(str,"conf_ddz")
end

function TestCard:load()
    -- local str = cc.UserDefault:getInstance():setStringForKey("SAVECARDS","")
    local str = self:readFile("conf_ddz")

    print("Load-----------------------",str)
    local cards = cjson.decode(str) or {}

    printTable(cards,"xp65")

    for i,v in ipairs(self.scrollviews) do
        v.data = cards[i] or {}
        self:refreshScrollview(v)
    end
end



function TestCard:request(index,cards)

    print("..............TestCard:request")
 
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_set_next_round_hand_cards


    local _list = {}
    for i,v in pairs(self.handviews) do

        print("...........i = ",i)
        print("..............#v.data = ",#v.data)
        
        if #v.data > 0 then
            for ii,vv in ipairs(v.data) do
                if i == 0 then
                    request.i_hand_cards_for_seat_0:append(tonumber(vv))
                elseif i == 1 then
                    request.i_hand_cards_for_seat_1:append(tonumber(vv))
                elseif i == 2 then
                    request.i_hand_cards_for_seat_2:append(tonumber(vv))
                elseif i == 3 then
                    request.i_hand_cards_for_seat_3:append(tonumber(vv))
                elseif i == 4 then
                    request.i_cards_pile_cards:append(tonumber(vv)) --地主牌
                elseif i == 5 then
                    request.i_jiang_card = vv
                end
            end
        end
    end

    SocketConnect_instance:send("cs_request_set_next_round_hand_cards", msg)
end


function TestCard:sendNextCard()

    if self.handviews[6] then
        local card = self.handviews[6].data 
        if  #card > 0 then
            local msg = poker_msg_pb.PBCSMsg()
            local request = msg.cs_request_set_next_card
            for ii,vv in ipairs(card) do
                request.i_next_card:append(tonumber(vv))
            end
            SocketConnect_instance:send("cs_request_set_next_card", msg)
        end
    end
end

function TestCard:responseHandCards(data)

    print("TestCard:responseHandCards")
    printTable(data,"xp65")

end

function TestCard:responseNextCard(data)

    print("TestCard:responseNextCard")
    printTable(data,"xp65")

end


function TestCard:saveFile(str,filename)
    local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.."test".. device.directorySeparator
    -- print("NetPicUtils.getLocalPic "..path)
    local FileUtils = cc.FileUtils:getInstance()

    -- if not io.exists(path) then
    if not FileUtils:isDirectoryExist(path) then    
        -- require "lfs"    
        --目录不存在，创建此目录
        if FileUtils:createDirectory(path) then
            release_print("创建成功")
            return
        else
            release_print("创建失败")   
        end
    end

    local file = io.open(path..filename..".txt","w")
    if file ~= nil then
        file:write(str)
        file:flush()
        file:close()
    end
end



function TestCard:readFile(filename)
     local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.."test".. device.directorySeparator
    print("NetPicUtils.getLocalPic "..path)
    
    local FileUtils = cc.FileUtils:getInstance()

    -- if not io.exists(path) then
    if not FileUtils:isDirectoryExist(path) then    
        -- require "lfs"    
        --目录不存在，创建此目录
        if FileUtils:createDirectory(path) then
            release_print("创建成功")
            return
        else
            release_print("创建失败")   
        end
    end

    local file1 = io.open(path..filename..".txt","r")
    if file1 ~= nil then
        for line in file1:lines() do
            -- table.insert(LOG_operatetypereport,line.."\n")
            return line
        end
        file1:close()
    end
end


return TestCard