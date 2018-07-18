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

		if listtable[real] == nil then
			listtable[real] = {num= 1,real = real,values = {v}}
		else
			table.insert(listtable[real].values,v)
			listtable[real].num = listtable[real].num + 1
		end


	end
	return listtable
end
function Suanfucforddz:sort( data )
	local realtable = self:getlist(data)
	 table.sort(data,function(a,b)
	 	if self:getrealvalue( a ) > self:getrealvalue( b ) then
	 		return true
	 	elseif  self:getrealvalue( a ) == self:getrealvalue( b ) then
	 		return a > b
	 	else
	 		return false
	 	end
	 end)
end
function Suanfucforddz:isnotjoker( real)
	if real == 16 or real == 17 then
		return false
	end
	return true
end
function Suanfucforddz:getrealvalue( v )

	local real = (v-1)%16+1
		
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
		-- print("real")
		-- print(real,v)
		return real
end


function Suanfucforddz:islai( value )
	-- body
	print("self.laizivalue:"..self.laizivalue)
	if value ==0x66  or self.laizivalue == self:getrealvalue( value ) then
		return true
	else
		return false
	end
end
function Suanfucforddz:getlaizinum(tablelist)
	local num =  0

	if tablelist[18] then
		num = num + tablelist[18].num
	end
	if  tablelist[self.laizivalue] then
		num = num + tablelist[self.laizivalue].num
	end
	print("laizinum:"..num)
	return num
end
-- 1单张 2 单对 3 顺子  4 连队  5 3带一 6飞机 7 四带二 8炸弹 
function Suanfucforddz:getype(data,isall)
	print("============================父类")
	local totall= #data
	if totall == 1 then
		if self:getrealvalue(data[1]) == 18 then
			if isall then
				return {type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = 0}
			else
				return
			end
		else
			return {type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real =self:getrealvalue(data[1])}
		end
	end

	if totall == 2 then
		if self:getrealvalue(data[1])  == self:getrealvalue(data[2]) then
			return {type= poker_common_pb.EN_POKER_TYPE_PAIR,real =self:getrealvalue(data[1])}
		end
		

		if (self:getrealvalue(data[1]) == 16 and self:getrealvalue(data[2]) == 17) or (self:getrealvalue(data[1]) == 17 and self:getrealvalue(data[2]) == 16) then
			return {type= poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER,real =17}
		end
		-- if (self:getrealvalue(data[1]) == 17 or  self:getrealvalue(data[1]) == 16) and self:islai( data[2] ) then
		-- 	return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real =17,islai =true}
		-- end
		-- if (self:getrealvalue(data[2]) == 17 or  self:getrealvalue(data[2]) == 16) and self:islai( data[1] ) then
		-- 	return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real =17,islai =true}
		-- end
		if self:getrealvalue(data[1]) ~= 16 and self:getrealvalue(data[1]) ~= 17 and self:getrealvalue(data[2]) ~= 16 and self:getrealvalue(data[2]) ~= 17 then
			if self:islai(data[1]) or  self:islai(data[2]) then
				if self:islai(data[1]) and  self:islai(data[2]) then
					return {type= poker_common_pb.EN_POKER_TYPE_PAIR,real =self.laizivalue}
				elseif self:islai(data[1]) then
					return {type= poker_common_pb.EN_POKER_TYPE_PAIR,real =self:getrealvalue(data[2])}
				elseif self:islai(data[2]) then
					return {type= poker_common_pb.EN_POKER_TYPE_PAIR,real =self:getrealvalue(data[1])}
				end
			end
		end
		
		return
	end
	local realtable = self:getlist(data)

	if totall == 3 then
		local realindex = nil
		local isdan = true 
		for k,v in pairs(realtable) do
			if self:islai( v.values[1]  ) == false then
				if realindex == nil then
					realindex = v.real
				else
					isdan = false 
					break
				end
			end
		end
		if isdan then
			if realindex and self:isnotjoker(realindex) then
				return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real =realindex,num =3 }
			elseif self:isnotjoker(realindex) then
				return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real = self.laizivalue,num = 3}
			end
		end
		return
	end
	if totall == 4 then
		local realindex = nil
		local isdan = 0 
		printTable(realtable)
		local realvalues = {}

		for k,v in pairs(realtable) do
			if self:islai( v.values[1]  ) == false then
				isdan= isdan + 1
				table.insert(realvalues,k)
			end
		end
		if isdan == 0 then
			printTable(realtable,"sjp10")
			if realtable[18] and realtable[18].num >=1 then
				return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real =self.laizivalue,num = 4,islai = true}
			else
				return {type= poker_common_pb.EN_POKER_TYPE_BOMB_OF_LAIZI,real =self.laizivalue,num = 4,islai = false}
			end
		elseif isdan == 1 then
			if realtable[realvalues[1]].num == 4 and self:isnotjoker(realvalues[1]) then
				return {type= poker_common_pb.EN_POKER_TYPE_BOMB,real =realvalues[1],num = 4,islai = false}
			elseif self:isnotjoker(realvalues[1]) then
				return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real =realvalues[1],num = 4,islai = true}
			end
		elseif isdan == 2 then
			if self:isnotjoker(realvalues[1]) == false and self:isnotjoker(realvalues[2]) == false then
				return
			elseif self:isnotjoker(realvalues[1]) == false and realtable[realvalues[1]].num == 1 then
				return  {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[2],num = 4}
			elseif self:isnotjoker(realvalues[2]) == false and realtable[realvalues[2]].num == 1  then
				return  {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[1],num = 4}
			else
				if realtable[realvalues[1]].num == 1 and realtable[realvalues[2]].num == 1 then
					if realvalues[1] > realvalues[2] then
						return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[1],num = 4}
					else
						return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[2],num = 4}
					end
				elseif realtable[realvalues[1]].num == 1 then
					return  {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[2],num = 4}
				elseif realtable[realvalues[2]].num == 1 then
					return  {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real =realvalues[1],num = 4}
				end
			end
		else
			return 
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
	local lainumtable = nil
	if realtable[self.laizivalue] then
		lainumtable = realtable[self.laizivalue]
	end
	realtable[self.laizivalue] = nil
	table.sort(realvaluetable)


	if totall >= 5 then
		printTable(realvaluetable,"sjp4")
		--顺子

		print("shunzi")
		if realvaluetable[1] then
			local num = totall
			local begin = nil
			if (realvaluetable[1] + num -1) > 14 then
				begin = 14 - num + 1
			else
				begin = realvaluetable[1]
			end
			local needlaizi = 0
			local iscan = true
			for i=1,num do
				if realtable[begin + i - 1] and realtable[begin + i - 1].num == 1 then
					
				elseif realtable[begin + i - 1] and realtable[begin + i - 1].num >1 then
					print("1")
					iscan = false
				else
					needlaizi=  needlaizi + 1
				end
			end
			print("needlaizi:"..needlaizi)
			print("lainum:"..needlaizi)

			if iscan then
				print("2")
				if needlaizi <=lainum then
					print("yes")
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =begin,num = num})
				end
			end
		else
			if totall == 5 then
				return {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =10,num = 5}
			end
		end

		--连队

		if totall%2 == 0 and totall>=6 then
			local num = totall/2
			local begin = nil
			if (realvaluetable[1] + num -1) > 14 then
				begin = 14 - num + 1
			else
				begin = realvaluetable[1]
			end
			local needlaizi = 0
			local iscan = true
			for i=1,num do
				if realtable[begin + i - 1] and realtable[begin + i - 1].num <= 2 then
					needlaizi=  needlaizi + 2-realtable[begin + i - 1].num
				elseif realtable[begin + i - 1] and realtable[begin + i - 1].num >2 then
					iscan = false
				else
					needlaizi=  needlaizi + 2
				end
			end
			if iscan then
				if needlaizi <= lainum then
					table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real =begin,num = num})
				end
			end
		end

		--飞机1
		if totall%3 == 0  then
			local num = totall/3
			local begin = nil
			if (realvaluetable[1] + num -1) > 14 then
				begin = 14 - num + 1
			else
				begin = realvaluetable[1]
			end
			local needlaizi = 0
			local iscan = true
			for i=1,num do
				if realtable[begin + i - 1] and realtable[begin + i - 1].num <= 3 then
					needlaizi=  needlaizi + 3-realtable[begin + i - 1].num
				elseif realtable[begin + i - 1] and realtable[begin + i - 1].num >3 then
					iscan = false
				else
					needlaizi=  needlaizi + 3
				end
			end
			if iscan then
				if needlaizi <= lainum then
					--return  {type= 6,real =begin,num = num}
					table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real =begin,num = num})
				end
			end

		end
		--飞机加翅膀
		if totall%4 == 0  then
			print("飞机")
			local num = totall/4
			local canlocal = {}
			for i,v in ipairs(realvaluetable) do
				local begin = nil
				if (realvaluetable[i] + num -1) > 14 then
					begin = 14 - num + 1
				else
					begin = realvaluetable[i]
				end
				local needlaizi = 0
				local iscan = true
				for j=1,num do
					if realtable[begin + j - 1] and realtable[begin + j - 1].num <= 3 then
						needlaizi=  needlaizi + 3-realtable[begin + j - 1].num
					else
						needlaizi=  needlaizi + 3
					end
				end
				print(needlaizi,lainum)
				if iscan then
					if needlaizi<=lainum then
						--return  {type= 6,real =begin,num = num}
						table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_1,real =begin,num = num})
					end
				end
			end
			if #canlocal > 0 then
				table.insert(cantable, canlocal[#canlocal])
			end
		end

		--四带2
		if totall == 6  then
			--print("4dai2")
			printTable(realvaluetable)
			local canlocal = {}
			for i,v in ipairs(realvaluetable) do
				if realtable[realvaluetable[i]].num == 4 then
					if  realtable[18] == nil then
						table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO,real =realvaluetable[i]})
					end
				end
			end
			if #canlocal > 0 then
				table.insert(cantable, canlocal[#canlocal])
			end
			print("sidaier ")
			printTable(realtable,"sjp3")
			if lainumtable and lainumtable.num == 4 then
				if realtable[18] == nil then
					table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO,real = self.laizivalue})
				end
			end
		end

		if #cantable == 0  then
			return nil
		elseif #cantable == 1 then
			return cantable[1]
		else
		 	return  cantable
		end
	end
	return nil
end


function Suanfucforddz:comparetype(lastaction,actions)
	local cantable = {}
	if lastaction.num == nil then
		lastaction.num = 0
	end
	for i,v in ipairs(actions) do
		if v.num == nil then
			v.num = 0
		end
		if lastaction.type == v.type then
			if v.real > lastaction.real and v.num == lastaction.num then
				table.insert(cantable,v)
			end
		else
			if lastaction.type < poker_common_pb.EN_POKER_TYPE_SOFT_BOMB and v.type < poker_common_pb.EN_POKER_TYPE_SOFT_BOMB then
			elseif lastaction.type < poker_common_pb.EN_POKER_TYPE_SOFT_BOMB and  v.type >= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB then
				table.insert(cantable,v)
			elseif lastaction.type >= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB and  v.type < poker_common_pb.EN_POKER_TYPE_SOFT_BOMB then
			elseif lastaction.type >= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB and  v.type >= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB then	
				if v.type > lastaction.type then
					table.insert(cantable,v)
				end
			end
		end
	end
	return cantable
end







function Suanfucforddz:havedoubleJoker( realtable )
	if realtable[16] and realtable[17] and realtable[16].num > 0 and realtable[17].num>0 then
		return true
	end
end
function Suanfucforddz:gettips(data,action)

	local realtable = self:getlist(data)
	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #data
	
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
	-- if realtable[self.laizivalue] then
	-- 	for i=1,realtable[self.laizivalue].num do
	-- 		table.insert(laizitable,realtable[self.laizivalue].value[i])
	-- 	end
	-- end
	printTable(laizitable,"sjp10")

	function addzha( cantable,realvaluetable,fuc)

		--printTable(realvaluetable,"sjp10")
		for i,v in ipairs(realvaluetable) do
			if v.num == 4 then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB,real = v.real,values = {v.values[1],v.values[2],v.values[3],v.values[4]}})
			end
		end
		if realtable[16] and realtable[17] then
			if realtable[16].num > 0 and realtable[17].num > 0 then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER,real = 17,values = {realtable[16].values[1],realtable[17].values[1]}})
			end
		end
		print("lainum:"..lainum)
		if lainum > 0 then
			print("-------------11111ss")
			printTable(realtable,"sjp10")
			fuc(cantable,1)
			for i,v in ipairs(realvaluetable) do
				if v.num == 3 and self:isnotjoker(v.real) then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],v.values[2],v.values[3],laizitable[1]}})
				end
			end
			-- if realtable[16] then
			-- 	if realtable[16].num > 0 then
			-- 		table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17,values = {realtable[16].values[1],laizitable[1]}})
			-- 	end
			-- end

			-- if realtable[17] then
			-- 	if realtable[17].num > 0 then
			-- 		table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17,values = {realtable[17].values[1],laizitable[1]}})
			-- 	end
			-- end

		end

		if lainum > 1 then
			fuc(cantable,2)
			for i,v in ipairs(realvaluetable) do
				if v.num == 2 and self:isnotjoker(v.real) then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],v.values[2],laizitable[1],laizitable[2]}})
				end
			end
		end

		if lainum > 2 then
			fuc(cantable,3)

			for i,v in ipairs(realvaluetable) do
				if v.num == 1 and self:isnotjoker(v.real) then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],laizitable[1],laizitable[2],laizitable[3]}})
				end
			end
		end
		if lainum >3 then
			fuc(cantable,lainum)
			if realtable[self.laizivalue].num > 3 then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB_OF_LAIZI,real = self.laizivalue,values = {laizitable[1],laizitable[2],laizitable[3],laizitable[4]}})
			else
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,islai = true,real = self.laizivalue,values = {laizitable[1],laizitable[2],laizitable[3],laizitable[4]}})
			end
		end

		
		
	end


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
			if v.num == 1 and v.real > action.real then
				if (v.real == 16 or v.real ==17) and self:havedoubleJoker( realtable ) then
				else
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]}})
				end
				
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and v.real > action.real then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]}})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and v.real > action.real then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]}})
			end
		end


		addzha( cantable,realvaluetable,function( ... )
			-- body
		end)
		if self.laizivalue > action.real and realtable[self.laizivalue] and realtable[self.laizivalue].num > 0 then
			table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = self.laizivalue,values = {realtable[self.laizivalue].values[1]}})
		end
		return cantable
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		if totall < 2 then
			return {}
		end
		printTable(realvaluetable)

		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]}})
			end
		end
		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and v.real > action.real and self:isnotjoker(v.real) then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]}})
			end
		end

		addzha( cantable,realvaluetable,function(cantable,lainumlocal)
			if lainumlocal == 1 then
				for i,v in ipairs(realvaluetable) do
					if v.num == 1 and v.real > action.real and self:isnotjoker(v.real) then
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],laizitable[1]}})
					end
				end
			end
		end)
		if self.laizivalue > action.real and lainum >= 2 then
			table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = self.laizivalue,values = {laizitable[1],laizitable[2]}})
		end
		printTable(cantable)
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE then
		print("---------dddd")
		printTable(realvaluetable,"sjp10")
		-- if totall < 4 then
		-- 	return {}
		-- end
		local function getone(real)
			local onevalue = nil
			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 1 then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 2 then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 3 then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

		end
		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and v.real > action.real and self:isnotjoker(v.real) then
				local onevalue = getone(v.real)
				if onevalue then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = v.real,values = {v.values[1],v.values[2],v.values[3],onevalue}})
				end
			end
		end

		addzha( cantable,realvaluetable,function( cantable,lainumlocal )
			local num = 3
			if lainumlocal == 1 then
				for i,v in ipairs(realvaluetable) do
					if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) and v.real ~= self.laizivalue then
						local onevalue = getone(v.real)
						if onevalue then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = v.real,values = {v.values[1],v.values[2],laizitable[1],onevalue}})
						end
					end
				end
			elseif lainumlocal == 2 then
				for i,v in ipairs(realvaluetable) do
					if v.num == 1 and v.real > action.real and self:isnotjoker(v.real) and v.real ~= self.laizivalue then
						local onevalue = getone(v.real)
						if onevalue then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = v.real,values = {v.values[1],laizitable[1],laizitable[2],onevalue}})
						end
					end
				end
			end
			
		end)

		-- if self.laizivalue > action.real and lainum >= 3 then
		-- 	local onevalue = getone(self.laizivalue)
		-- 	if onevalue then
		-- 		table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = self.laizivalue,values = {laizitable[1],laizitable[2],laizitable[3],onevalue}})
		-- 	end
		-- end

	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE then
			for i,v in ipairs(realvaluetable) do
				if v.num == 3 and v.real > action.real and self:isnotjoker(v.real) then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE,real = v.real,values = {v.values[1],v.values[2],v.values[3]}})
				end
			end

			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				local num = 3
				if lainumlocal == 1 then
					for i,v in ipairs(realvaluetable) do
						if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE,real = v.real,values = {v.values[1],v.values[2],laizitable[1]}})
						end
					end
				elseif lainumlocal == 2 then
					for i,v in ipairs(realvaluetable) do
						if v.num == 1 and v.real > action.real and self:isnotjoker(v.real) then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE,real = v.real,values = {v.values[1],laizitable[1],laizitable[2]}})
						end
					end
				end
			
			end)
			if self.laizivalue > action.real and lainum >= 3 then
			

				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE,real = self.laizivalue,values = {laizitable[1],laizitable[2],laizitable[3]}})
			end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		print("顺子")
		-- if totall < action.num  then
		-- 	return {}
		-- end 
		if action.num + action.real > 14 then
			print("------d1")
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				end)
		else
			local function getstraight(lainumlocal)
				for i=(action.real+1),(15-action.num) do
					local ishavefour =false
					local tablelist = {}
					local islian = true
					local needlai = 0
					for j=i,(i+action.num-1) do
						if realtable[j] and realtable[j].num > 0 and j ~= self.laizivalue  then
							if realtable[j].num >= 4 then
								ishavefour = true
							end
							table.insert(tablelist,realtable[j].values[1])
						else
							needlai = needlai + 1
							if needlai > lainumlocal then
								islian = false
								break
							else
								table.insert(tablelist,laizitable[needlai])
							end

						end
					end
					if islian and needlai == lainumlocal then
						if ishavefour then
						else
							local action = {type = poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = i,values = tablelist,num = action.num}
							local tablerealtype = self:getype(action.values,false)
							if tablerealtype then
								if #tablerealtype >=1 then
									for i,v in ipairs(tablerealtype) do
										if action.type == v.type and action.real == v.real then
											table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = j,values = tablelist,num = action.num})
										end
									end
								else
									if action.type == tablerealtype.type and action.real == tablerealtype.real then
										table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT,real = j,values = tablelist,num = action.num})
									end
								end
							end
						end
					end

				end
			end
			print("------d2")
			getstraight(0)
			print("------d3")
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
					getstraight(lainumlocal)
				end)
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_2 then

		-- if totall < action.num*2  then
		-- 	return {}
		-- end 
		if action.num + action.real > 14 then
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				end)
		else
			local function getstraight(lainumlocal)
				for i=(action.real+1),(15-action.num) do
					local ishavefour =false
					local tablelist = {}
					local islian = true
					local needlai = 0
					print("-----------")

					for j=i,(action.num+i-1) do
						print(j)
						if realtable[j] and realtable[j].num >= 2 and j ~= self.laizivalue  then
							if realtable[j].num >= 4 then
								print("four")
								ishavefour = true
							end
							print("add")
							table.insert(tablelist,realtable[j].values[1])
							table.insert(tablelist,realtable[j].values[2])
						elseif realtable[j] and realtable[j].num == 1 and j ~= self.laizivalue then
							needlai = needlai + 1
							print("need1:"..needlai)
							print("lainumlocal1:"..lainumlocal)
							if needlai > lainumlocal then
								islian = false
								break
							else
								table.insert(tablelist,laizitable[needlai])
							end
							table.insert(tablelist,realtable[j].values[1])
						else
							
							needlai = needlai + 1

							if needlai > lainumlocal then
								islian = false
								break
							else
								table.insert(tablelist,laizitable[needlai])
							end
							needlai = needlai + 1
							if needlai > lainumlocal then
								islian = false
								break
							else
								table.insert(tablelist,laizitable[needlai])
							end
						end
					end
					if islian and needlai == lainumlocal then
						print("---------------1")
						if ishavefour then
						else
							printTable(tablelist,"sjp10")
							local action = {type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = i,values = tablelist,num = action.num}
							local tablerealtype = self:getype(action.values,false)
							printTable(tablerealtype,"sjp10")
							printTable(action,"sjp10")
							if tablerealtype then
								print("---------------2")
								if #tablerealtype >=1 then
									print("---------------3")

									for i,v in ipairs(tablerealtype) do
										if action.type == v.type and action.real == v.real then
											table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = j,values = tablelist,num = action.num})
										end
									end
								else
									if action.type == tablerealtype.type and action.real == tablerealtype.real then
										table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = j,values = tablelist,num = action.num})
									end
								end
							end
						end
					end

				end
			end
			getstraight(0)
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
					print("laizi :"..lainumlocal)
					getstraight(lainumlocal)
				end)
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 or action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_1 then
		-- if totall < action.num*4  then
		-- 	return {}
		-- end 

		local function getone(reallist)
			local isdoulejoker = self:havedoubleJoker( realtable )
			local onevalue = nil
			local singletable = {}
			local function istong(real)
				for i,v in ipairs(reallist) do
					if real == v then
						return false
					end
				end
				return true
			end
			for i,v in ipairs(realvaluetable) do
				if istong(v.real) and v.num == 1 then
					if (v.real == 16 or v.real == 17 ) and isdoulejoker then
					else
						table.insert(singletable,v.values[1])
					end
				end
			end
			for i,v in ipairs(realvaluetable) do
				if istong(v.real) and v.num == 2 then
					if (v.real == 16 or v.real == 17 ) and isdoulejoker then
					else
						table.insert(singletable,v.values[1])
						table.insert(singletable,v.values[2])
					end
				end
			end
			for i,v in ipairs(realvaluetable) do
				if istong(v.real) and v.num == 3 then
					if (v.real == 16 or v.real == 17 ) and isdoulejoker then
					else
						table.insert(singletable,v.values[1])
						table.insert(singletable,v.values[2])
						table.insert(singletable,v.values[3])
					end
				end
			end

			return singletable
		end

		if action.num + action.real > 14 then
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				end)
		else
			local function getstraight(lainumlocal)
				for i=(action.real+1),(15-action.num) do
					local ishavefour =false
					local tablelist = {}
					local islian = true
					local needlai = 0
					print("开始")
					local reallianlist= {}
					for j=i, (i+action.num-1) do
						print(j)
						table.insert(reallianlist,j)
						if realtable[j] and realtable[j].num > 0 and j ~= self.laizivalue  then
							if realtable[j].num >= 4 then
								islian = false
								break
							end
							for k=1,realtable[j].num do
								table.insert(tablelist,realtable[j].values[k])
							end

							for k=1,(3-realtable[j].num) do
								needlai = needlai + 1
								if needlai > lainumlocal then
									islian = false
									break
								else
									table.insert(tablelist,laizitable[needlai])
								end
							end
						else
							for k=1,3 do
								needlai = needlai + 1
								if needlai > lainumlocal then
									islian = false
									break
								else
									table.insert(tablelist,laizitable[needlai])
								end
							end
						end
					end
					if islian and needlai == lainumlocal then
						if action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 then
						else
							local getonetable = getone(reallianlist)
							if #getonetable >= action.num then
								for i=1,action.num do
									table.insert(tablelist,getonetable[i])
								end
							else
								islian = false
							end
						end
					end
					print("结束")
					if islian and needlai == lainumlocal then
						if ishavefour then
						else
							local action = {type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real = i,values = tablelist,num = action.num}
							local tablerealtype = self:getype(action.values,false)
							if tablerealtype then
								if #tablerealtype >=1 then
									for i,v in ipairs(tablerealtype) do
										if action.type == v.type and action.real == v.real then
											table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real = j,values = tablelist,num = action.num})
										end
									end
								else
									if action.type == tablerealtype.type and action.real == tablerealtype.real then
										table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real = j,values = tablelist,num = action.num})
									end
								end
							end
						end
					end

				end
			end
			getstraight(0)
			addzha( cantable,realvaluetable,function( cantable,lainumlocal )
					getstraight(lainumlocal)
				end)
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO then
		addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				end)
	elseif action.type >= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB then
		addzha( cantable,realvaluetable,function( cantable,lainumlocal )
				
				end)
		printTable(cantable,"sjp10")
		local canlocaltab = {}
		for i,v in ipairs(cantable) do
			if v.type > action.type then
				table.insert(canlocaltab,v)
			elseif v.type == action.type then
				if v.real > action.real then
					table.insert(canlocaltab,v)
				end
			end
		end
		return canlocaltab
	end

	return cantable
end

-- enum ENPokerType
-- {
-- 	EN_POKER_TYPE_UNKONWN			= 0; // 未知
-- 	EN_POKER_TYPE_SINGLE_CARD		= 1; // 单牌
-- 	EN_POKER_TYPE_PAIR				= 2; // 对子
-- 	EN_POKER_TYPE_TRIPLE			= 3; // 三不带
-- 	EN_POKER_TYPE_TRIPLE_WITH_ONE	= 4; // 三带一
-- 	EN_POKER_TYPE_STRAIGHT			= 5; // 顺子
-- 	EN_POKER_TYPE_STRAIGHT_2		= 6; // 双顺
-- 	EN_POKER_TYPE_STRAIGHT_3		= 7; // 三顺
-- 	EN_POKER_TYPE_QUADRUPLE_WITH_TWO	= 8; // 四带二
-- 	EN_POKER_TYPE_SOFT_BOMB			= 9; // 软炸弹
-- 	EN_POKER_TYPE_SOFT_BOMB_OF_JOKER	= 10; // 软王炸
-- 	EN_POKER_TYPE_BOMB				= 11; // (硬)炸弹
-- 	EN_POKER_TYPE_BOMB_OF_JOKER		= 12; // (硬)王炸
-- }


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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 or action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_1 then
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
					if  action.real == self.laizivalue then
						laiindex = laiindex + 1
					end
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

	elseif action.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_LAIZI then
		for i=1,4 do
			if realtable[action.real] and realtable[action.real].num >= i then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
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
	print("self.laizivalue",self.laizivalue)
	while (index<=#pokers) do
		printTable(indextable)
		if self:getrealvalue(pokers[index]:getPoker()) < 15 and self:getrealvalue(pokers[index]:getPoker()) ~= self.laizivalue then
			if index == 1 then
				-- table.insert(indextable,pokers[index])
				indextable[index] = true
				num = num + 1
			else
				if self:getrealvalue(pokers[index]:getPoker()) - self:getrealvalue(pokers[index-1]:getPoker()) == 1 then
					-- table.insert(indextable,pokers[index])
					indextable[index] = true
					num = num + 1
				elseif self:getrealvalue(pokers[index]:getPoker()) == self:getrealvalue(pokers[index-1]:getPoker()) then
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