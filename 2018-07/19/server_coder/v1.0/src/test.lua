
--16近制 
--  1,2,3,4,5,6,7,8,9,//1-9 wan
-- 21,22,23,24,25,26,27,28,29,//1-9 tiao
-- 41,42,43,44,45,46,47,48,49,//1-9 tong

local function lessneedzhong(totall)
	if totall%3 == 2 then
		return 0,true
	elseif totall%3 == 1 then
		return 1,true
	elseif totall%3 == 0 then
		return 0,false
	end

end

local function realneedzhong(tab)
	local totall = #tab
	
end

function checkcanHu(tab)
	local majlist = {}
	majlist["113"] = 0
	local tongtotall = 0
	local tiaototall = 0
	local wantotall = 0
	for i,v in ipairs(tab) do
		if majlist[tostring(v)] == nil then
			majlist[tostring(v)] = 1
		else
			majlist[tostring(v)] = majlist[tostring(v)] + 1
		end
		if v < 0x09 then
			wantotall = wantotall + 1
		elseif v < 0x29 then
			tiaototall = tiaototall + 1
		elseif v < 0x49 then
			tongtotall = tongtotall + 1
		end
	end
	if wantotall > 0 and tiaototall > 0 and tongtotall > 0 then
		print("三色牌")
		return false
	end
	--至少需要的红中数
	local lessneed = 0
	local lesshavedoubel = false
	if wantotall > 0 then
		local need,havedoubel = lessneedzhong(wantotall)
		lessneed = need + lessneed
		lesshavedoubel = havedoubel
	end

	if tongtotall > 0 then
		local need,havedoubel = lessneedzhong(tongtotall)
		lessneed = need + lessneed
		if lesshavedoubel and havedoubel then
			lesshavedoubel = true
			lessneed = lessneed + 1
		end
	end

	if tiaototall > 0 then
		local need,havedoubel = lessneedzhong(tiaototall)
		lessneed = need + lessneed
		if lesshavedoubel and havedoubel then
			lesshavedoubel = true
			lessneed = lessneed + 1
		end
	end
	if lessneed > majlist["113"] then
		return false
	end

	--精确计算需要好多红中

end
