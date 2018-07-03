-- -1:无操作 1:拢2:招3:报牌4:碰5:吃6:胡7:特殊天胡8:出牌9:过;10畏)

local Card = require "app.ui.game.Card"
local PICWIDTH = 150
local ActionView = class("ActionView",function()
    return cc.Node:create()
end)
function ActionView:ctor(gameview)
	self.gameview = gameview
	local touchLayer = ccui.Layout:create()
	touchLayer:setAnchorPoint(cc.p(0.5,0.5))
	touchLayer:setPosition(cc.p(0,0))
    touchLayer:setContentSize(cc.size(display.width*2,display.height*2))
    touchLayer:setTouchEnabled(true)
    self:addChild(touchLayer)

	self.gameModel = model
	self.selectlist = {}
	--一级选择操作类型，如果没有多选直接不显示2级界面
	self.selectnode = cc.Node:create()
	self:addChild(self.selectnode)
	--self.selectnode:addChild(cc.Sprite:create("game/pai.png"))
	-- 二级选择界面
	self.lastnode = cc.Node:create()
	self:addChild(self.lastnode)
	self:setVisible(false)
	self.selectlist = {}
end

function ActionView:show(data)
	self.lastnode:removeAllChildren()
	self.data = data
	self.selectlist = {}
	local action = data.playType or data.playTypes
	if action == nil then
		return 
	end
	for i,v in ipairs(action) do
		if v == 8 then
			self.gameview:setMyturn(true)
		elseif v== -1 then
			--Socketapi.putOutcards(-1)
		else
			self:addtype(v)
		end
	end
	self:showAction()
end

function ActionView:addtype(typ)
	table.insert(self.selectlist,typ)
end

function ActionView:showAction()
	self.selectnode:removeAllChildren()
	printTable(self.selectlist)
	local totall = #self.selectlist
	if totall == 0 then
		self:setVisible(false)
	else
		self:setVisible(true)
	end

	for i,v in ipairs(self.selectlist) do
	--for k,v in pairs(self.selectlist) do
		local pic = "game/action/"..v..".png"
		print(pic)
		local btn = ccui.Button:create(pic,pic, pic, ccui.TextureResType.localType)
		 WidgetUtils.addClickEvent(btn, function()
    		if tonumber(v) == 1 then
    			Socketapi.doaction(1,self.data.carddata)
    		elseif tonumber(v) == 2  then
    			Socketapi.doaction(2,self.data.carddata)
    		elseif tonumber(v) == 3 then
    			Socketapi.doaction(3,self.data.carddata)
    		elseif tonumber(v) == 4 then
    			Socketapi.doaction(4,self.data.carddata)
    		elseif tonumber(v) == 5 then
    			self:addchijiemian(self.data)
    		elseif tonumber(v) == 6 then
    			Socketapi.doaction(6,self.data.carddata)
    		elseif tonumber(v) == 7 then
    			Socketapi.doaction(7,self.data.carddata)
    		elseif tonumber(v) == 9 then
    			Socketapi.doaction(9,self.data.carddata)
    		elseif tonumber(v) == 10 then
    			Socketapi.doaction(10,self.data.carddata)	
    		else
    			print('不存在的操作类型')
    		end
    	end)
		 --btn:setPositionX((i - totall/2)*PICWIDTH - PICWIDTH/2)
		 btn:setPositionX(0-(totall- i)*PICWIDTH)
		 print("posx:"..btn:getPositionX())
		 self.selectnode:addChild(btn)
	end
end


function ActionView:addchijiemian(data)
	local widget = cc.CSLoader:createNode("ui/game/tips.csb")
  self.lastnode:addChild(widget)
  widget:setPosition(self.lastnode:convertToNodeSpace(cc.p(display.cx,display.cy)))
  local bilayer = widget:getChildByName("bi")
  bilayer:setVisible(false)
  local biaddlayer = cc.Node:create()
  bilayer:addChild(biaddlayer)
  local chilayer = widget:getChildByName("chi")
  local Card = require "app.ui.game.Card"
  print("1")
  local index = 0
  self.chibtn = {}
  for k,v in pairs(data.chiCards) do
  		index= index + 1
  		local getdata = ComHelpFuc.getstrdata( k)
  		for i,v1 in ipairs(getdata) do
		 	local card = Card.new(v1,TYPECARD.BICHI)
		 	card:setCardAnchorPoint(cc.p(0,0))
		 	card:setPositionY((i-1)*50+10)
		 	card:setPositionX((index-1)*70+14)
		 	chilayer:addChild(card)
		 	print("create")

		 end
		 local selection = cc.Sprite:create("game/action/selecton.png")
		 selection:setAnchorPoint(cc.p(0,0))
		 selection:setPosition(cc.p(-5+(index-1)*70,0))
		 selection:setVisible(false)
		 chilayer:addChild(selection)
		 
		 local btn = WidgetUtils.createnullBtn(cc.size(50,160))
		 btn:setAnchorPoint(cc.p(0,0))
		 btn:setPositionX((index-1)*70+14)
		 btn:setPositionY(10)
		 chilayer:addChild(btn)
		 btn.keyvalue = k
		 btn.selection = selection
		 self.chibtn[index] = btn

		 
  end
  if index >= 3 then
  		chilayer:setContentSize(cc.size(211+(index- 3)*70,240))
  		chilayer:getChildByName("title"):setPositionX((211+(index- 3)*70)/2)
  end

  for i,v in ipairs(self.chibtn) do
  		local function callback()
  			biaddlayer:removeAllChildren()
  			for i1,v1 in ipairs(self.chibtn) do
  				if v ~= v1 then
  					v1.selection:setVisible(false)
  				else
  					v1.selection:setVisible(true)
  				end
  			end
  			local biindex = 0
  			for i1,v1 in pairs(data.chiCards[v.keyvalue]) do
  				biindex = biindex + 1
				local getdata = ComHelpFuc.getstrdata( v1)
		  		for i11,v11 in ipairs(getdata) do
				 	local card = Card.new(v11,TYPECARD.BICHI)
				 	card:setCardAnchorPoint(cc.p(0,0))
				 	card:setPositionY((i11-1)*50+10)
				 	card:setPositionX((biindex-1)*70+14)
				 	biaddlayer:addChild(card)
				 	print("create")

				 	 local btn = WidgetUtils.createnullBtn(cc.size(50,160))
					 btn:setAnchorPoint(cc.p(0,0))
					 btn:setPositionX((biindex-1)*70+14)
					 btn:setPositionY(10)
					 biaddlayer:addChild(btn)
					 local function call()
					 	print(v.keyvalue)
					 	print(v1)
					 	Socketapi.doaction(5,self.data.carddata,v.keyvalue,v1)
					 end
					 WidgetUtils.addClickEvent(btn, call)
				 end  				
  			end

  			if biindex >= 3 then
		  		bilayer:setContentSize(cc.size(211+(biindex- 3)*70,240))
		  		bilayer:getChildByName("title"):setPositionX((211+(biindex- 3)*70)/2)
		 	end
  			if biindex == 0 then
  				print(v.keyvalue)
  				Socketapi.doaction(5,self.data.carddata,v.keyvalue)
  				bilayer:setVisible(false)
  			else
  				bilayer:setVisible(true)
  			end
  		end
  		WidgetUtils.addClickEvent(v, callback)
  end
end

return ActionView