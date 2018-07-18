local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableBottom = class("TableBottom", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"

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
                realcantable = self.gamescene.Suanfuc:comparetype(lastaction,cantable)
            end
            if #realcantable == 0 then
                CommonUtils:prompt("您选择的牌型不正确")
            end

            -- if #realcantable > 0 and self.gamescene:getNowRound() == 1 and self.gamescene:getDealerIndex() == self:getTableIndex() and #self._pokers == 16 then
            --     local hascube3 = false
            --     for i,v in ipairs(gettable) do
                    
            --         if v == 19 then
            --             hascube3 = true
            --             break
            --         end
            --     end

            --     if not hascube3 then
            --         realcantable = {}
            --         CommonUtils:prompt("方块3！")
            --     end
            -- end

            self.actionview:showcanAction(realcantable,gettable,data)
        end
    end

    function TableBottom:refreshHandTile(move)
        print("理牌 move = ",move)

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
                    if index == 0 then
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
            self.gamescene.Suanfuc:sort( handtile )
            local totall = #handtile
            for i,v in ipairs(handtile) do
                local pokerCard = LongCard.new(v)
                pokerCard:setCardAnchorPoint(cc.p(0.5,0))
                pokerCard:setPositionX((i-(totall + 1) / 2)*55)
                pokerCard.localposx = (i-(totall + 1) / 2)*55
                self.handcardnode:addChild(pokerCard)
                table.insert(self._pokers ,pokerCard)
            end
            -- if self.gamescene:getDealerIndex() == self:getTableIndex() then
            --     if #self._pokers > 0 then
            --         self._pokers[#self._pokers]:setDizhutip()
            --     end
            -- end
        end
        --print("0=9999999")
    end

    function TableBottom:chuPaiAction(data,isan)

        -- print(".......TableBottom:chuPaiAction(")
        -- printTable(data,"xp68")
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
        -- if self.gamescene:getDealerIndex() == self:getTableIndex() then
        --     if #cards > 0 then
        --         cards[#cards]:setDizhutip()
        --     end
        -- end

        if isan then
            local showpos = cc.p(0,self.cardheight*CHU_CARD_SCALE/2)
            showpos = self.showcardnode:convertToWorldSpace(showpos)
            self:playCardtypeAn(data,showpos)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
        
    end

    function TableBottom:updateDiZhuCards(isShow,pokers)
        self.diPaiView:setVisible(false)
    end

    function TableBottom:refreshcardNum()
        self:refreshHandTile()
    end

    return TableBottom
end


return TableFactory