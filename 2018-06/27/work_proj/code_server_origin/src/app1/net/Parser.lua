--
-- Parser.lua
-- liyanzi
-- 解析协议返回数据
--

local HEADER_LENGTH = 6
local INTEGER_LENGTH = 4

local Parser = class("Parser")

function Parser:ctor( )
	-- empty
end


-- 返回false表示失败，true和解析后的数据都表示成功
function Parser:readPackage( data )
	-- local find = string.find(data,"\r\n")
	-- print(find)
	local getstr = data
	local result ={}
	while true do
		local find = string.find(getstr,"\r\n")
		if find then
			if find == 1 then
			else
				if self.buffer == nil then
					self.buffer = string.sub(getstr,1, find - 1)
				else
					--print(self.buffer)
					self.buffer = self.buffer..string.sub(getstr,1, find - 1)
				end
			end
			table.insert(result,self.buffer)
			self:reset()
			getstr = string.sub(getstr,find+2)

		else
			if self.buffer == nil then
				self.buffer = getstr
			else
				self.buffer = self.buffer..getstr
			end
			break
		end
	end
	return result
end

function Parser:reset( )
	self.buffer = nil
end

return Parser