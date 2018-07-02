
local effectinfo = {19,28,21,29}
Hudongeffect = {}
function Hudongeffect.playeffect( pos1,pos2,id )
	local sprite = cc.Sprite:create("biaoqing/item"..id.."/e1.png")
	sprite:setPosition(pos1)
	sprite:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,pos2),cc.CallFunc:create(function( ... )
		if id == 2 then
			sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function( ... )
				audio.playSound("biaoqing/item"..id.."/sound.mp3", false)
			end)))
		elseif id == 3 then
			sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
				audio.playSound("biaoqing/item"..id.."/sound.mp3", false)
			end)))
		elseif id == 4 then
			sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
				audio.playSound("biaoqing/item"..id.."/sound.mp3", false)
			end)))
		elseif id == 1 then
			--todo
			audio.playSound("biaoqing/item"..id.."/sound.mp3", false)
		end
		Hudongeffect.runAn( id,sprite)
	end)))
	return sprite
end

function Hudongeffect.runAn( id,sprite)
    local time =  0
    --如果动画小于1秒播两次
    local isfirist = true
    local function updata(deltime)
        time = time + deltime
       	local index =  math.floor(time/0.1) + 1
       	if index >effectinfo[id] then
       		sprite:removeFromParent()
       	else
       		sprite:setTexture("biaoqing/item"..id.."/e"..index..".png")
       	end
    end
    sprite:scheduleUpdateWithPriorityLua(updata,0)
end