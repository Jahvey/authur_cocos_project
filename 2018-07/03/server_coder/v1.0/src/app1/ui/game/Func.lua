Func  = {}
function Func.getlist(mycards)
	local tab = {}
	for i,v in ipairs(mycards) do
		local real = (v-1)%13+1
		if tab[real] then
			tab[real] = 1+tab[real]
		else
			tab[real] = 1
		end
	end
	return tab
end

function Func.islongshunzi( mycards )
	if #mycards <13 then
		return false
	end
	local tab = {}
	local istonghua = true
	local se = nil 
	for i,v in ipairs(mycards) do
		local real = (v-1)%13+1
		if se == nil  then
			se = math.floor((v-1)/13)
		else
			if se ~= math.floor((v-1)/13) then
				istonghua = false
			end
		end
		if tab[real] then
			tab[real] = 1+tab[real]
		else
			tab[real] = 1
		end
	end
	for k,v in pairs(tab) do
		print(k,v)
	end
	for i=1,13 do
		if tab[i] ~= 1 then
			return false
		end
	end
	if istonghua then
		return 1
	else
		return 2
	end
	return false
end


function Func.issixdui(mycards)
	if #mycards <13 then
		return false
	end
	local tab= {}
	for i,v in ipairs(mycards) do
		local real = (v-1)%13+1
		if tab[real] then
			tab[real] = 1+tab[real]
		else
			tab[real] = 1
		end
	end
	local duitotall = 0
	for k,v in pairs(tab) do
		if v == 2 or v == 3 then
			duitotall = duitotall + 1
		elseif v == 4 then
			duitotall = duitotall + 2
		end
	end
	if duitotall == 6 then
		return true
	end

end


function Func.iswutong(mycards)
	if #mycards < 5 then
		return false
	end
	local realtab  = Func.getlist(mycards)
	for k,v in pairs(realtab) do
		if v == 5 then
			return true
		end
	end
	return false

end

function Func.isshunzi(mycards)
	if #mycards < 5 then
		return false
	end
	local tab = {}
	for i,v in ipairs(mycards) do
		local real = (v-1)%13+1
		if tab[real] then
			tab[real].num = 1+tab[real].num
			table.insert(tab[real].values,v)
		else
			tab[real] = {num = 1, values= {v}}
		end
	end

	for i=1,10 do
		if tab[i] then
			if (tab[i+1] and tab[i+2] and tab[i+3] and tab[i+4])  then
				return true

			elseif i == 10 and tab[i+1] and tab[i+2] and tab[i+3] and tab[1] then
				return true
			end
		end
	end
	return false
end

function Func.istonghuashun(mycards)
	local ishunzi  = Func.isshunzi(mycards)
	if ishunzi == false then
		return false
	end
	local tablese = {}
	for i,v in ipairs(mycards) do
		local se = math.floor((v-1)/13)
		if tablese[se] == nil then
			tablese[se] = {}
		end
		table.insert(tablese[se],v)
	end

	for k,v in pairs(tablese) do
		if #v >= 5 then
			if  Func.isshunzi(v) then
				return true
			end
		end
	end
	return false
end

function Func.issitiao( mycards )
	if #mycards < 5 then
		return false
	end
	local realtab  = Func.getlist(mycards)
	for k,v in pairs(realtab) do
		if v == 4 then
			return true
		end
	end
	return false
end



function Func.ishulu( mycards )
	if #mycards < 5 then
		return false
	end
	local realtab  = Func.getlist(mycards)
	local havethree = false
	local havedui = false
	printTable(realtab)
	for k,v in pairs(realtab) do
		if v >= 3 then
			print("3")
			if havethree == true then
				return true
			else
				havethree = true
				if havedui then
					return true
				end
			end
		end
		if v == 2  then
			print("2")
			havedui = true
			if havethree then
				return true
			end
		end
	end
	return false
end

function Func.isthree( mycards )
	if #mycards < 3 then
		return false
	end
	local realtab  = Func.getlist(mycards)
	local havethree = false
	local havedui = true
	for k,v in pairs(realtab) do
		if v >= 3 then
			return true
		
		end
	end
	return false
end


function Func.istonghua( mycards )
	local tablese = {}
	for i,v in ipairs(mycards) do
		local se = math.floor((v-1)/13)
		if tablese[se] == nil then
			tablese[se] = {}
		end
		table.insert(tablese[se],v)
	end
	printTable(tablese)
	for k,v in pairs(tablese) do
		if #v >= 5 then
			--if  Func.isshunzi(mycards) then
				return true
			--end
		end
	end
	return false

end


function Func.isliangdui( mycards )
	if #mycards < 5 then
		return false
	end
	
	local realtab  = Func.getlist(mycards)
	local doublenum = 0
	for k,v in pairs(realtab) do
		if v >= 2 then
			doublenum = doublenum + 1
			if doublenum >= 2 then
				return true
			end
		end
	end
	return false
end


function Func.isyidui( mycards )
	local realtab  = Func.getlist(mycards)
	local doublenum = 0
	for k,v in pairs(realtab) do
		if v >= 2 then
			return true
		end
	end
	return false
end



function Func.getlistandcards(cards)

	local tab = {}
	for i,v in ipairs(cards) do
		local real = (v-1)%13+1
		if tab[real] then
			tab[real].num = 1+tab[real].num
			table.insert(tab[real].values,v)
		else
			tab[real] = {num = 1, values= {v}}
		end
	end
	return tab
	
end
function Func.getdui(cards)
	print("1")
	local list  = Func.getlistandcards(cards)
	printTable(list)
	local cantable = {}
	
	for k,v in pairs(list) do
		if v.num >=2 then
			print("3")
			table.insert(cantable,{v.values[1],v.values[2],v.values[3]})
		end
	end
	print("2")
	if #cantable == 0 then
		return nil 
	else
		return cantable
	end
end


function Func.getdoudui( cards )
	local list  = Func.getlistandcards(cards)
	local cantable = {}
	local twotable = {}
	local smallvalues =nil 
	local realsmallvalues = nil
	for k,v in pairs(list) do
		if v.num >=2 then
			table.insert(twotable,v.values)
		else
			if realsmallvalues == nil then
				realsmallvalues = k
				smallvalues = v.values
			else
				if realsmallvalues > k and k ~= 1 then
					realsmallvalues = k
					smallvalues = v.values
				end
			end
		end
	end

	local totall = #twotable
	if totall < 2 then
		return nil
	end

	for i=1,(totall-1) do
		for j=i+1,totall do
			if realsmallvalues then
				table.insert(cantable,{twotable[i][1],twotable[i][2],twotable[j][1],twotable[j][2],smallvalues[1]})
			else
				table.insert(cantable,{twotable[i][1],twotable[i][2],twotable[j][1],twotable[j][2]})
			end
		end
	end
	if #cantable == 0 then
		return nil
	else
		printTable(cantable)
		return cantable
	end
end
function Func.getthree( cards )
	local list  = Func.getlistandcards(cards)
	local cantable = {}
	local twotable = {}
	for k,v in pairs(list) do
		if v.num >=3 then
			table.insert(twotable,{v.values[1],v.values[2],v.values[3]})
		end
	end

	local totall = #twotable
	if totall < 1 then
		return nil
	end

	for i=1,(totall) do
		table.insert(cantable,{twotable[i][1],twotable[i][2],twotable[i][3]})
	end
	if #cantable == 0 then
		return nil
	else
		printTable(cantable)
		return cantable
	end
end





function Func.getshunzi( cards )
	local list  = Func.getlistandcards(cards)
	local cantable = {}
	for i=1,10 do
		if list[i] then
			--if i ~= 10 then
				local shuntable = {}
				table.insert(shuntable,list[i].values[1])
				local isshun =true
				for j=i+1,i+4 do
					if j == 14 then
						j = 1
					end
					if list[j] then
						table.insert(shuntable,list[j].values[1])
					else
						isshun = false
						break
					end
				end
				if isshun then
					table.insert(cantable,shuntable)
				end
			--end
		end
	end
	if #cantable == 0 then
		return nil 
	else
		return cantable
	end
end


function Func.gettonghua( cards )
	local setable = {}
	for i,v in ipairs(cards) do
		local se = math.floor((v-1)/13)
		if setable[se] == nil then
			setable[se] = {v}
		else 
			table.insert(setable[se],v)
		end
	end
	local cantable = {}
	for k,v in pairs(setable) do
		if #v >= 5 then
			for i1=1,#v-4 do
				local tablecan = {}
				for i2=i1,4+i1 do
					table.insert(tablecan,v[i2])
				end
				table.insert(cantable,tablecan)
			end
			
			
		end
	end
	if #cantable == 0 then
		return nil
	else
		return cantable
	end
end

function  Func.gethulu( cards )
	local list  = Func.getlistandcards(cards)
	local threetable = {}
	local twotable = {}
	local cantable = {}
	for k,v in pairs(list) do
		if v.num >=3 then
			table.insert(threetable,v.values)
		elseif  v.num >=2 then
			table.insert(twotable,v.values)
		end
	end
	local threenum = #threetable
	local twonum = #twotable
	
	if threenum > 0 and (threenum+twonum)>=2 then
		for i,v in ipairs(threetable) do
			if twonum == 0 then
				for i1,v1 in ipairs(threetable) do
					if v ~= v1 then
						table.insert(cantable,{v[1],v[2],v[3], v1[1],v1[2]})
					end
				end
			else
				for i1,v1 in ipairs(twotable) do
					table.insert(cantable,{v[1],v[2],v[3], v1[1],v1[2]})
				end
			end
		end
	end
	printTable(cantable)
	if #cantable == 0 then
		return nil
	else
		return cantable
	end
end


function  Func.getsitiao( cards )
	local list  = Func.getlistandcards(cards)
	local cantable = {}
	local smallvalues =nil 
	local realsmallvalues = nil

	printTable(list)
	for k,v in pairs(list) do
		if v.num == 1 then
			if realsmallvalues == nil then
				realsmallvalues = k
				smallvalues = v.values
			else
				if realsmallvalues > k and k ~= 1 then
					realsmallvalues = k
					smallvalues = v.values
				end
			end
		end
	end
	for k,v in pairs(list) do
		if v.num >=4 then
			print('----yes')
			if smallvalues then
				table.insert(cantable,{v.values[1],v.values[2],v.values[3],v.values[4],smallvalues[1]})
			else
				table.insert(cantable,v.values)
			end
		else
		end
	end
	printTable(cantable)
	if #cantable == 0 then
		return nil
	else
		return cantable
	end
end

function  Func.gettonghuashun( cards )
	local setable = {}
	for i,v in ipairs(cards) do
		local se = math.floor((v-1)/13)
		if setable[se] == nil then
			setable[se] = {v}
		else 
			table.insert(setable[se],v)
		end
	end
	local cantable = {}
	printTable(setable)
	for k,v in pairs(setable) do
		if #v < 5 then
		else
			local shunzi = Func.getshunzi( v )
			if shunzi then
				for i,v1 in ipairs(shunzi) do
					table.insert(cantable,v1)
				end
				
			end
		end
	end
	if #cantable == 0 then
		return nil
	else
		return cantable
	end
end



function Func.getcardbytype(type,cards )
	if type == 1 then
		return Func.getdui(cards)
	end
	if type == 2 then
		return Func.getdoudui(cards)
	end
	if type == 3 then
		return Func.getthree(cards)
	end

	if type == 4 then
		return Func.getshunzi(cards)
	end
	if type == 5 then
		return Func.gettonghua(cards)
	end
	if type == 6 then
		return Func.gethulu( cards )
	end
	if type == 7 then
		return Func.getsitiao( cards )
	end
	if type == 8 then
		return Func.gettonghuashun(cards)
	end
end


function Func.getcardbytypesend( cards)
	if Func.iswutong(cards) then
		return 10
	end

	if Func.istonghuashun(cards) then
		return 9
	end


	if Func.issitiao(cards) then
		return 8
	end


	if Func.ishulu(cards) then
		return 7
	end

	if Func.istonghua(cards) then
		return 6
	end

	if Func.isshunzi(cards) then
		return 5
	end

	if Func.isthree(cards) then
		return 4
	end

	if Func.isliangdui(cards) then
		return 3
	end

	if Func.isyidui(cards) then
		return 2
	end

	return 1
end




