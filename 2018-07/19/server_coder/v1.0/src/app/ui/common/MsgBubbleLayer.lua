-------------------------------------------------
--   TODO   消息气泡
--   @author yc
--   Create Date 2016.11.1
-------------------------------------------------
local MsgBubbleLayer = class("MsgBubbleLayer",function() 
	return cc.Node:create() 
end)
-- 背景1
local addSize1 = cc.size(50,40)
-- 背景2
local addSize2 = cc.size(40,50)
-- 表情
local addSize3 = cc.size(30,30)
-- 语音
local addSize4 = cc.size(0,0)
function MsgBubbleLayer:ctor(pos,data,_scene)
	self.gameScene = _scene
  cc.SpriteFrameCache:getInstance():addSpriteFrames("cocostudio/res/image/plist/emoji.plist")
  self:initData(pos,data)
  self:initView()
  if data and data.ctype == 2 and data.message and data.message ~= "" then 
    local output = cjson.decode(data.message)
    if  output and type(output) =="table" and output.time then
        self:runAction(cc.Sequence:create(cc.DelayTime:create((output.time)/1000),cc.CallFunc:create(function()
          self:removeFromParent()
      end)))
    else
      self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function()
          self:removeFromParent()
      end)))
    end
  else
    self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function()
      self:removeFromParent()
    end)))
  end
end
function MsgBubbleLayer:initData(pos,data)
	data = data or {}
	-- printTable(data)
	self.pos = pos 
	self.data = data
	self.size = cc.size(0,0)
end
function MsgBubbleLayer:createTextNode()
	local maxwidth = 200
	self.data.message = CommonUtils.checkchange(self.data.message)
	local text2 = ccui.Text:create(self.data.message,"",20)
	if text2:getContentSize().width <= maxwidth then
		maxwidth = text2:getContentSize().width
	end
	
    local text = ccui.Text:create("","",20)
    
    text:setColor(cc.c3b(0x09,0x36,0x34))
    if self.pos == 1 then
		text:setAnchorPoint(cc.p(0,1))
		text:setPosition(cc.p(self.addheight.width/2,-(self.addheight.height-5)/2))	
	elseif self.pos == 4 then
		text:setAnchorPoint(cc.p(0,1))	
		text:setPosition(cc.p((self.addheight.width+10)/2,-(self.addheight.height-10)/2))	
	elseif self.pos == 3 then
		text:setAnchorPoint(cc.p(0,1))
		text:setPosition(cc.p((self.addheight.width/2+35)/2,-(self.addheight.height)/2))		
	else
		text:setAnchorPoint(cc.p(1,1))
		text:setPosition(cc.p(-(self.addheight.width+30)/2,-(self.addheight.height)/2))
	end	
    text:ignoreContentAdaptWithSize(true)
    text:setTextAreaSize(cc.size(maxwidth,0))
    text:setString(self.data.message or "")
    text:ignoreContentAdaptWithSize(false) 
    
    self.size = cc.size(text:getContentSize().width+10,text:getContentSize().height+8)
    return text
end
function MsgBubbleLayer:createEmojNode()
	local size = cc.size(70,70)
	local id = self.data.BigFaceID 
	if not id then
		return 
	end
	local img = ccui.ImageView:create(EMOJ_LIST[id]..".png",ccui.TextureResType.plistType)
	img:setAnchorPoint(cc.p(0,1))
	self.size = size
	if self.pos == 1 then
		img:setAnchorPoint(cc.p(0,1))
		img:setPosition(cc.p((self.addheight.width+5)/2,-(self.addheight.height-20)/2))	
	elseif self.pos == 4 then
		img:setAnchorPoint(cc.p(0,1))	
		img:setPosition(cc.p((self.addheight.width+15)/2,-(self.addheight.height)/2))
	elseif self.pos == 3 then
		img:setAnchorPoint(cc.p(0,1))
		img:setPosition(cc.p((self.addheight.width+20)/2,-(self.addheight.height)/2))			
	else
		img:setAnchorPoint(cc.p(1,1))
		img:setPosition(cc.p(-(self.addheight.width+20)/2,-(self.addheight.height)/2))
	end	
	return img
end
function MsgBubbleLayer:createVoiceNode()
	local size = cc.size(100,60)
	local node = cc.Node:create()
	local imgList = {}
	for i=1,3 do
		local img = ccui.ImageView:create("common/voice_"..i..".png")

		node:addChild(img)
		table.insert(imgList,img)
	end
	if self.pos == 1 then
		size = cc.size(100,70)
		node:setPosition(cc.p(size.width/2,-size.height/2+7))
	elseif self.pos == 4 then	
		node:setPosition(cc.p(size.width/2,-size.height/2+3))
	elseif self.pos == 3 then	
		node:setPosition(cc.p(size.width/2,-size.height/2+3))	
	else
		node:setPosition(cc.p(-size.width/2,-size.height/2+3))	
	end	

	local setShow = function(index) 
		for i,v in ipairs(imgList) do
			if index == i then
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
	end
	setShow(1)
	local count = 1
	local act = cc.CallFunc:create(function() 
		count = count + 1
		setShow(count)
		if count % 3 == 0 then
			count = 0
		end
	end)
	local delay = cc.DelayTime:create(0.5)
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(act,delay)))
	self.size = size
	return node
end
-- ctype 1. 文字 2.表情 3.语音
function MsgBubbleLayer:createContent()
	local node = cc.Node:create()
	local node1 = nil
	if self.data.ctype == 0 then
		node1 = self:createTextNode()
	elseif self.data.ctype == 1 then
		if self.data.BigFaceChannel == 1 then
			local audio_type = cc.UserDefault:getInstance():getIntegerForKey("audio_type",1)
    		 if (self.gameScene:getTableConf().ttype == HPGAMETYPE.FJSDR or self.gameScene:getTableConf().ttype == HPGAMETYPE.LJSDR) and audio_type == 1 then
				self.data.message = QUICK_CHAT_LIST_fjsdr[self.data.BigFaceID]
			elseif self.gameScene:getTableConf().ttype == HPGAMETYPE.SJHP or self.gameScene:getTableConf().ttype == HPGAMETYPE.WJHP then
				self.data.message = QUICK_CHAT_LIST_sjhp[self.data.BigFaceID]
			else
				self.data.message = QUICK_CHAT_LIST[self.data.BigFaceID]
			end
			node1 = self:createTextNode()
		elseif self.data.BigFaceChannel == 2 then	
			node1 = self:createEmojNode()
		end	
	elseif self.data.ctype == 2 then
		node1 = self:createVoiceNode()
	end
	if node1 then
		node:addChild(node1)
		self:addChild(node,11)
	end
end
-- pos 1 自己 2 右手 3正对面 4 左手
function MsgBubbleLayer:createBg()
	local imagePath = 'common/bubble_1.png'
	if self.pos == 1 then
		imagePath = 'common/bubble_2.png'
	end
	local bg = ccui.ImageView:create(imagePath)
			:setScale9Enabled(true)
			:setCapInsets(cc.rect(38, 50, 1,1))
			:setAnchorPoint(cc.p(0,1))
	bg:setContentSize(cc.size(self.size.width+self.addheight.width, self.size.height+self.addheight.height))	
	if self.pos == 1 then	
	elseif self.pos == 3 then
		bg:setScaleX(1)
	elseif self.pos == 2 then
		bg:setScaleX(-1)
	elseif self.pos == 4 then
	end	
	
	self:addChild(bg)
end
function MsgBubbleLayer:getAddHeight()
	local addheight 
	if self.data.ctype == 0 then
		addheight = addSize1
		if self.pos == 1 then
			addheight = addSize2
		end
	elseif self.data.ctype == 1 then
		addheight = addSize3
	elseif  self.data.ctype == 2 then
		addheight = addSize4	
	end
	return addheight
end
function MsgBubbleLayer:initView()
	self.addheight = self:getAddHeight()
	self:createContent()
	self:createBg()
end
return MsgBubbleLayer