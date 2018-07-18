local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableBottom = class("TableBottom", tableClass)
    local ROW = 5
    local COL = 15
    local ALL_GEZI = ROW * COL

    function TableBottom:init()
        -- body
    end

    function TableBottom:initLocalConf()
        self.MsgLayerOffset = { posx = 30, posy = 130 }
        self.localpos = 1
        self.isTouched = false
        self.banedList = { }

        self.actionview = actionClass.new(self.gamescene)
        self.actionview:setPosition(cc.p(display.width / 2, display.height / 2))
        self.gamescene:addChild(self.actionview)

        self.shouzhiNode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("shouzhiNode"):setVisible(false)
        -- 手指节点坐标
        self.shouzhi = self.shouzhiNode:getChildByName("shouzhi")
        self.huadong = self.shouzhiNode:getChildByName("huadong")
        self.xuxian = self.shouzhiNode:getChildByName("panel")

        self.shouzhi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(0.5, -60), cc.DelayTime:create(0.2), cc.RotateBy:create(0.5, 60))))
        self.huadong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.2), cc.DelayTime:create(0.5), cc.ScaleTo:create(0.5, 0.8))))
        self.xuxian:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.DelayTime:create(1), cc.FadeIn:create(1))))

        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("bottom")
        -- 出牌节点
        self.moPaiPos = self.node:convertToWorldSpace(cc.p(self.handCardNode:getPosition()))
    end

    function TableBottom:getIsMyTurn()
        return self.ismyturn
    end

    function TableBottom:setIsMyTurn(bool)
        self.ismyturn = bool

    end

    function TableBottom:saveMyGrouping(isNil)
        
    end


    -- 显示手指
    function TableBottom:showShouZhi(bol, data)
        print("....... 显示手指 TableBottom:showShouZhi bol =", bol)
        self.shouzhiNode:setVisible(bol)
        self.chuData = data
    end

    -- 设置不能处理的牌的list
    function TableBottom:setBanedCardsList(list)
        -- print("........设置不能处理的牌的list")
        -- printTable(list,"xp")

        self.banedList = list
    end

    function TableBottom:refreshHandTile(move)
        -- 牌宽126 间距95 高174 间距50
        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)
        self:updataHuXiText()
        self:deleteMoveSprite()

        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        handtile = self:sortHandTile(handtile)

        local all_wid = #handtile*95

        local offx = 0
        -- self.handtile = ComHelpFuc.sortMyHandTile(handtile)

        -- self.handcardspr = { }

        -- local all_wid = #self.handtile * 88
        -- if #self.handtile > 7 then
        --     all_wid = 7 * 88
        -- end

        local banedList = clone(self.banedList)
        local function getIsBanedCard(card)
            for i,v in ipairs(banedList) do
                if v == card then
                    table.remove(banedList,i)
                    return true
                end
            end
            return false
        end

        for i, column in pairs(handtile) do
            if not self.handcardspr[i] then
                self.handcardspr[i] = { }
            end
            local _y = 9 - 10
            local oldCard = -1
            for m, unit in pairs(column) do
                local pai = self.gamescene:createCardSprite(CARDTYPE.MYHAND, unit)
                self.handCardNode:addChild(pai, 4 - m)

                local x = 1

                local _x = 95 *(i - 1) - all_wid / 2 + 95/2
                
                -- if self.gamescene:getIsJiangCard(unit.real_value) then
                --     pai:showJiang()
                -- end
                if getIsBanedCard(unit) or self.gamescene:getSeatInfoByIdx(self.tableidx).has_kou_pai then
                    pai:setGray()
                end

                pai.x = _x
                pai._y = _y
                -- local _y = 70 *(m - 1) + 9 - 30
                if move and self.gamescene.name == "GameScene" then
                    pai:setPosition(cc.p(0, _y))
                    -- 从最中间 往两边移动

                    table.insert(self.handcardspr[i], pai)
                    pai:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(_x, _y)), cc.CallFunc:create( function()

                        pai:setOriginPos(pai.x, pai._y)
                        pai:setPosition(cc.p(pai.x, pai._y))
                        self:addTileEvent(pai)
                    end )))
                else
                    pai:setOriginPos(pai.x, pai._y)
                    pai:setPosition(cc.p(pai.x, pai._y))
                    self:addTileEvent(pai)
                end

                oldCard = unit
                _y = _y + 50
            end
        end
            
    end

    function TableBottom:refreshShowTile()

        self.showCardNode:removeAllChildren()
        self.showCardNode:setVisible(true)

        print(".........TableBottom:refreshShowTile 刷新摆牌")

        self.showcardspr = { }
        print("bai  zji  test")
        local showCardList = self:getShowCardList()
        self.nextShowPos = cc.p(19, 21)
        
        printTable(showCardList,"xpp")

        local showlist = {{}}

        local cardsize = cc.size(42,52)
        local step = 21
        local colstep = 15

        local function getColWidth(cards)
            return cardsize.width*#cards-((#cards-1)*step)
        end

        for i,v in ipairs(showCardList) do
            local node = cc.Node:create()
                :addTo(self.showCardNode)

            for m,n in ipairs(v.cards) do
                local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, n)
                card:addTo(node)
                card:setPosition(cc.p(cardsize.width/2+step*(m-1),-cardsize.height/2))
            end

            local isinsert = false
            local index = 0
            local posx = 0
            while (not isinsert) do
                index = index + 1
                if not showlist[index] then
                    showlist[index] = {}
                end
                local num = 0
                posx = 0
                for _,cols in ipairs(showlist[index]) do
                    num = num + #cols
                    posx = posx + getColWidth(cols) + colstep
                end
                num = num + #v.cards
                if num <= 9 then
                    table.insert(showlist[index],v.cards)
                    isinsert = true
                end
            end

            node:setPosition(cc.p(posx,-(index-1)*cardsize.height))

        end
        printTable(showlist,"xpp")
        
    end

    function TableBottom:getShowPos(token)

        local showlist = {{}}

        local cardsize = cc.size(42,52)
        local step = 21
        local colstep = 15

        local function getColWidth(cards)
            return cardsize.width*#cards-((#cards-1)*step)
        end

        local showCardList = self:getShowCardList()
        for i,v in ipairs(showCardList) do
            local isinsert = false
            local index = 0
            local posx = 0
            while (not isinsert) do
                index = index + 1
                if not showlist[index] then
                    showlist[index] = {}
                end
                local num = 0
                posx = 0
                for _,cols in ipairs(showlist[index]) do
                    num = num + #cols
                    posx = posx + getColWidth(cols) + colstep
                end
                num = num + #v.cards
                if num <= 9 then
                    table.insert(showlist[index],v.cards)
                    isinsert = true
                end
            end
            if i == #showCardList then
                print("====================位置")
                return cc.p(posx,-(index-1)*cardsize.height)
            end
        end

        return self.nextShowPos
    end

    --根据有几排来调整展示位和操作按钮的坐标
    function TableBottom:getPosByShowRow()
        --x为展示位的y坐标
        --y为操作按钮的y坐标
        local _pos = cc.p(0, -35)
        return _pos
    end


    function TableBottom:refreshPutoutTile()
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local width = 42
        local height = 52
        local maxcolumnum = 4
        if self.gamescene:getTableConf().seat_num == 3 then
            width = 33
            maxcolumnum = 6
        end
        self.outcardspr = { }
        self.nextPutPos = cc.p(0+width/2, -height/2)
        local putouttile 
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.XE96 then
            print("....TableBottom 下方 的的牌")
            putouttile =  clone(self.gamescene:getDiscardTileByIdx(self.tableidx))
        else
            putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        end

        for i,v in ipairs(putouttile) do
            local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%maxcolumnum == 0 then
                self.nextPutPos = cc.p(0+width/2, -height/2 - height*i/maxcolumnum)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x+width,self.nextPutPos.y))
            end

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
        end
    end

    function TableBottom:refreshDiscardTile()

        print(".......TableBottom:refreshDiscardTile()")
        if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.XE96 then
            self.qiCardNode:setVisible(false)
            return
        end
        self.qiCardNode:setVisible(true)
        self.qiCardNode:getChildByName("sprnode"):removeAllChildren()
        self.qicardspr = { }

        local width = 42
        local height = 52

        self.nextDiscardPos = cc.p(width/2,0)
        local qiCardTile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        if  qiCardTile and #qiCardTile > 0 then
            self.qiCardNode:setVisible(true)
        end

        for i,v in ipairs(qiCardTile) do
            local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextDiscardPos)
            self.qiCardNode:getChildByName("sprnode"):addChild(card)
            table.insert(self.qicardspr, card)

          
            self.nextDiscardPos = cc.p(cc.p(self.nextDiscardPos.x+25,self.nextDiscardPos.y))
        end
    end


    function TableBottom:showActionView(data)
        self.actionview:showAction(data)
    end

    function TableBottom:tryChupai(tile)
        if self:getIsMyTurn() and not self.actionview:getIsShow() then
           
            if not self.chuData then
                return false
            end

            printTable(self.chuData)

            local value = tile:getCardValue()
            print("==================tryChupai，value ＝ ", value)

            local _index = self.chuData.seat_index
            local _type = self.chuData.act_type
            local _card = value
            local _cards = self.chuData.col_info and self.chuData.col_info.cards
            local _token = self.chuData.action_token
            
            Socketapi.request_do_action(_index, _type, _card, _cards, _token)

            self:setIsMyTurn(false)
            self:showShouZhi(false)
            self.gamescene:deleteAction("TableBottom:tryChupai")

            return true
        end
        return false
    end

    function TableBottom:addTileEvent(tile)
        -- body
        local beganposx, beganposy = tile:getOriginPos()
        local function shallResponseEvent()
            if not tolua.cast(tile, "cc.Node") then
                return false
            end

            if self.gamescene:getSeatInfoByIdx(self.tableidx).state == 99 then
                return false
            end

            if self.isTouched then
                return false
            end

            if tile:getIsGray() then
                return false
            end
            return true
        end


        local function onTouchBegan(touch, event)
            -- print("..............onTouchBegan.......1")
            -- print("...........self.isTouched = ",self.isTouched)
            if not shallResponseEvent() then
                return
            end
            -- print("..............onTouchBegan.......2")

            beganposx, beganposx = tile:getPosition()
            local locationInNode = tile:getbg():convertToNodeSpace(touch:getLocation())
            local s = tile:getbg():getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height);
            if cc.rectContainsPoint(rect, locationInNode) then
                tile:setCardOpacticy(255 * 0.4)
                self:addMoveSprite(tile, touch:getLocation())
                self.isTouched = true
                return true
            end
        end

        local function onTouchMove(touch, event)
            -- if not shallResponseEvent() then
            -- 	return
            -- end
            -- tile:setLocalZOrder(5)
            -- local target = event:getCurrentTarget()
            -- target:setPosition(cc.p(target:getPositionX() + touch:getDelta().x,target:getPositionY() + touch:getDelta().y))

            local touchPoint = touch:getLocation()
            self:setMoveSpritePos(touchPoint)

        end

        local function onTouchEnd(touch, event)
            self.isTouched = false
            -- if not shallResponseEvent() then
            -- 	return
            -- end
            -- print("..............onTouchEnd.......1")
            tile:setCardOpacticy(255)

            if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
                if self.moveCardImg:getPositionY() > self.shouzhiNode:getPositionY() then
                    if self:tryChupai(tile) then
                        self:deleteMoveSprite()
                        -- 重新整理位置，扣出一张牌
                        return
                    else
                        -- self.moveCardImg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3,cc.p(orginposx,orginposy))),cc.CallFunc:create(function()
                        -- 	self:deleteMoveSprite()
                        -- end)))
                    end
                end
                -- 重新调整位置
                local worldpos1 = self.handCardNode:convertToWorldSpace(cc.p(tile:getPosition()))

                self.moveCardImg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3, worldpos1)), cc.CallFunc:create( function()
                    self:deleteMoveSprite()
                end )))

            end

        end

        local function onTouchCancell(touch, event)
            print("onTouchCancel======")
            self.isTouched = false
            tile:setCardOpacticy(255)
            if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
                -- 重新调整位置
                local worldpos1 = self.handCardNode:convertToWorldSpace(cc.p(tile:getPosition()))

                self.moveCardImg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3, worldpos1)), cc.CallFunc:create( function()
                    self:deleteMoveSprite()
                end )))

            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(onTouchCancell, cc.Handler.EVENT_TOUCH_CANCELLED)
        local eventDispatcher = tile:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tile)
    end

    -- 添加移动精灵
    function TableBottom:addMoveSprite(tile, touchPoint)
        local cardValue = tile:getCardValue()

        local old = glApp:getCurScene():getChildByName("movePai")
        if WidgetUtils:nodeIsExist(old) then
            old:removeFromParent()
            old = nil
        end

        local _paiStr = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, cardValue)
        if _paiStr then
            self.moveCardImg = _paiStr
            _paiStr:setName("movePai")
            glApp:getCurScene():addChild(self.moveCardImg, 99)
            self:setMoveSpritePos(touchPoint)

            if self.gamescene:getIsJiangCard(cardValue) then
                _paiStr:showJiang()
            end
        end
    end
    -- 删除
    function TableBottom:deleteMoveSprite()
        if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
            self.moveCardImg:setVisible(false)
            self.moveCardImg:removeFromParent()
            self.moveCardImg = nil
            self.isTouched = false
        end
    end
    -- 设置位置
    function TableBottom:setMoveSpritePos(touchPoint)
        if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
            self.moveCardImg:setPosition(cc.p(touchPoint.x, touchPoint.y))
        end
    end

    return TableBottom
end

return TableFactory