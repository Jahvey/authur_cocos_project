
local Card = require "app.ui.game.Card"
local Gameview = class("Gameview",function()
    return cc.Node:create()
end)

function Gameview:ctor(scene,data,isre)
	self.data = data
	self.scene = scene
	self:initView(isre)
end
function Gameview:initView(isre)
	self:setLocalZOrder(1)
	self.tableviews = {}
	print('-------'..self.scene.gameplayernums)
	print('-------'..tostring(isre))
	local Basetable = require "app.ui.game.Basetable"
	for i,v in ipairs(self.scene.data.roomPlayerItemJsons) do
		if v.curGameResult == 0 then 
			local localpos = self.scene:getLocalindex(v.index)
			if localpos == 1 then
				print("set  false")
				printTable(v)
				self.tableviews[localpos] = Basetable.new(localpos,self.scene)
				self:showAction(v)

			else
				self.scene:setTip(v.index,true,self.data.baisurplustime)
				self.tableviews[localpos] = Basetable.new(localpos,self.scene)
			end
			if v.betscore and v.betscore ~= 0 then
				self.tableviews[localpos]:ya_zhu(v.betscore)
			end
			if v.curCards and v.curCards[1] ~= 0 then
				for i1,v1 in ipairs(v.curCards) do
					self.tableviews[localpos]:showcardfanpai(i1,v1)
				end
				if localpos == 1 and v.playTypes and v.playTypes[1] == 3 and self.scene.data.gamecuocardtype == 0 then
					self.tableviews[1].cards[5]:setlocalvalue(self.tableviews[1].cards[5]:getValue())
					self.tableviews[1].cards[5]:setValue(0)
				end
			elseif v.curCards then
				for i1,v1 in ipairs(v.curCards) do
					self.tableviews[localpos]:showcardfanpai(i1,v1,false)
				end
			end
			self.tableviews[localpos].handcardtype = v.cardtype
			if v.curStage == 3 then
				self.tableviews[localpos]:showallcard(v.cardtype,v.curCards,v.index,v.cardtimes)
			end
			self:addChild(self.tableviews[localpos])
		end
	end

end
function Gameview:showAction( data )
	print(1)

	if data.playTypes and #data.playTypes > 0 then
		print(2)
		
		if data.playTypes[1] == 1  then
			self.scene.actionnode:getChildByName("node"):removeAllChildren()
			for i,v in ipairs(data.qiangBankerTimes) do
				local btn 
				if v == 0 then
					btn = ccui.Button:create("game/buqiang.png","game/buqiang.png", "game/buqiang.png", ccui.TextureResType.localType)
				else
					if self.scene.data.gamebankertype ==1 then
						btn = ccui.Button:create("game/q"..v..".png","game/q"..v..".png", "game/q"..v..".png", ccui.TextureResType.localType)
					else
						btn = ccui.Button:create("game/qiangbtn.png","game/qiangbtn.png", "game/qiangbtn.png", ccui.TextureResType.localType)
					end
				end
				btn:setPosition(cc.p((i - #data.qiangBankerTimes/2 -0.5)*180,0))
				WidgetUtils.addClickEvent(btn, function( )
					Socketapi.doaction(1,v)
					self.scene.actionnode:getChildByName("node"):removeAllChildren()
				end)
				self.scene.actionnode:getChildByName("node"):addChild(btn)
			end
		elseif data.playTypes[1] == 2 or data.playTypes[1] == 4 then
			print(3)
			self.scene.actionnode:getChildByName("node"):removeAllChildren()
			--self.scene.icon[1]:getChildByName("qiang"):setVisible(false)
			for i,v in ipairs(data.betScores) do
				local btn 
				btn = ccui.Button:create("game/anniu.png","game/anniu.png", "game/anniu.png", ccui.TextureResType.localType)
				local lable = self.scene.copylable:clone()
				lable:setString(v)
				if data.mustHitBankerType  and data.mustHitBankerType > 0 then
					if i == #data.betScores then
						lable:setString(v.."(打庄)")
					end
				end
				local size = btn:getContentSize()
				lable:setPosition(cc.p(size.width/2,size.height/2))
				btn:addChild(lable)
				btn:setPosition(cc.p((i - #data.betScores/2 -0.5)*180,0))
				WidgetUtils.addClickEvent(btn, function( )
					Socketapi.doaction(data.playTypes[1],nil,v)
					self.scene.actionnode:getChildByName("node"):removeAllChildren()
				end)
				self.scene.actionnode:getChildByName("node"):addChild(btn)
			end
		elseif data.playTypes[1] == 3 then
			if self.scene.data.gamecuocardtype  and self.scene.data.gamecuocardtype == 1 then
				self.scene.kaipaibtn1:setVisible(true)
				self.scene.kaipaibtn2:setVisible(true)

				self.scene.kanpaibtn1:setVisible(false)
				self.scene.kanpaibtn2:setVisible(false)
			else
				self.scene.kaipaibtn1:setVisible(false)
				self.scene.kaipaibtn2:setVisible(false)

				self.scene.kanpaibtn1:setVisible(true)
				self.scene.kanpaibtn2:setVisible(true)
			end
		end
	end
end
function Gameview:fapaiaction(data )

	if data.curPlayerFourCards then
		for i,v in ipairs(data.curPlayerFourCards) do
			local localpos = self.scene:getLocalindex(v.index)
			if self.tableviews[localpos] then
				for i1,v1 in ipairs(v.curCards) do
					self.tableviews[localpos].cards[i1]:setlocalvalue(v1)
					self.tableviews[localpos]:fanpaione(self.tableviews[localpos].cards[i1])
				end
			end
		end
	end
	for i,v in ipairs(self.scene.data.roomPlayerItemJsons) do
		local localpos = self.scene:getLocalindex(v.index)
		if self.tableviews[localpos] then
			if localpos == 1 then
				self.tableviews[localpos].type_data = v.type_data
			end
			if #data.curCards == 1 then
				if self.scene.data.gamecuocardtype == 1 then
					self.tableviews[localpos]:showcardfanpai(5,data.curCards[1],true,false,true)
				else
					self.tableviews[localpos]:showcardfanpai(5,data.curCards[1],true,false,false)
				end
				self.tableviews[localpos].handcardtype = data.cardtype
			else
				for j=1,#data.curCards do
					if j == 5 then
						if self.scene.data.gamecuocardtype == 1 then
							self.tableviews[localpos]:showcardfanpai(j,data.curCards[j],true,false,true)
						else
							self.tableviews[localpos]:showcardfanpai(j,data.curCards[j],true,false,false)
						end
					else
						self.tableviews[localpos]:showcardfanpai(j,data.curCards[j],true,false,true)
					end
				end
				self.tableviews[localpos].handcardtype = data.cardtype
			end
		end
	end
	
end
function Gameview:fanpanall( )
	self.tableviews[1]:fanpaione(self.tableviews[1].cards[5])
end
function Gameview:cuopai()
	local cards = self.tableviews[1].cards
	local Director = cc.Director:getInstance()
    local WinSize = Director:getWinSize()
    self.scene.cuolayer:removeAllChildren()
    for i=1,4 do
       local spr = cc.Sprite:create("game/cardbig/card_"..cards[i]:getlocalvalue()..".png")
       spr:setScale(0.25)
       self.scene.cuolayer:addChild(spr)
       spr:setPosition(cc.p((WinSize.width/2)+(i - 2 -0.5)*180,WinSize.height/2+200))
    end
    local winSize = cc.Director:getInstance():getWinSize()
    local RubCardLayer = require("app/RubCardLayer")
   local cuo
      cuo = RubCardLayer:create("game/cardbig/card_0.png",  "game/cardbig/card_"..cards[5]:getlocalvalue()..".png",
                            WinSize.width/2,WinSize.height/2- 75,0.7,function(  )
           -- cuo:removeFromParent()
            local spr = cc.Sprite:create("game/cardbig/card_"..cards[5]:getlocalvalue()..".png")
            self.scene.cuolayer:addChild(spr)
            spr:setAnchorPoint(cc.p(0.5,0.5))
            spr:setRotation(90)
            spr:setPosition(WinSize.width/2,WinSize.height/2- 75)
            spr:setScale(0.7)
            spr:setOpacity(0)
            spr:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(1.2),cc.CallFunc:create(function( ... )
                 self.scene.cuolayer:setVisible(false)
                 self.scene.cuolayer:removeAllChildren()
                 self:fanpanall()
            end)))
        end)
        self.scene.cuolayer:addChild(cuo)
        self.scene.cuolayer:setVisible(true)

	-- if value ~= 0 then
	-- 	local cuo = require "app.cuoeffect"("Card.plist","card0.png", "card"..value..".png", 2,function( ... )
	-- 		self.scene.cuolayer:setVisible(false)
	-- 		self.scene.cuolayer:removeAllChildren()
	-- 		self:fanpanall()
	-- 	end)
	-- 	self.scene.cuolayer:addChild(cuo)
	-- 	self.scene.cuolayer:setVisible(true)
	-- end
end
function Gameview:xiazhu(data)
	local localpos = self.scene:getLocalindex(data.index)
	self.tableviews[localpos]:ya_zhu(data.betscore,true,data.firstbetscore)
end
function Gameview:kaipai( data )
	print("kaipai")
	local localpos = self.scene:getLocalindex(data.index)
	self.tableviews[localpos]:showallcard(data.cardtype,data.curCards,data.index,data.cardtimes)
end

function Gameview:doaciton(localpos)
	self.tableviews[localpos]:doaciton()
end

function Gameview:cs_notify_dn_game_over(data)
	printTable(data)
	local function gettime( pos1,pos2 )
		local length = cc.pGetLength(cc.p(pos1.x - pos2.x,pos1.y - pos2.y))
		return length/1300
	end
	local losttable = {}
	local wintable = {}
	local zhuangtable  = nil
	if self.scene.curBanker == 0 or self.scene.curBanker == nil then
		-- 牛牛比
		
		for i,v in ipairs(data.gameendinfolist) do
			if v.index ~= self.scene.curBanker then
				if v.onescore > 0 then
					zhuangtable = v
				elseif v.onescore < 0 then
					table.insert(losttable,v)
				end
			else
				zhuangtable  = v
			end
		end
	else
		--有庄
		for i,v in ipairs(data.gameendinfolist) do
			if v.index ~= self.scene.curBanker then
				if v.onescore > 0 then
					table.insert(wintable,v)
				elseif v.onescore < 0 then
					table.insert(losttable,v)
				end
				print("meiyou庄")
			else
				print("有庄")
				zhuangtable  = v
			end
		end
	end
		local isfirst = true
		local function endaction()
			if isfirst == false then
				return
			end
			isfirst = false
			for i,v in ipairs(data.gameendinfolist) do
				local localpos = self.scene:getLocalindex(v.index)
				-- if self.scene.data.gamebankertype == 4 and v.index == self.scene.curBanker then
				-- 	if self.tableviews[localpos] then
				-- 		self.tableviews[localpos]:showwinlost(v.onescore,true)
				-- 	end
				-- else
					if self.tableviews[localpos] then
						self.tableviews[localpos]:showwinlost(v.onescore)
					end
				--end
			end
			for i,v in ipairs(data.gameendinfolist) do
				local pos = self.scene:getLocalindex(v.index)
				self.scene.icon[pos]:getChildByName("fen"):setString(v.totalscore)
				self.scene.icon[pos]:getChildByName("qiang"):setVisible(false)
			end
			
			self.scene.xiazhu:getChildByName("text"):setString(data.curPoolScore)
			--self.scene:updataicons()
		end
		local function winaction(  )
			print("wintable:"..#wintable)
			if #wintable ~= 0 then
				AudioUtils.playEffect("gamegold")
				for i,v in ipairs(wintable) do
					local localpos =  self.scene:getLocalindex(v.index)
					local iconnode = self.scene.icon[localpos]
					local beiginpos = cc.p(iconnode:getPositionX(),iconnode:getPositionY())
					local zhuanglocalpos = self.scene:getLocalindex(zhuangtable.index)
					local iconnodezhuang = self.scene.icon[zhuanglocalpos]

					local endpos =  cc.p(iconnodezhuang:getPositionX(),iconnodezhuang:getPositionY())
					if self.scene.data.gamebankertype == 4 then
						endpos =  cc.p(self.scene.xiazhu:getPositionX(),self.scene.xiazhu:getPositionY())
					end
					print("播放wintable:",zhuanglocalpos,localpos)
					for j=1,30 do
						local spr = cc.Sprite:create("game/gold.png")
						spr:setScale(1.5)
						spr:setPositionX(endpos.x)
						spr:setPositionY(endpos.y)
						local time = math.random(1,1000)/5000
						print("random:"..time)
						spr:runAction(cc.Sequence:create(cc.Hide:create(),cc.DelayTime:create(time),cc.Show:create(),cc.MoveTo:create(gettime(beiginpos,endpos),cc.p(beiginpos.x+math.random(-35,35),beiginpos.y+math.random(-35,35))),cc.CallFunc:create(function( ... )
							if j == 20 then
								endaction()
							end
							spr:setVisible(false)
						end),cc.DelayTime:create(1),cc.CallFunc:create(function(  )
							spr:removeFromParent()
						end)))
						self:addChild(spr)
					end
				end
			else
				endaction()
			end
		end
		if #losttable ~= 0 then
			AudioUtils.playEffect("gamegold")
			for i,v in ipairs(losttable) do
				local localpos =  self.scene:getLocalindex(v.index)
				local iconnode = self.scene.icon[localpos]
				local beiginpos = cc.p(iconnode:getPositionX(),iconnode:getPositionY())
				local zhuanglocalpos = self.scene:getLocalindex(zhuangtable.index)
				local iconnodezhuang = self.scene.icon[zhuanglocalpos]
				local endpos =  cc.p(iconnodezhuang:getPositionX(),iconnodezhuang:getPositionY())
				if self.scene.data.gamebankertype == 4  then
					endpos =  cc.p(self.scene.xiazhu:getPositionX(),self.scene.xiazhu:getPositionY())
				end
				print("播放losttable:",localpos,zhuanglocalpos)
				for j=1,30 do
					local spr = cc.Sprite:create("game/gold.png")
					spr:setPositionX(beiginpos.x)
					spr:setPositionY(beiginpos.y)
					spr:setScale(1.5)
					local time = math.random(1,1000)/5000
					print("random:"..time)
					spr:runAction(cc.Sequence:create(cc.Hide:create(),cc.DelayTime:create(time),cc.Show:create(),cc.MoveTo:create(gettime(beiginpos,endpos),cc.p(endpos.x+math.random(-35,35),endpos.y+math.random(-35,35))),cc.CallFunc:create(function()
						spr:setVisible(false)
					end),cc.DelayTime:create(1),cc.CallFunc:create(function(  )
						if j == 20 and i == 1 then
							winaction()
						end
						spr:removeFromParent()
						
					end)))
					self:addChild(spr)
				end
			end
		else
			winaction()
		end

	
end

function Gameview:qiangzhuang( data )
	local localpos =  self.scene:getLocalindex(data.curBanker)
	if data.randomPlayerIndexs and #data.randomPlayerIndexs > 0 then
		for i,v in ipairs(data.randomPlayerIndexs) do
			local localpos1 =  self.scene:getLocalindex(v)
			if localpos == localpos1 then
				if self.tableviews[localpos1] then
					self.tableviews[localpos1]:createzhuang(true,false)
				end
			else
				if self.tableviews[localpos1] then
					self.tableviews[localpos1]:createzhuang(false,false)
				end
			end
		end
	else
		if self.tableviews[localpos] then
			self.tableviews[localpos]:createzhuang(true,true)
		end
	end
end

return Gameview