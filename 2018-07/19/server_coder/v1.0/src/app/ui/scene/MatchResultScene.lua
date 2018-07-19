local MatchResultScene = class("MatchResultScene",function()
	return cc.Scene:create()
end)
function MatchResultScene:ctor(data)
	self.owner = owner
	self:initData(data)
	self:initView()
	self:initEvent()
end
function MatchResultScene:initData(data)
	self.data = data
end
function MatchResultScene:initView()
	self.widget = cc.CSLoader:createNode("ui/match/result/matchresult.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.returnbtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.returnbtn, function( )
		glApp:enterSceneByName("MainScene")
	end)
	self.sharebtn = self.mainLayer:getChildByName("sharebtn")
	WidgetUtils.addClickEvent(self.sharebtn, function( )
		self:shareBtnCall()
	end)

	local bg = self.widget:getChildByName("bg")
		:setScale9Enabled(true)
		:setCapInsets(cc.rect(0,0,1280,720))
		:setContentSize(cc.size(display.width,display.height))

	WidgetUtils.setScalepos(self.mainLayer)
	-- bg:setPosition(cc.p(display.cx,display.cy))

	local name = self.mainLayer:getChildByName("name")
		:setString(LocalData_instance:getNick())

	local img1 = self.mainLayer:getChildByName("img1")
	local img2 = self.mainLayer:getChildByName("img2")
	local rank = self.mainLayer:getChildByName("rank")

	if self.data.ord then
		rank:setString(self.data.ord)
	else
		if self.data.result_list then
			-- table.sort(self.data.result_list, function (a,b)
			-- 	return a.total_score > b.total_score
			-- end)
			for i,v in ipairs(self.data.result_list) do
				if v.uid == LocalData_instance.uid then
					rank:setString(v.rank)
					break
				end
			end
		end
	end
	
	img1:setPositionX(rank:getPositionX()-rank:getContentSize().width/2-5)
	img2:setPositionX(rank:getPositionX()+rank:getContentSize().width/2+5)
end

function MatchResultScene:shareBtnCall()
	print("分享")
	CommonUtils.shareScreen()
end
function MatchResultScene:initEvent()

end
return MatchResultScene