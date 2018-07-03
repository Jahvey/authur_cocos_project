
-------------------------------------------------
--   TODO   公共函数
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

ComHelpFuc = {}

--@brief 切割字符串，并用“...”替换尾部  
--@param    sName:要切割的字符串  
--@return   nMaxCount，字符串上限,中文字为2的倍数  
--@param    nShowCount：显示英文字个数，中文字为2的倍数,可为空  
--@note         函数实现：截取字符串一部分，剩余用“...”替换  
function ComHelpFuc.GetShortName(sName,nMaxCount,nShowCount)  
    if sName == nil or nMaxCount == nil then  
        return  
    end  
    local sStr = sName  
    local tCode = {}  
    local tName = {}  
    local nLenInByte = #sStr  
    local nWidth = 0  
    if nShowCount == nil then  
       nShowCount = nMaxCount - 3  
    end  
    for i=1,nLenInByte do  
        local curByte = string.byte(sStr, i)  
        local byteCount = 0;  
        if curByte>0 and curByte<=127 then  
            byteCount = 1  
        elseif curByte>=192 and curByte<223 then  
            byteCount = 2  
        elseif curByte>=224 and curByte<239 then  
            byteCount = 3  
        elseif curByte>=240 and curByte<=247 then  
            byteCount = 4  
        end  
        local char = nil  
        if byteCount > 0 then  
            char = string.sub(sStr, i, i+byteCount-1)  
            i = i + byteCount -1  
        end  
        if byteCount == 1 then  
            nWidth = nWidth + 1  
            table.insert(tName,char)  
            table.insert(tCode,1)  
              
        elseif byteCount > 1 then  
            nWidth = nWidth + 2  
            table.insert(tName,char)  
            table.insert(tCode,2)  
        end  
    end  
      
    if nWidth > nMaxCount then  
        local _sN = ""  
        local _len = 0  
        for i=1,#tName do  
            _sN = _sN .. tName[i]  
            _len = _len + tCode[i]  
            if _len >= nShowCount then  
                break  
            end  
        end  
        sName = _sN .. "..."  
    end  
    return sName  
end



local utf8_look_for_table ={
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
}

--根据头一个字符确定这个数据有好长
function ComHelpFuc.getUtf8Length(char)
    local length = utf8_look_for_table[string.byte(char,1)]
    -- print(length)
    return length
end

function ComHelpFuc.getStrWithLength(str,lenth)
	  if lenth then
	  else
	    lenth = 4
	  end
    local pos = 0
    --str = "善良的简单快乐的"
    if str == nil or str == "" then
        return ""
    end
    local count = 1
     while(pos <string.len(str) )
       do
           --print(str)
            local char1 = string.sub(str,pos+1,pos+2)
            local len = ComHelpFuc.getUtf8Length(char1)
            
            if count > lenth then
              return  string.sub(str,1,pos)..".."
            else
              pos =pos  + len
            end
            count = count + 1
        end
   return str
end

function ComHelpFuc.getCharacterCountInUTF8String(str,length)
    local lengthmax = length or 16
    local locallengt = 0
    local c
    local i = 1
    while true do
        c = string.byte(string.sub(str,i,i))
        -- print(c)
        if not c then
            return str
        elseif (c<=127)  then
            locallengt = locallengt + 1
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 1;
        elseif (bit.band(c , 0xE0) == 0xC0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 2;
        elseif (bit.band(c , 0xF0) == 0xE0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 3;
        elseif (bit.band(c , 0xF8) == 0xF0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 4;
        else 
            return str
        end
    end
    return str
end

--我自己的手牌 排序
function ComHelpFuc.sortMyHandTile(list)
	-- list = {0x11,0x11,0x13,0x22,0x31,0x32,0x32,0x32,0x42,0x42,0x43,0x53,0x63,0x62,0x62,0x73,0x73,0x81,0x81,0x83,0x83}
	-- list = {0x42,0x41,0x41,0x43,0x43,0x43,0x62,0x61,0x61,0x61,0x63,0x63,0x63,0x71,0x73,0x82,0x83,0x83,0x53,0x32,0x12}
	table.sort(list,function(_a,_b)
		return _a < _b
	end)
	-- print(".............我自己的手牌 排序,#list = ",#list)
	-- printTable(list,"xp8")

	--结构体整理，统计每张牌的个数，
	local realList = {}
	for i,v in ipairs(list) do
		local ishave = false
		for kk,vv in pairs(realList) do
			if vv.real_value == v then
				vv.num = vv.num + 1
				ishave = true
			end
		end
		if not ishave then
			local _data = {}
			_data.real_value = v
			_data.one_value = math.floor(v/16)
			_data.two_value = v%16
			_data.num = 1
			table.insert(realList,_data)
		end
	end
	-- print("...........我自己的手牌 排序 .......1")
	-- printTable(realList,"xp8")

	--分列
	local function splitcolumn(columnData)
		-- print(".............拆分前")
		-- printTable(columnData,"xp8")
 		local _one_value = columnData.one_value
		local list = {}
		local _data = {}
		_data.valueList = {}
		_data.one_value = _one_value
		_data.num = 0
		table.insert(list,_data)
		
		--先按照数量而排序
		table.sort(columnData.valueList,function(_a,_b)
			return _a.num > _b.num
		end)

		-- print(".............排序后")
		-- printTable(columnData,"xp8")

		for k,v in pairs(columnData.valueList) do
			--找出是否满足合并的列，比如，同为6，2个33和2个42，可以合并，
			local insert = false
			for ii,vv in ipairs(list) do
				if vv.num + v.num <= 4 and not insert  then
					vv.num = vv.num + v.num
					table.insert(vv.valueList,v)
					insert = true
				end
			end
			--如果不满足，就另起一列
			if  not insert then
				local _data = {}
				_data.valueList = {v}
				_data.one_value = _one_value
				_data.num = v.num
				table.insert(list,_data)
			end
		end
		-- print(".............拆分后")
		-- printTable(list,"xp8")

		return list
	end

	--排序,队列里面满足123都有的时候，应排序为213
	local function listsort(list)
		local ishave = {false,false,false}		
		for k,v in pairs(list) do
			ishave[v.two_value] = true
		end
		if ishave[1] and ishave[2] and ishave[3] then
			for k,v in pairs(list) do
				if v.two_value == 1 then
					v.two_value = 2.5
				end
			end
		end
		table.sort(list,function(_a,_b)
			return _a.two_value < _b.two_value
		end)
		
		for k,v in pairs(list) do
			if v.two_value == 2.5 then
				v.two_value = 1
			end
		end
	end

	-- 统计每种牌的个数,比如，有几个6（3+3，2+4，1+5），并且先按照每列最多4张而分列
	local function tongJiCnt(tab)	
		local ret = {}
		local add = 20
		for i,v in ipairs(tab) do
			local cnt = v.one_value 
			if not ret[cnt] then
				ret[cnt] = {}
				ret[cnt].valueList = {}
				table.insert(ret[cnt].valueList,v)
				ret[cnt].one_value = v.one_value
				ret[cnt].num = v.num
			else	
				if ret[cnt].one_value == v.one_value then
					ret[cnt].num = ret[cnt].num + v.num
					table.insert(ret[cnt].valueList,v)
				else
					cnt = cnt + v.num
					ret[cnt] = {}
					ret[cnt].valueList = {}
					table.insert(ret[cnt].valueList,v)
					ret[cnt].one_value = v.one_value
					ret[cnt].num = v.num	
				end
			end

			listsort(ret[cnt].valueList)
		end
		return ret
	end	
	realList = tongJiCnt(realList)

	--整理，按照相加等于14的排序
	local function zhengliCnt(tab)
		local _ret = {}
		for k,v in pairs(tab) do
			table.insert(_ret,v)
		end
		local function sortfunc_(_a,_b)
			return _a.one_value < _b.one_value
		end
		table.sort(_ret,sortfunc_)

		-- 如果单列之后一个的话，删除列，把内容放到最后去
		local column_count = #_ret
		if column_count > 8 then
			column_count = 8
		end

		local _last = {}
		_last.valueList = {}
		_last.one_value = 9
		_last.num = 0

		for i=column_count,1,-1 do
			if _ret[i].num == 1 then
				_last.num = _last.num +1
				table.insert(_last.valueList,_ret[i].valueList[1])
				table.remove(_ret,i)
			end
		end
		local function sortfunc_(_a,_b)
			return _a.one_value < _b.one_value
		end
		table.sort(_last.valueList,sortfunc_)
		
		table.insert(_ret,_last)

		return _ret
	end	

	realList = zhengliCnt(realList)
	-- print("..................整合后的结构")
	-- printTable(realList,"xp8")
	--把排列好的队列，展开
	local _list = {}
	for k,v in pairs(realList) do
		local columnList = {}
		columnList.valueList = {}
		columnList.one_value = v.one_value
		columnList.num = v.num
		for kk,vv in pairs(v.valueList) do
			for i=1,vv.num do
				table.insert(columnList.valueList,1,vv)
			end
		end
		table.insert(_list,1,columnList)
	end

	local function sortfunc_(_a,_b)
		return _a.one_value < _b.one_value
	end
	table.sort(_list,sortfunc_)

	-- print("..................把排整合后的列表，展开")
	-- printTable(_list,"xp8")

	return _list
end



--别人的手牌 在回放界面的排序
function ComHelpFuc.sortOtherHandTile(list)
	-- list = { 0x14, 0x15, 0x24, 0x33, 0x33, 0x24, 0x26, 0x44, 0x34, 0x11}


	table.sort(list,function(_a,_b)
		return _a < _b
	end)

	
	-- local realList = {}
	-- for i,v in ipairs(list) do
	-- 	local _data = {}
	-- 	_data.real_value = v
	-- 	_data.one_value = math.floor(v/16)
	-- 	_data.all_value = _data.one_value + v%16
	-- 	table.insert(realList,_data)
	-- end
	
	-- -- 统计个数
	-- local function tongJiCnt(tab)	
	-- 	local ret = {}
	-- 	for i,v in ipairs(tab) do
	-- 		local cnt = v.all_value 
			
	-- 		if not ret[cnt] then
	-- 			ret[cnt] = {}
	-- 			ret[cnt].valueList = {}
	-- 			table.insert(ret[cnt].valueList,v)
	-- 			ret[cnt].all_value = v.all_value
	-- 			ret[cnt].num = 1
	-- 		else	
	-- 			if ret[cnt].all_value == v.all_value then
	-- 				ret[cnt].num = ret[cnt].num + 1
	-- 				table.insert(ret[cnt].valueList,v)
	-- 			else
	-- 				cnt = cnt + 1
	-- 				ret[cnt] = {}
	-- 				ret[cnt].valueList = {}
	-- 				table.insert(ret[cnt].valueList,v)
	-- 				ret[cnt].all_value = v.all_value
	-- 				ret[cnt].num = 1	
	-- 			end
	-- 		end	
	-- 	end
	-- 	return ret
	-- end	
	-- realList = tongJiCnt(realList)


	-- --整理big
	-- local function zhengliCnt(tab)
	-- 	local _ret = {}
	-- 	for k,v in pairs(tab) do
	-- 		table.insert(_ret,v)
	-- 	end
	-- 	local function sortfunc_(_a,_b)
	-- 		return _a.all_value < _b.all_value
	-- 	end
	-- 	table.sort(_ret,sortfunc_)

	-- 	local ret = {}

	-- 	for k,v in pairs(_ret) do
	-- 		local cnt = v.all_value
	-- 		if cnt < 8 then
	-- 			if not ret[cnt] then
	-- 				ret[cnt] = v
	-- 			end
	-- 		else
	-- 			if not ret[14-cnt] then
	-- 				ret[cnt] = v
	-- 			else
	-- 				ret[14-cnt].num = ret[14-cnt].num + v.num
	-- 				for ii,vv in pairs(v.valueList) do
	-- 					table.insert(ret[14-cnt].valueList,vv)
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	local list = clone(ret)
	-- 	for k,v in pairs(list) do		
	-- 		local function sortfunc_(_a,_b)

	-- 			local a_ =_a.all_value *10 + _a.one_value
	-- 			local b_ =_b.all_value *10 + _b.one_value
	-- 			return a_ < b_
	-- 		end
	-- 		table.sort(v.valueList,sortfunc_)
	-- 	end

	-- 	return list
	-- end	
	-- realList = zhengliCnt(realList)

	-- -- print("...............xp6")
	-- -- printTable(realList,"xp6")

	-- local _list = {}
	-- for k,v in pairs(realList) do
	-- 	for kk,vv in ipairs(v.valueList) do
	-- 		table.insert(_list,vv.real_value)
	-- 	end
	-- end

	return list
end

--出牌 排序
function ComHelpFuc.sortOutCardTile(list,num)
	local _list = {{},{}}
	for i,v in ipairs(list) do
		if i < (num or 8) then
			table.insert(_list[1],v)
		else
			table.insert(_list[2],v)
		end
	end
	return _list
end

function ComHelpFuc.sortOutCardThreeLine(list,num)
	local _list = {{},{}}
	local idx = 1
	for i,v in ipairs(list) do
		-- if i < (num or 8) then
		-- 	table.insert(_list[1],v)
		-- else
		-- 	table.insert(_list[2],v)
		-- end
		
		if #_list[1] <= num then
			table.insert(_list[1],v)
		elseif #_list[2] <= num then
			table.insert(_list[2],v)
		elseif not _list[3] then
			_list[3] = {}
			table.insert(_list[3],v)
		elseif #_list[3] <=7 then
			table.insert(_list[3],v)
		else
			table.insert(_list[idx],v)
			idx = (idx+1 < 4 and idx+1) or 1
		end 
	end
	return _list
end

 -- 短牌手牌排序
function ComHelpFuc.sortPokerHandTile(list)
    local handlist = {}

    table.sort(list,function (a,b)
        return (a%16 == b%16 and math.floor(a/16)>math.floor(b/16)) or a%16>b%16
    end)

    local redlist = {}
    local blacklist = {}

    for i,v in ipairs(list) do
        if math.floor(v/16) == 1 or math.floor(v/16) == 2 then
            table.insert(redlist,v)
        else
            table.insert(blacklist,v)
        end
    end

    local function getPairValue(value)
        local pairvalue = 0

        local colorvalue = math.floor(value/16)

        if colorvalue == 1 or colorvalue == 2 then
            pairvalue = 10
        else
            pairvalue = 20
        end

        local numvalue = value%16
        if numvalue > 10 then
            pairvalue = pairvalue + 4
        else
            pairvalue = pairvalue + math.ceil((numvalue%16)/3)
        end

        return pairvalue
    end

    local index = 0
    for k=1,2 do
        if k == 1 then
            list = redlist
        else
            list = blacklist
        end
        while #list > 0 do 
            local value = list[#list]
            table.remove(list,#list)
            local pairvalue = getPairValue(value)
            index = index + 1

            if not handlist[index] then
                handlist[index] = {}
            end

            table.insert(handlist[index],value)

            for i=#list,1,-1 do
                if getPairValue(list[i]) == getPairValue(value) then
                    -- if #handlist[index] >=5 then
                    --     index = index + 1
                    --     handlist[index] = {}
                    -- end
                    table.insert(handlist[index],list[i])
                    table.remove(list,i)
                end
            end
        end
    end

    return handlist
end

--牌的颜色，1是全红，2是黑红相间，3是全黑
--财神和听用（77和88）算全黑
function ComHelpFuc.getIsRedCard(card)

	local one = math.floor(card/16)
	local two = card%16
	if one == 1 or one == 4 or one == 6 or two == 4 then
		--地牌，人牌和幺四
		if card == 17 or card == 20 or card == 68  then 
			return 1
		end
		return 2
	end
	return 3
end


--获取删除目标牌之后的列表
function ComHelpFuc.getDeleteDestList(col_info,dest_card)
	local list = col_info.cards
	if col_info.original_cards then
		list = col_info.original_cards
	end
	--偎是自己手里面的4张牌，要全部删除
	if dest_card == nil then
		return list
	end
	local list = clone(list)
	for i,v in ipairs(list) do
		if v == dest_card  then
			table.remove(list,i)
			dest_card = -1
			break
		end
	end
	return list
end

ComHelpFuc.errorlist = {
	["0"] = "成功",	["1"] = "服务器系统错误",	["2"] = "服务器系统错误",	["3"] = "服务器系统错误",	["4"] = "服务器系统错误",	["5"] = "服务器系统错误",	["6"] = "服务器系统错误",	["100"] = "登录失败,token错误",	["101"] = "已经创建了房间",	["102"] = "房间不存在",	["103"] = "房间人数已满",	["104"] = "房间位子不存在",	["105"] = "操作不存在",	["106"] = "房间配置不存在",	["107"] = "房间状态不正确",	["108"] = "系统错误",	["109"] = "房卡不足",	["110"] = "你已经在房间内",	["111"] = "当前版本不是最新版本,请关闭游戏重新进入",	["112"] = "战绩回放数据查找失败",	["113"] = "代理房间达到上限",	["114"] = "您不是代理,申请代理请加官方微信",	["115"] = "系统维护中",	["116"] = "没有权限",	["1001"] = "您不是代理,无法创建茶馆",	["1002"] = "加入创建的茶馆最多只能5个,当前已经到达上限",	["1003"] = "您不在此茶馆",	["1004"] = "茶馆不存在",	["1005"] = "茶馆人数已满",	["1006"] = "已经申请加入茶馆,等待群主审核",	["1007"] = "您已经在这个茶馆内",	["1008"] = "没有权限",	["1009"]  = "申请不存在",	["1010"] = "茶馆人数已满",	["1011"] = "群主不能退出茶馆",	["1012"] = "群主和茶馆不匹配",	["1013"] = "茶馆创建房间已满",	["1014"] = "茶馆房卡不足",	["1015"] = "茶馆增加或者减少房卡数为0",	["1016"] = "房卡不足",	["1017"] = "茶馆房卡不足",	["1022"] = "牌局已经开始不能解散",
}

function ComHelpFuc.errortips(code)

	local str = ComHelpFuc.errorlist[tostring(code)]
	if str then
		return str
	else
		return "操作失败,错误代码"..code
	end
end



function ComHelpFuc.setScrollViewEvent(scrollview)
	local beganposx,beganposy = 0,0

	local function onTouchBegan(touch, event)
		local target = event:getCurrentTarget()
		target.isscrolling = false
		-- print(".........onTouchBegan .x = ")
		local locationInNode = target:convertToNodeSpace(touch:getLocation())
		local s = target:getContentSize()
		local rect = cc.rect(0, 0, s.width, s.height); 
		if cc.rectContainsPoint(rect,locationInNode) then
			beganposx,beganposy = locationInNode.x,locationInNode.y 
			return true
		end
	end

	local function onTouchMove(touch, event)
		local target = event:getCurrentTarget()

		local locationInNode = target:convertToNodeSpace(touch:getLocation())

		local length = cc.pGetLength(cc.p(locationInNode.x - beganposx,locationInNode.y - beganposy))

		if length > 5 then
			target.isscrolling = true
		end

		-- local pos = scrollview:getInnerContainerPosition()
		-- print(".........onTouchMove .x = ",pos.x)
		-- print(".........onTouchMove .y = ",pos.y)

	end

	local function onTouchEnd(touch, event)
		local target = event:getCurrentTarget()
		target.isscrolling = false

	end

	local function onTouchCancell(touch, event)
		local target = event:getCurrentTarget()
		target.isscrolling = false
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onTouchCancell,cc.Handler.EVENT_TOUCH_CANCELLED)
	
	local eventDispatcher = scrollview:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,scrollview)
	scrollview:setSwallowTouches(false)
end
