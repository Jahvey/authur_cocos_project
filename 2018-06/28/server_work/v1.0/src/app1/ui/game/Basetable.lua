local BaseView = class("BaseView",function()
    return cc.Node:create()
end)
local Card = require "app.ui.game.Card"
function BaseView:ctor(localpos,scene)
	self.localpos = localpos
	self.scene = scene
	self:createcards()
end

function BaseView:createcards()
	local node = self.scene.painode:getChildByName("node"..self.localpos)
	self.cardnode = cc.Node:create()
	if self.localpos == 1 then
		self.cardnode:setPositionX(node:getPositionX()-50)
	else
		self.cardnode:setPositionX(node:getPositionX())
	end
	self.cardnode:setPositionY(node:getPositionY())
	print(node:getPositionX())
	print(node:getPositionY())
	self:addChild(self.cardnode)
	self.cards = {}
	for i=1,5 do
		if self.localpos == 1 then
			self.cards[i] = Card.new(0)
		else
			self.cards[i] = Card.new(0,true)
		end
		if self.localpos == 1 then
			self.cards[i]:setPositionX((i-1)*130)
			self.cards[i]:setScale(1.2)

			self.cards[i]:setPositionY(0)
		else
			self.cards[i]:setScale(90/114)
			self.cards[i]:setPositionX((i-1)*40)
		end
		self.cardnode:addChild(self.cards[i])
		self.cards[i]:setVisible(false)
	end

	if self.localpos == 1 then
		self.showcards = {}
		local node = self.scene.painode:getChildByName("node0")
		self.showcardnode = cc.Node:create()
		self.showcardnode:setPositionX(node:getPositionX())
		self.showcardnode:setPositionY(node:getPositionY())
		self:addChild(self.showcardnode)

		for i=1,5 do
			self.showcards[i] = Card.new(0,true)
			self.showcards[i]:setScale(90/114)
			self.showcards[i]:setPositionX((i-1)*40)
			self.showcardnode:addChild(self.showcards[i])
			self.showcards[i]:setVisible(false)
		end
	end
end

function BaseView:ya_zhu(num,isan,firstscore)
	if self.scene.isfive  and self.localpos then
	end
	self.scene.icon[self.localpos]:getChildByName("goldxia"):setVisible(true)
	self.scene.icon[self.localpos]:getChildByName("goldxia"):getChildByName("text"):setString(num)


	if isan then
		AudioUtils.playEffect("niu_xiazhu")
		print("donghua")
		local xianode = self.scene.icon[self.localpos]:getChildByName("goldxia")
		xianode:setVisible(true)
		-- local goldbg = xianode:getChildByName("goldbg")
		-- goldbg:setOpacity(0)
		local text = self.scene.icon[self.localpos]:getChildByName("goldxia"):getChildByName("text")
		if firstscore then
			text:setString(firstscore)

			text:setVisible(true)
		else
			text:setString(num)

			text:setVisible(false)
		end
		local endpos = xianode:convertToWorldSpace(cc.p(46,20))
		local iconnode = self.scene.icon[self.localpos]
		local begposx,begposy  = iconnode:getPosition()
		local addnum = num
		if num >4 then
			addnum = 4
		end
		for i=1,addnum do
			local spr = cc.Sprite:create("game/gold.png")
			spr:setPosition(cc.p(begposx,begposy))
			spr:setVisible(false)
			local action1=  cc.MoveTo:create(0.3,endpos)
			spr:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.1),cc.Show:create(),action1,cc.CallFunc:create(function()
				
				if i == addnum then
					--goldbg:runAction(cc.FadeIn:create(0.4))
					if firstscore then
						text:setString(num+firstscore)
					else
						text:setVisible(true)
					end
				end
				spr:removeFromParent()
			end)))
			self:addChild(spr)
		end
	else
		self.scene.icon[self.localpos]:getChildByName("goldxia"):setVisible(true)
		self.scene.icon[self.localpos]:getChildByName("goldxia"):getChildByName("text"):setString(num)
	end

	
end
function BaseView:getniuvalue(type_data)
	
	-- body
end

function BaseView:showallcard(cardtype,dn_hand_tiles,index,cardtimes)
	self.isshowcardend = true 
	local num = cardtype
	if num == nil then
		return
	end

	if self.localpos == 1 then
		self.cardnode:setVisible(false)
		for i,v in ipairs(self.showcards) do
			v:setVisible(true)
			v:setlocalvalue(dn_hand_tiles[i])
			--v:setValue(dn_hand_tiles[i])
			local isgray = false
			if num == 0 then
				isgray = true
			end
			self:fanpaione(v,isgray)
		end

		local node  = self:createniuan(num,nil,cardtimes)
		node:setPositionX(75)
		node:setPositionY(-45)
		self.showcardnode:addChild(node)
		if index then
			AudioUtils.playVoice("niu"..num..".mp3",self.scene:getSex(index))
		end
	else
		for i,v in ipairs(self.cards) do
			v:setlocalvalue(dn_hand_tiles[i])
			local isgray = false
			if num == 0 then
				isgray = true
			end
			self:fanpaione(v,isgray)
		end
		local node  = self:createniuan(num,nil,cardtimes)
		node:setPositionX(75)
		node:setPositionY(-45)
		self.cardnode:addChild(node)
		if index then
			AudioUtils.playVoice("niu"..num..".mp3",self.scene:getSexByUid(index))
		end
	end
	AudioUtils.playEffect("liangpai")
	
end

function BaseView:showhandtip()
	if self.shownodeniu   then
		self.shownodeniu:removeFromParent()
	end
	--local isright,niuvalue,pos = self:getniuvalue()
	-- printTable(self.type_data)
	-- local num,pos = self:getniuvalue(self.type_data)

	-- if num then
	-- 	print('牛:'..num)
	-- else
	-- 	print('不能操作')
	-- end
	if self.shownodeniu   then
		self.shownodeniu:removeFromParent()
	end
	if self.handcardtype then
		self.shownodeniu  = self:createniuan(self.handcardtype,20)
		self.shownodeniu:setPositionX(113*2)
		self.cardnode:addChild(self.shownodeniu)
		if pos then
			for i,v in ipairs(pos) do
				self.cards[v]:setPositionY(30)
			end
		end
	end
end

function BaseView:showcardfanpai(pos,value,isan,isdan,isshow)


	self.cards[pos]:setVisible(true)
	if  isan then
		self.cards[pos]:setlocalvalue(value)
		self.cards[pos]:setValue(0)
		local oldpos = cc.p(self.cards[pos]:getPositionX(),self.cards[pos]:getPositionY())
		if self.localpos == 1 then
			self.cards[pos]:setScale(68/114)
			if isdan then
				self.cards[pos]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function( ... )
					 AudioUtils.playEffect("niu_diwu")
				end),cc.ScaleTo:create(0.2,1)))
			else
				self.cards[pos]:runAction(cc.Sequence:create(cc.DelayTime:create(pos*0.05),cc.CallFunc:create(function( ... )
					if pos == 1 then
						AudioUtils.playEffect("niu_fapaiall")
					end
				end),cc.ScaleTo:create(0.2,1.2)))
			end
		end
		local putout = self.scene.painode:getChildByName("putnode")
		local posbeigin = self.cardnode:convertToNodeSpace(cc.p(putout:getPositionX(),putout:getPositionY()))
		self.cards[pos]:setPosition(posbeigin)
		if isdan  then
			self.cards[pos]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
				 --AudioUtils.playEffect("fapai")
			end),cc.MoveTo:create(0.2,oldpos)))
		else
			self.cards[pos]:runAction(cc.Sequence:create(cc.DelayTime:create(pos*0.05),cc.CallFunc:create(function( ... )
				 --AudioUtils.playEffect("fapai")
			end),cc.MoveTo:create(0.2,cc.p(0,0)),cc.DelayTime:create(0),cc.MoveTo:create(0.1,oldpos),cc.CallFunc:create(function()
				if isshow then
					if self.localpos == 1 then
						self.cards[pos]:setlocalvalue(value)
						self:fanpaione(self.cards[pos])
					end
				else
					--self.cards[pos]:setValue(value)
				end
				
			end)))
		end
	else
		self.cards[pos]:setVisible(true)
		self.cards[pos]:setValue(value)
	end



end
--是否存在这个牌型
function BaseView:ishavepaixing(type)
	-- body
	if self.scene.data.conf.dn_table_config.speceial_type then
		for i,v in ipairs(self.scene.data.conf.dn_table_config.speceial_type) do
			if v == type then
				return true
			end
		end
	end
	return false
end

function BaseView:getniuposcards()

	local valuetable = {}
	local ishave = true
	for i,v in ipairs(self.cards) do
		local num = v:getValue()
		print("num:"..num)
		if num == 0 then
			ishave = false
		end
		num = num%16
		if num > 10 then
			num = 0
		end
		table.insert(valuetable,num)
	end
	printTable(valuetable)
	local  haveniu = false
	local num1,num2,num3
	local niuvalue  =0
	if ishave  then
		for i=1,5 do
			for j=i+1,5 do
				for k=j+1,5 do
					print(valuetable[i] ,valuetable[j],valuetable[k])
					if (valuetable[i] + valuetable[j]+valuetable[k])%10 == 0 then
						haveniu = true
						num1 = i
						num2 = j
						num3 = k
						print("位子"..num1.." "..num2.." "..num3)
						print('找到牛')
						return {num1,num2,num3}
					end
				end
				if haveniu then
					break
				end
			end
			if haveniu then
				break
			end
		end
		
	else
		return nil
	end
end

function BaseView:fanpaisAnima()
	for i,v in ipairs(self.cards) do
		local value = v:getValue()
		if value == 0 then
			self:fanpaione(v)
		end
		 AudioUtils.playEffect("liangpai")
	end
end

function BaseView:fanpaione(card,isgray)
	if card:getValue() ~= 0 then
		if  card:getlocalvalue() ~= card:getValue() and card:getlocalvalue() ~= 0 then
			card:setValue(card:getlocalvalue())
		end
		return
	end
	local ation1 = cc.Sequence:create(cc.RotateTo:create(0, 0, -180),cc.RotateTo:create(0.2, 0, -90),cc.CallFunc:create(function()
				card:showlocalvlue()
				-- if isgray then
				-- 	card:setGray()
				-- end
			end),cc.RotateTo:create(0.1, 0, 0),cc.CallFunc:create(function()
				
			end))
	card:runAction(cc.EaseSineIn:create(ation1))
end
function BaseView:createniuan(value,num,bei)
	-- local node =  cc.CSLoader:createNode("Animation/niuniu/niuniu.csb")
	-- local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu/niu"..value..".png")
	-- local action = cc.CSLoader:createTimeline("Animation/niuniu/niuniu.csb")
 --    node:runAction(action)
 --    action:gotoFrameAndPlay(num or 0,false)
 	if bei and bei > 1 then
 		local node =  cc.CSLoader:createNode("Animation/niuniu1/niuniubei.csb")
		local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu"..value..".png")
		local niubei = node:getChildByName("Node_1"):getChildByName("niubei")
		if  value >= 10 then
			niubei:setTexture("game/bei/"..bei..".png")
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(true)
		else
			niubei:setTexture("game/bei/x"..bei..".png")
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(true)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
		end
		local action = cc.CSLoader:createTimeline("Animation/niuniu1/niuniubei.csb")
	    node:runAction(action)
	    action:gotoFrameAndPlay(num or 0,false)
	    if value == 0 then
	    	node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
	    end
	    return node 
 	else
	 	local node =  cc.CSLoader:createNode("Animation/niuniu1/niuniu.csb")
		local niu = node:getChildByName("Node_1"):getChildByName("niu_4"):setTexture("game/niu"..value..".png")
		local action = cc.CSLoader:createTimeline("Animation/niuniu1/niuniu.csb")
	    node:runAction(action)
	    action:gotoFrameAndPlay(num or 0,false)

	    if  value >= 10 then
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(true)
		else
			node:getChildByName("Node_1"):getChildByName("di1"):setVisible(true)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
		end

	    if value == 0 then
	    	node:getChildByName("Node_1"):getChildByName("di1"):setVisible(false)
	    	node:getChildByName("Node_1"):getChildByName("di2"):setVisible(false)
	    end
	    return node
	end
    
end


function BaseView:createzhuang(isdeal,isding)
	-- local node =  cc.CSLoader:createNode("Animation/qiangzhuang/xuanzhuang.csb")
	-- local action = cc.CSLoader:createTimeline("Animation/qiangzhuang/xuanzhuang.csb")
	if isdeal then
		 self.scene.icon[self.localpos]:getChildByName("zhuang"):setVisible(false)
	end
	local node 
	local action
	if self.localpos == 2 or  self.localpos == 6 or (self.scene.isfive and (self.localpos == 2 or  self.localpos == 3 or  self.localpos == 4 or  self.localpos == 5)) then
		node =  cc.CSLoader:createNode("Animation/qiangzhuang/xuan1.csb")
		action = cc.CSLoader:createTimeline("Animation/qiangzhuang/xuan1.csb")
	else
		node = cc.CSLoader:createNode("Animation/qiangzhuang/xuan2.csb")
		action = cc.CSLoader:createTimeline("Animation/qiangzhuang/xuan2.csb")
	end
	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
        	if isdeal then
        	else
        		node:removeFromParent()
        	end
        end

         if str == "allend" then
        	if isdeal then
        		node:removeFromParent()
        		if self.scene~= nil then
	        		self.scene.icon[self.localpos]:getChildByName("zhuang"):setVisible(true)
	        		self.scene.icon[self.localpos]:getChildByName("zhuang1"):setVisible(true)
	        	end
        	end
        end

    end
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    if isding then
    	action:gotoFrameAndPlay(38,false)
    else
    	action:gotoFrameAndPlay(0,false)
    end
    local iconnode =  self.scene.icon[self.localpos]
    node:setPosition(cc.p(iconnode:getContentSize().width/2, iconnode:getContentSize().height/2))
    iconnode:addChild(node)
 
end


function BaseView:showwinlost(value,isfour)
	local node =  cc.CSLoader:createNode("cocostudio/ui/game/goldnode1.csb")
	local win = node:getChildByName("win")
	local lost = node:getChildByName("lost")
	if value >= 0 then
		win:setString("/"..value)
		win:setVisible(true)
		lost:setVisible(false)
		if self.localpos == 1 then
			AudioUtils.playEffect("niu_yingle")
		end
	elseif value < 0 then
		lost:setString("/"..math.abs(value))
		lost:setVisible(true)
		win:setVisible(false)
		if self.localpos == 1 then
			AudioUtils.playEffect("niu_shule")
		end
	else
		lost:setVisible(false)
		win:setVisible(false)
	end
	local action = cc.CSLoader:createTimeline("cocostudio/ui/game/goldnode1.csb")
    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    if isfour == nil then
    	local iconnode =  self.scene.icon[self.localpos]
	    node:setPosition(cc.p(iconnode:getContentSize().width/2, iconnode:getContentSize().height))
	    iconnode:addChild(node)
    else
	    local iconnode =  self.scene.xiazhu
	    node:setPosition(cc.p(iconnode:getContentSize().width/2, iconnode:getContentSize().height))
	    iconnode:addChild(node)
	  end
end

function BaseView:cuopai()
	if self.isshowcardend then
		return
	end
	print("名字："..self.scene.conf.dn_table_config.play_type)
	if self.scene.conf.dn_table_config.play_type == poker_common_pb.EN_DN_Play_Type_Ming_Pai_Qiang_Zhuang or self.scene.conf.dn_table_config.play_type == poker_common_pb.EN_DN_Play_Type_Crazy_Niu_Niu then
		local Cuopai1 = require "app.ui.niuniu.Cuopai1".new(self.cards[5]:getlocalvalue(),function()
			self:fanpaione(self.cards[5])
		end)
		Cuopai1:setPosition(cc.p(display.cx,display.cy))
		self.scene:addChild(Cuopai1)
		self.Cuopai1 = Cuopai1
	else
		local tablevalue = {}
		tablevalue[1] = self.cards[1]:getlocalvalue()
		tablevalue[2] = self.cards[2]:getlocalvalue()
		tablevalue[3] = self.cards[3]:getlocalvalue()
		tablevalue[4] = self.cards[4]:getlocalvalue()
		tablevalue[5] = self.cards[5]:getlocalvalue()

		local Cuopai2 = require "app.ui.niuniu.Cuopai2".new(tablevalue,function()
			for i,v in ipairs(self.cards) do
				self:fanpaione(v)
			end
		end)
		Cuopai2:setPosition(cc.p(display.cx,display.cy))
		self.scene:addChild(Cuopai2)
		self.Cuopai2 = Cuopai2
	end
end

function BaseView:showqiang(bei)
	-- body
end



return BaseView