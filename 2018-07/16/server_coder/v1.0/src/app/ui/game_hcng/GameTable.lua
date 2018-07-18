local GameTable = class("GameTable", require("app.ui.game_base_cdd.GameTable"))
function GameTable:updateDiZhuCards(isShow,pokers)
    self.diPaiView:setVisible(false)
end

function GameTable:showshuangniu()

	local node =  cc.CSLoader:createNode("animation/xiaotubiao/shuangniu.csb")
	local action = cc.CSLoader:createTimeline("animation/xiaotubiao/shuangniu.csb")
	self.gamescene:addChild(node)

	local pos = self.gamescene:convertToNodeSpace(cc.p(display.cx,display.cy))
	node:setPosition(pos)


	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
        	local pos = cc.p(self.icon:getPositionX(),self.icon:getPositionY())
        	local movepos = self.icon:getParent():convertToWorldSpace(pos)
        	node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,movepos),cc.CallFunc:create(function( ... )
        		local action1 = cc.CSLoader:createTimeline("animation/xiaotubiao/shuangniu.csb")
        		local function onFrameEvent1( ... )
        			if nil == frame then
			            return
			        end
			        local str = frame:getEvent()
			        if str == "end1" then
			        	node:removeFromParent()
			    	end
        		end
        		action1:setFrameEventCallFunc(onFrameEvent1)
        		node:runAction(action1)
				action1:gotoFrameAndPlay(50,false)
				
        	end)))
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

	node:runAction(action)
	action:gotoFrameAndPlay(0,50,false)
    AudioUtils.playVoice("ddz_shuangniu",self.gamescene:getSexByIndex(self:getTableIndex()))

end

function GameTable:showrank(numrank)

    
	self.baojin:removeAllChildren()
	local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
	info.bao_type = 0
	local num = numrank - 115
    AudioUtils.playVoice("ddz_rank"..num,self.gamescene:getSexByIndex(self:getTableIndex()))
	local node =  cc.CSLoader:createNode("animation/xiaotubiao/123you.csb")
	local action = cc.CSLoader:createTimeline("animation/xiaotubiao/123you.csb")
	self.effectnode:addChild(node)
	node:getChildByName("Node_1"):getChildByName("Sprite_2"):setTexture("cocostudio/animation/xiaotubiao/"..num.."you.png")
	local pos = self.effectnode:convertToNodeSpace(cc.p(display.cx,display.cy))
	node:setPosition(pos)


	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
        	local pos = cc.p(self.icon:getChildByName("rank"):getChildByName("icon"):getPositionX(),self.icon:getChildByName("rank"):getChildByName("icon"):getPositionY())
        	local movepos = self.icon:getChildByName("rank"):convertToWorldSpace(pos)
        	movepos = self.effectnode:convertToNodeSpace(movepos)
        	node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,movepos),cc.CallFunc:create(function( ... )
        		local action1 = cc.CSLoader:createTimeline("animation/xiaotubiao/123you.csb")
        		local function onFrameEvent1( ... )
        			if nil == frame then
			            return
			        end
			        local str = frame:getEvent()
			        if str == "end1" then
			        	node:removeFromParent()
			        	self:setrank(numrank)
			    	end
        		end
        		action1:setFrameEventCallFunc(onFrameEvent1)
        		node:runAction(action1)
				action1:gotoFrameAndPlay(35,false)
				
        	end)))
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

	node:runAction(action)
	action:gotoFrameAndPlay(0,35,false)

end
return GameTable