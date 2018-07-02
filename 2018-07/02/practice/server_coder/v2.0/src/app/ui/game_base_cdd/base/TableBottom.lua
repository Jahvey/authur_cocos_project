local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableBottom = class("TableBottom", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"

    function TableBottom:init()
        -- body

    end

    function TableBottom:initLocalConf()
        self.iscantouch =true
        self.isanmati = false
        self.MsgLayerOffset = { posx = 30, posy = 130 }
        self.localpos = 1
        self.tianpaitype = 1

        self.cardAnchor = cc.p(0.5,0.5)  

        self.actionview = actionClass.new(self.gamescene)
        self.actionview:setPosition(cc.p(display.width / 2, display.height / 2))
        self.gamescene:addChild(self.actionview)

        self.diPaiView = self.gamescene.layout:getChildByName("dipai")
        self.diPaiView:setVisible(false)

        if self.gamescene:getTableConf().ttype == HPGAMETYPE.MCDDZ then

            local  _laiziView = ccui.ImageView:create("cocostudio/ui/ddz/dipai_bg.png")
            _laiziView:setPositionX(self.diPaiView:getPositionX()+145)
            _laiziView:setPositionY(self.diPaiView:getPositionY()+35)
            _laiziView:setContentSize(cc.size(25+37,70))
            _laiziView:setScale9Enabled(true)
            _laiziView:setCapInsets(cc.rect(7, 21, 10, 24))

            self.gamescene.layout:addChild(_laiziView)

            self.laiZiBack = ccui.ImageView:create("gameddz/laiz_back.png")
      
            local _size = _laiziView:getContentSize()
            printTable(_size,"xp66")

            self.laiZiBack:setAnchorPoint(cc.p(0.5,0.5))
            
            self.laiZiBack:setPositionX(_size.width/2.0)
            self.laiZiBack:setPositionY(_size.height/2.0)

            _laiziView:addChild(self.laiZiBack)

            _laiziView:setVisible(false)
            self.laiziView = _laiziView
        end



        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("bottom")

        self.cannotspr = cc.Sprite:create("gameddz/hand_no_put_card_prompt.png")
        self.node:addChild(self.cannotspr)
        self.cannotspr:setVisible(false)
        self.cannotspr:setPosition(cc.p(self.handcardnode:getPositionX(),self.handcardnode:getPositionY()+self.cardheight/2))
        self:_initHandCard()

        self.btn1 = self.node:getChildByName("btn1")
        self.btn2 = self.node:getChildByName("btn2")
        self.btn3 = self.node:getChildByName("btn3")
        self.btn1:setVisible(false)
        self.btn2:setVisible(false)
        self.btn3:setVisible(false)

        self.sort_hcng = cc.UserDefault:getInstance():getIntegerForKey("sort_hcng",0)

        self.btn3:getChildByName("icon"):setTexture("cocostudio/ui/ddz/tipsort"..(self.sort_hcng)..".png")


        WidgetUtils.addClickEvent(self.btn1, function( )
            self.tipstable = self.gamescene.Suanfuc:gettips(self.gamescene:getHandTileByIdx(self.gamescene:getMyIndex()),{type =poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = 4,num = 1})
            if #self.tipstable > 0 then
                if self.tipstable[self.tipnum] == nil then
                    self.tipnum = 1
                end
                -- print("....提示 ")
                -- printTable(self.tipstable[self.tipnum],"xp69")

                self:showTip(self.tipstable[self.tipnum].values)
                self.tipnum = self.tipnum + 1


            end
        end)


        WidgetUtils.addClickEvent(self.btn3, function( )
            if self.iscantouch then
                self.sort_hcng = (self.sort_hcng + 1)%3
                self.btn3:getChildByName("icon"):setTexture("cocostudio/ui/ddz/tipsort"..(self.sort_hcng)..".png")
                self:refreshHandTile()
            end
        end)

        WidgetUtils.addClickEvent(self.btn2, function( )
            if self.tianpaitype == 2 then
                local lipaicard = {}
                for i,v in ipairs(self.lipailist) do
                    for i1,v1 in ipairs(v) do
                       lipaicard[v1] = 1
                    end
                end
                local selecttab = {}
                local selectlipai = {}
                for i,v in ipairs(self._pokers) do
                    if v:getSelected() and lipaicard[v:getPoker()] == nil then
                        table.insert(selecttab,v:getPoker())
                    elseif v:getSelected() and lipaicard[v:getPoker()] then
                        table.insert(selectlipai,v:getPoker())
                    end
                end
                local selectlipaireal = {}
                for i,v in ipairs(selectlipai) do
                    selectlipaireal[v]=  1
                end
                print("-----1")
                if #selectlipai == 0 then
                    print("1")
                    self.lipailist = {}
                else
                    print("2")
                    if #selecttab == 0 then
                        for i,v in ipairs(self.lipailist) do
                            local localtable = {}
                            for i1,v1 in ipairs(v) do
                               if selectlipaireal[v1] == nil then
                                    table.insert(localtable,v1)
                               end
                            end
                            self.lipailist[i] = localtable
                        end
                    end
                end

                
            else
                local lipaicard = {}
                for i,v in ipairs(self.lipailist) do
                    local isallhave =  true
                    for i1,v1 in ipairs(v) do
                       lipaicard[v1] = 1
                    end
                end
                local selecttab = {}
                for i,v in ipairs(self._pokers) do
                    if v:getSelected() and lipaicard[v:getPoker()] == nil then
                        table.insert(selecttab,v:getPoker())
                    end
                end
                if #selecttab > 0 then
                    table.insert(self.lipailist,1,selecttab)
                end
            end
            self:refreshHandTile()
        end)


    end

    function TableBottom:getIsMyTurn()
        return self.ismyturn
    end

    function TableBottom:setIsMyTurn(bool)
        self.ismyturn = bool
    end
    function TableBottom:setbtn2()
        local isallnotselect = true
        for i,v in ipairs(self._pokers) do
            if v:getSelected() then
                isallnotselect = false
            end
        end
        if isallnotselect then
            self.tianpaitype = 2
        else
            local lipaicard = {}
            for i,v in ipairs(self.lipailist) do
                for i1,v1 in ipairs(v) do
                   lipaicard[v1] = 1
                end
            end
            local selecttab = {}
            for i,v in ipairs(self._pokers) do
                if v:getSelected() and lipaicard[v:getPoker()] == nil then
                    table.insert(selecttab,v:getPoker())
                end
            end
            if #selecttab == 0 then
                self.tianpaitype = 2
            else
                self.tianpaitype = 1
            end

        end
        self.btn2:getChildByName("icon"):setTexture("cocostudio/ui/ddz/lipai"..(self.tianpaitype)..".png")
    end
    function TableBottom:sortdata( handtile )
        local realtable = {}
        for i,v in ipairs(handtile) do
            realtable[v] = 1
        end
        local reallipailist = {}
        for i,v in ipairs(self.lipailist) do
            local isallhave =  true
            for i1,v1 in ipairs(v) do
                if realtable[v1] == nil then
                    isallhave = false
                end
            end
            if isallhave then
                table.insert(reallipailist,v)
            end
        end
        local reallipai = {}
        for i,v in ipairs(reallipailist) do
            for i1,v1 in ipairs(v) do
                realtable[v1] = nil
                table.insert(reallipai,v1)
            end
        end
        local lastpai = {}
        for k,v in pairs(realtable) do
            table.insert(lastpai,k)
        end
        if self.sort_hcng == 0 then
            self.gamescene.Suanfuc:sort( lastpai )
        elseif self.sort_hcng == 1 then
            self.gamescene.Suanfuc:sort1( lastpai )
        elseif self.sort_hcng == 2 then
            self.gamescene.Suanfuc:sort2( lastpai )
        end
        local handcards = {}
        for i,v in ipairs(reallipai) do
            table.insert(handcards,{value = v,isan = true})
        end

        for i,v in ipairs(lastpai) do
            table.insert(handcards,{value = v,isan = false})
        end
        return handcards
    end
    function TableBottom:refreshHandTile(move)
        print("理牌 move = ",move)
        self.tipnum = 1
        if  self.isanmati  then
            return
        end
        if move then
            self.isanmati = true
            self.iscantouch =false
        else
            self.iscantouch = true
        end
        self._pokers = {}
        self.handcardnode:removeAllChildren()
        self.handcardnode:setVisible(true)

        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        if move then
            print(".......................手牌生成，排序 move")
            printTable(handtile,"xp66")
            local totall = #handtile
            local index = 0

            self.nodebegin:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function( ... )
                    if index%2 == 0 then
                        AudioUtils.playEffect("ddz_fapai")
                    end

                    index = index + 1
                    if index > totall then
                        self.nodebegin:stopAllActions()
                        self.isanmati = false
                        self:refreshHandTile(false)
                        return 
                    else
                        self.handcardnode:removeAllChildren()
                        for i=1,index do
                            local pokerCard = LongCard.new(handtile[i])
                            pokerCard:setCardAnchorPoint(cc.p(0.5,0))
                            pokerCard:setPositionX((i-(index + 1) / 2)*55)
                            pokerCard.localposx = (i-(index + 1) / 2)*55
                            self.handcardnode:addChild(pokerCard)
                            table.insert(self._pokers ,pokerCard)
                        end
                    end
                    
            end))))
        else
             print(".......................手牌生成，排序 move111")
            -- if self.sort_hcng == 0 then
            --     self.gamescene.Suanfuc:sort( handtile )
            -- elseif self.sort_hcng == 1 then
            --     self.gamescene.Suanfuc:sort1( handtile )
            -- elseif self.sort_hcng == 2 then
            --     self.gamescene.Suanfuc:sort2( handtile )
            -- end

            local handtile = self:sortdata( handtile )
            local totall = #handtile
            for i,v in ipairs(handtile) do
                local pokerCard = LongCard.new(v.value)
                pokerCard:setCardAnchorPoint(cc.p(0.5,0))
                pokerCard:setPositionX((i-(totall + 1) / 2)*55)
                pokerCard.localposx = (i-(totall + 1) / 2)*55
                self.handcardnode:addChild(pokerCard)
                table.insert(self._pokers ,pokerCard)
                if v.isan then
                    pokerCard:setgray(true)
                else
                    pokerCard:setgray(false)
                end
            end
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.HCNG then
                    if #self._pokers > 0 then
                        self._pokers[#self._pokers]:setDizhutip()
                    end
                end
            end
            -- ming pai
            if self.gamescene:isMingPaiByIdx(self:getTableIndex()) then
                if #self._pokers > 0 then
                    self._pokers[#self._pokers]:showMingPai()
                end
            end
            self:setbtn2()
        end
        --print("0=9999999")
       
    end

    function TableBottom:_initHandCard()

    local istouchin = false
    local selectcards = 0
    local touchbeginindex = 0
    local function onTouchBegan(touch, event)
        print("touch")
        touchbeginindex = 0
        if #self._pokers == 0 then
            return false
        end
        print("1")
        if not self.iscantouch then
            return false
        end
        print("2")
        selectcards = 0
        -- AudioUtils.playEffect("ddz_xuanpai")
        -- istouchin = true
        for i,v in ipairs(self._pokers) do
            v.isnotmove = true
        end
        local totall = #self._pokers
       -- print("x:"..totall)
        for i=1,totall do
            if self._pokers[totall - i + 1] and self._pokers[totall - i + 1]._poker then
                local beginpos = self._pokers[totall - i + 1]._poker:convertTouchToNodeSpace(touch)
                -- print("x:"..beginpos.x)
                -- print("y:"..beginpos.y)
                local size =self._pokers[totall - i + 1]._poker:getContentSize()
                if self._pokers[totall - i + 1].isnotmove then
                    if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                        --posset(self._pokers[totall - i + 1])
                        self._pokers[totall - i + 1]:setSelected(not self._pokers[totall - i + 1]:getSelected())
                        self._pokers[totall - i + 1].isnotmove = false
                        --print("ture")
                        selectcards = selectcards + 1
                        touchbeginindex = totall - i + 1
                        AudioUtils.playEffect("ddz_xuanpai")
                        break
                    end
                end
            end
        end
        return true

    end

    local function onTouchMove(touch, event)
        -- AudioUtils.playEffect("ddz_xuanpai")
        local totall = #self._pokers
        for i=1,totall do
            if self._pokers[totall - i + 1] and self._pokers[totall - i + 1]._poker then
                local beginpos = self._pokers[totall - i + 1]._poker:convertTouchToNodeSpace(touch)
                local size =self._pokers[totall - i + 1]._poker:getContentSize()
                if self._pokers[totall - i + 1].isnotmove then
                     -- AudioUtils.playEffect("ddz_xuanpai")
                    if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                        self._pokers[totall - i + 1]:setSelected(not self._pokers[totall - i + 1]:getSelected())
                        self._pokers[totall - i + 1].isnotmove = false
                        selectcards = selectcards + 1
                        AudioUtils.playEffect("ddz_xuanpai")
                        break
                    end
               else
                    if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                        
                        break
                    end
                end
            end
        end
    end
    local function selectend(  )
        if selectcards >= 2 then
        end
        touchbeginindex = 0
        self:setbtn2()
    end
    local function onTouchEnd(touch, event)
        istouchin =false
        local touchendindex = 0
        local totall = #self._pokers
        for i=1,totall do
            if self._pokers[totall - i + 1] and self._pokers[totall - i + 1]._poker then
                local beginpos = self._pokers[totall - i + 1]._poker:convertTouchToNodeSpace(touch)
               
                local size =self._pokers[totall - i + 1]._poker:getContentSize()
                if size.width >= beginpos.x and beginpos.x>=0 and size.height >= beginpos.y and beginpos.y>=0 then
                    touchendindex = totall - i + 1
                    break
                end
            end
        end
      
        if touchendindex > 0 and touchbeginindex > 0 then
            local selecttable = {}

            for i=math.max(touchendindex,touchbeginindex),math.min(touchendindex,touchbeginindex),-1 do
                -- print("value",self.gamescene.Suanfuc:getrealvalue(self._pokers[i]:getPoker()) )
                table.insert(selecttable,self._pokers[i])
            end

            self.gamescene.Suanfuc:selectStraight(selecttable,self._pokers)
        end

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
    local eventDispatcher = self.handcardnode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.handcardnode)
end

    function TableBottom:showTip( values )


        -- printTable(values,"xp68")

        -- print("......#values ",#values)


        for i,v in ipairs(self._pokers) do
            v:setSelected(false)
            v.isselect = false
        end
        for i,v in ipairs(values) do
            for i1,v1 in ipairs(self._pokers) do
                if v1:getPoker() == v then
                    v1:setSelected(true)
                    v1.isselect = true
                end
            end
        end
        self:setbtn2()
    end
    function TableBottom:refreshShowTile()

        
    end

    function TableBottom:getShowPos()
        
    end

    function TableBottom:showActionView(data)
        self.actionview:showAction(data)
    end

    function TableBottom:tryChupai(actionview,data)
        local gettable = {}
        for i,v in ipairs(self._pokers) do
            if v:getSelected() then
                table.insert(gettable,v:getPoker())
            end
        end

        -- gettable = {0x1a,0x1a,0x19,0x18,0x18,0x17,0x17,0x16}
        local action = nil

        if #gettable == #self._pokers then
            action = self.gamescene.Suanfuc:getype(gettable,true)
        else
            if self.gamescene:getTableConf().ttype == HPGAMETYPE.MCDDZ or
            self.gamescene:getTableConf().ttype == HPGAMETYPE.ESDDZ then   --麻城和恩施要判断是否是拆了双王
                local handCards = self.gamescene:getHandTileByIdx(self.tableidx)
                if self.gamescene.Suanfuc:getIsTakeApartKing(gettable,handCards) == false then
                    action = self.gamescene.Suanfuc:getype(gettable,false)
                else
                    action = nil
                end
            else
                action = self.gamescene.Suanfuc:getype(gettable,false)
            end
        end

        print("action = ")
        printTable(action,"xp68")


        -- print("111111")
        if action == nil  then
            print('不存在的牌型')
            CommonUtils:prompt("您选择的牌型不正确")
        else
             -- print("22222")
            local cantable = {}
            if #action >= 2 then
                cantable = action
            else
                cantable[1] = action
            end
            local lastaction = nil 
            if self.gamescene.table_info.sdr_total_action_flows and #self.gamescene.table_info.sdr_total_action_flows > 0 then
                local totall = #self.gamescene.table_info.sdr_total_action_flows
                for i,v in ipairs(self.gamescene.table_info.sdr_total_action_flows) do
                    local action = self.gamescene.table_info.sdr_total_action_flows[totall-i+1].action
                    if action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                        lastaction = action
                        break
                    end
                end
            end

            -- printTable(lastaction,"xp66")
            
            -- printTable(cantable,"xp68")


            local realcantable = {}
            if lastaction == nil then
                realcantable = cantable
            else
                lastaction.type = lastaction.cardtype
                printTable(lastaction,"sjp3")
                 printTable(cantable,"sjp3")
                realcantable = self.gamescene.Suanfuc:comparetype(lastaction,cantable)
            end
            if #realcantable == 0 then
                print("2")
                CommonUtils:prompt("您选择的牌型不正确")
                return
            end
            print("seat:"..self.gamescene:getTableConf().seat_num)
            printTable(realcantable,"sjp3")
            if actionview.is_first_chu_pai then
                print('是第一手出牌')
                local isnotcall = false
                for i,v in ipairs(gettable) do
                    print("v:"..v)
                    if v == 0x14 then
                        isnotcall = true
                    end
                end
                if isnotcall == false then
                     CommonUtils:prompt("第一手牌必须包含 方块4 ")
                     return
                end
            else
                print('不是第一手出牌')
            end
            self.actionview:showcanAction(realcantable,gettable,data)
        end
    end
    function TableBottom:Chupai( tab,cards,data)
        printTable(cards,"sjp3")
        Socketapi.request_do_actionforddz(data.seat_index, data.act_type,data.action_token,tab.type,cards,tab.real,tab.num)
        self:delehandtiles(cards)
        self.actionview:setVisible(false)
    end
    function TableBottom:chuPaiAction(data,isan)

        -- print(".......TableBottom:chuPaiAction(")
        printTable(data,"sjp3")
        self.buchunode:setVisible(false)

        self.showcardnode:removeAllChildren()
        self.showcardnode:setVisible(true)
        local totall = #data.cards
        data.type = data.cardtype
        local cardslocal = self.gamescene.Suanfuc:getrealcardsTab(data.cards,data)
        local cards = {}
        for i,v in ipairs(cardslocal) do
            local pokerCard = LongCard.new(v.value)
            if v.islai or pokerCard:getPokerValue() == LocalData_instance:getLaiZiValuer() then
                pokerCard:setisshowLai(true)
            else
                pokerCard:setisshowLai(false)
            end
            pokerCard:setCardAnchorPoint(cc.p(0.5,0.5))
            pokerCard:setScale(CHU_CARD_SCALE)
            pokerCard:setPositionY(self.cardheight*CHU_CARD_SCALE/2)
            pokerCard:setPositionX((i-(totall + 1) / 2)*55*CHU_CARD_SCALE)
            self.showcardnode:addChild(pokerCard)
            table.insert(cards,pokerCard)
        end
        if self.gamescene:getDealerIndex() == self:getTableIndex() then
            if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.HCNG then
                if #cards > 0 then
                    cards[#cards]:setDizhutip()
                end
            end
        end
        -- ming pai
        if self.gamescene:isMingPaiByIdx(self:getTableIndex()) then
            if #cards > 0 then
                cards[#cards]:showMingPai()
            end
        end

        if isan then
            local showpos = cc.p(0,self.cardheight*CHU_CARD_SCALE/2)
            showpos = self.showcardnode:convertToWorldSpace(showpos)
            self:playCardtypeAn(data,showpos)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
        
    end

    --叫地主牌
    function TableBottom:updateDiZhuCards(isShow,pokers)

        if self.gamescene:getTableConf().ttype == HPGAMETYPE.HCNG then
            self.diPaiView:setVisible(false)
            return 
        end
        print("[DdzView:updateDiZhuCards]1",isShow)
        printTable(pokers,"xp67")
        local cardBg = self.diPaiView:getChildByName("bg")
        cardBg:removeAllChildren()
        if isShow then 
            self.diPaiView:setVisible(true)
            if pokers then 
                if cardBg then
                    local width = 3*37
                    if #pokers == 4 then
                        width = 3*37+25
                    end
                    print("pokers:"..#pokers)
                    cardBg:setContentSize(cc.size(width,70))
                end
                for i = 1, table.getn(pokers) do
                    local pokerCard = LongCard.new(pokers[i])
                    pokerCard:setScale(0.28)
                    pokerCard:setPosition(cc.p(i*26 +4,35))
                    cardBg:addChild(pokerCard)
                end
            end
        else
            self.diPaiView:setVisible(false)
        end
    end

    function TableBottom:updateLaiZiCards(isShow,poker)

        print("......setLaiZiCards = ",poker)
        -- printTable(poker,"xp67")

        self.laiZiBack:removeAllChildren()
        if isShow then
            self.laiziView:setVisible(true)
            if poker ~= nil and  poker ~= 0  then 
                local pokerCard = LongCard.new(poker)
                pokerCard:setScale(0.28)
                pokerCard:setPosition(cc.p(21,26))
                self.laiZiBack:addChild(pokerCard)
            end
        else
            self.laiziView:setVisible(false)
        end

    end

    function TableBottom:showCannotPut()
        self.cannotspr:setVisible(true)
        for i,v in ipairs(self._pokers) do
            v:setgray(true)
        end
    end

    function TableBottom:hideCannotPut()
        self.cannotspr:setVisible(false)
        for i,v in ipairs(self._pokers) do
            v:setgray(false)
        end
        self:refreshHandTile()
    end

    function TableBottom:updatastate(info)
        if info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
            self.btn1:setVisible(true)
            self.btn2:setVisible(true)
            self.btn3:setVisible(true)
        else
            self.btn1:setVisible(false)
            self.btn2:setVisible(false)
            self.btn3:setVisible(false)
        end
    end




    return TableBottom
end


return TableFactory