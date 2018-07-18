local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableBottom = class("TableBottom", tableClass)
    local ROW = 5
    local COL = 15
    local ALL_GEZI = ROW * COL

    -- function TableBottom:refreshShowTile()

    --     self.showCardNode:removeAllChildren()
    --     self.showCardNode:setVisible(true)

    --     print(".........TableBottom:refreshShowTile 刷新摆牌")

    --     self.showcardspr = { }
    --     print("bai  zji  test")
    --     local showCardList = self:getShowCardList()
    --     self.nextShowPos = cc.p(19, 21)
        
    --     printTable(showCardList,"xpp")

    --     local showlist = {{}}

    --     local cardsize = cc.size(42,52)
    --     local step = 21
    --     local colstep = 15
    --     local maxheight = 185

    --     local function getColWidth(cards)
    --         return cardsize.width*#cards-((#cards-1)*step)
    --     end

    --     local function getColHeight(cards)
    --         local height = 0
    --         local lastcard = nil
    --         for i,v in ipairs(cards) do
    --             if not lastcard then
    --                 height = height + 35
    --             elseif lastcard == v%16 or lastcard == 0 then
    --                 height = height + 10
    --             else
    --                 height = height + 30
    --             end
    --             lastcard = v%16
    --         end
    --         return height
    --     end

    --     for i,v in ipairs(showCardList) do
    --         local node = cc.Node:create()
    --             :addTo(self.showCardNode)

    --         local lastcard = nil
    --         local cardposx = cardsize.width/2
    --         local cardposy = -cardsize.height/2
    --         for m,n in ipairs(v.cards) do
    --             local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, n)
    --             card:addTo(node)
                
    --             if not lastcard then
    --             elseif lastcard == n%16 or lastcard == 0 then
    --                 cardposy = cardposy - 10
    --             else
    --                 cardposy = cardposy - 30
    --             end
    --             card:setPosition(cc.p(cardposx,cardposy))

    --             lastcard = n%16
    --             -- card:setPosition(cc.p(cardsize.width/2+step*(m-1),-cardsize.height/2))
    --         end

    --         local isinsert = false
    --         local index = 0
    --         local posy = 0
            
    --         while (not isinsert) do
    --             index = index + 1
    --             if not showlist[index] then
    --                 showlist[index] = {}
    --             end
    --             local height = 0
    --             posy = 0
    --             height = 0
    --             for _,cols in ipairs(showlist[index]) do
    --                 -- num = num + #cols
    --                 -- posx = posx + getColWidth(cols) + colstep
    --                 posy = posy + getColHeight(cols)
    --             end
    --             height = posy + getColHeight(v.cards)
    --             if height <= maxheight then
    --                 table.insert(showlist[index],v.cards)
    --                 isinsert = true
    --             end
    --         end

    --         node:setPosition(cc.p((index-1)*(cardsize.width+1),-posy))

    --     end
    --     printTable(showlist,"xpp")
        
    -- end

    -- function TableBottom:getShowPos(token)

    --     local showlist = {{}}

    --     local cardsize = cc.size(42,52)
    --     local step = 21
    --     local colstep = 15
    --     local maxheight = 185

    --     local function getColWidth(cards)
    --         return cardsize.width*#cards-((#cards-1)*step)
    --     end

    --     local function getColHeight(cards)
    --         local height = 0
    --         local lastcard = nil
    --         for i,v in ipairs(cards) do
    --             if not lastcard then
    --                 height = height + 35
    --             elseif lastcard == v%16 or lastcard == 0 then
    --                 height = height + 10
    --             else
    --                 height = height + 30
    --             end
    --             lastcard = v%16
    --         end
    --         return height
    --     end

    --     local showCardList = self:getShowCardList()
    --     for i,v in ipairs(showCardList) do
    --         local isinsert = false
    --         local index = 0
    --         local posy = 0
    --         while (not isinsert) do
    --             index = index + 1
    --             if not showlist[index] then
    --                 showlist[index] = {}
    --             end
    --             local height = 0
    --             posy = 0
    --             height = 0
    --             for _,cols in ipairs(showlist[index]) do
    --                 -- num = num + #cols
    --                 -- posx = posx + getColWidth(cols) + colstep
    --                 posy = posy + getColHeight(cols)
    --             end
    --             height = posy + getColHeight(v.cards)
    --             if height <= maxheight then
    --                 table.insert(showlist[index],v.cards)
    --                 isinsert = true
    --             end
    --         end
    --         if i == #showCardList then
    --             print("====================位置")
    --             return cc.p((index-1)*(cardsize.width+1),-posy)
    --         end
    --     end

    --     return self.nextShowPos
    -- end

    return TableBottom
end


return TableFactory