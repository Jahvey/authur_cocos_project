-- local Suanfucforddz = class("Suanfucforddz")
-- self.laizivalue = -1
-- self:isfivelai = false

local Suanfucforddz = class("RecordScene", require "app.ui.game_base_cdd.base.Suanfucforddz")


function Suanfucforddz:getlist(data)
	local listtable =  {}
	for i,v in ipairs(data) do
		local real = (v-1)%16+1
		
		if real == 2 then
			real = 15
		end

		if real == 3 then
			real = 16
		end

		if real == 14 then
			real = 14
		end
		if v == 0x51 then
			real = 17
		end
		if v == 0x52 then
			real = 18
		end


		if listtable[real] == nil then
			listtable[real] = {num= 1,real = real,values = {v}}
		else
			table.insert(listtable[real].values,v)
			listtable[real].num = listtable[real].num + 1
		end
	end
	for k,v in pairs(listtable) do
		table.sort(v.values,function(a,b)
			return a > b
		end)
	end
	return listtable
end
function Suanfucforddz:sort( data )
	local realtable = self:getlist(data)
	 table.sort(data,function(a,b)
	 	if self:getrealvalue( a ) > self:getrealvalue( b ) then
	 		return true
	 	elseif  self:getrealvalue( a ) == self:getrealvalue( b ) then
	 		return self:gethua(a) > self:gethua(b)
	 	else
	 		return false
	 	end
	 end)
end

function Suanfucforddz:sort1( data )
	local realtable = self:getlist(data)
	 table.sort(data,function(a,b)
	 	if self:gethua(a) > self:gethua(b) then
	 		return true
	 	elseif self:gethua(a) == self:gethua(b) then
	 		return self:getrealvalue( a ) > self:getrealvalue( b )
	 	else
	 		return false
	 	end
	 end)
end

function Suanfucforddz:sort2( data )
	local realtable = self:getlist(data)
	table.sort(data,function(a,b)
		if realtable[self:getrealvalue(a)].num > realtable[self:getrealvalue(b)].num then
			return true
		elseif realtable[self:getrealvalue(a)].num == realtable[self:getrealvalue(b)].num then
			if self:getrealvalue( a ) > self:getrealvalue( b ) then
				return true
			elseif self:getrealvalue( a ) == self:getrealvalue( b ) then
				return self:gethua(a) > self:gethua(b)
			else
				return false
			end
	 	else
	 		return false
	 	end
	 end)
	
end



function Suanfucforddz:isnotjoker( real)
	if real == 17 or real == 18 then
		return false
	end
	return true
end
function Suanfucforddz:getrealvalue( v )

	local real = (v-1)%16+1
		
		if real == 2 then
			real = 15
		end

		if real == 3 then
			real = 16
		end
		if real == 14 then
			real = 14
		end
		if v == 0x51 then
			real = 17
		end
		if v == 0x52 then
			real = 18
		end
		return real
end

function Suanfucforddz:gettonghuarealvalue( v )

	local real = (v-1)%16+1
		
		if real == 2 then
			real = 2
		end

		if real == 3 then
			real = 3
		end
		if real == 14 then
			real = 14
		end
		if real == 15 then
			real = 2
		end
		if real == 16 then
			real = 3
		end

		if v == 0x51 then
			real = 17
		end
		if v == 0x52 then
			real = 18
		end
		return real
end


function Suanfucforddz:getmaxhua(data)
	-- body
	local maxhua = 0
	for i,v in ipairs(data) do
		local hua = math.floor(v/16)
		if hua > maxhua then 
			maxhua = hua
		end
	end
	return maxhua
end

function Suanfucforddz:gethua(card)
	-- body
	return math.floor(card/16)
end

-- 1单张 2 单对 3 顺子  4 连队  5 3带一 6飞机 7 四带二 8炸弹 
function Suanfucforddz:getype(data,isall)
	print("============================父类")
	local totall= #data
	if totall == 1 then
		return {type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = self:getrealvalue(data[1]),num = self:getmaxhua(data)}
	end

	if totall == 2 then
		if self:getrealvalue(data[1])  == self:getrealvalue(data[2]) then
			return {type= poker_common_pb.EN_POKER_TYPE_PAIR,real =self:getrealvalue(data[1]),num = self:getmaxhua(data)}
		end
		return
	end
	local realtable = self:getlist(data)

	if totall == 3 then
		local realindex = nil
		local isdan = true 
		for k,v in pairs(realtable) do
			if v.num ==3 then
				return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real =k,num =3 ,islai = false}
			end
		end
	end
	if totall == 4 then
		local realindex = nil
		local isdan = true 
		for k,v in pairs(realtable) do
			if v.num == 4 then
				return {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE,real =k,num =3 ,islai = false}
			end
		end
	end
	-- local lainum = self:getlaizinum(realtable)
	local cantable = {}

	local realvaluetable = {}
	for k,v in pairs(realtable) do
		if self:islai( v.values[1]  ) == false then
			table.insert(realvaluetable,v.real)
		end
	end
	local lainum = self:getlaizinum(realtable)
	realtable[self.laizivalue] = nil
	table.sort(realvaluetable)


	if totall == 5 then
		printTable(realvaluetable,"sjp3")

		-- 同花
		local huase = 0
		local istonghua = true
		for i,v in ipairs(data) do
			if huase == 0 then
				huase = math.floor(v/16)
			elseif huase ~= math.floor(v/16) then
				istonghua = false
			end
		end
		print("同花1")
		if istonghua then
			print("同花2")
			
			local reallocal = 0
			for i,v in ipairs(realvaluetable) do
				if self:gettonghuarealvalue( v ) > reallocal then
					reallocal = self:gettonghuarealvalue( v )
				end
			end
			print("reallocal:"..reallocal)
			table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TONGHUA,real = reallocal,num = huase})
		end
		--顺子
		if realvaluetable[1] then
			print("shunzi")
			if realvaluetable[1] > 10 then
			else
				local islian = true
				if realtable[16] == nil and  realtable[15] == nil then
					for i=1,5 do
						if realtable[realvaluetable[1]+i-1] then
						else
							islian =false
						end
					end
					if islian then
						printTable(realvaluetable,"sjp3")
						if istonghua then
							return {type= poker_common_pb.EN_POKER_TYPE_TONGHUASHUN,real =realvaluetable[1],num = huase}
						else
							return {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =realvaluetable[1],num = math.floor(realtable[realvaluetable[5]].values[1]/16)}
						end
					end
				else
					if realtable[15] == nil then
						if realtable[16] and realtable[4] and  realtable[5] and realtable[6] and realtable[7] then
							if istonghua then
								return {type= poker_common_pb.EN_POKER_TYPE_TONGHUASHUN,real =3,num = huase}
							else
								return {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =3,num = math.floor(realtable[7].values[1]/16)}
							end
						end
					else
						if realtable[14] then
							if realtable[14] and realtable[15] and  realtable[16] and realtable[4] and realtable[5] then
								if istonghua then
									return {type= poker_common_pb.EN_POKER_TYPE_TONGHUASHUN,real =1,num = huase}
								else
									return {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =1,num = math.floor(realtable[5].values[1]/16)}
								end
							end
						else
							if realtable[15] and  realtable[16] and realtable[4] and realtable[5] and realtable[6] then
								if istonghua then
									return {type= poker_common_pb.EN_POKER_TYPE_TONGHUASHUN,real =2,num = huase}
								else
									return {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =2,num = math.floor(realtable[6].values[1]/16)}
								end
							end
						end
					end
				end
			end
		end

		
		
		if #realvaluetable == 2 then
			--三代二
			-- print("sandaier ")
			-- printTable(realtable,"sjp3")
			if realtable[realvaluetable[1]].num == 3 then
				if realtable[realvaluetable[2]].num == 2 then
					return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real =realvaluetable[1]}
				end
			elseif realtable[realvaluetable[1]].num == 2 then
				if realtable[realvaluetable[2]].num == 3 then
					return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real =realvaluetable[2]}
				end
			end


			--三代二
			if realtable[realvaluetable[1]].num == 4 then
				if realtable[realvaluetable[2]].num == 1 then
					return {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE,real =realvaluetable[1]}
				end
			elseif realtable[realvaluetable[1]].num == 1 then
				if realtable[realvaluetable[2]].num == 4 then
					return {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE,real =realvaluetable[2]}
				end
			end

		else

		end
		

		if #cantable == 0  then
			return nil
		elseif #cantable == 1 then
			return cantable[1]
		else
		 	return  cantable
		end
	else
		return nil
	end
	return nil
end


function Suanfucforddz:getfivereal(type)
	-- body
	if type == poker_common_pb.EN_POKER_TYPE_TONGHUA then
		return 2
	elseif type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		return 1
	elseif type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO then
		return 3
	elseif type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE then
		return 4
	elseif type == poker_common_pb.EN_POKER_TYPE_TONGHUASHUN then
		return 5
	end
end

function Suanfucforddz:comparetype(lastaction,actions)
	local cantable = {}
	if lastaction.num == nil then
		lastaction.num = 0
	end
	for i,v in ipairs(actions) do

		if lastaction.type == v.type then
			if lastaction.type ~= poker_common_pb.EN_POKER_TYPE_TONGHUA and lastaction.type ~= poker_common_pb.EN_POKER_TYPE_TONGHUASHUN then
				if v.real > lastaction.real then
					table.insert(cantable,v)
				elseif v.real == lastaction.real then
					if v.num > lastaction.num then
						table.insert(cantable,v)
					end
				end
			else
				if v.num > lastaction.num then
					table.insert(cantable,v)
				elseif v.num == lastaction.num then
					if v.real > lastaction.real then
						table.insert(cantable,v)
					end
				end
			end
		else
			if lastaction.type > 2 and lastaction.type ~= poker_common_pb.EN_POKER_TYPE_TRIPLE and lastaction.type ~= poker_common_pb.EN_POKER_TYPE_QUADRUPLE then
				if self:getfivereal(lastaction.type) < self:getfivereal(v.type) then
					table.insert(cantable,v)
				end
			end
		end
	end
	return cantable
end







function Suanfucforddz:gettips(data,action)

	local realtable = self:getlist(data)
	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #data
	


	local cantable = {}
	local realvaluetable = {}
	for k,v in pairs(realtable) do
		if self:islai( v.values[1]  ) == false then
			table.insert(realvaluetable,v)
		end
	end
	table.sort(realvaluetable,function(a,b)
		if a.num == b.num then
		
			return a.real < b.real
		elseif  a.num > b.num then
			return false
		else
			return true
		end
	end)
	if action.type == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD then
		
		printTable(realvaluetable)

		for i,v in ipairs(realvaluetable) do
			if v.num == 1 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]},num = self:getmaxhua(v.values)})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]},num = self:getmaxhua(v.values)})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]},num = self:getmaxhua(v.values)})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 4 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]},num = self:getmaxhua(v.values)})
			end
		end

		return cantable
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		if totall < 2 then
			return {}
		end
		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]},num = self:getmaxhua(v.values)})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]},num = self:getmaxhua(v.values)})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 4 and (v.real > action.real or (v.real == action.real and self:getmaxhua(v.values) > action.num)) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]},num = self:getmaxhua(v.values)})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE then
		for k,v in pairs(realtable) do
			if v.num == 3 and v.real > action.real then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE,real = v.real,values = {v.values[1],v.values[2],v.values[3]},num = 0})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE then

		for k,v in pairs(realtable) do
			if v.num == 4 and v.real > action.real then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_QUADRUPLE,real = v.real,values = {v.values[1],v.values[2],v.values[3],v.values[4]},num = 0})
			end
		end

	else 
		if self:getfivereal(poker_common_pb.EN_POKER_TYPE_STRAIGHT)  >= self:getfivereal(action.type) then
			--找顺子
			for i=1,10 do
				local values  = {}
				local isshun = true
				for j=1,5 do
					local index = i+j-1
					if index <= 3 then
						index = index + 13
					end
					if realtable[index] and realtable[index].num > 0 then
						table.insert(values,realtable[index].values[1])
					else
						isshun =false
					end
				end
				if isshun then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = i,values =values,num = math.floor(values[5]/16)})
				end
			end
		end
		local huasetab = {}
		for i,v in ipairs(data) do
			local hua = math.floor(v/16)
			if huasetab[hua] == nil then
				huasetab[hua] = {}
			end
			table.insert(huasetab[hua],v)
		end

		if self:getfivereal(poker_common_pb.EN_POKER_TYPE_TONGHUA)  >= self:getfivereal(action.type) then
			--同花
			for k,v in pairs(huasetab) do
				local totall = #v
				if totall >= 5 then
					--local tab  = clone(v)
					table.sort(v,function(a,b)
						return self:getrealvalue(a) < self:getrealvalue(b)
					end)
					
					for i=1,totall-4 do
						local values = {}
						local reallocal = 0
						for j=1,5 do
							table.insert(values,v[i+j -1])
							if self:gettonghuarealvalue( v[i+j -1] ) > reallocal then
								reallocal = self:gettonghuarealvalue( v[i+j -1] )
							end
						end
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TONGHUA,real = reallocal,values =values,num = k})
					end
				end
			end

		end

		if self:getfivereal(poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO)  >= self:getfivereal(action.type) then
			--3带2
			-- for k,v in pairs(realtable) do
			-- 	print(k,v)
			-- end
			print("sandaier ")
			printTable(realtable,"sjp3")
			local function finddouble(real)
				for i=4,16 do
					if realtable[i] and realtable[i].num == 2 and i ~= real then
						return i
					end
				end

				for i=4,16 do
					if realtable[i] and realtable[i].num == 3 and i ~= real then
						return i
					end
				end
				return nil
			end
			for i=4,16 do
				if realtable[i] and realtable[i].num == 3 then
					local doulbevalue = finddouble(i)
					if doulbevalue then
						local values = {}
						values = {realtable[i].values[1],realtable[i].values[2],realtable[i].values[3],realtable[doulbevalue].values[1],realtable[doulbevalue].values[2]}
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real = i,values = values})
					end
				end
			end
		end

		if self:getfivereal(poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE)  >= self:getfivereal(action.type) then
			local function finddouble(real)
				for i=4,16 do
					if realtable[i] and realtable[i].num == 1 and i ~= real then
						return i
					end
				end

				for i=4,16 do
					if realtable[i] and realtable[i].num == 2 and i ~= real then
						return i
					end
				end
				for i=4,16 do
					if realtable[i] and realtable[i].num == 3 and i ~= real then
						return i
					end
				end
				for i=4,16 do
					if realtable[i] and realtable[i].num == 4 and i ~= real then
						return i
					end
				end
				return nil
			end
			for i=4,16 do
				if realtable[i] and realtable[i].num == 4 then
					local doulbevalue = finddouble(i)
					if doulbevalue then
						local values = {}
						values = {realtable[i].values[1],realtable[i].values[2],realtable[i].values[3],realtable[i].values[4],realtable[doulbevalue].values[1]}
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE,real = i,values = values})
					end
				end
			end
		end

		if self:getfivereal(poker_common_pb.EN_POKER_TYPE_TONGHUASHUN)  >= self:getfivereal(action.type) then
			for k,v in pairs(huasetab) do
				local totall = #v
				if totall >= 5 then
					--local tab  = clone(v)
					table.sort(v,function(a,b)
						return self:getrealvalue(a) < self:getrealvalue(b)
					end)
					local real1tab = {}
					for i1,v1 in ipairs(v) do
						local realvalue = self:getrealvalue(v1)
						real1tab[realvalue] = v1
					end
					for i=1,10 do
						local values  = {}
						local isshun = true
						for j=1,5 do
							local index = i+j-1
							if index <= 3 then
								index = index + 13
							end
							if real1tab[index] then
								table.insert(values,real1tab[index])
							else
								isshun =false
							end
						end
						if isshun then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TONGHUASHUN,real = i,values =values,num = math.floor(values[5]/16)})
						end
					end
				end
			end
		end

	end
	printTable(cantable,"sjp3")
	return self:comparetype(action,cantable)
end


function Suanfucforddz:getrealcardsTab(cards,action)
	local realtable = self:getlist(cards)
	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #cards
	
	if realtable[self.laizivalue] then
		for i=1,realtable[self.laizivalue].num do
			table.insert(laizitable,realtable[self.laizivalue].values[i])
		end
	end

	if realtable[18] then
		for i=1,realtable[18].num do
			table.insert(laizitable,0x66)
		end
	end
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
		if self:islai( v.values[1]  ) == false then
			table.insert(realvaluetable,v)
		end
	end
	table.sort(realvaluetable,function(a,b)
		return a.num > b.num
	end)

	local cardslist = {}
	if action.type == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD then
		table.insert(cardslist,{value = cards[1],islai =false})

	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then

		for i=1,2 do
			table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO then
		for k,v in pairs(realtable) do
			if v.num == 3 then
				for i=1,3 do
					table.insert(cardslist,{value =v.values[i],islai =false})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num == 2 then
				for i=1,2 do
					table.insert(cardslist,{value =v.values[i],islai =false})
				end
			end
		end

		
	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_ONE then
		for k,v in pairs(realtable) do
			if v.num == 4 then
				for i=1,4 do
					table.insert(cardslist,{value =v.values[i],islai =false})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num == 1 then
				for i=1,1 do
					table.insert(cardslist,{value =v.values[i],islai =false})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TONGHUA then
		table.sort(cards,function(a,b)
			-- body
			return self:gettonghuarealvalue(a) > self:gettonghuarealvalue(b)
		end)
		for i,v in ipairs(cards) do
			table.insert(cardslist,{value =v,islai =false})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		for i=1,5 do
			local realbegin = i + action.real - 1
			if realbegin <  4 then
				realbegin = realbegin + 13
			end
			table.insert(cardslist,{value =realtable[realbegin].values[1],islai =false})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TONGHUASHUN then
		for i=1,5 do
			local realbegin = i + action.real - 1
			if realbegin <  4 then
				realbegin = realbegin + 13
			end
			table.insert(cardslist,{value =realtable[realbegin].values[1],islai =false})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE then
		for i,v in ipairs(cards) do
			table.insert(cardslist,{value =v,islai =false})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE then
		for i,v in ipairs(cards) do
			table.insert(cardslist,{value =v,islai =false})
		end
	end
	print("111111222")
	printTable(cardslist,"sjp10")
	return cardslist
end

function Suanfucforddz:selectStraight(pokers,handcards)
	-- if #pokers < 5 then
	-- 	return
	-- end

	-- -- <16
	-- local index = 1
	-- local indextable = {}
	-- local num = 0
	-- print("self.laizivalue",self.laizivalue)
	-- while (index<=#pokers) do
	-- 	printTable(indextable)
	-- 	if self:getrealvalue(pokers[index]:getPoker()) < 15 and self:getrealvalue(pokers[index]:getPoker()) ~= self.laizivalue then
	-- 		if index == 1 then
	-- 			-- table.insert(indextable,pokers[index])
	-- 			indextable[index] = true
	-- 			num = num + 1
	-- 		else
	-- 			if self:getrealvalue(pokers[index]:getPoker()) - self:getrealvalue(pokers[index-1]:getPoker()) == 1 then
	-- 				-- table.insert(indextable,pokers[index])
	-- 				indextable[index] = true
	-- 				num = num + 1
	-- 			elseif self:getrealvalue(pokers[index]:getPoker()) == self:getrealvalue(pokers[index-1]:getPoker()) then
	-- 			else
	-- 				if num >=5 then
	-- 					break
	-- 				end
	-- 				indextable = {}
	-- 				num = 0
	-- 				-- table.insert(indextable,pokers[index])
	-- 				indextable[index] = true
	-- 				num = num + 1
	-- 			end
	-- 		end
			
	-- 	else
	-- 		if num >=5 then
	-- 			break
	-- 		else
	-- 			indextable = {}
	-- 			num = 0
	-- 		end
	-- 	end
	-- 	index = index + 1
	-- end
	-- printTable(indextable)
	-- print(num)
	-- if num >= 5 then
	-- 	for i,v in ipairs(handcards) do
	-- 		v:setSelected(false)
	-- 	end
	-- 	for i,v in ipairs(pokers) do
	-- 		if indextable[i] then
	-- 			v:setSelected(true)
	-- 		else
	-- 			v:setSelected(false)
	-- 		end
	-- 	end
	-- end
end

return Suanfucforddz