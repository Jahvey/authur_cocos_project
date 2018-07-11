--
-- Author: fee
-- Date: 2017-12-01 10:31:23
--
local DdzcsbAnmation = {}
function DdzcsbAnmation.chuntianfornongming()
    print("反春天")
	local node =  cc.CSLoader:createNode("animation/chuntian/nongminchuntian.csb")
	local action = cc.CSLoader:createTimeline("animation/chuntian/nongminchuntian.csb")
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
    AudioUtils.playEffect("ddz_Spring")
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end





function DdzcsbAnmation.chuntianfordizhi()
	local node =  cc.CSLoader:createNode("animation/chuntian/dizhuchuntian.csb")
	local action = cc.CSLoader:createTimeline("animation/chuntian/dizhuchuntian.csb")
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
    AudioUtils.playEffect("ddz_Spring")
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end





function DdzcsbAnmation.feiji()
	local node =  cc.CSLoader:createNode("animation/feiji/feiji.csb")
	local action = cc.CSLoader:createTimeline("animation/feiji/feiji.csb")
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
    AudioUtils.playEffect("ddz_airplane_the_first_time")
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end




function DdzcsbAnmation.huojian()
	local node =  cc.CSLoader:createNode("animation/huojian/huojian.csb")
	local action = cc.CSLoader:createTimeline("animation/huojian/huojian.csb")
	local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            AudioUtils.playEffect("ddz_bomb")
        end

    end
    --AudioUtils.playEffect("ddz_rocket")
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end






--警报
function DdzcsbAnmation.jingbao()
	local node =  cc.CSLoader:createNode("animation/jingbao/jingbao.csb")
	local action = cc.CSLoader:createTimeline("animation/jingbao/jingbao.csb")
	local function onFrameEvent(frame)
    	print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()

    end
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,true)
    return node
end




--顺子
function DdzcsbAnmation.shunzi()
	local node =  cc.CSLoader:createNode("animation/shunzi/shunzi.csb")
	local action = cc.CSLoader:createTimeline("animation/shunzi/shunzi.csb")
	local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            AudioUtils.playEffect("ddz_shunzi")
        end

    end
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end






--炸弹
function DdzcsbAnmation.zhadan()
	local node =  cc.CSLoader:createNode("animation/zhadan/zhadan.csb")
	local action = cc.CSLoader:createTimeline("animation/zhadan/zhadan.csb")
	local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            AudioUtils.playEffect("ddz_bomb")
        end

    end

    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end


--踢和回踢
function DdzcsbAnmation.tiAndHuiTi(ishui)
    local iconPath = "gameddz/action_ti.png"
    local audio = "ddz_tipai"

    if ishui then
        iconPath = "gameddz/action_huiti.png"
        audio = "ddz_huiti"
    end

    local node =  cc.CSLoader:createNode("animation/shunzi/shunzi.csb")
    local Node_1 = node:getChildByName("shunzi_zuo"):getChildByName("Node_1")
    Node_1:getChildByName("Image_1"):loadTexture(iconPath,ccui.TextureResType.localType)

    local action = cc.CSLoader:createTimeline("animation/shunzi/shunzi.csb")
    local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            -- AudioUtils.playEffect(audio)
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end
--五龙炸弹
function DdzcsbAnmation.zhadan_five()
    local node =  cc.CSLoader:createNode("animation/longzha/5longzha.csb")
    local action = cc.CSLoader:createTimeline("animation/longzha/5longzha.csb")
    local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            AudioUtils.playEffect("ddz_long_bloom")
        end

    end

    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end
--滚龙炸弹
function DdzcsbAnmation.zhadan_gun()
    local node =  cc.CSLoader:createNode("animation/longzha/gunlongzha.csb")
    local action = cc.CSLoader:createTimeline("animation/longzha/gunlongzha.csb")
    local function onFrameEvent(frame)
        print("action111")
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            node:removeFromParent()
        elseif str == "yinxiao" then
            print(".........滚龙炸的音效")
            AudioUtils.playEffect("ddz_long_bloom")
        end

    end

    action:setFrameEventCallFunc(onFrameEvent)

    node:runAction(action)
    action:gotoFrameAndPlay(0,false)
    return node
end

return DdzcsbAnmation

