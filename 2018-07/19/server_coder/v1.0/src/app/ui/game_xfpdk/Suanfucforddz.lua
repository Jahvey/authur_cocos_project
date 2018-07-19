local Suanfucforddz = class("RecordScene", require "app.ui.game_base_cdd.base.Suanfucforddz")

local Card_Type_Weight = {
	[poker_common_pb.EN_POKER_TYPE_BOMB] = 1,
	[poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN] = 2,
}

function Suanfucforddz:ctor(_scene)
	self.gamescene = _scene

end

-- 获取牌的大小值
-- 3-10  j:11 q:12 k:13 A:14 2:15
function Suanfucforddz:getCardWeight(value)
	local real = (value-1)%16+1
		
	if real == 2 then
		real = 15
	end
	if real == 14 then
		real = 14
	end
	if v == 0x51 then
		real = 16
	end
	if v == 0x52 then
		real = 17
	end

	if v == 0x66 then
		real = 18
	end
	return real
end

-- 重构数据
-- 输出示例: {{weight = 3,num = 2,cards = {3,19}},{weight = 4,num = 1,values = {4}},}
function Suanfucforddz:reconsitutionData(data)
	local maps = {}
	for i,v in ipairs(data) do
		local weight = Suanfucforddz:getCardWeight(v)
		if not maps[weight] then
			maps[weight] = {weight = weight,num = 0,values = {}}
		end
		table.insert(maps[weight].values,v)
		maps[weight].num = maps[weight].num + 1
	end

	local output = {}
	for k,v in pairs(maps) do
		table.insert(output,v)
	end
	table.sort(output,function (a,b)
		-- return a.weight == b.weight and a.num < b.num or a.weight < b.weight
		return a.num == b.num and a.weight < b.weight or a.num < b.num
		-- if a.num == b.num then
		-- 	return a.weight < b.weight
		-- else
		-- 	return a.num < b.num
		-- end
	end)

	return output
end

-- 传入参数
-- typ 牌型
-- 返回值
-- uppertype 可出牌型表 例:{poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,poker_common_pb.EN_POKER_TYPE_BOMB}
function Suanfucforddz:getUpperCardType(typ)
	local uppertype = {}

	-- if not Card_Type_Weight[typ] then
	-- 	table.insert(uppertype,typ)
	-- end

	for k,v in pairs(Card_Type_Weight) do
		if v > (Card_Type_Weight[typ] or 0) then
			table.insert(uppertype,k)
		end
	end
	
	table.sort(uppertype,function (a,b)
		return  (Card_Type_Weight[a] or 0) < (Card_Type_Weight[b] or 0)
	end)

	return uppertype
end

function Suanfucforddz:getUsableCardType(typ)
	local usabletype = Suanfucforddz:getUpperCardType(typ)

	local isinclude = false
	for i,v in ipairs(usabletype) do
		if v == typ then
			isinclude = true
		end
	end

	if not isinclude then
		table.insert(usabletype,1,typ)
	end

	return usabletype
end

function Suanfucforddz:getIsEquativeType(lastgroup,curgroup)
	return lastgroup.type == curgroup.type
end

-- 通用比牌方法
-- action {type = ,real = , num = ,}
function Suanfucforddz:commonCompare(lastgroup,curgroup)
	local uppertype = Suanfucforddz:getUpperCardType(lastgroup.type)

	-- 检验是否为上级牌型，如果是，则返回true
	for i,v in ipairs(uppertype) do
		if v == curgroup.type then
			return true
		end
	end

	-- 检验是否为同级牌型
	if Suanfucforddz:getIsEquativeType(lastgroup,curgroup) then
		if lastgroup.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN and curgroup.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN then
			-- if lastgroup.num == curgroup.num then
			-- 	return lastgroup.real < curgroup.real
			-- else
			-- 	return lastgroup.num < curgroup.num
			-- end
			return lastgroup.num == curgroup.num and lastgroup.real < curgroup.real or lastgroup.num < curgroup.num
		else
			return lastgroup.num == curgroup.num and lastgroup.real < curgroup.real
		end
	end

	return false
end

-- function Suanfucforddz:specialCompare(lastgroup,curgroup)
-- 	if lastgroup.type == poker_common_pb.EN_POKER_TYPE_BOMB and curgroup.type == poker_common_pb.EN_POKER_TYPE_BOMB then

-- 	end
-- end

function Suanfucforddz:comparetype(lastaction,groups)
	local output = {}

	for i,v in ipairs(groups) do
		if Suanfucforddz:commonCompare(lastaction,v) then
			table.insert(output,v)
		end
	end

	return output
end

function Suanfucforddz:insertDataToTable(data1,data2)
	for i,v in ipairs(data2 or {}) do
		table.insert(data1,v)
	end
end

function Suanfucforddz:getIsSingle(data,totalnum)
	local output = {}
	if totalnum == 1 then
		for i,v in ipairs(data) do
			if v.num == 1 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.weight,num = 1})
				return output
			end
		end
	end
	return nil
end

function Suanfucforddz:getIsPair(data,totalnum)
	local output = {}
	if totalnum == 2 then
		for i,v in ipairs(data) do
			if v.num == 2 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_PAIR,real = v.weight,num = 1})
				return output
			end
		end
	end
	return nil
end

function Suanfucforddz:getisTriple(data,totalnum)
	local output = {}
	if totalnum == 3 then
		for i,v in ipairs(data) do
			if v.num == 3 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real = v.weight,num = 1})
				return output
			end
		end
	end
	return nil
end

function Suanfucforddz:getisTripleWithOne(data,totalnum)
	local output = {}
	if totalnum == 4 then
		for i,v in ipairs(data) do
			if v.num == 3 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = v.weight,num = 1})
				return output
			end
		end
	end
	return nil
end

function Suanfucforddz:getisTripleWithTwo(data,totalnum)
	local output = {}
	if totalnum == 5 then
		for i,v in ipairs(data) do
			if v.num == 3 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real = v.weight,num = 1})
				return output
			end
		end
	end
	return nil
end

function Suanfucforddz:getIsBomb(data,totalnum)
	local output = {}
	if totalnum == 4 then
		for i,v in ipairs(data) do
			if v.num == 4 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_BOMB,real = v.weight,num = 1})
				return output
			end
		end
	end

	return output
end

function Suanfucforddz:getIsGunlongBomb(data,totalnum)
	local output = {}

	if totalnum%4 == 0 and totalnum/4 == #data then
		if totalnum/4 > 1 then
			if data[#data].weight < 14 then
				if data[#data].weight - data[1].weight == totalnum/4 - 1 then
					table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN,real = data[1].weight,num = totalnum/4})
				end
			end
		end
	end
	
	return output
end

function Suanfucforddz:getIsStraight(data,totalnum)
	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	local output = {}
	if totalnum >= 5 and #data == totalnum then
		local begin = data[1].weight
		local ed = data[#data].weight
		if ed <= 14 and (ed - begin == (#data - 1)) then
			table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = begin,num = totalnum})
			return output
		end
	end
	return nil
end

function Suanfucforddz:getIsStraight2(data,totalnum)
	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	local output = {}
	if totalnum >= 4 and #data == totalnum/2 then
		local begin = data[1].weight
		local ed = data[#data].weight
		if ed <= 14 and (ed - begin == (#data - 1)) then
			for i,v in ipairs(data) do
				if v.num ~= 2 then
					return nil
				end
			end
			table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = begin,num = totalnum/2})
			return output
		end
	end
	return nil
end

function Suanfucforddz:getIsStraight3_2(data,totalnum)
	local output = {}

	if totalnum >= 10 and totalnum%5 == 0 then
		data = clone(data)
		for i=#data,1,-1 do
			if data[i].num < 3 then
				table.remove(data,i)
			end
		end

		table.sort(data,function (a,b)
			return a.weight > b.weight
		end)

		if #data == totalnum/5 then
			if data[1].weight <= 14 and data[1].weight - data[#data].weight == totalnum/5 - 1 then
				table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2,real = data[#data].weight,num = totalnum/5})
			end 
		end

		return output
	end

	return nil
end

function Suanfucforddz:getIsStraight3_4(data,totalnum)
	local output = {}

	data = clone(data)

	for i=#data,1,-1 do
		if data[i].num < 3 then
			table.remove(data,i)
		end
	end

	table.sort(data,function (a,b)
		return a.weight > b.weight
	end)

	if #data >= 2 and #data*5 > totalnum then
		if data[1].weight <= 14 and data[1].weight - data[#data].weight == #data - 1 then
			table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_4,real = data[#data].weight,num = #data})
		end 
	end

	return output
end

function Suanfucforddz:getisQuadrupleWithOne(data,total)
	local output = {}

	if total == 5 then
		for i,v in ipairs(data) do
			if v.num == 4 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE,real = v.weight,num = 1})
			end
		end
	end

	return output
end

function Suanfucforddz:getisQuadrupleWithTwo(data,total)
	local output = {}

	if total == 6 then
		for i,v in ipairs(data) do
			if v.num == 4 then
				table.insert(output,{type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO,real = v.weight,num = 1})
			end
		end
	end

	return output
end

function Suanfucforddz:getype(data,isall)
	-- print(#data)
	-- print(data)
	-- printTable(data,"xp68")
	local total = #data

	if total == 0 then
		return nil
	end

	-- 重构数据
	local redata = Suanfucforddz:reconsitutionData(data)

	local usabletable = {}

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsSingle(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsPair(redata,total))

	if isall then
		Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getisTriple(redata,total))
		Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getisTripleWithOne(redata,total))
		Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getisQuadrupleWithOne(redata,total))
		Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getisQuadrupleWithTwo(redata,total))
		Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsStraight3_4(redata,total))
	end

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getisTripleWithTwo(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsBomb(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsGunlongBomb(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsStraight(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsStraight2(redata,total))

	Suanfucforddz:insertDataToTable(usabletable,Suanfucforddz:getIsStraight3_2(redata,total))

	printTable(usabletable,"xp")

	if #usabletable > 1 then
		return usabletable
	elseif #usabletable == 1 then
		return usabletable[1]
	end
	return nil
end

function Suanfucforddz:getAllSingle(data)
	local output = {}
	for i,v in ipairs(data) do
		table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.weight,values = {v.values[1]},num = 1})
	end

	return output
end

function Suanfucforddz:getAllPair(data)
	local output = {}
	for i,v in ipairs(data) do
		if v.num >= 2 then
			table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.weight,values = {v.values[1],v.values[2]},num = 1})
		end
	end

	return output
end

function Suanfucforddz:getAllTripleWithTwo(data)
	local output = {}

	local function gettwo(real)
		local twovalues = {}

		for i,v in ipairs(data) do
			if v.weight ~= real and v.num <= 3 then
				table.insert(twovalues,v.values[1])
				if #twovalues == 2 then
					return twovalues
				end
			end
		end

		return false
	end

	for i,v in ipairs(data) do
		if v.num == 3 then
			local twovalues = gettwo(v.weight)

			if twovalues then
				table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real = v.weight,values = {v.values[1],v.values[2],v.values[3],twovalues[1],twovalues[2]},num = 1})
			end
		end
	end

	return output
end

function Suanfucforddz:getAllStraight(data,length)
	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	local output = {}

	for i,v in ipairs(data) do
		if v.weight <= 14 - length + 1 then
			if data[i+length-1] and data[i+length-1].weight - v.weight == length - 1 then
				local values = {}
				for m=i,i+length-1 do
					table.insert(values,data[m].values[1])
				end

				table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = v.weight,values = values,num = length})
			end
		end
	end

	return output
end

function Suanfucforddz:getAllStraight2(data,length)
	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	for i=#data,1,-1 do
		if data[i].num <= 1 then
			table.remove(data,i)
		end
	end

	local output = {}

	for i,v in ipairs(data) do
		if v.weight <= 14 - length + 1 then
			if data[i+length-1] and data[i+length-1].weight - v.weight == length - 1 then
				local values = {}
				for m=i,i+length-1 do
					table.insert(values,data[m].values[1])
					table.insert(values,data[m].values[2])
				end

				table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = v.weight,values = values,num = length})
			end
		end
	end

	return output
end

function Suanfucforddz:getAllStraight3_2(data,length)
	-- if #data < length*5 then
	-- 	return {}
	-- end

	local origindata = clone(data)
	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	for i=#data,1,-1 do
		if data[i].num <= 2 then
			table.remove(data,i)
		end
	end

	local output = {}

	local maintable = {}

	for i,v in ipairs(data) do
		if v.weight <= 14 - length + 1 then
			if data[i+length-1] and data[i+length-1].weight - v.weight == length - 1 then
				local values = {}
				local weights = {}
				for m=i,i+length-1 do
					table.insert(values,data[m].values[1])
					table.insert(values,data[m].values[2])
					table.insert(values,data[m].values[3])
					table.insert(weights,v.weight)
				end

				-- table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real = v.weight,values = values})
				table.insert(maintable,{values = values,weights = weights})
			end
		end
	end

	for i,v in ipairs(maintable) do
		local attachtable = {}
		for m,n in ipairs(origindata) do
			local issame = false
			for _i,_v in ipairs(v.weights) do
				if _v == n.weight then
					issame = true
				end
			end

			if not issame then
				for _i=1,n.num do
					table.insert(attachtable,n.values[_i])
					if #attachtable == length*2 then
						local values = {}
						for _,_value in ipairs(v.values) do
							table.insert(values,_value)
						end
						for _,_value in ipairs(attachtable) do
							table.insert(values,_value)
						end
						table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2,real = v.weights[1],values = values,num = length})
						break
					end
				end
			end
		end
	end

	return output
end

function Suanfucforddz:getAllBomb(data)
	local output = {}

	
	-- local length = 0
	-- if length == 1 then
	-- 	for i,v in ipairs(data) do
	-- 		if v.num >= 4 then
	-- 			table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_BOMB,real = v.weight,values = v.values,num = 1})
	-- 		end
	-- 	end
	-- else

	data = clone(data)
	table.sort(data,function (a,b)
		return a.weight < b.weight
	end)

	for i=#data,1,-1 do
		if data[i].num <= 3 then
			table.remove(data,i)
		end
	end

	for length=1,4 do
		for i,v in ipairs(data) do
			if v.weight <= 14 - length + 1 then
				if data[i+length-1] and data[i+length-1].weight - v.weight == length - 1 then
					local values = {}
					for m=i,i+length-1 do
						table.insert(values,data[m].values[1])
						table.insert(values,data[m].values[2])
						table.insert(values,data[m].values[3])
						table.insert(values,data[m].values[4])
					end

					if length == 1 then
						table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_BOMB,real = v.weight,values = values,num = length})
					else
						table.insert(output,{type = poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN,real = v.weight,values = values,num = length})
					end
				end
			end
		end
	end

	-- end

	return output
end


function Suanfucforddz:gettips(data,action)
	local output = {}

	local usabletypetable = Suanfucforddz:getUsableCardType(action.type)
	printTable(usabletypetable,"xp")
	-- 重构数据
	local redata = Suanfucforddz:reconsitutionData(data)
	printTable(redata,"xp")

	for i,v in ipairs(usabletypetable) do
		if v == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllSingle(redata))
		elseif v == poker_common_pb.EN_POKER_TYPE_PAIR then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllPair(redata))
		elseif v == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllTripleWithTwo(redata))
		elseif v == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllStraight(redata,action.num))
		elseif v == poker_common_pb.EN_POKER_TYPE_STRAIGHT_2 then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllStraight2(redata,action.num))
		elseif v == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllStraight3_2(redata,action.num))
		elseif v == poker_common_pb.EN_POKER_TYPE_BOMB or v == poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN then
			Suanfucforddz:insertDataToTable(output,Suanfucforddz:getAllBomb(redata,action))
		end
	end

	printTable(output,"xp")

	for i=#output,1,-1 do
		if not Suanfucforddz:commonCompare(action,output[i]) then
			table.remove(output,i)
		end
	end

	printTable(output,"xp")
	return output
end

function Suanfucforddz:getrealcardsTab(cards,action)
	local realtable = Suanfucforddz:getlist(cards)
	local laizitable = {}
	local lainum = 0
	local totall = #cards
	
	local function setvalue(value,real)
		local type = math.floor(value /16)
		if type > 5 then
			type = 1
		end
		local num = real
		if real  == 15 then
			num = 2
		elseif real == 16 then
			return 0x51
		elseif real == 17 then
			return 0x52
		end
		return type*16+num
	end
	local realvaluetable = {}
	for k,v in pairs(realtable) do
		if Suanfucforddz:islai( v.values[1]  ) == false then
			table.insert(realvaluetable,v)
		end
	end
	table.sort(realvaluetable,function(a,b)
		return a.num > b.num
	end)

	local cardslist = {}
	if action.type == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD then
		if realtable[action.real]~= nil  then
			table.insert(cardslist,{value = cards[1],islai =false})
		else
			table.insert(cardslist,{value = setvalue(cards[1],action.real),islai =true})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		local laiindex = 0
		for i=1,2 do
			if realtable[action.real] and realtable[action.real].num >= i then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE then
		local laiindex = 0
		for i=1,3 do
			if realtable[action.real] and realtable[action.real].num >= i then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE then
		local laiindex = 0
		for i=1,3 do
			if realtable[action.real] and realtable[action.real].num >= i then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
			end
		end
		for i=1,(lainum - laiindex) do
			table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO then
		for i=1,3 do
			table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
		end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		local laiindex = 0
		printTable(laizitable,"sjp10")
		for i=action.real,(action.real+action.num-1) do
			if realtable[i] and realtable[i].num >= 1 then
				table.insert(cardslist,{value = realtable[i].values[1],islai =false})
			else
				laiindex = laiindex + 1
				print(laizitable[laiindex],i)
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_2 then
		local laiindex = 0
		printTable(laizitable,"sjp10")
		for i=action.real,(action.real+action.num-1) do
			for j=1,2 do
				if realtable[i] and realtable[i].num >= j then
					table.insert(cardslist,{value = realtable[i].values[j],islai =false})
				else
					laiindex = laiindex + 1
					print(laiindex)
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 then
		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			for j=1,3 do
				if realtable[i] and realtable[i].num >= j then
					table.insert(cardslist,{value = realtable[i].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
				end
			end
		end
		for i=1,(lainum - laiindex) do
			table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		end
		local function isreal(real)
			for i=action.real,(action.real+action.num-1) do
				if real == i then
					return false
				end
			end
			return true
		end
		for i,v in ipairs(realvaluetable) do
			if isreal(v.real) then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end

	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO then
		local laiindex = 0
		--for i=action.real,(action.real+action.num-1) do
			for j=1,4 do
				if realtable[action.real] and realtable[action.real].num >= j then
					table.insert(cardslist,{value = realtable[action.real].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
				end
			end
		--end
		for i=1,(lainum - laiindex) do
			table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_SOFT_BOMB or action.type == poker_common_pb.EN_POKER_TYPE_BOMB then
		local laiindex = 0
		--for i=action.real,(action.real+action.num-1) do
			for j=1,4 do
				if realtable[action.real] and realtable[action.real].num >= j then
					table.insert(cardslist,{value = realtable[action.real].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
				end
			end
		--end
		for i=1,(lainum - laiindex) do
			table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER or action.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER then
		local laiindex = 0
		printTable(realtable,"sjp10")
		printTable(laizitable)

		if realtable[17] then
			table.insert(cardslist,{value = realtable[17].values[1],islai =false})
		else
			laiindex = laiindex + 1
			table.insert(cardslist,{value = setvalue(laizitable[laiindex],17),islai =true})
		end

		if realtable[16] then
			table.insert(cardslist,{value = realtable[16].values[1],islai =false})
		else
			laiindex = laiindex + 1
			table.insert(cardslist,{value = setvalue(laizitable[laiindex],16),islai =true})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_GUN then
		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			for j=1,4 do
				if realtable[i] and realtable[i].num >= j and self:islai(realtable[i].values[j]) == false then
					table.insert(cardslist,{value = realtable[i].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_4 then
		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			for j=1,3 do
				-- if realtable[i] and realtable[i].num >= j then
					table.insert(cardslist,{value = realtable[i].values[j],islai =false})
				-- else
				-- 	laiindex = laiindex + 1
				-- 	table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
				-- end
			end
		end
		-- for i=1,(lainum - laiindex) do
		-- 	table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		-- end
		local function isreal(real)
			for i=action.real,(action.real+action.num-1) do
				if real == i then
					return false
				end
			end
			return true
		end
		for i,v in ipairs(realvaluetable) do
			if isreal(v.real) then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE then
		-- local laiindex = 0
		--for i=action.real,(action.real+action.num-1) do
			for j=1,4 do
				table.insert(cardslist,{value = realtable[action.real].values[j],islai =false})
			end
		--end
		-- for i=1,(lainum - laiindex) do
		-- 	table.insert(cardslist,{value = laizitable[laiindex+i],islai =true})
		-- end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real then
				for i1,v1 in ipairs(v.values) do
					table.insert(cardslist,{value = v1,islai =false})
				end
			end
		end
	end

	printTable(cardslist,"sjp10")
	return cardslist
end

function Suanfucforddz:selectStraight(pokers,handcards)
	if #pokers < 5 then
		return
	end

	-- <16
	local index = 1
	local indextable = {}
	local num = 0
	while (index<=#pokers) do
		printTable(indextable)
		if Suanfucforddz:getrealvalue(pokers[index]:getPoker()) < 15 then
			if index == 1 then
				-- table.insert(indextable,pokers[index])
				indextable[index] = true
				num = num + 1
			else
				if Suanfucforddz:getrealvalue(pokers[index]:getPoker()) - Suanfucforddz:getrealvalue(pokers[index-1]:getPoker()) == 1 then
					-- table.insert(indextable,pokers[index])
					indextable[index] = true
					num = num + 1
				elseif Suanfucforddz:getrealvalue(pokers[index]:getPoker()) == Suanfucforddz:getrealvalue(pokers[index-1]:getPoker()) then
				else
					if num >=5 then
						break
					end
					indextable = {}
					num = 0
					-- table.insert(indextable,pokers[index])
					indextable[index] = true
					num = num + 1
				end
			end
			
		else
			if num >=5 then
				break
			else
				indextable = {}
				num = 0
			end
		end
		index = index + 1
	end
	printTable(indextable)
	print(num)
	if num >= 5 then
		for i,v in ipairs(handcards) do
			v:setSelected(false)
		end
		for i,v in ipairs(pokers) do
			if indextable[i] then
				v:setSelected(true)
			else
				v:setSelected(false)
			end
		end
	end
end

return Suanfucforddz