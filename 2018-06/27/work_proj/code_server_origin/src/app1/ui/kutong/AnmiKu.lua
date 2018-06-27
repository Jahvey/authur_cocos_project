AnmiKu = {}


function AnmiKu.sazi(num1,num2,fuc)

	cc.SpriteFrameCache:getInstance():addSpriteFrames("effect/dice.plist", "effect/dice.png")
	local node =cc.Node:create()
	local spr1 = cc.Sprite:createWithSpriteFrameName("dice"..num1.."_000.png")
	node:addChild(spr1)
	spr1:setScale(2)
	local time1 = 0
	local function updata(deltime)
          time1 = deltime+time1
        local index  =math.floor(time1/0.05)
        if index > 13 then
            spr1:unscheduleUpdate()
            --spr1:removeFromParent()
            return
        end
        if index >= 7 then
        	index = index + 1
        end
        if index < 10 then
        	spr1:setSpriteFrame("dice"..num1.."_00"..index..".png")
        else
        	spr1:setSpriteFrame("dice"..num1.."_0"..index..".png")
        end
    end
    spr1:scheduleUpdateWithPriorityLua(updata,0.05)


	local spr2 = cc.Sprite:createWithSpriteFrameName("dice"..num2.."_000.png")
	spr2:setFlippedX(true)
	spr2:setScale(2)
	node:addChild(spr2)

	local time2 = 0
	local function updata(deltime)
          time2 = deltime+time1
        local index  =math.floor(time2/0.05)
        if index > 13 then
            spr2:unscheduleUpdate()
            --spr2:removeFromParent()
            node:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function( ... )
            	fuc()
            	node:removeFromParent()

            end)))
            return
        end
        if index >= 7 then
        	index = index + 1
        end
        if index < 10 then
        	spr2:setSpriteFrame("dice"..num2.."_00"..index..".png")
        else
        	spr2:setSpriteFrame("dice"..num2.."_0"..index..".png")
        end
    end
    spr2:scheduleUpdateWithPriorityLua(updata,0.05)



	return node
end
return AnmiKu