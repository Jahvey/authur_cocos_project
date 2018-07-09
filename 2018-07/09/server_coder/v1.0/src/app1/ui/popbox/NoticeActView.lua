local NoticeActView = class("NoticeActView",PopboxBaseView)

function NoticeActView:ctor()
	self:initView()
	self:initEvent()
end

function NoticeActView:initView()
	self.isget1 = false
	self.isget2 = false
	self.list1 = {}
	self.list2 = {}
	print("-------123--------")
	self.widget = cc.CSLoader:createNode("ui/notice/noticeActView.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")

	local closebtn = self.mainLayer:getChildByName("closeBtn")

	WidgetUtils.addClickEvent(closebtn,function ()
		LaypopManger_instance:back()
		
	end)
	self.item1 = self.mainLayer:getChildByName("item")
	local function touch(num)
		if num ==1 then
			if self.isget1 == false then
				self.isget1 = true
				Socketapi.sendhuodong()
			else
				self:updataview(1)
			end
		else

			if self.isget2 == false then
				self.isget2 = true
				Socketapi.sendggao()
			else
				self:updataview(2)
			end
		end
	end
	self.scrollView = self.mainLayer:getChildByName("scrollview")
	self.imagenode = self.mainLayer:getChildByName("scrollview"):getChildByName("actimg")
	self.listview = self.mainLayer:getChildByName("listview")
	self.listview:setItemModel(self.item1)
	self.item1:setVisible(false)
	touch(1)
end
function NoticeActView:updataview(type)
	-- body
	local listdata = {}
	if type == 1 then
		listdata = self.list1 or {}
	else
		listdata = self.list2 or {}
	end
	self.listview:removeAllItems()
	local btnlists = {}
	local function touch( num)
		for i,v in ipairs(btnlists) do
			if i == num then
				v:setEnabled(false)
				v:getChildByName("1"):setVisible(true)
    			v:getChildByName("2"):setVisible(false)
			else
				v:getChildByName("1"):setVisible(false)
    			v:getChildByName("2"):setVisible(true)
				v:setEnabled(true)
			end
		end

		self.imagenode.downcallback = function(image)
            local size =  self.imagenode:getVirtualRendererSize()
            self.imagenode:ignoreContentAdaptWithSize(true)
            print("111:"..size.height)
            print("111:"..size.width)
            self.imagenode:setScaleX(740.00/size.width)
            self.imagenode:setScaleY(740.00/size.width)
            self.imagenode:setPosition(cc.p(0,0))
            local height = 740.00/size.width*size.height
            if height < 500 then
            	height  = 500
            end
            self.scrollView:setInnerContainerSize(cc.size(740.00,height))
            self.imagenode:setVisible(true)
        end
        self.imagenode:setVisible(false)
        if listdata[num] ~= nil then
    		NetPicUtils.getPic(self.imagenode, listdata[num].imgurl )
    	end

	end
	for i,v in ipairs(listdata) do
		self.listview:pushBackDefaultItem()
    	local item = self.listview:getItem(i-1)
    	item:setVisible(true)
    	item:getChildByName("1"):setString(v.title)
    	item:getChildByName("2"):setString(v.title)
    	table.insert(btnlists,item)
    	WidgetUtils.addClickEvent(item,function ()
			touch(i)
			
		end)

	end
	touch(1)
end
function NoticeActView:huodong( data )
	-- body
	print("huodong")
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return 
	else
		self.list1 = data.gamespreadlist
		--self.list1[2] =self.list1[1] 
		self:updataview(1)
	end
end

function NoticeActView:ggao( data )
	print("ggao")
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return 
	else
		self.list2 = data.gamespreadlist
		--self.list2[2] =self.list2[1]
		self:updataview(2)
	end
end


function NoticeActView:initEvent()

	ComNoti_instance:addEventListener("3;1;6",self,self.huodong)
end

return NoticeActView