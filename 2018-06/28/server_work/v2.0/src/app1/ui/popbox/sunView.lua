-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor(fuc)
	self.fuc =fuc
	self:initView()
end

function HelpView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/jisuanqi.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	self.sub = self.mainLayer:getChildByName("sub")
	self.insettable = {}
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("sure"), function( )
		local str = ""
		for i,v in ipairs(self.insettable) do
			if v == "/" then
				str=str.."."
			else
				str=str..v
			end
		end
		if tonumber(str) then
			self.fuc(tonumber(str))
			LaypopManger_instance:back()
		else

			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请输入正确的数字",sureCallFunc = function()
			end})
		end
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("delbtn"), function( )
		
		if self.insettable and #self.insettable > 0 then
			table.remove(self.insettable,#self.insettable)
		end
		self:setnum()
	end)
	for i=1,10 do 
		WidgetUtils.addClickEvent(self.mainLayer:getChildByName(i-1), function( )
			if #self.insettable> 6 then
				return
			end
			table.insert(self.insettable,i-1)
			self:setnum()
		end)
	end
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("."), function( )
			if #self.insettable> 6 then
				return
			end
			table.insert(self.insettable,"/")
			self:setnum()
		end)
end
function HelpView:setnum()
	local str = ""
	for i,v in ipairs(self.insettable) do
			str=str..v
		end
		self.sub:setString(str)
end

return HelpView