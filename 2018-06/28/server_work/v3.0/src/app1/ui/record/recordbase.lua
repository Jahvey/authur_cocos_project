
local Card = require "app.ui.game.Card"
require "app.ui.game.Func"
local INDEXWIDTH = 70
local INDEXHEIGHT = 130*70/115
local paihight = 30
local recordbase = class("recordbase",function()
    return cc.Node:create()
end)


function recordbase:ctor(localpos,data,scene)
	self.cardslist = {}
	self.localpos = localpos
	self.carddata = data
	self.scene = scene
	local node = self.scene.painode:getChildByName("node"..self.localpos)
	self.x,self.y = node:getPosition()
	self.cardnode = cc.Node:create()
	self.cardnode:setPosition(cc.p(self.x,self.y))
	self:addChild(self.cardnode)

	self.actionnode = cc.Node:create()
	self:addChild(self.actionnode)
	
	self.outnode = cc.Node:create()

	local node = self.scene.painode:getChildByName("out"..self.localpos)
	self.outx,self.outy = node:getPosition()
	self.outnode:setPosition(cc.p(self.outx,self.outy))
	if self.localpos == 2 or self.localpos == 3 then
		self.outnode:setPositionY(self.outy-80)
	end
	self:addChild(self.outnode)
	self.outnode:setScale(0.5)
	self:createhand()
end

function recordbase:sort()
		table.sort(self.carddata,function(a,b)
			if  a == 53 or b == 53 then
				return a>b
			end

			if  a == 54 or b == 54 then
				return a>b
			end

			local realvalue1 = math.floor((a-1)%13)+1
			local realvalue2 = math.floor((b-1)%13)+1
			if realvalue1 == realvalue2 then
				local se1 = math.floor((a-1)/13)+1
				local se2 = math.floor((b-1)/13)+1
				return se1 <se2
			else
				if realvalue1 ==  1 then
					realvalue1 = 14
				end

				if realvalue2 ==  1 then
					realvalue2 = 14
				end


				if realvalue1 ==  2 then
					realvalue1 = 15
				end

				if realvalue2 ==  2 then
					realvalue2 = 15
				end
				return realvalue1 > realvalue2
			end
		end)
end
function recordbase:createhand()
	self:sort()
	self.cardnode:removeAllChildren()
	self.cardslist = {}
	if self.localpos == 1 then
		
		for i,v in ipairs(self.carddata) do
			local card = Card.new(v,1)
			card:setPositionX((i-1)*100/2)
			self.cardnode:addChild(card)
			table.insert(self.cardslist,card)
		end
		self.cardnode:setPositionX(self.x - (#self.carddata-1)*(100/4))
	elseif self.localpos == 2 then
		self.cardnode:setScale(0.5)
		local totall = #self.carddata
		for i,v in ipairs(self.carddata) do
			local card = Card.new(v,1)
			--card:setLocalZOrder(100-i)
			card:setPositionX(0-(totall-i+1)*100/2-100)
			self.cardnode:addChild(card)
			table.insert(self.cardslist,card)
		end
	elseif self.localpos == 3 then
		self.cardnode:setScale(0.5)
		for i,v in ipairs(self.carddata) do
			local card = Card.new(v,1)
			card:setPositionX((i-1)*100/2)
			self.cardnode:addChild(card)
			table.insert(self.cardslist,card)
		end
	end
end

function recordbase:chupai( data ,isnotta)
	---------------
	print("----------")
	printTable(data.carddatas)
	self.outnode:removeAllChildren()
	local is,tab =Func.getput(data.carddatas,data.cardtype) 
	local realcardtab = Func.getcardreal(data.carddatas,tab)
	for i,v in ipairs(data.carddatas) do
		local pos = nil
		for i1,v1 in ipairs(self.carddata) do
			if v == v1 then
				pos = i1
				break
			end
		end
		if pos then
			table.remove(self.carddata,pos)
		end
	end
	if #self.carddata == 1 then
		AudioUtils.playVoice("baojing1.wav",self.scene:getSex(data.index))
	end
	self:createhand()
	print("剩余好多牌1:"..#self.carddata)

	-- for i,v in ipairs(realcardtab) do
	-- 	local card = Card.new(v.value,1)
	-- 	card:setPositionX((i-1)*90/2)
	-- 	if v.islaizi then
	-- 		card:setlai(true)
	-- 	end
	-- 	self.outnode:addChild(card)
	-- end
	-- self.outnode:setPositionX(self.outx - (#data.carddatas-1)*(90/4))
	if self.localpos == 1 then
		for i,v in ipairs(realcardtab) do
			local card = Card.new(v.value,1)
			card:setPositionX((i-1)*90/2)
			if v.islaizi then
				card:setlai(true)
			end
			self.outnode:addChild(card)
		end
		self.outnode:setPositionX(self.outx - (#data.carddatas-1)*(90/4))
	elseif self.localpos == 2 then
		local totall = #realcardtab
		for i,v in ipairs(realcardtab) do
			local card = Card.new(v.value,1)
			card:setCardAnchorPoint(cc.p(1,0.5))
			--card:setPositionY(-108)
			card:setPositionX((1-(totall - i+ 1))*90/2)
			if v.islaizi then
				card:setlai(true)
			end
			self.outnode:addChild(card)
		end
		--self.outnode:addChild(cc.Sprite:create("common/head.png"))
	elseif self.localpos == 3 then
		for i,v in ipairs(realcardtab) do
			local card = Card.new(v.value,1)
			card:setCardAnchorPoint(cc.p(0,0.5))
			card:setPositionX((i-1)*90/2)
			--card:setPositionY(-108)
			if v.islaizi then
				card:setlai(true)
			end
			self.outnode:addChild(card)
		end
		--self.outnode:addChild(cc.Sprite:create("common/head.png"))
	end
	-- 1单张  2 连  3 对  4连对 5 3带2 6 飞机 7 炸弹 0不存在的状态
	local is,typedata = Func.getput(data.carddatas,data.cardtype)
	if isnotta then
	else
		if  typedata.type == 4 then
			local spr = WidgetUtils:lianduieffect()
			spr:setPositionX(self.outx)
			spr:setPositionY(self.outy+50)
			self:addChild(spr)
		elseif typedata.type == 2 then
			local spr = WidgetUtils:shunzieffect()
			spr:setPositionX(self.outx)
			spr:setPositionY(self.outy+50)
			self:addChild(spr)
		elseif typedata.type == 6 then
			local spr = WidgetUtils:feijieffect()
			spr:setPositionX(self.outx)
			spr:setPositionY(self.outy+50)
			self:addChild(spr)
		elseif typedata.type == 7 then
			local spr = WidgetUtils:zhandaneffect()
			spr:setPositionX(self.outx)
			spr:setPositionY(self.outy+100)
			self:addChild(spr)
		end
	end
	
	print("出牌")
	printTable(typedata,"sjp")
	if isnotta then
	else
		if typedata.type == 1 then
			local realvalue = (typedata.real-1)%13+1
			AudioUtils.playVoice("pk_"..realvalue..".wav",self.scene:getSex(data.index))
		elseif typedata.type == 3 then
			local realvalue = (typedata.real-1)%13+1
			AudioUtils.playVoice("dui"..realvalue..".wav",self.scene:getSex(data.index))
		elseif typedata.type == 2 then
			if data.clear == 1 then
				AudioUtils.playVoice("shunzi.wav",self.scene:getSex(data.index))
			else
				AudioUtils.playVoice("shunzi.wav",self.scene:getSex(data.index))
			end
		elseif typedata.type == 4 then
			AudioUtils.playVoice("liandui.wav",self.scene:getSex(data.index))
		elseif typedata.type == 5 then
			if #data.carddatas == 5 then
				AudioUtils.playVoice("sandaiyidui.wav",self.scene:getSex(data.index))
			elseif #data.carddatas == 4 then
				AudioUtils.playVoice("sandaiyi.wav",self.scene:getSex(data.index))
			elseif #data.carddatas == 3 then
				local realvalue = (typedata.value[1]-1)%13+1
				AudioUtils.playVoice("Man_tuple"..realvalue..".wav",self.scene:getSex(data.index))
			end
		elseif typedata.type == 6 then
			AudioUtils.playVoice("feiji.wav",self.scene:getSex(data.index))
		elseif typedata.type == 7 then
			AudioUtils.playVoice("zhadan.wav",self.scene:getSex(data.index))
		end
	end
end
function recordbase:guo( ... )
	self.outnode:removeAllChildren()

	local spr = cc.Sprite:create("game/guoaction.png")
		spr:setScale(1)
		spr:setPositionX(self.outx)
		spr:setPositionY(self.outy)
		self.outnode:getParent():addChild(spr)
		spr:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
			spr:removeFromParent()
		end)))
end
return recordbase