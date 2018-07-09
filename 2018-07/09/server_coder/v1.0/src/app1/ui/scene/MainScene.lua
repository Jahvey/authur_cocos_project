
local MainScene = class("MainScene",function()
    return cc.Scene:create()
end)


function MainScene:ctor(data)
    print("MainScene")
    AudioUtils.playMusic()
 
    self.table_id = nil
    self:initview()
end

function MainScene:initview()
	local HallView  = require "app.ui.hall.HallView"
	local HallView = HallView.new(self)
	self.HallView = HallView
	self:addChild(HallView)

	if ISFIRSTJION == nil then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function( ... )
			ISFIRSTJION = true
			LaypopManger_instance:PopBox("NoticeActView",msg)
		end)))
	end
end

function MainScene:updataview()
	self.HallView:updataview()
end
function MainScene:havecreateTable(tid)
	print("已经创建了房间:".. tid)
	self.table_id = tid
	-- 刷新大厅界面
	self.HallView:initMidNode()
end
return MainScene