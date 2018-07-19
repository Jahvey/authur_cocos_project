local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableTop = class("TableTop", tableClass)

    -- function TableTop:refreshShowTile()
    --     if self.gamescene.name == "GameScene" then
    --         self:updataHuXiText()
    --     end
    --             self.showCardNode:removeAllChildren()
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

    --     local function getColWidth(cards)
    --         return cardsize.width*#cards-((#cards-1)*step)
    --     end

    --     for i,v in ipairs(showCardList) do
    --         local node = cc.Node:create()
    --             :addTo(self.showCardNode)

    --         for m,n in ipairs(v.cards) do
    --             local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, n)
    --             card:addTo(node)
    --             card:setPosition(cc.p(cardsize.width/2+step*(m-1),-cardsize.height/2))
    --         end

    --         local isinsert = false
    --         local index = 0
    --         local posx = 0
    --         while (not isinsert) do
    --             index = index + 1
    --             if not showlist[index] then
    --                 showlist[index] = {}
    --             end
    --             local num = 0
    --             posx = 0
    --             for _,cols in ipairs(showlist[index]) do
    --                 num = num + #cols
    --                 posx = posx + getColWidth(cols) + colstep
    --             end
    --             num = num + #v.cards
    --             if num <= 9 then
    --                 table.insert(showlist[index],v.cards)
    --                 isinsert = true
    --             end
    --         end

    --         node:setPosition(cc.p(posx,-(index-1)*cardsize.height))

    --     end
    --     printTable(showlist,"xpp")
    -- end

    -- function TableTop:getShowPos(token)
    --     local showlist = {{}}

    --     local cardsize = cc.size(42,52)
    --     local step = 21
    --     local colstep = 15

    --     local function getColWidth(cards)
    --         return cardsize.width*#cards-((#cards-1)*step)
    --     end

    --     local showCardList = self:getShowCardList()
    --     for i,v in ipairs(showCardList) do
    --         local isinsert = false
    --         local index = 0
    --         local posx = 0
    --         while (not isinsert) do
    --             index = index + 1
    --             if not showlist[index] then
    --                 showlist[index] = {}
    --             end
    --             local num = 0
    --             posx = 0
    --             for _,cols in ipairs(showlist[index]) do
    --                 num = num + #cols
    --                 posx = posx + getColWidth(cols) + colstep
    --             end
    --             num = num + #v.cards
    --             if num <= 9 then
    --                 table.insert(showlist[index],v.cards)
    --                 isinsert = true
    --             end
    --         end
    --         if i == #showCardList then
    --             print("====================位置")
    --             return cc.p(posx,-(index-1)*cardsize.height)
    --         end
    --     end
    --     return self.nextShowPos
    -- end

    return TableTop
end

return TableFactory