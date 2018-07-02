
-------------------------------------------------
--   TODO   NODE帮助函数
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

WidgetUtils = {}
local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
local xscale =  size.width/1334
local yscale = size.height/750
local offxscale = 1
local offyscale = 1
if xscale > yscale then
	offxscale = 1* xscale/yscale
else
	offyscale  = 1*yscale/xscale
end
WidgetUtils.offxscale = offxscale

WidgetUtils.offyscale = offyscale

--界面适配
function WidgetUtils.setScalepos(node)
	
	local children = node:getChildren()
	if children then
		for i,v in ipairs(children) do
			local x = v:getPositionX()
			local y = v:getPositionY()
			v:setPositionX(x*WidgetUtils.offxscale)
			v:setPositionY(y*WidgetUtils.offyscale)
		end
	end
	--node:setPosition(display.cx,display.cy)
end
function WidgetUtils.setBgScale(bg)
	if offxscale >offyscale then
		bg:setScale(offxscale)
	else
		bg:setScale(offyscale)
	end
	bg:setPosition(display.cx,display.cy)
end
--获取csload 倒入的cocos stuido子节点，如果节点太多的话可能会导致搜索时间太慢 提供两种方法

--方法一 直接搜索

function WidgetUtils.getNodeByName(node,name)
	if node == nil or not tolua.cast(node,"cc.Node") then
		return nil
	end
	if node:getChildByName(name) then
		return node:getChildByName(name)
	end
	local childrennode = node:getChildren()
	for i,v in ipairs(childrennode) do
		if v and tolua.cast(v,"cc.Node") then
			local findnode = WidgetUtils.getNodeByName(v,name)
			if findnode ~= nil then
				return findnode
			end
		end
	end
	return nil 
end
--方法二直接给出搜索路径
function WidgetUtils.getNodeByWay(node,tableway)
	-- body
	local  nodeget =  node 
	for i,v in ipairs(tableway) do
		nodeget = nodeget:getChildByName(v)
	end
	if nodeget == nil or nodeget == node then
		print("get node fail")
		print(tableway)
	end
	return nodeget
end
---按钮点击事件注册
function WidgetUtils.addClickEvent(btn, func,notplayeffect)
    
    --btn:setPressedActionEnabled(true)
    --是否可以执行
    local onbtn = function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理
        end
    
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            if notplayeffect == nil then
                AudioUtils.playEffect("audio_button_click",false)
            end
            if func then
           		func()
            end
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理
           
        end
        
        if eventType == ccui.TouchEventType.moved then    --按钮 触摸移动事件处理
          
        end
    end
    
    btn:addTouchEventListener(onbtn)
end

function WidgetUtils.createnullBtn(size)
	local btn = ccui.Button:create("common/null1.png", "common/null1.png", "common/null1.png", ccui.TextureResType.localType)
    btn:setScale9Enabled(true)
    btn:setContentSize(size)
    return btn
end

-- 创建loding 
function WidgetUtils.createLoading(node,type)
	if not node then
		return
	end
	local LoadingView = require "app.ui.popbox.LoadingView".new(type)
	LoadingView:setPosition(cc.p(display.width/2,display.height/2))
	node:addChild(LoadingView,9999)
end

---------------------------------------------------------------------------------------------
-- 创建单选框
-- @checkBoxs checkBox
-- @defaultsSelected 默认选择
-- @selectedCallback 选中的回调
-- @uncheckedCallback 未选中的回调
-- @selectColor 选中字体颜色
-- @unselectColor 未选中字体颜色
-- function callback(sender, isSelected) --checkBox 是否选中
-- end
-- 默认都是未选中的
---------------------------------------------------------------------------------------------
function WidgetUtils.createSingleBox(checkBoxs, defaultsSelected, callback,selectColor,unselectColor)  
    local checkBoxs = checkBoxs
    local localSelected
    local defaultsSelected = defaultsSelected or error("WidgetUtils:createSingleBox defaultsSelected is nil")
    local callback = callback or function ()
    end
    local function selectedEvent(sender,eventType)
        local index = sender:getTag()
        local checkBox = checkBoxs[index]
        checkBox:setSelected(true)
        -- checkBox:setTouchEnabled(false)
        if checkBox.label and selectColor then
            checkBox.label:setTextColor(cc.c3b(0xff,0xff,0xff))
            checkBox.label:setTextColor(selectColor) 
        end
        if localSelected == index then
            return -- 重复选择
        end
        callback(checkBox, true)
        -- print("index = ", index, "localSelected = ", localSelected)
        if localSelected then
            checkBox = checkBoxs[localSelected]
            checkBox:setSelected(false)
            -- checkBox:setTouchEnabled(true)
            if checkBox.label and unselectColor then
                checkBox.label:setTextColor(cc.c3b(0xff,0xff,0xff))
                checkBox.label:setTextColor(unselectColor) 
            end
            callback(checkBox, false)
        end
        localSelected = index
    end
    for i,checkBox in ipairs(checkBoxs) do
        checkBox:addEventListener(selectedEvent)
        checkBox:setTag(i)
        checkBox:setSelected(false)
        checkBox:setTouchEnabled(true)
        -- 用于直接选中某一个
        checkBox.selectedEvent = selectedEvent
    end
    selectedEvent(checkBoxs[defaultsSelected])
end

function WidgetUtils.addLayerAnimation(layer,callback)
    local oldscale = layer:getScale()
    layer:setScale(oldscale*0.5)
    local function endaction()
        print("endaction")
        if callback then
            print("call")
            callback()
        end
    end
    local action = cc.EaseBackOut:create(cc.ScaleTo:create(0.5,oldscale))
    layer:runAction(cc.Sequence:create(action,cc.CallFunc:create(endaction)))
    --layer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,oldscale+0.1),cc.ScaleTo:create(0.05,oldscale),cc.CallFunc:create(endaction)))
    --layer:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.ScaleTo:create(0.1,oldscale+0.1)),cc.ScaleTo:create(0.05,oldscale),cc.CallFunc:create(endaction)))
    --layer:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.ScaleTo:create(0.15,oldscale)),cc.CallFunc:create(endaction)))
end

--判断一个NODE是否存在
function WidgetUtils:nodeIsExist(node)
    if tolua.cast(node,"cc.Node") and tolua.cast(node,"cc.Node"):isRunning() then
        return true
    else
        return false
    end
end

--表情动画
local table = {
    
}

function WidgetUtils:shunzieffect()
     cc.SpriteFrameCache:getInstance():addSpriteFrames("effect/shunzi.plist", "effect/shunzi.png")
     local sprite = cc.Sprite:createWithSpriteFrameName("shunzi1.png")
     local time = 0
     local function updata(deltime)
          time = deltime+time
        local index  =math.floor(time/0.05)+1
        if index > 27 then
            sprite:unscheduleUpdate()
            sprite:removeFromParent()
            return
        end
        sprite:setSpriteFrame("shunzi"..index..".png")
    end
    sprite:scheduleUpdateWithPriorityLua(updata,0.1)
    return sprite
end



function WidgetUtils:zhandaneffect()
     cc.SpriteFrameCache:getInstance():addSpriteFrames("effect/zhadan.plist", "effect/zhadan.png")
     local sprite = cc.Sprite:createWithSpriteFrameName("zhadan1.png")
     local time = 0
     local function updata(deltime)
          time = deltime+time
        local index  =math.floor(time/0.05)+1
        if index > 16 then
            sprite:unscheduleUpdate()
            sprite:removeFromParent()
            return
        end
        sprite:setSpriteFrame("zhadan"..index..".png")
    end
    sprite:scheduleUpdateWithPriorityLua(updata,0.1)
    return sprite
end



function WidgetUtils:lianduieffect()
     cc.SpriteFrameCache:getInstance():addSpriteFrames("effect/liandui.plist", "effect/liandui.png")
     local sprite = cc.Sprite:createWithSpriteFrameName("liandui1.png")
     local time = 0
     local function updata(deltime)

          time = deltime+time
        local index  =math.floor(time/0.05)+1
        if index > 18 then
            sprite:unscheduleUpdate()
            sprite:removeFromParent()
            return
        end

        sprite:setSpriteFrame("liandui"..index..".png")
    end
    sprite:scheduleUpdateWithPriorityLua(updata,0.1)
    return sprite
end


function WidgetUtils:feijieffect()
     cc.SpriteFrameCache:getInstance():addSpriteFrames("effect/feiji.plist", "effect/feiji.png")
     local sprite = cc.Sprite:createWithSpriteFrameName("feiji1.png")
     local time = 0
     local function updata(deltime)
        time = deltime+time
        local index  =math.floor(time/0.05)+1
        if index > 22 then
            sprite:unscheduleUpdate()
            sprite:removeFromParent()
            return
        end
        
        sprite:setSpriteFrame("feiji"..index..".png")
        
    end
    sprite:scheduleUpdateWithPriorityLua(updata,2)
    return sprite
end



function WidgetUtils:getFaceeffect(idx)

    -- body
    -- display.addSpriteFrames("game/chat/"..idx.."/"..idx..".plist", "game/chat/"..idx.."/"..idx..".png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/chat/"..idx.."/"..idx..".plist", "game/chat/"..idx.."/"..idx..".png")
    local timetale = {}
    timetale[1] = {0.5,0.3,0.2,0.1,0.2}
    timetale[2] = {0.2,0.1,0.3,0.2,0.2,0.2,0.2}
    timetale[3] = {0.2,0.2,0.2,0.2,0.5}
    timetale[4] = {0.2,0.2,0.2,0.2}
    timetale[5] = {0.2,0.2,0.2,0.2,0.2}
    timetale[6] = {0.2,0.2,0.1,0.1,0.1,0.1,0.5}
    timetale[7] = {0.2,0.2,0.2,0.2}
    timetale[8] = {0.2,0.2,0.2,0.2,0.2,0.2}
    timetale[9] = {0.1,0.1,0.1,0.1,0.1,0.1,0.5}
    timetale[10] = {0.1,0.2,0.5}
    timetale[11] = {0.1,0.05,0.1,0.5,0.2,0.5}
    timetale[12] = {0.2,0.2,0.2,0.2,0.5}
    timetale[13] ={0.2,0.2,0.2,0.2,0.2}
    timetale[14] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[15] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[16] ={0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[17] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[18] ={0.2,0.2,0.2,0.2}
    timetale[19] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[20] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[21] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[22] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[23] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[24] ={0.6,0.1}
    timetale[25] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[26] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[27] ={0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[28] ={0.2,0.2,0.2}
    timetale[29] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    timetale[30] ={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1}
    local sprite = cc.Sprite:createWithSpriteFrameName("faceeffect"..idx.."_1.png")
    local time =  0
    --如果动画小于1秒播两次
    local isfirist = true
    local function updata(deltime)
        time = time + deltime
        local localtime = 0
        for i,v in ipairs(timetale[idx]) do
            print("time:"..time.."localtime:"..localtime)
            if time >= localtime and time < (localtime +v)then
                print("faceeffect"..idx.."_"..i..".png")
                sprite:setSpriteFrame("faceeffect"..idx.."_"..i..".png")
                break
            end
            localtime = localtime + v
            if i == #timetale[idx]  then
                if isfirist == true and localtime < 1.2 then
                    isfirist = false
                    time = 0
                else
                    sprite:unscheduleUpdate()
                    sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeOut:create(0.2),cc.CallFunc:create(function( ... )
                        sprite:removeFromParent()
                    end)))
                end
            end
        end
    end
    sprite:scheduleUpdateWithPriorityLua(updata,0)
    return sprite
end



function WidgetUtils:daqiang(times,diredaqiang,fuc,fuc1)
    local node  = cc.CSLoader:createNode("ui/qiang/node.csb")
    local action = cc.CSLoader:createTimeline("ui/qiang/node.csb")
    local index = 0
    local midindex = 0
    if  diredaqiang and diredaqiang[1] then
        node:setScaleX(diredaqiang[1])
    end
    local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        print("event :"..str)
        if str == "end" then
            index = index+ 1 
             if  diredaqiang and diredaqiang[index+1] then
                node:setScaleX(diredaqiang[index+1])
            end
            if index == times then
                node:removeFromParent()
            end
        elseif str == "mid" then
            midindex = midindex + 1
            fuc(midindex)
        elseif str == "begin"then
            print("begin event")
            fuc1()
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)
    node:runAction(action)
    action:gotoFrameAndPlay(0,true)
    return node


end


function WidgetUtils.quanleida()
    local spr = cc.Sprite:create("effect/quanleida/1.png")
    spr:setPosition(cc.p(display.cx,display.cy))
    local index = 1
    spr:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( ... )
        index = index + 1
        spr:setTexture("effect/quanleida/"..index..".png")
        if index == 6 then
              spr:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( ... )
                  spr:removeFromParent()
              end)))
        end
    end)), 5))
    cc.Director:getInstance():getRunningScene():addChild(spr)
end