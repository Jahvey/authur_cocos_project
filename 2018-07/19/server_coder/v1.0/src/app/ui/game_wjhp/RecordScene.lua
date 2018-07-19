local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")
local LongCard = require "app.ui.game.base.LongCard"
local perwidth = 100
local perheight = 58
function RecordScene:otherInitView()
    local LongCard = require "app.ui.game.base.LongCard"

   self.mytable.checkbanedList =function(self)
        if self.handcardspr == nil then
            return 
        end
        print("checkbanedList")
        local banedList = clone(self.banedList)
        if #self.banedList == 0 then
            return
        end
        local zhatab = {}
        for i,v in ipairs(self.banedList) do
            local value = v%(16*16)
            if zhatab[value] == nil then
                zhatab[value] ={}
            end
            table.insert(zhatab[value],v)
        end
        for k,v in pairs(zhatab) do
            table.sort(v,function(a,b)
               local real1 = a%(16*16)
               local real2 = b%(16*16)
               if real1 == real2 then
                    return a < b
                else
                    return real1 < real2
               end
           end)
        end
        for k,v in pairs(zhatab) do
            table.insert(self.handcardspr,1,{})
            for i1,v1 in ipairs(v) do
                local isfind = false
                
                for i2,v2 in ipairs(self.handcardspr) do
                    if i2 ~= 1 then
                        for i3,v3 in ipairs(v2) do
                            if v3:getCardValue() == v1 then
                                table.remove(self.handcardspr[i2],i3)
                                table.insert(self.handcardspr[1],v3)
                                if #self.handcardspr[i2] == 0 then
                                  table.remove(self.handcardspr,i2)
                                end
                                isfind =true 
                                break
                            end
                        end

                        if isfind then
                            break
                        end

                    end
                end
            end
        end
        local function sortlie( )
            if #self.handcardspr > 9 then
                for i,v in ipairs(self.handcardspr) do
                    if #v == 0 then
                        table.remove(self.handcardspr,i)
                        --return findnulltable()

                        return sortlie()
                    end
                end
                for i,v in ipairs(self.handcardspr) do
                    if #v < 3 then
                        for i1,v1 in ipairs(self.handcardspr) do
                            if i1 > i then
                                if #v1< 3 then
                                    for i2,v2 in ipairs(v1) do
                                        table.insert(v,v2)
                                        table.remove(self.handcardspr,i1)
                                        --findnulltable()
                                        return sortlie()
                                    end
                                end
                            end
                        end
                    end
                end
                
            else
                return
            end

        end
        sortlie()

   end
   self.mytable.sorthanndcards = function( self,handtitle)
        self.realtable = {}
       for i,v in ipairs(handtitle) do
           if self.realtable[v%(16*16)] == nil then
                self.realtable[v%(16*16)] = {}
           end
          table.insert(self.realtable[v%(16*16)],v)
       end
       local listtab = {}
       for k,v in pairs(self.realtable) do
           if #v == 5 then
                table.insert(listtab,v)
                v = {}
                self.realtable[k] = {}
           end
       end
       for k,v in pairs(self.realtable) do
           if #v == 4 then
                table.insert(listtab,v)
                v = {}
                self.realtable[k] = {}
           end
       end
       for k,v in pairs(self.realtable) do
           if #v == 3 then
                table.insert(listtab,v)
                self.realtable[k] = {}
           end
       end
        local function getlevel(value )
            local value = value%(16*16)
            if value == 0x51 or value == 0x42 or value == 0x73 then
                return 1
            end
            if value < 0x30 then
                return 2
            end
            return 3
        end
        --printTable(listtab,"sjp3")
       table.sort(listtab,function(a,b)
           if #a == #b then
                print(a[1])
                print(b[1])
                if getlevel(a[1]) == getlevel(b[2]) then
                    return a[1]%(16*16) < b[2]%(16*16)
                else
                    return getlevel(a[1]) < getlevel(b[2])
                end
           else
                return #a > #b
           end
       end)
        --printTable(self.realtable,"sjp3")
       local listlietab = {}
       for k1,v1 in pairs(self.realtable) do
          
           for k,v in pairs(v1) do
              local real =math.floor( (v%(16*16))/16)
               if listlietab[real] == nil then
                    listlietab[real]  = {}
               end
               table.insert(listlietab[real],v)
           end
       end
       
       for i=1,8 do
           if listlietab[i] then
                local totall = #listlietab[i]
                -- if totall >=6 then
                --     local tab = {}
                --     for j=1,4 do
                --         table.insert(tab,listlietab[i][j])
                --     end
                --     --table.insert(listtab,tab)
                --     local tab = {}
                --     for j=5,totall do
                --         table.insert(tab,listlietab[i][j])
                --     end
                --     --table.insert(listtab,tab)
                -- elseif totall >=3 then
                --     local tab = {}
                --     for j=1,totall do
                --         table.insert(tab,listlietab[i][j])
                --     end
                --     --table.insert(listtab,tab)
                -- else
                -- end
                local tab = {}
                for j=1,totall do
                    table.insert(tab,listlietab[i][j])
                end
           end
       end
       -- print("_----------")
       -- printTable(listtab,"sjp3")
       local totalllost = 0
       local losttab = {}
       for i=1,8 do
           if listlietab[i] then
                if #listlietab[i] > 6 then
                    totalllost = totalllost + 2
                else
                    totalllost = totalllost + 1
                end
                table.insert(losttab,listlietab[i])
            end
       end
       table.sort(losttab,function(a,b)
         return #a > #b
       end)
       totalllost = totalllost + #listtab - 9
       if totalllost < 0 then
            totalllost = 0
       end
       --printTable(listtab,"sjp3")
       for i,v in ipairs(losttab) do
                  local totall = #v
                if totall > 6 then
                    table.insert(listtab,{})
                    for j=1,4 do
                        table.insert(listtab[#listtab],losttab[i][j])
                    end
                    table.insert(listtab,{})
                    for j=5,#losttab[i] do
                        table.insert(listtab[#listtab],losttab[i][j])
                    end
                elseif totall <= 2 and i ~= 1 then
                    if (#(listtab[#listtab]) + totall) > 5 or totalllost <= 0 then
                        table.insert(listtab,{})
                    else
                        totalllost = totalllost - 1
                    end
                    local tab = {}
                    for j,v in ipairs(losttab[i]) do
                       table.insert(listtab[#listtab],losttab[i][j])
                    end
                else
                    table.insert(listtab,{})
                    local tab = {}
                    for j,v in ipairs(losttab[i]) do
                       table.insert(listtab[#listtab],losttab[i][j])
                    end
                end
       end
       -- for i=1,8 do
       --      if listlietab[i] then
       --          local totall = #listlietab[i]
       --          if totall >= 6 then
       --              table.insert(listtab,{})
       --              for j=1,4 do
       --                  table.insert(listtab[#listtab],listlietab[i][j])
       --              end
       --              table.insert(listtab,{})
       --              for j=5,#listlietab[i] do
       --                  table.insert(listtab[#listtab],listlietab[i][j])
       --              end
       --          elseif totall <= 2 and i ~= 1 then
       --              if (#(listtab[#listtab]) + totall) > 5 or totalllost <= 0 then
       --                  table.insert(listtab,{})
       --              else
       --                  totalllost = totalllost - 1
       --              end
       --              local tab = {}
       --              for j,v in ipairs(listlietab[i]) do
       --                 table.insert(listtab[#listtab],listlietab[i][j])
       --              end
       --          else
       --              table.insert(listtab,{})
       --              local tab = {}
       --              for j,v in ipairs(listlietab[i]) do
       --                 table.insert(listtab[#listtab],listlietab[i][j])
       --              end
       --          end
       --      end
       --  end

        for k,v in pairs(listtab) do
           table.sort(v,function(a,b)
               local real1 = a%(16*16)
               local real2 = b%(16*16)
               if real1 == real2 then
                    return a < b
                else
                    return real1 < real2
               end
           end)
       end
       
        return listtab
   end
   self.mytable.refreshHandTile = function (self,move)

        self:updataHuXiText()
        local banedList = clone(self.banedList)
        local function getIsBanedCard( card )
            for i,v in ipairs(banedList) do
                if v == card then
                    table.remove(banedList,i)
                    return true
                end
            end
            return false
        end
        if self.handcardspr == nil or #self.handcardspr == 0 then

            local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
            self.handtile = self:sorthanndcards(handtile)

            self.handcardspr = {}
            local all_wid =  9
            
            for i,v in ipairs(self.handtile) do
                if not self.handcardspr[i] then
                    self.handcardspr[i] = { }
                end
                local _y = -1
                local posy = perheight
                if #v >= 6 then
                  posy = perheight*4/5
                end
                for m, unit in pairs(v) do
                    local pai = LongCard.new(CARDTYPE.MYHAND, unit)
                    self.handCardNode:addChild(pai, 6 - m)

                    local _x =(i-(all_wid + 1) / 2)*perwidth
                    if getIsBanedCard(unit)  then
                        pai:setGray()
                        pai.isnotmove = true
                    else
                        pai.isnotmove = false
                    end

                    pai.x = _x
                    pai.y = _y
                    pai:setPosition(cc.p(pai.x,pai.y))
                    pai.localpos = cc.p(i,m)
                    _y = _y + posy
                    self:addTileEvent(pai)
                    self.handcardspr[i][m] = pai
                    --print("show")
                end
            end

            self.handCardNode:setVisible(true)

            --创建框
            for i=1,9 do
              local spr = cc.Sprite:create("game/black_back.png")
              spr:setAnchorPoint(cc.p(0.5,0))
              spr:setPosition(cc.p((i-(9 + 1) / 2)*perwidth,-45))
              self.handCardNode:addChild(spr,-1)
            end

        else
            self:checkbanedList()
            for i,v in ipairs(self.handcardspr) do
                if v[1] and v[1].isnotmove then
                elseif v[1] then
                  self.handcardspr[i] = self.gamescene:singlelinesort(v)
                end 

            end


            for i,v in ipairs(self.handcardspr) do
                for i1,v1 in ipairs(v) do
                    if getIsBanedCard(v1:getCardValue())  then
                        v1:setGray()
                        v1.isnotmove = true
                    else
                        v1:hideGray()
                        v1.isnotmove = false
                    end
                    v1:setLocalZOrder(6 - i1)
                    v1.localpos = cc.p(i,i1)
                    v1:stopAllActions()
                    v1:setCardOpacticy(255)
                    v1:setVisible(true)
                    v1:runAction(cc.MoveTo:create(0.2,self:getTilepos(v1)))
                end
            end
            self.handCardNode:setVisible(true)

        end     
    end
    self.mytable.getTilepos = function (self,tile)
        local x =  (tile.localpos.x-(9 + 1) / 2)*perwidth
        local y = (tile.localpos.y - 1)*perheight
        if  self.handcardspr[tile.localpos.x] and #self.handcardspr[tile.localpos.x] >=6 then
            y = (tile.localpos.y - 1)*perheight*4/5
        end
        return cc.p(x,y)
    end
    self.mytable.addHandTile = function(self,value )
        print("添加手牌")
        if #self.handcardspr < 9 then
            local pai = LongCard.new(CARDTYPE.MYHAND, value)
            self.handcardspr[#self.handcardspr+1] = {}
            self.handcardspr[#self.handcardspr][1] = pai
            self.handCardNode:addChild(pai,1)
            self:addTileEvent(pai)
            pai.localpos = cc.p(#self.handcardspr+1,1)
            pai:setPosition(self:getTilepos(pai))
            pai:setVisible(false)
        else
            local totall = #self.handcardspr
            for i=1,totall do
                local real = totall -i + 1
                if #(self.handcardspr[real]) < 5 then
                    local pai = LongCard.new(CARDTYPE.MYHAND, value)
                    self:addTileEvent(pai)
                    self.handCardNode:addChild(pai,1)
                    table.insert(self.handcardspr[real],pai)
                    pai.localpos = cc.p(real,#self.handcardspr[real]+1)
                    pai:setPosition(self:getTilepos(pai))
                    pai:setVisible(false)
                    return
                end
            end
        end
        
    end
    self.mytable.deletitles = function( self,values )
       if self.chupaidelect and #values == 1 then
            self.chupaidelect = false
            return
       end
       -- print("删除111111111111111")
       -- printTable(values,"sjp3")
       for i,v in ipairs(values) do
          for i1,v1 in ipairs(self.handcardspr) do
                local isfind = false
              for i2,v2 in ipairs(v1) do
                    print(v,v2)
                  if v == v2:getCardValue() then
                        table.remove(self.handcardspr[i1],i2)
                        -- print("删除成功")
                        v2:removeFromParent()
                        isfind = true
                        break
                  end
              end
              if isfind then
                break
              end
          end
       end
    end
    self.mytable.addTileEvent = function (self,tile)

        local function returntile()
             self.movespr:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,self:getTilepos(tile)),cc.CallFunc:create(function( ... )
                self.movespr:removeFromParent()
                self.movespr = nil
                tile:setCardOpacticy(255)
            end)))
        end
        local function endaction(pos)

            local function endmovetopos (  )
                -- for i,v in ipairs(self.handcardspr) do
                --     for i1,v1 in ipairs(v) do
                --         print(i,v)
                --     end
                -- end
                tile:setCardOpacticy(255)
                tile:setPosition(cc.p(self.movespr:getPositionX(),self.movespr:getPositionY()))
                self.movespr:removeFromParent()
                self.movespr = nil
                self:refreshHandTile()
            end
            local selectindex = nil
            --print("pos.x:"..pos.x)
            for i=1,(#self.handcardspr+2) do
                local x =  ((i-1)-(9 + 1) / 2)*perwidth
                if pos.x >(x - perwidth/2) and pos.x < (x + perwidth/2) then
                    selectindex = i - 1
                    --print('1')
                    break
                elseif i == 1 and pos.x < (x + perwidth/2) then
                    selectindex = i - 1
                    --print('2')
                    break
                elseif #self.handcardspr+2 == i and pos.x >(x + perwidth/2) then
                    selectindex = i - 1
                    --print('3')
                end
            end
            local replacepos = nil
           -- print("#self.handcardspr:"..#self.handcardspr)
            if selectindex and selectindex == 0 then
                --print("selectindex1:"..selectindex)
                if #self.handcardspr >= 9 then
                    if #(self.handcardspr[1]) >= 6 then
                    else
                        
                        if self.handcardspr[1][1].isnotmove then
                        else
                            replacepos = cc.p(1,#self.handcardspr[1]+1)
                            table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                            table.insert(self.handcardspr[1],tile)
                        end
                    end
                else
                    table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                    table.insert(self.handcardspr,1,{tile})
                    replacepos = cc.p(1,1)
                end
            elseif selectindex and selectindex > #self.handcardspr then
                --print("selectindex2:"..selectindex)
                if #self.handcardspr >= 9 then
                    --print("1111")
                    if #self.handcardspr[9] >= 6 then
                    else
                        if self.handcardspr[9][1] and self.handcardspr[9][1].isnotmove then
                        else
                            table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                            table.insert(self.handcardspr[9],tile)
                            replacepos = cc.p(9,#self.handcardspr[1]+1)
                        end
                        
                    end
                else
                    --print("2222")
                    table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                    
                    table.insert(self.handcardspr,{tile})
                    replacepos = cc.p(#self.handcardspr,1)
                end
            elseif selectindex and selectindex  then
                --print("selectindex3:"..selectindex)
                if #self.handcardspr[selectindex] >= 6 then
                else
                    if self.handcardspr[selectindex][1] and self.handcardspr[selectindex][1].isnotmove then
                    else
                        replacepos = cc.p(selectindex,#self.handcardspr[selectindex]+1)
                        table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                        
                        table.insert(self.handcardspr[selectindex],tile)
                    end
                end
            else
                
            end
            if replacepos then
                --print("replaceposx:"..replacepos.x)
                --print("replaceposy:"..replacepos.y)
                endmovetopos()
            else
                returntile()
            end
        end
        local function endactionchupai(pos)
            if self:tryChupai(tile) then
                --print("出牌成功1")
                table.remove(self.handcardspr[tile.localpos.x],tile.localpos.y)
                self:refreshHandTile()
                self.movespr:removeFromParent()
                tile:removeFromParent()
                self.chupaidelect = true
                return
            else
                endaction(pos)
            end
        end
        local beginposworld 
        local beginposmove 
        local function onTouchBegan(touch, event)
            if tolua.cast(self.movespr,"cc.Node") then
                self.movespr:removeFromParent()
            end
            if tile.isnotmove then
                return
            end
            beginposworld = self.handCardNode:convertTouchToNodeSpace(touch)
            --local beganposx, beganposx = tile:getPosition()
            local locationInNode = tile:getbg():convertToNodeSpace(touch:getLocation())
            local s = tile:getbg():getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height);
            if cc.rectContainsPoint(rect, locationInNode) then
                tile:setCardOpacticy(255 * 0.4)
                self.isTouched = true
                beginposmove = cc.p(tile:getPositionX(),tile:getPositionY())
                self.movespr = LongCard.new(CARDTYPE.ACTIONSHOW, tile:getCardValue())
                self.handCardNode:addChild(self.movespr,100)
                self.movespr:setCardanpos(cc.p(0.5,0.79))
                self.movespr:setPosition(self:getTilepos(tile))

                return true
            end
        end

        local function onTouchMove(touch, event)
            local touchPoint = touch:getLocation()
            if tolua.cast(tile,"cc.Node") == nil then
                self.isTouched = false
                return 
            end
            local moveposworld = self.handCardNode:convertTouchToNodeSpace(touch)
            local pos = cc.p(moveposworld.x - beginposworld.x,moveposworld.y - beginposworld.y)
            self.movespr:setPosition(cc.p(beginposmove.x+pos.x,beginposmove.y+pos.y))
        end

        local function onTouchEnd(touch, event)
            if tolua.cast(tile,"cc.Node") == nil then
                if tolua.cast(self.movespr,"cc.Node") then
                    self.movespr:removeFromParent()
                end
                self.isTouched = false
                return 
            end
            self.handCardNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( ... )
                if tolua.cast(tile,"cc.Node") then
                    tile.isdouble = false
                end
            end)))
            local touchPoint = touch:getLocation()
            self.isTouched = false
            -- tile:setCardOpacticy(255)
            if tile.isdouble == true then
                print("双击")
                endactionchupai(self.handCardNode:convertTouchToNodeSpace(touch))
            elseif self.movespr:getPositionY() > self.shouzhiNode:getPositionY() then
                endactionchupai(self.handCardNode:convertTouchToNodeSpace(touch))
            else 
                tile.isdouble = true
                print("设置第一次点击")
                endaction(self.handCardNode:convertTouchToNodeSpace(touch))
            end
        end

        local function onTouchCancell(touch, event)
            local touchPoint = touch:getLocation()
            if tolua.cast(tile,"cc.Node") == nil then
                if tolua.cast(self.movespr,"cc.Node") then
                    self.movespr:removeFromParent()
                end
                self.isTouched = false
                return 
            end

            self.isTouched = false
            -- tile:setCardOpacticy(255)
            endaction(self.handCardNode:convertTouchToNodeSpace(touch))
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
end


function RecordScene:priorityAction(data,hidenAnimation)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG then
        self:tableHideEffectnode()

        --self:addShowTile(data.seat_index, data.col_info)

        -- if data.dele_hand_cards then
        --     self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        -- else
        --     local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
        --     self:deleteHandTile(list,data.seat_index)
        -- end
        print("扎")
        printTable(data,"sjp3")
        self.tablelist[data.seat_index + 1]:zhaPaiAction(data)
		--self:deleteAction("扎")
        self.tablelist[data.seat_index + 1]:showzha(data.zha_num)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            -- print
            self:deleteAction("扎")
        end )))
        return true

	elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PENG then
        print(".........碰牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)

        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:pengPaiAction(data)

        self:deleteAction("对")
        return true
	elseif data.act_type == poker_common_pb.EN_SDR_ACTION_GANG then
		self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:kaifanAction(data)
        self.tablelist[data.seat_index + 1]:showzha(data.zha_num)
        return true
		--self:deleteAction("开泛")
	elseif data.act_type == poker_common_pb.EN_SDR_ACTION_GANG_2 then

		self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:tachuanAction(data)
        return true
		--self:deleteAction("踏船")
	elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHAO then --明杠为招
        print(".........招牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        -- else
        --     local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
        --     if self:getTableConf().ttype == HPGAMETYPE.HFBH then
        --         if data.col_info.is_waichi == true then
        --             list = {}
        --         end
        --     end
        --     self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:zhaoPaiAction(data)
        return true
	end 
    return false
end

local lianzi = {0x32,0x71,0x42,0x72,0x73,0x74,0x51,0x61,0x62,0x52}
function RecordScene:singlelinesort(line )
  -- body
    local realtab = {}
   for i,v in ipairs(line) do
     -- print("v:"..v:getrealCardValue())
      if realtab[v:getrealCardValue()] == nil then
         realtab[v:getrealCardValue()] = {}
         realtab[v:getrealCardValue()].num = 1
         realtab[v:getrealCardValue()].values ={v}
         realtab[v:getrealCardValue()].real = v:getrealCardValue()
      else
         realtab[v:getrealCardValue()].num = 1 + realtab[v:getrealCardValue()].num
         table.insert(realtab[v:getrealCardValue()].values,v)
      end
   end
   for k,v in pairs(realtab) do
      table.sort(v.values,function(a,b)
          return a:getCardValue() < b:getCardValue()
      end)
   end
   local hailian = 0
   for i=1,8 do
      if  realtab[lianzi[i]] and realtab[lianzi[i + 1]] and realtab[lianzi[i + 2]] then
           hailian = i
          break
      end
   end
   local newtab = {}
   if hailian ~= 0 then
      for i=1,3 do
            for j,v in ipairs(realtab[lianzi[hailian+i-1]].values) do
                table.insert(newtab,v)
            end
            realtab[lianzi[hailian+i-1]].values = {}
      end
    else

      table.sort(line,function(a,b)
          if a:getrealCardValue() == b:getrealCardValue() then
              if a:getCardValue() == b:getCardValue() then
                  return a.localpos.y < b.localpos.y
              else
                  return a:getCardValue() < b:getCardValue()
              end
          else
             return a:getrealCardValue() < b:getrealCardValue()
          end
      end)
      return line
   end
   local losttab = {}
    
    for k,v in pairs(realtab) do
        for i1,v1 in ipairs(v.values) do
            print("1111222")
            table.insert(losttab,v1)
        end
    end
   
     table.sort(losttab,function(a,b)
        if a:getrealCardValue() == b:getrealCardValue() then
          return a:getCardValue() <= b:getCardValue()
        else
           return a:getrealCardValue() < b:getrealCardValue()
        end
    end)
     printTable(losttab,"sjp3")
     for i,v in ipairs(losttab) do
        table.insert(newtab,v)
     end
      for i,v in ipairs(newtab) do
        print(i,v:getCardValue())
      end
    return newtab
end

return RecordScene