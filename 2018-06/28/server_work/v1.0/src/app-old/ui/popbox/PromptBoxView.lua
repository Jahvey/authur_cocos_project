-------------------------------------------------
--   TODO   通用提示框UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local PromptBoxView = class("PromptBoxView",PopboxBaseView)
-- opentype 1 只有确定按钮 2 确定 取消
-- param = {str = "",title = ""}
-- tipstr 提示内容
-- title 标题 默认提示
-- sureCallFunc  确定 回调
-- cancelCallFunc 取消回调
function PromptBoxView:ctor(opentype,param)
	self:initData(opentype,param)
	self:initView()
	self:initEvent()
end

function PromptBoxView:initData(opentype,param)
	if not opentype then
		opentype = 1
	end
	self.opentype = opentype
	self.param = param or {}
end

function PromptBoxView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/promptBoxView.csb")
	self:addChild(self.widget)	

	self.layer = self.widget:getChildByName("layer")
	self.mainLayer = self.widget:getChildByName("main")
	self.bg = self.mainLayer:getChildByName("bg")
	self.title = self.mainLayer:getChildByName("title"):setString("")
	self.content = self.mainLayer:getChildByName("content")

	self.sureBtn = self.mainLayer:getChildByName("sureBtn") 
	self.cancelBtn = self.mainLayer:getChildByName("cancelBtn") 


	WidgetUtils.addClickEvent(self.sureBtn, function( )
		local callfunc = self.param.sureCallFunc
		LaypopManger_instance:back()
		if callfunc and type(callfunc) == "function" then
			callfunc()
		end
	end)

	WidgetUtils.addClickEvent(self.cancelBtn, function( )
		local callfunc = self.param.cancelCallFunc
		LaypopManger_instance:back()
		if callfunc and type(callfunc) == "function" then
			callfunc()
		end
	end)

	if self.opentype == 1 then
		self.cancelBtn:setVisible(false)
		self.sureBtn:setPositionX(0)
	elseif self.opentype == 2 then
		-- self.sureBtn:setPositionX(-self.cancelBtn:getPositionX())
	end

	local contentStr = self.param.tipstr or ""
	self.content:setString(contentStr)

	-- 当contentStr 长度超过1行 锚点设置为cc.p(0,1)，从左开始 没超过居中
	local strWidth = self.content:getContentSize().width
	local rowWidth = self.bg:getContentSize().width-100
	if strWidth > rowWidth then
		self.content:setAnchorPoint(cc.p(0,1))
		self.content:setPosition(cc.p(-rowWidth/2,60))
		self.content:ignoreContentAdaptWithSize(true)
		self.content:setTextAreaSize(cc.size(rowWidth,0))
		self.content:setString(contentStr)
		self.content:ignoreContentAdaptWithSize(false)
	else
		self.content:setPosition(cc.p(0,19))
	end

	local title  = self.param.title or "温馨提示"
	self.title:setString(title)

end

function PromptBoxView:initEvent()
end
function PromptBoxView:setViewScale(scale)
	self.layer:setScale(1/scale)
	self.widget:setScale(scale)
	self.layer:setPosition(cc.p(-display.cx*(1/scale),-display.cy*(1/scale)))
end

function PromptBoxView:setSureToShare( )
	self.sureBtn:getChildByName("Sprite_2"):setTexture("ui/popbox/text_share.png")
end

return PromptBoxView