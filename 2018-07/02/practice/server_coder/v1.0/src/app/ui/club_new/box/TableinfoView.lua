local TableinfoView = class("TableinfoView",PopboxBaseView)

function TableinfoView:ctor(tbid,tid,numtotall,isstart)
	self.isstart = isstart
	self.tbid = tbid
	self.tid = tid
	self.totall = numtotall
	self:initView()
	self:initEvent()
	
end
function TableinfoView:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/Tableinfobox.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)

	self.surebtn = self.mainLayer:getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.surebtn, function( )
		Notinode_instance:jointable(self.tid)
		print(self.tid)
		--LaypopManger_instance:back()
	end)
	--Socketapi.requestmsgclube(self.tid)
	self.cell = self.widget:getChildByName("cell")
	self.cell:setVisible(false)
	self.node = self.mainLayer:getChildByName("node")
	if self.isstart then
		self.surebtn:setVisible(false)
	end
	
end

function TableinfoView:msgcallback(data)
	if data.result == 0 then
		local cells = {}
		for i=1,self.totall do
			local cell = self.cell:clone()
			cell:setVisible(true)
			cell:getChildByName("name"):setVisible(false)
			cell:getChildByName("icon"):setVisible(false)
			self.node:addChild(cell)
			cell:setPositionX((i-(self.totall/2+0.5))*100)
			cells[i] = cell
		end

		if  data.users and #data.users > 0  then
			for i,v in ipairs(data.users) do
				if cells[i] then
					cells[i]:getChildByName("name"):setString(v.name)
					cells[i]:getChildByName("name"):setVisible(true)
					local icon = cells[i]:getChildByName("icon")
					icon:setVisible(true)
					icon:setScale(68/88)
					icon:setLocalZOrder(-1)
					 require("app.ui.common.HeadIcon_Club").new(icon,v.url)
				end
			end
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function TableinfoView:initEvent()
	ComNoti_instance:addEventListener("cs_response_table_detail",self,self.msgcallback)
	
end

function TableinfoView:onEndAni()
	Socketapi.requesttableinfoclue(self.tbid,self.tid)
end

return TableinfoView