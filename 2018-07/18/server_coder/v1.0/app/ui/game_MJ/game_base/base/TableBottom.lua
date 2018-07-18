local TableFactory = { }
function TableFactory.create(tableClass, actionClass)
    local TableBottom = class("TableBottom", tableClass)
    local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
    local ROW = 5
    local COL = 15
    local ALL_GEZI = ROW * COL

    --特殊牌站宽
    local peroff = 210
    --摸牌的间隔
    local  shoupaioff = 23
    --我自己看到的牌间隔
    local perMyself = 85

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
        if  self.gamescene:getTableConf().seat_num == 2 then
            self.outCardNode:setPosition(cc.p(0,140))
        else
            self.outCardNode:setPosition(cc.p(0,160))
        end

       


        self.cellItem = self.node:getChildByName("huCell"):setVisible(false)
        self.cellItem:retain()

        self.cellItem:removeFromParent()

         self:initHuPaiView()

    end

    function TableBottom:getIsMyTurn()
        return self.ismyturn
    end

    function TableBottom:setIsMyTurn(bool)
        self.ismyturn = bool

    end
    -- 显示手指
    function TableBottom:showShouZhi(bol, data)
        print("....... 显示手指 TableBottom:showShouZhi bol =", bol)
        self.shouzhiNode:setVisible(false)
        self.chuData = data
    end

    -- 设置不能处理的牌的list
    function TableBottom:setBanedCardsList(list)
        -- print("........设置不能处理的牌的list")
        -- printTable(list,"xp")

        self.banedList = list
    end

    function TableBottom:refreshHandCards(move)

        print(".TableBottom:refreshHandCards ")
        self:updataHuXiText()
        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)
        -- self:deleteMoveSprite()
        self.handcardspr = {}
        self.showcardspr = {}
        self.showJokerGangspr = {} --恩施麻将的癞子痞子杠
        self.node:setLocalZOrder(0)

        local showCol = clone(self.gamescene:getShowCardsByIdx(self.tableidx))
        printTable(showCol,"xp10")
        local offx = 0
        if  showCol and #showCol > 0 then
            for k,v in pairs(showCol) do
                if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
                    local isHave = false
                    for kk,vv in pairs(self.showJokerGangspr) do
                        if vv:getCardValue() == v.dest_card then
                            vv.num = vv.num + 1
                            vv:setCardNum(vv.num)
                            isHave = true
                        end
                    end

                    if isHave == false then
                        local ma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,v.dest_card)
                        ma.num = 1
                        self.handCardNode:addChild(ma)
                        ma:setScale(0.75)
                        table.insert(self.showJokerGangspr,ma)
                        ma:setCardNum(1)
                        if self.gamescene:getIsJokerCard(v.dest_card) then
                            ma:showJoker()
                        end
                        if self.gamescene:getIsPiziCard(v.dest_card) then
                            ma:showPizi()
                        end
                        ma:setOriginPos(180+#self.showJokerGangspr*55*0.75, 135)
                        ma:setPosition(cc.p(180+#self.showJokerGangspr*55*0.75, 135))
                    end
                else

                    if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                        for _k,_v in pairs(v.cards) do
                            if _v == v.dest_card  then
                                table.remove(v.cards,_k)
                            end
                        end
                        table.insert(v.cards,2,v.dest_card)
                    end

                    for kk,vv in pairs(v.cards) do
                        if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG and kk == 4 then
                            vv = 0
                        end
                        local ma = MaJiangCard.new(MAJIANGCARDTYPE.BOTTOM,vv)
                        self.handCardNode:addChild(ma)
                        table.insert(self.showcardspr,ma)
                        if self.gamescene:getIsJokerCard(vv) then
                            ma:showJoker()
                        end

                        if self.gamescene:getIsPiziCard(vv) then
                            ma:showPizi()
                        end

                        ma:setOriginPos(offx, 30)
                        ma:setPosition(cc.p(offx,30))
                      
                        -- if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                        --     if  vv == v.dest_card  then
                        --         ma:setYellow()
                        --     end
                        -- end

                        if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
                            if  kk == 4  then
                                ma:setPosition(cc.p(offx-55*2,48))
                            end
                        end
                        if  kk ~= 4  then
                            offx = offx + 55
                        end
                    end
                    offx = offx + 15
                end
                if k == #showCol then
                    offx = offx + 25
                end
            end
        end 

        local handcards = clone(self.gamescene:getHandCardsByIdx(self.tableidx))
        table.sort(handcards)

        if  handcards and #handcards > 0 then
            for i,v in ipairs(handcards) do
                if  self.isChiPeng and i == #handcards then
                    self:showMoPai(v)
                else
                    local ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,v)
                    table.insert(self.handcardspr,ma)
                    ma:setAnchorPoint(cc.p(0.5,0.5))
                    ma.index = i
                    if self.gamescene.name == "GameScene" then
                        self:addCardEvent(ma)
                    end

                    self.handCardNode:addChild(ma)

                    ma:setOriginPos(offx, 40)
                    ma:setPosition(cc.p(offx,40))

                    if self.gamescene:getIsJokerCard(v) then
                        ma:showJoker()
                    end

                    if self.gamescene:getIsPiziCard(v) then
                        ma:showPizi()
                    end
                     -- ma:setJiaoTips()
                    offx = offx + perMyself
                end

              
            end

         end
    end

    --添加新摸的牌
    function TableBottom:showMoPai(value)

        print("...........TableBottom:addputout .......value = ",value)

        local showCol = self.gamescene:getShowCardsByIdx(self.tableidx)
        local offx = 20
        if  showCol and #showCol > 0 then
             for k,v in pairs(showCol) do
                if v.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
                    for kk,vv in pairs(v.cards) do
                        if  kk ~= 4  then
                            offx = offx + 55
                        end
                    end
                    offx = offx + 15
                end
                if k == #showCol then
                    offx = offx + 25
                end
            end
        end
        
        local handcards = self.gamescene:getHandCardsByIdx(self.tableidx)
        if  handcards and #handcards > 0 then
            offx = offx + (#handcards-1) * perMyself
        end

        local ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,value)
        table.insert(self.handcardspr,ma)
        self:addCardEvent(ma)
        self.handCardNode:addChild(ma)

        ma:setOriginPos(offx, 40)
        ma:setPosition(cc.p(offx,40))
        if self.gamescene:getIsJokerCard(value) then
            ma:showJoker()
        end

        if self.gamescene:getIsPiziCard(value) then
            ma:showPizi()
        end
        self:setHuViewIsShow(false)
        return ma
    end

    function TableBottom:refreshOutCards()

        print("...........TableBottom:refreshOutCards()")
        self:updataHuXiText()
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)

        self.outcardspr = { }
        self.nextPutPos = cc.p(0-BASECARDWIDTH/2, BASECARDHEIGHT/2)
        local putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        
        printTable(putouttile,"xp70")

        for i,v in ipairs(putouttile) do
            local ma = self:addputout(v)
            table.insert(self.outcardspr,ma)
        end
    end

    --添加一张打出去的牌
    function TableBottom:addputout(value)
        print("...........TableBottom:addputout .......value = ",value)
        local totall = #self.outcardspr + 1
        local ma = MaJiangCard.new(MAJIANGCARDTYPE.TOP,value)
        ma:setLocalZOrder(100-totall)
        ma:setAnchorPoint(cc.p(0,0))
        self.outCardNode:addChild(ma)

        if self.gamescene:getIsJokerCard(value) then
            ma:showJoker()
        end
        if self.gamescene:getIsPiziCard(value) then
            ma:showPizi()
        end

        local _num = 12
        if self.gamescene:getTableConf().seat_num == 2 then 
            _num = 14
        end
        local _x = ((totall-1)%_num - _num/2.0 )*42
        local _y = math.floor((totall-1)/_num)*50

        ma:setPosition(cc.p(_x,_y))
        ma:setTag(totall)
        return ma
    end


    function TableBottom:showActionView(data)
        self.actionview:showAction(data)
    end

    function TableBottom:tryChupai(tile)
        -- if self:getIsMyTurn() and not self.actionview:getIsShow() then
            if self:getIsMyTurn() then
           
            if not self.chuData then
                return false
            end

            local value = tile:getCardValue()
            local _index = self.chuData.seat_index
            local _type = self.chuData.act_type
            local _card = value
            local _cards = self.chuData.col_info and self.chuData.col_info.cards
            local _token = self.chuData.action_token
            
            Socketapi.request_do_action(_index, _type, _card, _cards, _token)

            self:setIsMyTurn(false)
            self:showShouZhi(false)


            self.gamescene:resignTile()
            self:hideJiaoTips()
            self.gamescene:setRunningAction(0.3)

            local data  = 
            {
                ["new_sdr_action_flow"] = 
                 {
                    ["action"] =  
                    {
                        ["dest_card"] =  _card,
                        ["tid"] = LocalData_instance.uid,
                        ["seat_index"] = _index,
                        ["act_type"] = _type,
                        ["ismyself"] = true,
                    },
                },
            }
            ComNoti_instance:dispatchEvent("cs_notify_action_flow",data)

            if tile:getIsJiao() then
                self:setHuPaiInfo(value)
            end
            return true
        end
        return false
    end

    function TableBottom:selectTile(tile)
        AudioUtils.playEffect("xuanpai")

        for i,v in ipairs(self.handcardspr) do
            local orginposx,orginposy = v:getOriginPos()
            
            if v.isselect and v.tileBack then
                v.tileBack()
            else
                v:stopAllActions()
                v.isbacking = false
                v:setPosition(cc.p(orginposx,orginposy))
            end

            v.isselect = false
        end

        tile:stopAllActions()
        tile.isselect = true
        tile.isbacking = false
        local orginposx,orginposy = tile:getOriginPos()
        tile:setPosition(cc.p(orginposx,orginposy+30))
        self.selectMa = tile

        if tile:getIsJiao() then
           self:setHuPaiInfo(tile:getCardValue())
        end

        self.gamescene:seekAndSignTile(tile:getCardValue())
        AudioUtils.playEffect("ddz_xuanpai")
    end

    function TableBottom:downAllCards()
        for i,v in ipairs(self.handcardspr) do
            local orginposx,orginposy = v:getOriginPos()
            
            if not v.istouching and not v.isbacking then
                if v.isselect and v.tileBack then
                    v.tileBack()
                else
                    v:stopAllActions()
                    v.isbacking = false
                    v:setPosition(cc.p(orginposx,orginposy))
                end

                v.isselect = false
            end
        end
    end

    function TableBottom:addCardEvent(tile)
        -- body
        local beganposx,beganposy = tile:getOriginPos()

        local function shallResponseEvent()
            if not tolua.cast(tile,"cc.Node") then
                return false
            end

            if self.gamescene:getSeatInfoByIdx(self.tableidx).state == 99 then
                return false
            end

            -- if tile:getIsJoker() then
            --     return false
            -- end

            if tile:getIsGray() then
                return false
            end

            if tile.isbacking then
                return false
            end

            return true
        end

        local function tileBack()
            if not tolua.cast(tile,"cc.Node") then
                return
            end

            local orginposx,orginposy = tile:getOriginPos()

            tile:stopAllActions()
            tile.isbacking = true
            tile.isselect = false
            tile:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3,cc.p(orginposx,orginposy))),cc.CallFunc:create(function()
                    tile:setLocalZOrder(1)
                    tile.isbacking = false
                    self.node:setLocalZOrder(0)
                    end)))

            self.gamescene:resignTile()
        end
        tile.tileBack = tileBack

        local function chuPai()
            if not self:tryChupai(tile) then
                tileBack()
            end
        end

        local function onTouchBegan(touch, event)
            if not shallResponseEvent() then
                return
            end
            beganposx,beganposy = tile:getPosition()
            local locationInNode = tile:getbg():convertToNodeSpace(touch:getLocation())
            local s = tile:getbg():getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height); 
            if cc.rectContainsPoint(rect,locationInNode) then
                tile.istouching = true
                return true
            end
        end

        local function onTouchMove(touch, event)
            if not shallResponseEvent() then
                return
            end
            tile:setLocalZOrder(5)
            self.node:setLocalZOrder(1)
          
             if touch:getDelta().x > 3 or touch:getDelta().y > 3 then
                self:downAllCards()
            end

            local target = event:getCurrentTarget()
            target:setPosition(cc.p(target:getPositionX() + touch:getDelta().x,target:getPositionY() + touch:getDelta().y))
        end

        local function onTouchEnd(touch, event)
            tile.istouching = false
            if not shallResponseEvent() then
                return
            end
            local curposx,curposy = tile:getPosition()
            if tile.isselect then
                if (curposy - beganposy) < 3 and (curposy - beganposy) > -3 and (curposx - beganposx) < 3 and (curposx - beganposx) > -3 then
                    chuPai()
                    return
                end
            end

            local orginposx,orginposy = tile:getOriginPos()
            if tile:getPositionY() - orginposy > 100 then
                chuPai()
            elseif (curposy - orginposy < 30) and (curposy - orginposy >= -3) and (curposx - orginposx > -10) and (curposx - orginposx < 10)  then
                self:selectTile(tile)
            else
                tileBack()
            end
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


    function TableBottom:initHuPaiView( )
        self.huView = ccui.ImageView:create("gamemj/hu_bg.png")
            :setScale9Enabled(true)
            :setCapInsets(cc.rect(30, 30, 19,107))
            :setAnchorPoint(cc.p(0,0))
        self.huView:setPositionY(120)
        self.node:addChild(self.huView,9)
   
        self.huView:setContentSize(cc.size(154+(163+10)*1,167))
        self.huView:setPositionX(-self.huView:getContentSize().width/2.0)
        self.huView:setVisible(false)
        -- self:setHuPaiInfo()
       
    end

    function TableBottom:setXiaJiaoInfo( data )
        for k,v in pairs(self.handcardspr) do
            v:setJiaoTips()
        end
    end

    function TableBottom:hideJiaoTips( data )
        for k,v in pairs(self.handcardspr) do
            v:hideJiaoTips()
        end
    end

    function TableBottom:setHuPaiInfo( card )
        self.huView:removeAllChildren()

        -- local _data =
        -- {
        --     {
        --         ["card"] = 1,
        --         ["num"] = 2,
        --         ["bei"] = 3,
        --     },
        --     {
        --         ["card"] = 2,
        --         ["num"] = 2,
        --         ["bei"] = 3,
        --     },
        --     {
        --         ["card"] = 3,
        --         ["num"] = 2,
        --         ["bei"] = 3,
        --     },
        --     {
        --         ["card"] = 4,
        --         ["num"] = 2,
        --         ["bei"] = 3,
        --     },
        -- }

        
        local _all = #_data

        --30+54+20+(12+163)*n-12+30
        local _all_w = _all%5
        if _all >= 5 then
            _all_w = 5
        end
        local _width = 104+(163+12)*_all_w+30-12
        --28+(111+15)*n+28-15
        local _height = 28+(111+15)*(math.floor((_all-1)/5)+1)+28-15

        self.huView:setContentSize(cc.size(_width,_height))

        self.huView:setPositionX(-_width/2.0)


        for k,v in pairs(_data) do

            local cell = self.cellItem:clone()
            cell:setVisible(true)
            cell:setAnchorPoint(0,1)
            local _y = _height - 22 -(111+15)*(math.floor((k-1)/5))
            local _x = k%5 == 0 and 5 or k%5

            cell:setPosition(cc.p(104+(163+12)*(_x-1),_y))
            self.huView:addChild(cell)


            local ma = MaJiangCard.new(MAJIANGCARDTYPE.MYSELF,v.card)
            ma:setPosition(cc.p(43,55))
            ma:setScale(0.75)
            cell:addChild(ma)
            if self.gamescene:getIsJokerCard(v.card) then
                ma:showJoker()
            end
            if self.gamescene:getIsPiziCard(v.card) then
                ma:showPizi()
            end

            cell:getChildByName("num_num"):setString(v.num)
            cell:getChildByName("bei_num"):setString(v.bei)
        end

        local tip = cc.Sprite:create("gamemj/hu_tips.png")
        tip:setAnchorPoint(cc.p(0,0.5))
        tip:setPosition(cc.p(30,_height/2.0+10))
        self.huView:addChild(tip)

    end

    function TableBottom:setHuViewIsShow(show)
        self.huView:setVisible(show)
    end

    return TableBottom
end

return TableFactory