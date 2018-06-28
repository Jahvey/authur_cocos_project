

local MylistView  =class("MylistView",function()
    return {}
end)

function MylistView:ctor(listview,size)
	self.freecelllist = {}
	self.listview = listview
	self.size = self.listview:getContentSize()
	--一个屏幕能装下好多个
	self.callinput = math.floor(self.size.height/size.height)+2
    --self.listview:addChild(self)
    self.height = size.height
	 self.listview:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "SCROLL_TO_TOP"
        elseif eventType == 1 then
            event.name = "SCROLL_TO_BOTTOM"
        elseif eventType == 2 then
            event.name = "SCROLL_TO_LEFT"
        elseif eventType == 3 then
            event.name = "SCROLL_TO_RIGHT"
        elseif eventType == 4 then
            event.name = "SCROLLING"
        elseif eventType == 5 then
            event.name = "BOUNCE_TOP"
        elseif eventType == 6 then
            event.name = "BOUNCE_BOTTOM"
        elseif eventType == 7 then
            event.name = "BOUNCE_LEFT"
        elseif eventType == 8 then
            event.name = "BOUNCE_RIGHT"
        elseif eventType == 9 then
            event.name = "CONTAINER_MOVED"
        elseif eventType == 10 then
            event.name = "AUTOSCROLL_ENDED"
        end
        event.target = sender
        if  eventType == 9 then
           -- print(self)
            self:updataView()
        end
        -- print(event.name)
    end)

	 


    local height = self.listview:getContentSize().height
    local createtotall =math.floor( height/self.height)+ 2
    self.createtotall  = math.floor( height/self.height)+ 2
    self.listtable = {}
end

function MylistView:setcellAtindex(fuc)
   self.cellcall = fuc
end
function MylistView:updatasize()
	local height = self.totall*self.height
	if height < self.size.height then
		height  = self.size.height
	end
	self.listview:setInnerContainerSize(cc.size(self.size.width,height))
	self.maxheight = height

end

function MylistView:setModelcell( cell )
	self.modelcell = cell
end
function MylistView:setTotall(totall,isfrist)
    print("totall:"..totall)
    local lastmovepos = self.listview:getInnerContainerPosition()
    self.totall = totall
    self:updatasize()
    if isfrist then
    else
      if lastmovepos.y < (self.size.height - totall*self.height) then
        lastmovepos.y  = self.size.height - totall*self.height
      end
      self.listview:setInnerContainerPosition(lastmovepos)
    end
end

function MylistView:updataView(isupdata)
	-- if true then
	-- 	return 
	-- end
    if #self.listtable == 0 then
    else
    end
    print("totall cell:"..#self.freecelllist)
    print("posx:"..self.listview:getInnerContainer():getPositionY())
    local offy = self.listview:getInnerContainer():getPositionY()+ self.listview:getInnerContainer():getContentSize().height
    --print("posx:"..offy)

    local indexbegin =  math.ceil(offy/self.height)
    if self.lastindexbegin ==  indexbegin and isupdata == nil then
    	return
    else
    	self.lastindexbegin  = indexbegin
    end
   	local showttable = {}
   	for i=1,self.callinput do
   		local num =  indexbegin - i + 1
   		if num > self.totall or num < 1 then
   		else
   			table.insert(showttable,num)
   		end
   	end
   	for i,v in ipairs(self.freecelllist) do
   		v:setPositionX(-1280)
   	end
   	for i,v in ipairs(showttable) do
   		if self.freecelllist[i] == nil then
   			local cell = self.modelcell:clone()
   			cell:setVisible(true)
   			table.insert(self.freecelllist,cell)
   			self.listview:getInnerContainer():addChild(cell)
   			--print('create cell')
   		end
   		local cell  = self.freecelllist[i]
   		cell:setVisible(true)
   		cell:setPositionX(0)
   		cell:setPositionY(self.maxheight - self.height*(v))
   		self.cellcall(cell,v)
   	end

end

return MylistView