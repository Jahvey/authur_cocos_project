
-------------------------------------------------
--   TODO   公共函数
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

ComHelpFuc = {}
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
function ComHelpFuc.getStrWithLengthByJSP(str)
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
            
            if count > 4 then
            	return  string.sub(str,1,pos)..".."
            else
            	pos =pos  + len
            end
            count = count + 1
        end
   return str
end
function ComHelpFuc.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  -- for
        return setmetatable(new_table, getmetatable(object))
    end  -- function _copy
    return _copy(object)
end 


function ComHelpFuc.getstrdata( str)
	-- body
	if str == nil then
		return nil
	end
	local  len = string.len(str)
	local index = 1
	local datatab = {}
	while index <= len do
		local findindex = string.find(str,";",index)
		if findindex then
			local value = string.sub(str,index,findindex - 1)
			table.insert(datatab,tonumber(value))
		else
			local value = string.sub(str,index)
			table.insert(datatab,tonumber(value))
			break
		end
		index = findindex + 1
	end
	return datatab
end


function ComHelpFuc.sortcard(tab)
	printTable(tab)
	local baitab=  {}
	for i,v in ipairs(tab) do
		if baitab[v] == nil then
			 baitab[v] = 1
		else
			 baitab[v] =  baitab[v] + 1
		end
	end
	local fourtable = {}
	local threetable = {}
	local jiathreetable = {}
	local shunzi = {}
	local duizi = {}
	local danzhang = {}
	for i=1,20 do
		if baitab[i] then
			if baitab[i] == 4 then
				table.insert(fourtable,i)
				baitab[i] = 0
			elseif baitab[i] == 3 then
				--print("有三个")
				table.insert(threetable,i)
				baitab[i] = 0
			else
				--取 AAa类型
				if i <= 0x0a then
					if baitab[(i)] < 3 and baitab[(i+10)] and baitab[(i+10)] < 3 then
						if (baitab[(i)] + baitab[(i+10)]) > 2 then
							--print("aaA类型")
							
							local tablelocal = {}
							--print(baitab[tostring(i)])

							--print(baitab[tostring(i+16)])
							for j=1,baitab[(i)] do
								table.insert(tablelocal,i)
							end

							for j=1,baitab[(i+10)] do
								table.insert(tablelocal,i+10)
							end
							table.insert(jiathreetable,tablelocal)
							baitab[(i)] = 0
							baitab[(i+10)] = 0
						end
					end 
				end
			end
			
		end
	end

	--取对子
	for i=1,20 do
		if baitab[(i)] and baitab[(i)] == 2 then
			table.insert(duizi,{i,i})
			baitab[(i)] = baitab[(i)]  - 2
		end
	end
	--取顺子
	for i=1,20 do
		if i < 9 or i >10 then
			if  baitab[(i)] and baitab[(i)] > 0 and baitab[(i+1)] and baitab[(i+1)] > 0 and baitab[(i+2)] and baitab[(i+2)] > 0 then
				table.insert(shunzi,{i,i+1,i+2})
				baitab[(i)] = baitab[(i)]  - 1
				baitab[(i+1)] = baitab[(i+1)]  - 1
				baitab[(i+2)] = baitab[(i+2)]  - 1
			end

			if baitab[(i)] and baitab[(i)] > 0 and baitab[(i+1)] and baitab[(i+1)] > 0 and baitab[(i+2)] and baitab[(i+2)] > 0 then
				table.insert(shunzi,{i,i+1,i+2})
				baitab[(i)] = baitab[(i)]  - 1
				baitab[(i+1)] = baitab[(i+1)]  - 1
				baitab[(i+2)] = baitab[(i+2)]  - 1
			end
		end
	end

	-- 2 7 10
	if baitab[(0x02)] and baitab[(0x02)] >0 and baitab[(0x07)] and baitab[(0x07)] > 0 and baitab[(0x0a)] and baitab[(0x0a)] > 0 then
		if baitab[(0x02)] == 2 and baitab[(0x07)] == 2 and  baitab[(0x09)] == 2 then
			table.insert(shunzi,{0x02,0x07,0x0a})
			table.insert(shunzi,{0x02,0x07,0x0a})
			baitab[(0x02)] = baitab[(0x02)]  - 2
			baitab[(0x07)] = baitab[(0x07)]  - 2
			baitab[(0x0a)] = baitab[(0x0a)]  - 2
		else
			table.insert(shunzi,{0x02,0x07,0x0a})
			baitab[(0x02)] = baitab[(0x02)]  - 1
			baitab[(0x07)] = baitab[(0x07)]  - 1
			baitab[(0x0a)] = baitab[(0x0a)]  - 1
		end
	end
	-- 12 17 20
	if baitab[(12)] and baitab[(12)] >0 and baitab[(17)] and baitab[(17)] > 0 and baitab[(20)] and baitab[(20)] > 0 then
		if baitab[(12)] == 2 and baitab[(17)] == 2 and  baitab[(20)] == 2 then
			table.insert(shunzi,{12,17,20})
			table.insert(shunzi,{12,17,20})
			baitab[(12)] = baitab[(12)]  - 2
			baitab[(17)] = baitab[(17)]  - 2
			baitab[(20)] = baitab[(20)]  - 2
		else
			table.insert(shunzi,{12,17,20})
			baitab[(12)] = baitab[(12)]  - 1
			baitab[(17)] = baitab[(17)]  - 1
			baitab[(20)] = baitab[(20)]  - 1
		end
	end
	
	--单张
	for i=1,20 do
		if baitab[(i)] and baitab[(i)] == 1 then
			table.insert(danzhang,i)
			baitab[(i)] = 0
		end
	end
	--牌列子
	local listtotoall = 0
	local listtable = {}
	for i,v in ipairs(fourtable) do
		listtotoall = listtotoall + 1
		table.insert(listtable,{ismove = false,value = {v,v,v,v}})
	end

	for i,v in ipairs(threetable) do
		listtotoall = listtotoall + 1
		table.insert(listtable,{ismove = false,value = {v,v,v}})
	end


	for i,v in ipairs(jiathreetable) do
		listtotoall = listtotoall + 1
		table.insert(listtable,{ismove = true,value = v})
	end
	for i,v in ipairs(duizi) do
		listtotoall = listtotoall + 1
		table.insert(listtable,{ismove = true,value = v})
	end

	for i,v in ipairs(shunzi) do
		listtotoall = listtotoall + 1
		table.insert(listtable,{ismove = true,value = v})
	end

	--顺子
	-- printTable(fourtable)
	-- printTable(threetable)
	-- printTable(jiathreetable)
	-- printTable(shunzi)
	-- printTable(duizi)
	-- printTable(danzhang)
	local lostnumber = 10 - listtotoall
	local danzhangtotall = #danzhang
	local index = 0
	while danzhangtotall > 0 do
		local number = math.ceil(danzhangtotall/lostnumber)
		local localtable = {}
		for i=1,number do
			table.insert(localtable,danzhang[index+i])
		end
		index = index + number
		table.insert(listtable,{ismove = true,value = localtable})
		danzhangtotall = danzhangtotall - number
	end
	return listtable
end


function ComHelpFuc.selectall(list,defaut,callback)
	local function sele( sender, eventType )
		if eventType == ccui.CheckBoxEventType.selected then
            for i,v in ipairs(list) do
                v:setSelected(false)
                v:setTouchEnabled(true)
                v:getChildByName("text"):setColor(cc.c3b(0x61,0x2f, 0x2a))
            end
            sender:setSelected(true)
            sender:setTouchEnabled(false)
            sender:getChildByName("text"):setColor(cc.c3b(0,133, 14))
            callback(sender:getTag())
        end
	end
	for i,v in ipairs(list) do
		v:addEventListener(sele)
	end
	sele(list[defaut], ccui.CheckBoxEventType.selected )
end

function ComHelpFuc.selectsingle(check,defaut,callback)

	local function selectedEvent15(sender, eventType)
        -- body
        if eventType == ccui.CheckBoxEventType.selected then
            callback(1)
        else
            callback(0)
        end
    end
    if defaut == 1 then
        check:setSelected(true)
    else
        check:setSelected(false)
    end
    check:addEventListener(selectedEvent15)
end