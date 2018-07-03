

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
	if totall == 1 and  Suanfuc.islaiorwang( data[1] ) == false then
		return {type= 1,real =Suanfuc.getrealvalue(data[1])}
	end
	--对子
	if totall == 2 then
		if Suanfuc.getrealvalue(data[1])  == Suanfuc.getrealvalue(data[2]) and Suanfuc.islaiorwang( data[1] ) == false then
			return {type= 3,real =Suanfuc.getrealvalue(data[1])}
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
			if realindex == nil then
				realindex = v.real
			else
				isdan = false 
				break
			end
		end
		if isdan and Suanfuc.islaiorwang(data[1]) == false then
			return {type= 5,real =realindex}
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
			if needlaizi ==lainum and lainum == 0 then
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
			if needlaizi ==lainum and needlaizi == 0 then
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
			if needlaizi ==lainum and needlaizi == 0 then
				return  {type= 2,real =begin,num = num}
			end
		end

	end

end



function Suanfuc.tips(data,actiontable)
	local mosttype,mostnum = Suanfuc.getmostzha(data)
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
	--printTable(zhatable)
	local zha1 = {}


	for i,v in ipairs(zhatable) do
		table.insert(zha1,1,v)
	end
	zhatable = zha1
	local addzhatable = {}
	if laizitotall > 0 then
		print("1")
		local sutable = {}
		for i=3,15 do
			if realtable[i] then
				table.insert(sutable,realtable[i])
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(sutable,v)
		end
		table.sort(sutable,function(a,b)
			if a.num > b.num then
				return true
			elseif a.num == b.num then
				if a.real >b.real then
					return false
				else
					return true
				end
			else
				return false
			end
		end)
		printTable(sutable)
		if mosttype == 1 then
			print("2")
			if sutable[1] and sutable[2] and (sutable[1].num == sutable[2].num) then
				for i,v in ipairs(sutable) do
					print(v.num)
					print(mostnum)
					if v.num == mostnum then
						local tab = {num = v.num,real =v.real,values = v.values,type = 7}
						tab.values = clone(v.values)
						for i1,v1 in ipairs(laizitable) do
							table.insert(tab.values,v1)
						end
						tab.num = laizitotall + tab.num
						table.insert(zhatable,tab)
					end
				end
			elseif sutable[1] then

				local tab = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab.values = clone(sutable[1].values)
				for i1,v1 in ipairs(laizitable) do
					table.insert(tab.values,v1)
				end
				tab.num = laizitotall + tab.num
				for i,v in ipairs(zhatable) do
					if v.real == tab.real then
						zhatable[i] = tab
						tab = nil 
					end
				end
				if tab  then
					table.insert(zhatable,tab)
				end
			end
		elseif mosttype == 2 then
			if sutable[1] and sutable[2] and sutable[3] and (sutable[1].num == sutable[2].num) and (sutable[2].num == sutable[3].num) then
				local tab = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab.values = clone(sutable[1].values)
				for i1,v1 in ipairs(laizitable) do
					table.insert(tab.values,v1)
				end
				tab.num = laizitotall + tab.num
				zhatable[#zhatable] = nil
				table.insert(zhatable,tab)

			else
				zhatable[#zhatable] = nil
				zhatable[#zhatable] = nil
				local tab1 = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab1.num = tab1.num + 1
				tab1.values = clone(sutable[1].values)
				table.insert(tab1.values,laizitable[1])

				local tab2 = {num = sutable[2].num,real =sutable[2].real,values = sutable[2].values,type = 7}
				tab2.values = clone(sutable[2].values)
				tab2.num = tab2.num + 1
				table.insert(tab2.values,laizitable[2])

				local tab3 = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab3.values = clone(sutable[1].values)
				tab3.num = tab3.num + 2
				table.insert(tab3.values,laizitable[1])
				table.insert(tab3.values,laizitable[2])


				local tab4 = {num = sutable[2].num,real =sutable[2].real,values = sutable[2].values,type = 7}
				tab4.values = clone(sutable[2].values)
				tab4.num = tab4.num + 2
				table.insert(tab4.values,laizitable[1])
				table.insert(tab4.values,laizitable[2])

				table.insert(zhatable,tab1)
				table.insert(zhatable,tab2)
				table.insert(zhatable,tab3)
				table.insert(zhatable,tab4)
				
			end
		elseif mosttype == 3 then
			if sutable[2] and sutable[3] and (sutable[2].num == sutable[3].num) then
				local tab = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab.values = clone(sutable[1].values)
				for i1,v1 in ipairs(laizitable) do
					table.insert(tab.values,v1)
				end
				tab.num = laizitotall + tab.num
				zhatable[#zhatable] = nil
				table.insert(zhatable,tab)
			else
				-- zhatable[#zhatable] = nil
				-- zhatable[#zhatable] = nil

				local tab2 = {num = sutable[2].num,real =sutable[2].real,values = sutable[2].values,type = 7}
				tab2.values = clone(sutable[2].values)
				tab2.num = tab2.num + 1
				table.insert(tab2.values,laizitable[1])
				table.insert(zhatable,tab2)

				local tab1 = {num = sutable[1].num,real =sutable[1].real,values = sutable[1].values,type = 7}
				tab1.num = tab1.num + 1
				tab1.values = clone(sutable[1].values)
				table.insert(tab1.values,laizitable[1])
				table.insert(zhatable,tab1)

			end
		end
	end


	--1单张 2 顺子  3 单对 4 连队  5 3张 6飞机  7炸弹
	local enabletable = {}
	if actiontable.type == 1 then
		print("单张")
		--printTable(realtable)
		for k,v in pairs(realtable) do
			if v.num ==1 then
				if v.real > actiontable.real then
					if Suanfuc.islaiorwang(v.values[1]) == false then
						table.insert(enabletable,{type = 1,real = v.real,values = v.values})
					end
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==2 then
				if v.real > actiontable.real then
					if Suanfuc.islaiorwang(v.values[1]) == false then
						table.insert(enabletable,{type = 1,real = v.real,values = {v.values[1]}})
					end
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if Suanfuc.islaiorwang(v.values[1]) == false then
					if v.real > actiontable.real then
						table.insert(enabletable,{type = 1,real = v.real,values = {v.values[1]}})
					end
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		--return enabletable
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
		--return enabletable
	elseif actiontable.type == 3 then
		for k,v in pairs(realtable) do
			if v.num ==2   then
				if v.real > actiontable.real and Suanfuc.islaiorwang(v.values[1]) == false then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2]}})
				end
			end
		end
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if v.real > actiontable.real and Suanfuc.islaiorwang(v.values[1]) == false then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2]}})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		--return enabletable

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
		--return enabletable
	elseif actiontable.type == 5 then
		for k,v in pairs(realtable) do
			if v.num ==3 then
				if v.real > actiontable.real and Suanfuc.islaiorwang(v.values[1]) == false then
					table.insert(enabletable,{type = 3,real = v.real,values = {v.values[1],v.values[2],v.values[3]}})
				end
			end
		end
		for i,v in ipairs(zhatable) do
			table.insert(enabletable,v)
		end
		--return enabletable
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
		--return enabletable
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
		--return enabletable
		
	end
	local enabletable1 = {}
	for i,v in ipairs(enabletable) do
		if Suanfuc.iscanchu(v,data,mosttype,mostnum) then
			table.insert(enabletable1,v)
		end
	end
	return enabletable1

end

function Suanfuc.iscanchu(action,hand,mosttype,mostnum)
	local realtable = Suanfuc.getlist(hand)
	local laizitotalllocal = Suanfuc.getlaizinum(realtable)
	print("laizi1:"..laizitotalllocal)
	-- local zhatable = {}
	-- local laizitotall = Suanfuc.getlaizinum(realtable)
	if mosttype == 0 then
		return true
	end

	for i,v in ipairs(action.values) do
			local real = Suanfuc.getrealvalue( v )
			realtable[real].num = realtable[real].num - 1
		end

	local laizitotall = Suanfuc.getlaizinum(realtable)
	print("laizi2:"..laizitotall)
	local sutable = {}
	for i=3,15 do
		if realtable[i] then
			table.insert(sutable,realtable[i])
		end
	end
	table.sort(sutable,function(a,b)
		if a.num > b.num then
			return true
		end
	end)

	if action.type ~= 7 then
		
		if mosttype == 1 then
			if sutable[1].num == mostnum then
				return true
			else
				return false
			end
		elseif mosttype == 2 then
			if sutable[1] and sutable[1].num == 5 then
				return true
			else
				return false
			end
		elseif mosttype == 3 then
			if sutable[1] and sutable[1].num == 6   then
				return true
			else
				return false
			end
		end

	else
		if mosttype == 1 then
			if sutable[1].num ~= mostnum then
				if action.num == (mostnum + laizitotalllocal) then
					return true
				else
					return false
				end
			else
				if action.num == (mostnum + laizitotalllocal) then
					return true
				else
					if laizitotalllocal == laizitotall then
						return true
					else
						return false
					end
				end
			end
		elseif mosttype == 2 then
			if action.num == 7 then
				return true
			elseif action.num == 6 then
				return true
			elseif sutable[1] and sutable[2] and sutable[1].num == 5 and  sutable[2].num == 5 and laizitotall == 2 then
				return true
			elseif sutable[1] and sutable[1].num == 5 and laizitotall == 2 then
				return true
			else
				return false
			end
		elseif mosttype == 3 then
			if action.num == 7 then
				return true
			elseif action.num == 6 then
				return true
			elseif sutable and sutable[1].num == 6 and  laizitotall == 1 then
				return true
			else
				return false
			end
		end


	end



	-- local realtable = Suanfuc.getlist(data)
end

function Suanfuc.getmostzha(data)
	local realtable = Suanfuc.getlist(data)
	local laizitotall = Suanfuc.getlaizinum(realtable)
	if laizitotall == 0 then
		return 0
	end
	local sutable = {}
	for i=3,15 do
		if realtable[i] then
			table.insert(sutable,realtable[i])
		end
	end
	table.sort(sutable,function(a,b)
		if a.num > b.num then
			return true
		end
	end)
	printTable(sutable)
	local mostnumber = sutable[1].num
	if mostnumber == 5 and laizitotall == 2 and sutable[2] and sutable[2].num == 5 then
		print("most:"..2)
		return 2
	end
	if mostnumber == 6 and laizitotall == 1 then
		for i,v in ipairs(sutable) do
			if v.num == 5 then
				print("most:"..3)
				return 3
			end
		end
	end
	print("mostnum:"..mostnumber)
	return 1,mostnumber
end









