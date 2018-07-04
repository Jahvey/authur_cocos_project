
local myshowView1 = class("myshowView1",PopboxBaseView)
function myshowView1:ctor()
	self:initView()
end


function myshowView1:initView()
	local widget = cc.CSLoader:createNode("myui/test/show.csb")
	self:addChild(widget)


end


return myshowView1