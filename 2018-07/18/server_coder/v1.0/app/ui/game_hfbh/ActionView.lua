
local ActionView = class("ActionView", require "app.ui.game.ActionView")
local LongCard = require "app.ui.game.base.LongCard"
local PICWIDTH = 200
function ActionView:init()
    --wai  和 chi  都叫吃
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI]= { sort = 2, img = "game/btn_chi.png" }
  	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_WAI]= { sort = 2, img = "game/btn_chi.png" }
  	--deng 叫 跳
  	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_DENG]= { sort = 2, img = "game/btn_tiao.png" }
  	--wei 叫绍
  	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_WEI]= { sort = 2, img = "game/btn_shao.png" }
    -- 打 
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_DA]= { sort = 2, img = "game/btn_da.png" }
    -- 下抓
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHUA]= { sort = 7, img = "game/btn_xiazhua.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_TUO]= { sort = 7, img = "game/btn_tuo.png" }

  	self.lanjieLayer = ccui.Layout:create()
	self.lanjieLayer:setContentSize(cc.size(display.size.width*2,display.size.height*2))
	self:addChild(self.lanjieLayer)
	self.lanjieLayer:setPosition(cc.p(-display.cx,-display.cy))
	self.lanjieLayer:setVisible(false)
	self.lanjieLayer:setTouchEnabled(true)
 	self.lanjieLayer:setSwallowTouches(true)

	WidgetUtils.addClickEvent(self.lanjieLayer, function( )
		print("点击！！！！！self.lanjieLayer")
		self.selectNode_2:setVisible(false)
		self.lanjieLayer:setVisible(false)
	end)

	self.selectNode_2 = cc.Node:create()
	self:addChild(self.selectNode_2)
	self.selectNode_2:setVisible(false)

end



function ActionView:showAction(choices)
    print("..........ActionView:showAction(")
    printTable(choices, "xppp")

    self:showHiddenBtn()

    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = "game/btn_guo.png"

    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.btnNode:removeAllChildren()
    

    local choices = clone(choices)

    for i = #choices, 1, -1 do
        if not self.ACTIONCONF[choices[i].act_type] then
            table.remove(choices, i)
        end
    end

    if #choices == 0 then
        return
    end

    --如果有歪，改为吃，但是，发过去的还是歪
     for k, v in pairs(choices) do
        v.real_act_type = v.act_type
        if  v.real_act_type == poker_common_pb.EN_SDR_ACTION_WAI  then
        	v.act_type = poker_common_pb.EN_SDR_ACTION_CHI
        end
    end

    ------------整合
    --找出所有的sub_col
    local allSubCol = {}

    local choicesList = { }
    for k, v in pairs(choices) do
        if v.real_act_type == poker_common_pb.EN_SDR_ACTION_WAI and v.col_info then
            if v.col_info.sub_col then
                table.insert(allSubCol,clone(v))
                v.col_info.sub_col = nil
                v.sublist = {}
            end
        end

        if not choicesList[v.act_type] then
            local _list = { num = 1, act_type = v.act_type, list = { v } }
            choicesList[v.act_type] = _list
        else
            choicesList[v.act_type].num = choicesList[v.act_type].num + 1
            table.insert(choicesList[v.act_type].list, v) 
        end
    end

    

    print("..........ActionView: allSubCol ")
    printTable(allSubCol, "xppp")

    print("..........ActionView: choicesList ")
    printTable(choicesList, "xppp")


        -- 统计个数
    local function addSubList(_tab)    
        if _tab.real_act_type == poker_common_pb.EN_SDR_ACTION_WAI then
           local _sublist = {}
            print(".............合并二级")
            printTable(_tab, "xppp")
            --合并二级
            for i=#allSubCol,1,-1 do
                 if allSubCol[i].dest_card == _tab.dest_card then
                    local ishe = true
                    local _all = allSubCol[i].col_info.cards
                    for _k,__v in pairs(_tab.col_info.cards) do
                        if _all[_k] and __v ~= _all[_k] then
                            ishe = false
                        end
                    end
                    if ishe then
                        table.insert(_sublist, allSubCol[i])  
                        table.remove(allSubCol,i)  
                    end
                end
            end
            _tab.sublist = _sublist
        end
        return _tab
    end  

    
    for k,v in pairs(choicesList) do
        if v.num > 1 and v. act_type == poker_common_pb.EN_SDR_ACTION_CHI then
            local _list = nil
            for kk,vv in pairs(v.list) do
                if _list == nil then
                    _list = {addSubList(vv)}
                else
                    local haveIndex = -1
                    --合并一级
                    for kkk,vvv in pairs(_list) do
                        if haveIndex == -1 and vvv.real_act_type == poker_common_pb.EN_SDR_ACTION_WAI then
                            local ishe = true
                            for i,_v in ipairs(vvv.col_info.cards) do
                                if ishe and _v ~= vv.col_info.cards[i] then
                                    ishe = false
                                end 
                            end
                            if ishe then
                                haveIndex = kkk
                            else
                            end
                        end
                    end
                    if haveIndex ~= -1  then
                        v.num = v.num - 1
                    else
                        table.insert(_list, addSubList(vv)) 
                    end
                end
            end
            v.list = _list
        end
    end

    ------------整合结束
    -- print("..........ActionView: endList ")
    -- printTable(choicesList, "xppp")

    

    local endList = { }
    for k, v in pairs(choicesList) do
        table.insert(endList, v)
    end

    table.sort(endList, function(a, b)
        return self.ACTIONCONF[a.act_type].sort > self.ACTIONCONF[b.act_type].sort
    end )
    ------------整合结束
    -- print("..........ActionView: endList ")
    -- printTable(endList, "xpp")
    -- 是否有选择坐庄
    for i, v in ipairs(endList) do
        if v.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG then
            self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PASS].img = self.huazhuangsrc
            break
        end
    end

    self:setVisible(true)
    self.btnNode:removeAllChildren()
    local half =(#endList + 1) / 2.0

    local btnList = { }
    for i, v in ipairs(endList) do

        local btn = ccui.Button:create(self.ACTIONCONF[v.act_type].img)
        :addTo(self.btnNode)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :setPositionX((half - i) * PICWIDTH)
        :setTag(i)

        v.btn = btn

        table.insert(btnList, btn)
        WidgetUtils.addClickEvent(btn, function()
            self:commonAction(v)
        end )
    end
end

function ActionView:hide()
    self:setVisible(false)
    self.selectNode:setVisible(false)
    self.selectNode:removeAllChildren()
    self.selectNode.btn = nil

    self.selectNode_2:setVisible(false)
    self.selectNode_2:removeAllChildren()
    self.lanjieLayer:setVisible(false)

    self.hiddenBtn:setVisible(false)
    self.hiddenBtn:runAction(cc.MoveTo:create(0.01, cc.p(695, -30)))
end

function ActionView:sendAction(_tab)

    self:hide()

    local _index = _tab.seat_index
    local _type = _tab.real_act_type
    local _card = _tab.dest_card
    local _cards = _tab.col_info and _tab.col_info.cards
    local _token = _tab.action_token
    local _choice_token = _tab.choice_token
    
    Socketapi.request_do_action(_index, _type, _card, _cards, _token,_choice_token)
end


-- 生成某操作下的选择项
function ActionView:createSelectNode(_tab)
    print("........生成某操作下的选择项")
    -- printTable(_tab, "xpp")

    local node = cc.Node:create()
    local btn = ccui.Button:create("game/action_btn_bg.png", "game/action_btn_bg.png", "common/null.png", ccui.TextureResType.localType)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:setScale9Enabled(true)
    btn:setContentSize(cc.size(50, 76 +(#_tab.col_info.cards - 1) * 32))
    btn:setPositionX(0)
    btn:setPositionY(0)

    WidgetUtils.addClickEvent(btn, function()
    	-- printTable(_tab, "xpp")
    	print("........生成二级菜单！哈哈哈")
    	if _tab.sublist and #_tab.sublist > 0 then
    		print("........生成二级菜单！")
    		self:commonErSelectAction(_tab,node)
    	else
		  self:sendAction(_tab)
    	end
    end )
    node:addChild(btn)

     --生成牌
    for i, v in ipairs(_tab.col_info.cards) do
        local pai = LongCard.new(CARDTYPE.MYHAND, v)
        pai:setAnchorPoint(cc.p(0.5, 0.5))
        pai:setPositionX(0)
        pai:setScale(0.5)
        pai:setPositionY(((#_tab.col_info.cards + 1) / 2.0 - i) * 32)
        -- 牌的高度+上下距离
        pai:addTo(node)

        if self.gamescene:getIsJiangCard(v) then
            pai:showJiang()
        end
    end
    return node
end


--生成某操作下的二级选择界面
function ActionView:commonErSelectAction(data,_node)
	print("..--生成某操作下的二级选择界面 ")
	-- printTable(data,"xpp")

	self.selectNode_2:removeAllChildren()
	self.selectNode_2:setVisible(true)
	self.lanjieLayer:setVisible(true)

	--找到可以吃这张牌的所有牌
	local cardList = data.sublist

	local mac_cards_num = 2 --吃牌2张

	local bg = ccui.ImageView:create("game/action_bg.png")
			:setScale9Enabled(true)
			:setCapInsets(cc.rect(30, 30, 44,44))
			:setAnchorPoint(cc.p(0.5,1))
	bg:setLocalZOrder(-1)
	bg:setContentSize(cc.size(56+44+92*(#cardList-1),76+76+(mac_cards_num-1)*32))
	self.selectNode_2:addChild(bg)

	local jiantou = ccui.ImageView:create("game/action_arrow.png")
	jiantou:setScaleY(-1)
	jiantou:setAnchorPoint(cc.p(0.5,1))
	jiantou:setPositionX(bg:getContentSize().width/2.0)
	jiantou:setPositionY(bg:getContentSize().height)
	bg:addChild(jiantou)

	--生成选择项
	for i,v in ipairs(cardList) do
		local node  = self:createErSelectNode(v)
		node:setPositionX(28+22+(i-1)*92)
		node:setPositionY(bg:getContentSize().height/2.0)
		bg:addChild(node)
	end
	
	local worldpos1 = _node:getParent():convertToWorldSpace(cc.p(_node:getPositionX(),_node:getPositionY()))
	local spacepos = self:convertToNodeSpace(worldpos1)

	self.selectNode_2:setPosition(cc.p(spacepos.x,spacepos.y-bg:getContentSize().height/2.0+25))
	-- self.selectNode_2:setPosition(cc.p(spacepos.x,spacepos.y-bg:getContentSize().height/2.0+10))

end

--生成某操作下的二级选择项
function ActionView:createErSelectNode(_sub)

	local listCard = _sub.col_info.sub_col.cards
	local node =  cc.Node:create()
	local btn = ccui.Button:create("game/action_btn_bg.png","game/action_btn_bg.png","common/null.png", ccui.TextureResType.localType)
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(50,76+(#listCard-1)*32))
	btn:setPositionX(0)
	btn:setPositionY(0)

	WidgetUtils.addClickEvent(btn, function()
		print("......点击成功！！！！")
		self:sendAction(_sub)
	end)
	node:addChild(btn)
	
	for i,v in ipairs(listCard) do
		local pai = LongCard.new(CARDTYPE.ONTABLE,v)
		pai:setAnchorPoint(cc.p(0.5,0.5))
		pai:setPositionX(0)
		print("....=",(((#listCard)+1)/2.0)-i)
		pai:setPositionY(((#listCard+1)/2.0-i)*32) --牌的高度+上下距离
		pai:addTo(node)
	end
	return node
end



return ActionView