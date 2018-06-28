
local myshowNodeView1= class("myshowNodeView1",PopboxBaseView)
function myshowNodeView1:ctor()
	self:initView()
end


function myshowNodeView1:initView()
	local widget = cc.CSLoader:createNode("myui/test/showNode.csb")
	self:addChild(widget)


end


return myshowNodeView1