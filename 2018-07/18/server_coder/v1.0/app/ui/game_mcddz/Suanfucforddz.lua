local Suanfucforddz = class("RecordScene", require "app.ui.game_base_cdd.base.Suanfucforddz")

--判断是否拆开了双王
function Suanfucforddz:getIsTakeApartKing(list,allList)
	--选中的王的数量
	local real_list = self:getlist(list)
	if (real_list[16] and real_list[16].num > 0) and (real_list[17] and real_list[17].num > 0) then --选中了双王，没拆
		--但是如果还有其它牌的话，也算拆，双王只能是炸弹
		if #list > 2 then
			return true
		end
		return false
	elseif (real_list[16] and real_list[16].num > 0) or (real_list[17] and real_list[17].num > 0) then --选中一个王，
		local real_all = self:getlist(allList)
		if (real_all[16] and real_all[16].num > 0) and (real_all[17] and real_all[17].num > 0) then --总共有两王，表示拆了
			return true
		end
	else
		return false --没王，没拆
	end
	return false
end


--按照牌值排序
function Suanfucforddz:sort( data )	
	table.sort(data,function(a,b)

		local _a = self:getrealvalue( a )
		local _b = self:getrealvalue( b )

		if  self:islai(a) then
			_a = _a + 100
		end
		if  self:islai(b) then
			_b = _b + 100
		end

		if  _a > _b then
			return true
		elseif  _a == _b then
			return a > b
		else
			return false
		end
	end)
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

-------------获取选择的牌的牌型，
function Suanfucforddz:getype(data,isall)
	-- print("......获取选择的牌的牌型")

	local realtable = self:getlist(data)

	local lainum = self:getlaizinum(realtable)

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
				return {type= poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = realvaluetable[1]}
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
		if totall >= 6 and totall%2 == 0 then
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
				if _data and self:islai(_data.values[1]) == false then
					if _data.num > 2  then
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
				if needlaizi <= lainum then
					table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real =begin,num = num})
				end
			end
		end

		
		if totall >= 5 then
	
			--顺子
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
				local _data = realtable[begin + i - 1]
				if _data and self:islai(_data.values[1]) == false then
					if _data.num > 1 then
						iscan = false
					end
				else
					needlaizi =  needlaizi + 1
				end
			end


			if iscan then
				if needlaizi <= lainum then
					table.insert(cantable,{type= poker_common_pb.EN_POKER_TYPE_STRAIGHT,real =begin,num = num})
				end
			end
	
			--四带2
			if totall == 6  then
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
						local _data = realtable[begin + i - 1]
						if _data and self:islai(_data.values[1]) == false then
							if  _data.num <= 3 then
								needlaizi =  needlaizi + 3-_data.num
							else
								iscan = false
							end
						else
							needlaizi =  needlaizi + 3
						end
					end

					if iscan then
						if needlaizi == lainum then
							--return  {type= 6,real =begin,num = num}
							table.insert(cantable, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real = begin,num = num})
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
							local _data = realtable[begin + j - 1]
							if _data and  self:islai(_data.values[1]) == false then
								if  _data.num <= 3 then
									needlaizi =  needlaizi + 3 - _data.num
								end
							else
								needlaizi =  needlaizi + 3
							end
						end
						if iscan then
							if needlaizi <= lainum then
								table.insert(canlocal, {type= poker_common_pb.EN_POKER_TYPE_STRAIGHT_3,real =begin,num = num})
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
			return nil1011
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

	-- print("找出能大于别人出的牌型")
	local realtable = self:getlist(data)
	local laizitable = {}
	local lainum = self:getlaizinum(realtable)
	local totall = #data
	
	if realtable[self:getlaizi()] then
		for i=1,realtable[self:getlaizi()].num do
			table.insert(laizitable,realtable[self:getlaizi()].values[i])
		end
	end

	local isDoubleJoker = false
	if realtable[16] and realtable[17] then
		if realtable[16].num > 0 and realtable[17].num > 0 then
			isDoubleJoker = true
		end
	end
	function addzha( cantable,realvaluetable,fuc)
		for i,v in ipairs(realvaluetable) do
			if v.num == 4 then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB,real = v.real,values = {v.values[1],v.values[2],v.values[3],v.values[4]}})
			end
		end
		if isDoubleJoker then
			table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER,real = 17,values = {realtable[16].values[1],realtable[17].values[1]}})
		end
		if lainum > 0 then
			fuc(cantable,1)
			for i,v in ipairs(realvaluetable) do
				if v.num == 3 and self:isnotjoker(v.real) and self:islai(v.values[1]) == false then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],v.values[2],v.values[3],laizitable[1]}})
				end
			end

			if isDoubleJoker == false then
				if realtable[16] then
					if realtable[16].num > 0 then
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 16,values = {realtable[16].values[1],laizitable[1]}})
					end
				end
				if realtable[17] then
					if realtable[17].num > 0 then
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER,real = 17,values = {realtable[17].values[1],laizitable[1]}})
					end
				end
			end
		end

		if lainum > 1 then
			fuc(cantable,2)
			for i,v in ipairs(realvaluetable) do
				if v.num == 2 and self:isnotjoker(v.real)  and self:islai(v.values[1]) == false then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],v.values[2],laizitable[1],laizitable[2]}})
				end
			end
		end

		if lainum > 2 then
			fuc(cantable,3)
			for i,v in ipairs(realvaluetable) do
				if v.num == 1 and self:isnotjoker(v.real) and self:islai(v.values[1]) == false  then
					table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SOFT_BOMB,real = v.real,islai = true,values = {v.values[1],laizitable[1],laizitable[2],laizitable[3]}})
				end
			end
		end
		if lainum > 3 then
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
		--在麻城斗地主里面，癞子可以作为本身出牌,并且，双王不能拆
		if (v.real == 16 or v.real == 17) and isDoubleJoker then
		else
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
		for i,v in ipairs(realvaluetable) do
			if v.num == 1 and v.real > action.real and self:islai(v.values[1]) == false then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,islai = self:islai(v.values[1]),real = v.real,values = {v.values[1]}})
			end
		end

		if lainum == 1 and self:getlaizi() > action.real then
			table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_SINGLE_CARD,islai = true,real = self:getlaizi() ,values = {laizitable[1]}})
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
		return cantable
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		if totall < 2 then
			return {}
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) and self:islai(v.values[1]) == false then
				table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],v.values[2]}})
			end
		end

		for i,v in ipairs(realvaluetable) do
			if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) and self:islai(v.values[1]) == true then
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
					if v.num == 1 and v.real > action.real and self:isnotjoker(v.real) and self:islai(v.values[1]) == false  then
						table.insert(cantable,{type = poker_common_pb.EN_POKER_TYPE_PAIR,real = v.real,values = {v.values[1],laizitable[1]}})
					end
				end
			end
		end)
		
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE then
	
		local function getone(real)
			local onevalue = nil
			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 1 and self:islai(v.values[1]) == false then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 2 and self:islai(v.values[1]) == false then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

			for i,v in ipairs(realvaluetable) do
				if v.real ~= real and v.num == 3 and self:islai(v.values[1]) == false then
					onevalue = v.values[1]
					break
				end
			end
			if onevalue then
				return onevalue
			end

			if  laizitable and laizitable[1] then
				return laizitable[1]
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
					if v.num == 2 and v.real > action.real and self:isnotjoker(v.real) and self:islai(v.values[1]) == false then
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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
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
					for j=i,(i+action.num-1) do

						if realtable[j] and realtable[j].num > 0 and self:islai( realtable[j].values[1]  ) == false then 
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
			getstraight(0)
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
				for i = (action.real+1),(15-action.num) do
					local ishavefour =false
					local tablelist = {}
					local islian = true
					local needlai = 0

					for j=i,(action.num+i-1) do
						if realtable[j] and realtable[j].num >= 2  and self:islai( realtable[j].values[1]  ) == false then
							if realtable[j].num >= 4 then
								ishavefour = true
							end
							table.insert(tablelist,realtable[j].values[1])
							table.insert(tablelist,realtable[j].values[2])
						elseif realtable[j] and realtable[j].num == 1  and self:islai( realtable[j].values[1]  ) == false then
							needlai = needlai + 1
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
						if ishavefour then
						else
							local action = {type = poker_common_pb.EN_POKER_TYPE_STRAIGHT_2,real = i,values = tablelist,num = action.num}
							local tablerealtype = self:getype(action.values,false)
							if tablerealtype then
								if #tablerealtype >=1 then
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
					getstraight(lainumlocal)
				end)
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 then
		local function getone(reallist,needlai)
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
				if istong(v.real) and v.num == 1 and self:islai(v.values[1]) == false then
					if (v.real == 16 or v.real == 17 ) and isDoubleJoker then
					else
						table.insert(singletable,v.values[1])
					end
				end
			end

			for i,v in ipairs(realvaluetable) do
				if istong(v.real) and v.num == 2 and self:islai(v.values[1]) == false then
					if (v.real == 16 or v.real == 17 ) and isDoubleJoker then
					else
						table.insert(singletable,v.values[1])
						table.insert(singletable,v.values[2])
					end
				end
			end

			for i,v in ipairs(realvaluetable) do
				if istong(v.real) and v.num == 3 and self:islai(v.values[1]) == false then
					if (v.real == 16 or v.real == 17 ) and isDoubleJoker then
					else
						table.insert(singletable,v.values[1])
						table.insert(singletable,v.values[2])
						table.insert(singletable,v.values[3])
					end
				end
			end

			for i,v in ipairs(realvaluetable) do
				if self:islai(v.values[1]) == true and v.num > needlai then
					for i=needlai+1,v.num do
						table.insert(singletable,v.values[i])
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
					local reallianlist= {}
					for j=i, (i+action.num-1) do
						table.insert(reallianlist,j)
						if realtable[j] and realtable[j].num > 0 and self:islai( realtable[j].values[1]  ) == false  then
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
						local getonetable = getone(reallianlist,needlai)
						if #getonetable >= action.num then
							for i=1,action.num do
								table.insert(tablelist,getonetable[i])
							end
						else
							islian = false
						end
					end

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
	local realtable = self:getlist(cards)

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
		if realtable[action.real] ~= nil  then
			table.insert(cardslist,{value = cards[1],islai = self:islai(cards[1])})
		else
			table.insert(cardslist,{value = setvalue(cards[1],action.real),islai = true})
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_PAIR then
		local laiindex = 0
		for i=1,2 do
			if realtable[action.real] and realtable[action.real].num >= i and self:islai(realtable[action.real].values[i]) == false then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai = self:islai(realtable[action.real].values[i])})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai = true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE then
		local laiindex = 0
		for i=1,3 do
			if realtable[action.real] and realtable[action.real].num >= i  and self:islai(realtable[action.real].values[i]) == false then
				table.insert(cardslist,{value = realtable[action.real].values[i],islai =false})
			else
				laiindex = laiindex + 1
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_TRIPLE_WITH_ONE then
		local laiindex = 0
		for i=1,3 do
			if realtable[action.real] and realtable[action.real].num >= i and self:islai(realtable[action.real].values[i]) == false then
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
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT then
		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			if realtable[i] and realtable[i].num >= 1 and self:islai(realtable[i].values[1]) == false then
				table.insert(cardslist,{value = realtable[i].values[1],islai =false})
			else
				laiindex = laiindex + 1
				print(laizitable[laiindex],i)
				table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_2 then
		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			for j=1,2 do
				if realtable[i] and realtable[i].num >= j and self:islai(realtable[i].values[j]) == false then
					table.insert(cardslist,{value = realtable[i].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],i),islai =true})
				end
			end
		end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_STRAIGHT_3 then

		local laiindex = 0
		for i=action.real,(action.real+action.num-1) do
			for j=1,3 do
				if realtable[i] and realtable[i].num >= j and self:islai(realtable[i].values[j]) == false then
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
			else
				if #v.values >3 and self:islai(v.values[4]) == false then
					table.insert(cardslist,{value = v.values[4],islai =false})
				end
			end
		end

	elseif action.type == poker_common_pb.EN_POKER_TYPE_QUADRUPLE_WITH_TWO then
		local laiindex = 0
		--for i=action.real,(action.real+action.num-1) do
			for j=1,4 do
				if realtable[action.real] and realtable[action.real].num >= j and self:islai(realtable[action.real].values[j]) == false then
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
				if realtable[action.real] and realtable[action.real].num >= j and self:islai(realtable[action.real].values[j]) == false then
					table.insert(cardslist,{value = realtable[action.real].values[j],islai =false})
				else
					laiindex = laiindex + 1
					table.insert(cardslist,{value = setvalue(laizitable[laiindex],action.real),islai =true})
				end
			end
		--end
	elseif action.type == poker_common_pb.EN_POKER_TYPE_SOFT_BOMB_OF_JOKER or action.type == poker_common_pb.EN_POKER_TYPE_BOMB_OF_JOKER then
		local laiindex = 0

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

	return cardslist
end
-----把滑动选择的顺子牌从手牌中提出来
function Suanfucforddz:selectStraight(pokers,handcards)
	if #pokers < 5 then
		return
	end
	local laiziList = {}
	local needLaizinum = 0
	local pokersList = {}
	for k,v in pairs(pokers) do
		local _pokerValue = self:getrealvalue(v:getPoker())
		if  _pokerValue == self:getlaizi() then
			table.insert(laiziList, v )
		else
			if  _pokerValue < 15 then
				table.insert(pokersList, v )
			end
		end
	end

	-- <16
	local index = 1
	local indextable = {}
	local num = 0
	while (index<=#pokersList) do

		local _pokerValue =  self:getrealvalue(pokersList[index]:getPoker())

		if index == 1 then
			indextable[index] = true
			num = num + 1
		else
			local _last = self:getrealvalue(pokersList[index-1]:getPoker())
			if _pokerValue - _last == 1 then
				indextable[index] = true
				num = num + 1
			elseif _pokerValue == _last then
			else
				needLaizinum = needLaizinum + (_pokerValue - _last - 1)
				if  needLaizinum <= #laiziList  then
					indextable[index] = true
					num = num + 1
				else
					needLaizinum = 0
					indextable = {}
					num = 0
					indextable[index] = true
					num = num + 1
				end
			end
		end
		index = index + 1
	end
	if num <5 and  (5 - num) <= #laiziList then
		needLaizinum = (5 - num)
	end

	if num + needLaizinum >= 5 then
		for i,v in ipairs(handcards) do
			v:setSelected(false)
		end
		for i,v in ipairs(pokersList) do
			if indextable[i] then
				v:setSelected(true)
			else
				v:setSelected(false)
			end
		end
		if needLaizinum ~= 0 then
			for i=1,needLaizinum do
				laiziList[i]:setSelected(true)
			end
		end
	end
end



return Suanfucforddz