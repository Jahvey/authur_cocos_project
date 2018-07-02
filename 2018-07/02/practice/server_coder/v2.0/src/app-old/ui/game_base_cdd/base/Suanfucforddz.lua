local Suanfucforddz = class("Suanfucforddz")

-- enum ENPokerType
-- {
-- 	EN_POKER_TYPE_UNKONWN			= 0; // 未知
-- 	EN_POKER_TYPE_SINGLE_CARD		= 1; // 单牌
-- 	EN_POKER_TYPE_PAIR				= 2; // 对子
-- 	EN_POKER_TYPE_TRIPLE			= 3; // 三不带
-- 	EN_POKER_TYPE_TRIPLE_WITH_ONE	= 4; // 三带一
-- 	EN_POKER_TYPE_TRIPLE_WITH_TWO	= 5; // 三带二
-- 	EN_POKER_TYPE_STRAIGHT			= 6; // 顺子
-- 	EN_POKER_TYPE_STRAIGHT_2		= 7; // 双顺
-- 	EN_POKER_TYPE_STRAIGHT_3		= 8; // 三顺
-- 	EN_POKER_TYPE_QUADRUPLE_WITH_TWO	= 9; // 四带二
-- 	EN_POKER_TYPE_SOFT_BOMB			= 20; // 软炸弹
-- 	EN_POKER_TYPE_SOFT_BOMB_OF_JOKER	= 21; // 软王炸
-- 	EN_POKER_TYPE_BOMB				= 22; // (硬)炸弹
-- 	EN_POKER_TYPE_BOMB_OF_JOKER		= 23; // (硬)王炸
-- }
--J:11, Q:12, K:13, A:14, 2:15, 小王:16, 大王:17, 癞子:18
function Suanfucforddz:ctor(_scene)
	self.gamescene = _scene

end

--返回剔除花色后的牌值，如，红桃8和黑桃8都是8
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
	return real
end

--按照数量，牌值整理
function Suanfucforddz:getlist(data)
	local listtable =  {}
	-- print(".........按照数量，牌值整理")
	-- printTable(data,"xp68")
	
	for i,v in ipairs(data) do
		local real = self:getrealvalue(v)
		if listtable[real] == nil then
			listtable[real] = {num= 1,real = real,values = {v}}
		else
			table.insert(listtable[real].values,v)
			listtable[real].num = listtable[real].num + 1
		end
	end
	return listtable
end
--按照牌值排序
function Suanfucforddz:sort( data )	
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
--是不是王
function Suanfucforddz:isnotjoker( real )
	if real == 16 or real == 17 then
		return false
	end
	return true
end

--是不是双王
function Suanfucforddz:havedoubleJoker( realtable )
	if realtable[16] and realtable[17] and realtable[16].num > 0 and realtable[17].num > 0 then
		return true
	end
	return false
end
--是不是癞子
function Suanfucforddz:islai( value )
	-- body
	if value == 0x66  or self:getlaizi() == self:getrealvalue( value ) then
		return true
	else
		return false
	end
end
function Suanfucforddz:getlaizi( )
	return LocalData_instance:getLaiZiValuer()
end

--列表中癞子的数量，必须是正理过后的列表
function Suanfucforddz:getlaizinum(tablelist)
	local num =  0

	local _laizi = self:getlaizi()
	if  tablelist[_laizi] then
		num = num + tablelist[_laizi].num
	end
	return num
end

------对比我选择的牌型是否和别人出的牌型一样
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

----------------------------------以下函数大多需要重载，差异性太大----------------------------------
-------------获取选择的牌的牌型，
function Suanfucforddz:getype(data,isall)
	print("......获取选择的牌的牌型")

	print("......data = ")
	printTable(data,"xp68")

	local realtable = self:getlist(data)

	local lainum = self:getlaizinum(realtable)

	print("......realtable = ")
	printTable(realtable,"xp68")

	--真实牌值
	local maxCard = {num = 0}
	local realvaluetable = {}
	for k,v in pairs(realtable) do
	
		if self:islai( v.values[1]  ) == false then
			table.insert(realvaluetable,v.real)
			if v.num > maxCard.num then
				maxCard = v
			end
		end
	end
		
	
	table.sort(realvaluetable)

	print("......realvaluetable = ")
	printTable(realvaluetable,"xp66")

	local totall = #data
	if totall == 1 then
		if #realvaluetable == 0 then --癞子当自己本身
			return {type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = self:getlaizi()}
		else
			return {type= poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = realvaluetable[1]}
		end
	end

	if totall == 2 then
		if #realvaluetable == 0 then --癞子当自己本身
			return {type = poker_common_pb.EN_POKER_TYPE_PAIR,real = self:getlaizi()}
		elseif #realvaluetable == 1 then --有效值为1的时候，可能是一对，也可能是1王+1癞
			if self:isnotjoker(realvaluetable[1]) then
				return {type = poker_common_pb.EN_POKER_TYPE_PAIR,real = realvaluetable[1] }
			else
				return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17}
			end
		elseif #realvaluetable == 2 then --两张牌的时候
			if  self:havedoubleJoker(realtable) then --双王
				return {type= poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER,real = 17}
			end
		end
		return
	end

	--三不带，
	if totall == 3 and isall then
		-- print(".....三不带")
		--剔除癞子牌之后的其它牌
		if #realvaluetable  == 0 then --全癞子
			return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real = self:getlaizi() ,num = 3}
		elseif #realvaluetable == 1 and self:isnotjoker(realvaluetable[1])  then --只有一种牌，并且不是王的时候，
			return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE,real = realvaluetable[1],num = 3}
		end
		return
	end
	if totall >= 4 then
		local cantable = {}
		if totall == 4 then
			--先找出炸弹
			if  maxCard.num + lainum == 4 then --必定可以出炸弹
				if lainum == 0 then --4+0
					return {type= poker_common_pb.EN_POKER_TYPE_BOMB,real = maxCard.real ,num = 4}
				elseif lainum == 4 then --0+4
					return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = self:getlaizi() ,num = 4} 
				elseif lainum == 3 then --1+3，
					if self:isnotjoker(maxCard.real) then
						table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = maxCard.real,num = 4})
					else
						return {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = self:getlaizi() ,num = 4} 
					end
				else
					--2+2，3+1，
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = maxCard.real,num = 4})
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = maxCard.real,num = 4})
				end
			end

			--再找出三带一
			if  maxCard.num + lainum == 3 then --
				if lainum == 2 then --1+2
					if self:isnotjoker(realvaluetable[1]) and self:isnotjoker(realvaluetable[2]) then --2个都不是王的时候
						if realvaluetable[1] > realvaluetable[2] then
							table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = realvaluetable[1],num = 4})
						else
							table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = realvaluetable[2],num = 4})
						end
					elseif self:isnotjoker(realvaluetable[1]) then
						table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = realvaluetable[1],num = 4})
					else
						table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = realvaluetable[2],num = 4})
					end
				else --只有2+1了，3+0
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE,real = maxCard.real,num = 4})
				end
			end
		end

		--连队
		local islian = false
		--只有野三关能出两对的顺子
		if  self.gamescene:getTableConf().ttype == HPGAMETYPE.YSGDDZ then
			if totall >= 4 and totall%2 == 0 then
				islian = true
			end
		else
			if totall >= 6 and totall%2 == 0 then
				islian = true
			end
		end

		if islian then
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
				local _data = realtable[begin + i - 1]
				if _data then
					if _data.num > 2 then
						iscan = false
					end
					if _data.num <= 2 then
						needlaizi =  needlaizi + 2 - _data.num
					end
				else
					needlaizi =  needlaizi + 2
				end				
			end
			if iscan then
				if needlaizi == lainum then
					table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real =begin,num = num})
				end
			end
		end

		
		if totall >= 5 then
			--3带2，野三关斗地主才有三带二
			if  totall == 5 and self.gamescene:getTableConf().ttype == HPGAMETYPE.YSGDDZ then
				local canlocal = {}
				for i,v in ipairs(realvaluetable) do
					if self:isnotjoker(v) then
						if (3-realtable[v].num) <= lainum then
							local _lai = lainum - (3-realtable[v].num)
							local isTwo = false
							for j,vv in ipairs(realvaluetable) do
								if v ~= vv then 
									if realtable[vv].num + _lai == 2 then
										isTwo = true
									end
								end
							end
							if isTwo then
								table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real = v})
							end
						end
					end
				end
				if #canlocal > 0 then
					table.insert(cantable, canlocal[#canlocal])
				end
			end

			--顺子
			local num = totall
			local begin = nil
			if (realvaluetable[1] + num -1) > 14 then
				begin = 14 - num + 1
			else
				begin = realvaluetable[1]
			end

			-- print("begin = ",begin)

			local needlaizi = 0
			local iscan = true
			for i=1,num do
				local _data = realtable[begin + i - 1]
				if _data then
					if _data.num > 1 then
						iscan = false
					end
				else
					needlaizi =  needlaizi + 1
				end
			end
			-- print("lainum = ",lainum)
			-- print("needlaizi = ",needlaizi)

			if iscan then
				if needlaizi <= lainum then
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =begin,num = num})
				end
			end
	
			--四带2
			if totall == 6  then
				--print("4dai2")
				printTable(realvaluetable)
				local canlocal = {}
				for i,v in ipairs(realvaluetable) do
					if self:isnotjoker(realvaluetable[i]) then
						if (4-realtable[realvaluetable[i]].num)<=lainum then
							table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO,real =realvaluetable[i]})
						end
					end
				end
				if #canlocal > 0 then
					table.insert(cantable, canlocal[#canlocal])
				end
			end

			if  totall > 5 then
				--飞机1
				if totall%3 == 0 and isall then
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
						if needlaizi == lainum then
							--return  {type= 6,real =begin,num = num}
							table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real =begin,num = num})
						end
					end
				end

				--飞机加翅膀，（3+1）＊n 
				if totall%4 == 0  then
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
						if iscan then
							if needlaizi<=lainum then
								--return  {type= 6,real =begin,num = num}
								table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real =begin,num = num})
							end
						end
					end
					if #canlocal > 0 then
						table.insert(cantable, canlocal[#canlocal])
					end
				end

				--飞机加双翅膀 （3+2）＊n 
				if totall%5 == 0  then
					local num = totall/5
					local canlocal = {}

					local function getIsTwo(begin,_lai) --找出n对个对子
						local _needlaizi = 0
						for j,vv in ipairs(realvaluetable) do
							if  vv < begin or  begin + num < vv then 
								if realtable[vv] and realtable[vv].num <= 2 then
									_needlaizi =  _needlaizi + 2 - realtable[vv].num
								else
									_needlaizi=  _needlaizi + 2
								end
							end
						end

						if _needlaizi == _lai  then
							return true
						end
						return false
					end

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
						if iscan then
							if needlaizi<=lainum then
								local _lai = lainum - needlaizi						
								if getIsTwo(begin,_lai) then
									table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2,real = begin,num = num})
								end
							end
						end
					end
					if #canlocal > 0 then
						table.insert(cantable, canlocal[#canlocal])
					end
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

-------找出能大于别人出的牌型
function Suanfucforddz:gettips(data,action)

	local realtable = self:getlist(data)
	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #data
	
	if realtable[self:getlaizi()] then
		for i=1,realtable[self:getlaizi()].num do
			table.insert(laizitable,realtable[self:getlaizi()].values[i])
		end
	end

	if realtable[18] then
		for i=1,realtable[18].num do
			table.insert(laizitable,0x66)
		end
	end
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
			if realtable[16] then
				if realtable[16].num > 0 then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17,values = {realtable[16].values[1],laizitable[1]}})
				end
			end

			if realtable[17] then
				if realtable[17].num > 0 then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17,values = {realtable[17].values[1],laizitable[1]}})
				end
			end

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
			if realtable[self:getlaizi()].num > 3 then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB,real = self:getlaizi(),values = {laizitable[1],laizitable[2],laizitable[3],laizitable[4]}})
			else
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,islai = true,real = self:getlaizi(),values = {laizitable[1],laizitable[2],laizitable[3],laizitable[4]}})
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
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,real = v.real,values = {v.values[1]}})
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
		printTable(cantable)
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
		
		printTable(cantable)
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE then
		print("---------dddd")
		printTable(realvaluetable,"xp66")
	
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
			return nil
		end
		for i,v in ipairs(realvaluetable) do
			if v.num == 3 and v.real > action.real and self:isnotjoker(v.real) then
				local onevalue = getone(v.real)
				if onevalue then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2],v.values[3],onevalue}})
				end
			end
		end

		addzha( cantable,realvaluetable,function( cantable,lainumlocal )
			local num = 3
			if lainumlocal == 1 then
				for i,v in ipairs(realvaluetable) do
					if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) then
						local onevalue = getone(v.real)
						if onevalue then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2],laizitable[1],onevalue}})
						end
					end
				end
			elseif lainumlocal == 2 then
				for i,v in ipairs(realvaluetable) do
					if v.num == 1 and v.real > action.real and self:isnotjoker(v.real) then
						local onevalue = getone(v.real)
						if onevalue then
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],laizitable[1],laizitable[2],onevalue}})
						end
					end
				end
			end
		end)
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO then
	
		local function gettwo(real) --找出一个对子列表
			local twovalues = {}

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 2 then
					table.insert(twovalues,v.values[1])
					table.insert(twovalues,v.values[2])
					return twovalues
				end
			end

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 3 then
					for m=1,2 do
						table.insert(twovalues,v.values[m])
						if #twovalues == 2 then
							return twovalues
						end
					end
				end
			end

			return twovalues
		end

		if totall >= 5 then
			for i,v in ipairs(realvaluetable) do
				if v.num == 3 and v.real > action.real then
					local twovalues = gettwo(v.real)

					if twovalues and #twovalues == 2 then
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_TWO,real = v.real,values = {v.values[1],v.values[2],v.values[3],twovalues[1],twovalues[2]}})
					end
				end
			end
		end

		addzha( cantable,realvaluetable,function( cantable,lainumlocal )

		end)

	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		print("顺子")
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
						if realtable[j] and realtable[j].num > 0  then
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
						if realtable[j] and realtable[j].num >= 2  then
							if realtable[j].num >= 4 then
								print("four")
								ishavefour = true
							end
							print("add")
							table.insert(tablelist,realtable[j].values[1])
							table.insert(tablelist,realtable[j].values[2])
						elseif realtable[j] and realtable[j].num == 1  then
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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 then
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
						if realtable[j] and realtable[j].num > 0  then
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
						local getonetable = getone(reallianlist)
						if #getonetable >= action.num then
							for i=1,action.num do
								table.insert(tablelist,getonetable[i])
							end
						else
							islian = false
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

	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 then
		-- print("............飞机加双翅膀,realtable")
		-- printTable(realtable,"xp66")

		-- print("............飞机加双翅膀,action")
		-- printTable(action,"xp66")

		-- print("............飞机加双翅膀,realvaluetable")
		-- printTable(realvaluetable,"xp66")

		local function gettwo(real) --找出一个对子列表
			local twovalues = {}

			for i,v in ipairs(realvaluetable) do
				if v.num == 2 then
					table.insert(twovalues,v.values[1])
					table.insert(twovalues,v.values[2])
					if #twovalues == (action.num * 2) then
						return twovalues
					end
				end
			end

			for i,v in ipairs(realvaluetable) do
				if (v.real < real or v.real > real + action.num - 1) and v.num == 3  then
					for m=1,2 do
						table.insert(twovalues,v.values[m])
						if #twovalues == (action.num * 2) then
							return twovalues
						end
					end
				end
			end
			return twovalues
		end

		if totall >= 6 then
			local function getdata(real,twodata) --组合数据
				local _data = {}
				for i=1,action.num do
					for j=1,3 do
						table.insert(_data,realtable[real+i-1].values[j])
					end
				end
				for k,v in pairs(twodata) do
					table.insert(_data,v)
				end
				return _data
			end
			
			--找出满足条件的(action.num)个三个
			for i,v in ipairs(realvaluetable) do
				if v.num == 3 and v.real > action.real then
					local notOrder = true
					for j=1,action.num -1 do
						if realtable[v.real+j] then
							if  (realtable[v.real+j].num ~= 3 or (v.real+j) > 14) then --2不能连
								notOrder = false
								break
							end
						else
							notOrder = false
							break
						end
					end
					if  notOrder then
						--找出(action.num)个对子
						local twovalues = gettwo(v.real)
						if twovalues and #twovalues == (action.num * 2) then
							local _data = getdata(v.real,twovalues)
							table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2,real = v.real,values = _data})
						end
					end
				end
			end
		end

		addzha( cantable,realvaluetable,function( cantable,lainumlocal )

		end)
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

------别人打的牌的，牌型归类
function Suanfucforddz:getrealcardsTab(cards,action)

	-- print(".....别人打的牌的，牌型归类")
	-- printTable(cards,"xp68")

	local realtable = self:getlist(cards)

	-- print(".....realtable = ")
	-- printTable(realtable,"xp68")

	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #cards
	
	if realtable[self:getlaizi()] then
		for i=1,realtable[self:getlaizi()].num do
			table.insert(laizitable,realtable[self:getlaizi()].values[i])
		end
	end

	if realtable[18] then
		for i=1,realtable[18].num do
			table.insert(laizitable,0x66)
		end
	end

	-- print(".....laizitable = ")
	-- printTable(laizitable,"xp68")

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

	-- print(".....realvaluetable = ")
	-- printTable(realvaluetable,"xp68")

	local cardslist = {}
	if action.type == poker_common_pb.EN_POKER_TYPE_SINGLE_CARD then
		if realtable[action.real] ~= nil  then
			table.insert(cardslist,{value = cards[1],islai = self:islai(cards[1])})
		else
			table.insert(cardslist,{value = setvalue(cards[1],action.real),islai = true})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		local laiindex = 0
		for i=1,2 do
			if realtable[action.real] and realtable[action.real].num >= i then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai = self:islai(realtable[action.real].values[i])})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai = true})
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
					table.insert(cardslist,{value = v1,islai = false})
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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 then
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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3_2 then

		-- print("............飞机加双翅膀,realtable")
		-- printTable(realtable,"xp66")

		-- print("............飞机加双翅膀,action")
		-- printTable(action,"xp66")

		-- print("............飞机加双翅膀,realvaluetable")
		-- printTable(realvaluetable,"xp66")

		for j=1,action.num do
			for i=1,3 do
				table.insert(cardslist,{value = realtable[action.real+action.num-j].values[i],islai =false})
			end
		end
		for i,v in ipairs(realvaluetable) do
			if v.real ~= action.real and realtable[v.real].num == 2 then
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

		

	end

	printTable(cardslist,"sjp10")
	return cardslist
end

-----把滑动选择的顺子牌从手牌中提出来
function Suanfucforddz:selectStraight(pokers,handcards)
	if #pokers < 5 then
		return
	end

	-- <16
	local index = 1
	local indextable = {}
	local num = 0
	-- print("self:getlaizi()",self:getlaizi())
	while (index<=#pokers) do
		printTable(indextable)

		local _pokerValue =  self:getrealvalue(pokers[index]:getPoker())

		if  _pokerValue < 15 and _pokerValue ~= self:getlaizi() then
			if index == 1 then
				indextable[index] = true
				num = num + 1
			else
				if _pokerValue - self:getrealvalue(pokers[index-1]:getPoker()) == 1 then
					indextable[index] = true
					num = num + 1
				elseif _pokerValue == self:getrealvalue(pokers[index-1]:getPoker()) then
				else
					if num >=5 then
						break
					end
					indextable = {}
					num = 0
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