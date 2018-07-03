

Suanfuc  = {}

function Suanfuc.getlist(data)
	local listtable =  {}
	for i,v in ipairs(data) do
		local real = (v-1)%13+1
		
		if real == 2 then
			real = 15
		end
		if real == 1 then
			real = 14
		end
		if v == 53 then
			real = 16
		end
		if v == 54 then
			real = 17
		end

		if v == 55 then
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


function Suanfuc.sort1hand(data)
	local returntable = {}
	local listtable = Suanfuc.getlist(data)
	for i=1,16 do
		if listtable[19-i]~= nil then
			table.sort(listtable[19-i].values)
			for i1,v1 in ipairs(listtable[19-i].values) do
				table.insert(returntable,v1)
			end
		end
	end
	return returntable
end



function Suanfuc.sort2hand(data)
	local returntable = {}
	local listtable = Suanfuc.getlist(data)

	for i=1,3 do
		if listtable[19-i]~= nil then
			table.sort(listtable[19-i].values)
			for i1,v1 in ipairs(listtable[19-i].values) do
				table.insert(returntable,v1)
			end
			listtable[19-i] = nil
		end
	end
	local sorttable = {}
	for k,v in pairs(listtable) do
		table.insert(sorttable,v)
	end
	table.sort(sorttable,function(a,b)
		if a.num > b.num then
			return true
		elseif a.num == b.num then
			if a.real > b.real then
				return true
			else
				return false
			end
		elseif a.num < b.num then
			return false
		end
	end)
	for i,v in ipairs(sorttable) do
		table.sort(v.values)
		for i1,v1 in ipairs(v.values) do
			table.insert(returntable,v1)
		end
	end
	return returntable
end


-- 1单张 2 顺子  3 单对 4 连队  5 3张 6飞机  7炸弹
function Suanfuc.islaiorwang( value )
	-- body
	if value == 53 or  value == 54 or  value ==55 then
		return true
	else
		return false
	end
end
function Suanfuc.getlaizinum(tablelist)
	local num =  0
	if tablelist[16] then
		num = num + tablelist[16].num
	end

	if tablelist[17] then
		num = num + tablelist[17].num
	end

	if tablelist[18] then
		num = num + tablelist[18].num
	end
	return num
end
function Suanfuc.getrealvalue( v )
	local real = (v-1)%13+1
		
		if real == 2 then
			real = 15
		end
		if real == 1 then
			real = 14
		end
		if v == 53 then
			real = 16
		end
		if v == 54 then
			real = 17
		end

		if v == 55 then
			real = 18
		end
		return real
end
function Suanfuc.getmostlaizi( data )
	if data[16] then
		return 16
	end
	if data[17] then
		return 17
	end
	if data[18] then
		return 18
	end
end
function Suanfuc.getype(data)
	--单子3
	local totall= #data
	if totall == 1 then
		return {type= 1,real =Suanfuc.getrealvalue(data[1])}
	end
	--对子
	if totall == 2 then
		if Suanfuc.getrealvalue(data[1])  == Suanfuc.getrealvalue(data[2]) then
			return {type= 3,real =Suanfuc.getrealvalue(data[1])}
		elseif Suanfuc.islaiorwang(data[1]) or Suanfuc.islaiorwang(data[2]) then
			if Suanfuc.getrealvalue(data[1]) > Suanfuc.getrealvalue(data[2]) then
				return {type= 3,real =Suanfuc.getrealvalue(data[1])}
			else
				return {type= 3,real =Suanfuc.getrealvalue(data[2])}
			end
		end
	end
	local realtable = Suanfuc.getlist(data)

	-- 炸弹
	if totall >= 4  then
		local realindex = nil
		local isdan = true 
		printTable(realtable)
		for k,v in pairs(realtable) do
			if Suanfuc.islaiorwang( v.values[1]  ) == false then
				if realindex == nil then
					realindex = v.real
				else
					isdan = false 
					break
				end
			end
		end
		if isdan then
			if realindex then
				return {type= 7,real =realindex,num = totall}
			else
				return {type= 7,real =Suanfuc.getmostlaizi( realtable ),num = totall}
			end
		end
	end

	--三个
	if totall == 3  then
		local realindex = nil
		local isdan = true 
		for k,v in pairs(realtable) do
			if Suanfuc.islaiorwang( v.values[1]  ) == false then
				if realindex == nil then
					realindex = v.real
				else
					isdan = false 
					break
				end
			end
		end
		if isdan then
			if realindex then
				return {type= 5,real =realindex}
			else
				return {type= 5,real =Suanfuc.getmostlaizi( realtable )}
			end
		end
	end

	--飞机
	if totall%3 == 0 and totall >=6 then

		local num = totall/3
		local realvaluetable = {}
		for k,v in pairs(realtable) do
			if Suanfuc.islaiorwang( v.values[1]  ) == false then
				table.insert(realvaluetable,v.real)
			end
		end
		local lainum = Suanfuc.getlaizinum(realtable)
		table.sort(realvaluetable)
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
			if needlaizi ==lainum then
				return  {type= 6,real =begin,num = num}
			end
		end
	end

	--连对

	if totall%2 == 0 and totall>=4 then
		print(debug.traceback("", 2))
		print("连队")
		local num = totall/2
		local realvaluetable = {}
		for k,v in pairs(realtable) do
			if Suanfuc.islaiorwang( v.values[1]  ) == false then
				table.insert(realvaluetable,v.real)
			end
		end
		local lainum = Suanfuc.getlaizinum(realtable)
		table.sort(realvaluetable)
		printTable(realvaluetable)
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
			if needlaizi ==lainum then
				return  {type= 4,real =begin,num = num}
			end
		end
	end
	--顺子

	if  totall >= 5 then
		local num = totall
		local realvaluetable = {}
		for k,v in pairs(realtable) do
			if Suanfuc.islaiorwang( v.values[1]  ) == false then
				table.insert(realvaluetable,v.real)
			end
		end
		local lainum = Suanfuc.getlaizinum(realtable)
		table.sort(realvaluetable)
		printTable(realvaluetable)
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
				iscan = false
			else
				needlaizi=  needlaizi + 1
			end
		end
		if iscan then
			if needlaizi ==lainum then
				return  {type= 2,real =begin,num = num}
			end
		end

	end

end



function Suanfuc.tips(data,actiontable)
	local realtable = Suanfuc.getlist(data)
	local zhatable = {}
	local laizitotall = Suanfuc.getlaizinum(realtable)
	local laizitable = {}
	if realtable[16] then
		for i=1,realtable[16].num do
			table.insert(laizitable,53)
		end
	end
	if realtable[17] then
		for i=1,realtable[17].num do
			table.insert(laizitable,54)
		end
	end
	if realtable[18] then
		for i=1,realtable[18].num do
			table.insert(laizitable,55)
		end
	end
	for k,v in pairs(realtable) do
		if Suanfuc.islaiorwang( v.values[1]) == false then
			if v.num >=4 then
				table.insert(zhatable,{num = v.num,real =v.real,values = v.values,type = 7})
				realtable[k] = nil
			end
		end
		
	end
	table.sort(zhatable,function(a,b)

		print("a.real:"..a.real)
		print("b.real:"..b.real)
		if a.num == b.num then
			
			if a.real > b.real then
				return true
			else
				return false
			end
		elseif  a.num > b.num then
			print("a.num > b.num")
			return true
		else
			print("a.num < b.num")
			return false
		end
	end)
	printTable(zhatable)
	local zha1 = {}
	for i,v in ipairs(zhatable) do
		table.insert(zha1,1,v)
	end
	zhatable = zha1
	--1单张 2 顺子  3 单对 4 连队  5 3张 6飞机  7炸弹
	local enabletable = {}
	if actiontable.type == 1 then
		print("单张")
		printTable(realtable)
		for k,v in pairs(realtable) do
			if v.num ==1 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 1,real = v.real,values = v.values})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==2 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 1,real = v.real,values = {v.values[1]}})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 1,real = v.real,values = {v.values[1]}})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable
	elseif actiontable.type == 2 then

		if (actiontable.real + actiontable.num -1) >= 14 then

		else
			for j=(actiontable.real + 1),(15-actiontable.num) do
				local istrue = true
				local tablelianvalue = {}
				for i=1,actiontable.num do
					if realtable[j+i -1] and realtable[j+i -1].num > 0 and realtable[j+i -1].num < 4 then
						table.insert(tablelianvalue,realtable[j+i -1].values[1])
					else
						istrue = false
						break
					end
				end
				if istrue then
					table.insert(enabletable,{type = 2,real = j,values = tablelianvalue})
				end
			end
			

		end


		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable
	elseif actiontable.type == 3 then
		for k,v in pairs(realtable) do
			if v.num ==2 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2]}})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2]}})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable

	elseif actiontable.type == 4 then
		if (actiontable.real + actiontable.num -1) >= 14 then

		else
			for j=(actiontable.real + 1),(15-actiontable.num) do
				local istrue = true
				local tablelianvalue = {}
				for i=1,actiontable.num do
					if realtable[j+i -1] and realtable[j+i -1].num >=2  and realtable[j+i -1].num < 4 then
						table.insert(tablelianvalue,realtable[j+i -1].values[1])
						table.insert(tablelianvalue,realtable[j+i -1].values[2])
					else
						istrue = false
						break
					end
				end
				if istrue then
					table.insert(enabletable,{type = 2,real = j,values = tablelianvalue})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable
	elseif actiontable.type == 5 then
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if v.real > actiontable.real then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2],v.values[3]}})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable
	elseif actiontable.type == 6 then

		if (actiontable.real + actiontable.num -1) >= 14 then

		else
			for j=(actiontable.real + 1),(15-actiontable.num) do
				local istrue = true
				local tablelianvalue = {}
				for i=1,actiontable.num do
					if realtable[j+i -1] and realtable[j+i -1].num ==3  then
						table.insert(tablelianvalue,realtable[j+i -1].values[1])
						table.insert(tablelianvalue,realtable[j+i -1].values[2])
						table.insert(tablelianvalue,realtable[j+i -1].values[3])
					else
						istrue = false
						break
					end
				end
				if istrue then
					table.insert(enabletable,{type = 2,real = j,values = tablelianvalue})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		return enabletable
	elseif actiontable.type == 7 then
		print("z粘蛋")

		if #enabletable == 0 or #enabletable == 1 then
			local allhand = Suanfuc.getype(data)
			if allhand and allhand.type == 7 then
				if allhand.num >= actiontable.num then
					if allhand.real > actiontable.real then
						table.insert(enabletable,allhand)
						return enabletable
					end
				end
			end
		end

		for i,v in ipairs(zhatable) do
			if v.num == actiontable.num then
				if v.real > actiontable.real then
					table.insert(enabletable,v)
				end
				
			elseif v.num >= actiontable.num then
				table.insert(enabletable,v)
			end
		end
		return enabletable
		
	end

	return nil

end







