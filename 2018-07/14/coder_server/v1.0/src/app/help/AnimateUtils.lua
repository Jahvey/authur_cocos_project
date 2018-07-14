AnimateUtils = {}

function AnimateUtils.getactiontime(pos1,pos2)
	local length = cc.pGetLength(cc.p(pos1.x - pos2.x,pos1.y - pos2.y))
 	return length/1500
end
function AnimateUtils.playBynum(num,pos1,pos2,addnode)
	-- body
	if num == 1 then
		AnimateUtils.pengbei( pos1,pos2,addnode)
		
	elseif num == 2 then
		AnimateUtils.zhadan( pos1,pos2,addnode)
		
	elseif num == 3 then
		
		AnimateUtils.zhuaji( pos1,pos2,addnode)
	elseif num == 4 then
		
		AnimateUtils.fanggou( pos1,pos2,addnode)
	elseif num == 5 then

		AnimateUtils.daoshui( pos1,pos2,addnode)
	elseif num == 6 then
		AnimateUtils.tuoxie( pos1,pos2,addnode)
	end
end
function AnimateUtils.zhuaji( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/zhuaji/zhuaji.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/zhuaji/zhuaji.csb")
	local nodeshou = node:getChildByName("shou")
	local zhuaji = node:getChildByName("zhuaji")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x+50,pos2.y))
	else
		nodeshou:setPosition(cc.p(pos2.x-50,pos2.y))
	end
	action:gotoFrameAndPlay(0,19,true)
	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(AnimateUtils.getactiontime(pos1,pos2),pos1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		local action = cc.CSLoader:createTimeline("ui/playerinfo/zhuaji/zhuaji.csb")
		AudioUtils.playEffect("zhuoji")
		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(20,85,false)
	end)))
end


function AnimateUtils.daoshui( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/daoshui/daoshui.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/daoshui/daoshui.csb")
	local nodeshou = node:getChildByName("st")
	local zhuaji = node:getChildByName("poshui")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x+110,pos2.y-60))
	else
		nodeshou:setPosition(cc.p(pos2.x-110,pos2.y-60))
	end
	action:gotoFrameAndPlay(0,19,true)
	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(AnimateUtils.getactiontime(pos1,pos2),pos1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		AudioUtils.playEffect("sashui")
		local action = cc.CSLoader:createTimeline("ui/playerinfo/daoshui/daoshui.csb")

		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(20,85,false)
	end)))
end



-- function AnimateUtils.liulian( pos1,pos2,addnode)

-- 	local node =  cc.CSLoader:createNode("ui/playerinfo/liulian/liulian.csb")
-- 	local action = cc.CSLoader:createTimeline("ui/playerinfo/liulian/liulian.csb")
-- 	local nodeshou = node:getChildByName("boluo")
-- 	local zhuaji = node:getChildByName("bao")
-- 	if pos1.x - pos2.x > 0 then
-- 		nodeshou:setScaleX(-1)
-- 		zhuaji:setScaleX(-1)
-- 	end
-- 	zhuaji:setPosition(pos1)
-- 	node:runAction(action)
-- 	addnode:addChild(node)
-- 	action:gotoFrameAndPlay(0,19,true)
-- 	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,pos1),cc.CallFunc:create(function( ... )
-- 		node:stopAllActions()
-- 		local action = cc.CSLoader:createTimeline("ui/playerinfo/liulian/liulian.csb")

-- 		local function onFrameEvent(frame)
-- 	    	print("action111")
-- 	        if nil == frame then
-- 	            return
-- 	        end
-- 	        local str = frame:getEvent()
-- 	        if str == "end" then
-- 	        		node:removeFromParent()
-- 	        end
-- 	    end
-- 	    action:setFrameEventCallFunc(onFrameEvent)

-- 		node:runAction(action)
-- 		action:gotoFrameAndPlay(20,85,false)
-- 	end)))
-- end



function AnimateUtils.pengbei( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/pengbei/pengbei.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/pengbei/pengbei.csb")
	local nodeshou = node:getChildByName("beizi_y")
	local zhuaji = node:getChildByName("beizi_z")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x+97.52,pos2.y+61))
	else
		nodeshou:setPosition(cc.p(pos2.x-97.52,pos2.y+61))
	end
	action:gotoFrameAndPlay(0,19,true)
	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(AnimateUtils.getactiontime(pos1,pos2),pos1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		nodeshou:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
			AudioUtils.playEffect("jiubei")
		end)))
		local action = cc.CSLoader:createTimeline("ui/playerinfo/pengbei/pengbei.csb")

		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(20,85,false)
	end)))
end


function AnimateUtils.fanggou( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/fanggou/fanggou.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/fanggou/fanggou.csb")
	local nodeshou = node:getChildByName("gou_all")
	local zhuaji = node:getChildByName("yan_big")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x,pos2.y+-17.80))
	else
		nodeshou:setPosition(cc.p(pos2.x,pos2.y+-17.80))
	end
	action:gotoFrameAndPlay(20,39,true)
	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(AnimateUtils.getactiontime(pos1,pos2),pos1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		nodeshou:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
			 AudioUtils.playEffect("gou")
		end)))
		local action = cc.CSLoader:createTimeline("ui/playerinfo/fanggou/fanggou.csb")

		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(39,85,false)
	end)))
end



function AnimateUtils.tuoxie( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/tuoxie/tuoxie.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/tuoxie/tuoxie.csb")
	local nodeshou = node:getChildByName("tuoxie")
	local zhuaji = node:getChildByName("yan")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x+50,pos2.y))
	else
		nodeshou:setPosition(cc.p(pos2.x-50,pos2.y))
	end
	action:gotoFrameAndPlay(0,19,true)
	local timevoice = AnimateUtils.getactiontime(pos1,pos2) - 0.3
		if timevoice < 0 then
			timevoice = 0
		end
	nodeshou:runAction(cc.Sequence:create(cc.DelayTime:create(timevoice),cc.CallFunc:create(function( ... )
			 AudioUtils.playEffect("tuoxie")
		end)))

	nodeshou:runAction(cc.Sequence:create(cc.MoveTo:create(AnimateUtils.getactiontime(pos1,pos2),pos1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		-- nodeshou:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
		-- 	 AudioUtils.playEffect("tuoxie")
		-- end)))
		 --AudioUtils.playEffect("tuoxie")
		local action = cc.CSLoader:createTimeline("ui/playerinfo/tuoxie/tuoxie.csb")

		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(20,85,false)
	end)))
end




function AnimateUtils.zhadan( pos1,pos2,addnode)

	local node =  cc.CSLoader:createNode("ui/playerinfo/zhadan/zhadan.csb")
	local action = cc.CSLoader:createTimeline("ui/playerinfo/zhadan/zhadan.csb")
	local nodeshou = node:getChildByName("zhadan_y")
	local zhuaji = node:getChildByName("baozha")
	if pos1.x - pos2.x > 0 then
		nodeshou:setScaleX(-1)
		zhuaji:setScaleX(-1)
	end
	zhuaji:setPosition(pos1)
	node:runAction(action)
	addnode:addChild(node)
	if pos1.x - pos2.x > 0 then 
		nodeshou:setPosition(cc.p(pos2.x+128.00,pos2.y+23))
	else
		nodeshou:setPosition(cc.p(pos2.x-128.00,pos2.y+23))
	end
	AudioUtils.playEffect("zhadanreng",false)
	action:gotoFrameAndPlay(0,19,true)
	nodeshou:runAction(cc.Sequence:create(cc.JumpTo:create(0.3,pos1,250,1),cc.CallFunc:create(function( ... )
		node:stopAllActions()
		
		nodeshou:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(function( ... )
			AudioUtils.playEffect("zhadanzha")
		end)))
		local action = cc.CSLoader:createTimeline("ui/playerinfo/zhadan/zhadan.csb")

		local function onFrameEvent(frame)
	    	print("action111")
	        if nil == frame then
	            return
	        end
	        local str = frame:getEvent()
	        if str == "end" then
	        		node:removeFromParent()
	        end
	    end
	    action:setFrameEventCallFunc(onFrameEvent)

		node:runAction(action)
		action:gotoFrameAndPlay(20,112,false)
	end)))
end







