
local Card = require "app.ui.game.Card"
local Gameview = class("Gameview",function()
    return cc.Node:create()
end)

function Gameview:ctor(scene,gamemodel,isre)
	self.isre = isre
	self.scene = scene
	self.gameModel = gamemodel
	self:initView()
	self.nownode = cc.Node:create()
	self.nownode:setPosition(cc.p(display.cx,display.cy+200))
	self:addChild(self.nownode)
	self.lastdata = nil
end
function Gameview:initView()
	-- body

    self.tableview = {}
    for i,v in ipairs(self.gameModel.roomPlayerItemJsons) do
    	local localindex  = self.scene:getLocalindex(v.index)
        self.tableview[localindex] = require "app.ui.record.recordbase".new(localindex,v.curCards,self.scene)
        self:addChild(self.tableview[localindex])
    	--self.table[localindex]:createHandcard(v.curCards)
    end
   	
end

function Gameview:chupai(data,isnotta)
    if self.scene.lastaction and self.scene.lastaction.index == data.index then
        for i,v in ipairs(self.tableview) do
            v.outnode:removeAllChildren()
        end
        print("--------------清理--------")
    end
    local localindex  = self.scene:getLocalindex(data.index)
    self.tableview[localindex]:chupai(data,isnotta)

end

function Gameview:guo(data,isnotta)
    local localindex  = self.scene:getLocalindex(data.index)
    self.tableview[localindex]:guo(data)
    if isnotta then
    else
        AudioUtils.playVoice("buyao"..math.random(1,4)..".wav",self.scene:getSex(data.index))
    end

end


return Gameview