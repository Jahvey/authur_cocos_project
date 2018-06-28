
-------------------------------------------------
--   TODO   NODE帮助函数
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

WidgetUtils = {}
local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
local xscale =  size.width/1280
local yscale = size.height/720
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
		-- printTable(tableway)
	end
	return nodeget
end
---按钮点击事件注册
function WidgetUtils.addClickEvent(btn, func,notplayeffect,quicktouch)
    
    -- btn:setPressedActionEnabled(true)
    local iscantouch = true
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
-- 添加按下监听
---------------------------------------------------------------------------------------------
function WidgetUtils:addPressListener(widget, callback, ...)
    if type(callback) == "function" then
        widget:setTouchEnabled(true)
    else
        widget:setTouchEnabled(false)
    end
    widget:addTouchEventListener(function (widget, event)
        if event == ccui.TouchEventType.began then
        elseif event == ccui.TouchEventType.moved then
        elseif event == ccui.TouchEventType.ended then
            if callback then
                callback()
            end
        elseif event == ccui.TouchEventType.canceled then
        end
    end)
end

function WidgetUtils.createnullBtn(size)
	local btn = ccui.Button:create("common/null.png", "common/null.png", "common/null.png", ccui.TextureResType.localType)
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
        if checkBox.label and unselectColor then
            checkBox.label:setTextColor(cc.c3b(0xff,0xff,0xff))
            checkBox.label:setTextColor(unselectColor) 
        end
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
           -- print("time:"..time.."localtime:"..localtime)
            if time >= localtime and time < (localtime +v)then
                --print("faceeffect"..idx.."_"..i..".png")
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
-- 游戏标题动画
function WidgetUtils:createLoginEffect1()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/login_title.plist", "plist/login_title.png")
    local timetable = {0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3}
    local sprite = cc.Sprite:createWithSpriteFrameName("game_title1.png")
    local cnt = 8
    local index = 1
    local function action()
        if index > 8 then
            index = 1
        end
        sprite:setSpriteFrame("game_title"..index..".png")
        index = index + 1
    end
    sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(action),cc.DelayTime:create(0.2))))
    return sprite
end
-- 游戏登录按钮特效
function WidgetUtils:createLoginEffect2(direction)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/login_btn.plist", "plist/login_btn.png")
    local timetable = {0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3}
    local sprite = cc.Sprite:createWithSpriteFrameName("login_1.png")
    sprite:setScaleX(direction)
    local cnt = 14
    local index = 1
    local function action()
        if index > cnt then
           sprite:stopAllActions()
           sprite:removeFromParent()
           return
        end
        sprite:setSpriteFrame("login_"..index..".png")
        index = index + 1
    end
    sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(action),cc.DelayTime:create(0.1))))
    return sprite
end

function WidgetUtils.icon9( node,tab )
    if #tab > 0 then
        for i1,v1 in ipairs(tab) do
            local image = ccui.ImageView:create("common/head.png")
            image:setLocalZOrder(-1)
            image:setAnchorPoint(cc.p(0,1))
            node:addChild(image)
            image:setScale(23/88)
            image:setPositionX((i1-1)%3*69/3+6.2)
            image:setPositionY(72 - math.floor((i1-1)/3)*69/3+3.6)
            local nodeim = require("app.ui.common.HeadIcon").new(image,v1)
            nodeim.headicon:setTouchEnabled(false)
        end
    else
        local url = ""
        if tab and tab[1] then
            url = tab[1]
        end
        local image = ccui.ImageView:create("common/head.png")
        image:setLocalZOrder(-1)
        node:addChild(image)
        local nodeim = require("app.ui.common.HeadIcon").new(image,url)
        nodeim.headicon:setTouchEnabled(false)
    end
end