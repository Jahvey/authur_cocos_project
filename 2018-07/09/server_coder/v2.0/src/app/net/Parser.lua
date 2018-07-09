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

-- 解析包头
local function parseHeader( data )
	local p = data:getPos()
	local length = -1

	data:setPos(INTEGER_LENGTH + 1)
	-- 校验信息
	if data:readStringBytes(2) == "XX" then
		data:setPos(1)
		length = data:readUInt()
	end
	data:setPos(p)

	-- 由于length不包含自身int占的四个字节，再减去XX的两个字节，就是剩下的长度
	return length-2
end

-- protobuf数据转table
local function protobuf2Table( data)
    assert(data,"protobuf2Table the data is must not nil")

    local FieldDescriptor = require("descriptor").FieldDescriptor

    local function field2value( field, value )
        local tab = {}

        if field.cpp_type == FieldDescriptor.CPPTYPE_MESSAGE then

            if field.label == FieldDescriptor.LABEL_REPEATED then
                for i,v in ipairs(value) do
                    tab[i] = protobuf2Table(v)
                end
            else
                tab = protobuf2Table(value)
            end
        else
            if field.label == FieldDescriptor.LABEL_REPEATED then
                for i,v in ipairs(value) do
                    table.insert(tab, v )
                end
            else
                tab = value
            end
        end

        return tab
    end
        
    local result = {}
    for field, value in pairs(data._fields) do
        result[field.name] = field2value(field, value)
    end

    return result
end

-- 解析包体
local function parseBody( data )
	data:setPos(HEADER_LENGTH + 1)
	local len1 = data:readUInt()
	data:setPos(HEADER_LENGTH + INTEGER_LENGTH + 1)
	local head = poker_msg_pb.PBHead()
	head:ParseFromString(data:readBuf(len1))
	-- TODO header数据相关，以后需要处理的时候再加

	local bodyPos = HEADER_LENGTH + INTEGER_LENGTH + len1 + 1
	data:setPos(bodyPos)
	local len2 = data:readUInt()
	data:setPos(bodyPos+INTEGER_LENGTH)
	local msg = poker_msg_pb.PBCSMsg()
	msg:ParseFromString(data:readBuf(len2))

	return protobuf2Table(msg),protobuf2Table(head)
end

local function writeBytes( buf, data, len )
	for i=1,len do
		buf:writeRawByte(data:readRawByte())
	end
end

-- 返回false表示失败，true和解析后的数据都表示成功
function Parser:readPackage( data )
	local utils = require("cocos.utils.init")
	local buf = utils.ByteArray.new(utils.ByteArray.ENDIAN_BIG)
	buf:writeBuf(data)
    buf:setPos(1)
    -- print("[socket data] " .. buf:toString())

	local dataLen = buf:getLen()
	
	local result = {}
	local headResult = {}
	while true do
		if buf:getAvailable() <= 0 then
			break
		end

		if not self.buffer then
			self.buffer = utils.ByteArray.new(utils.ByteArray.ENDIAN_BIG)
		else
			self.buffer:setPos(self.buffer:getLen() + 1)
		end

		local bufferLen = self.buffer:getLen()
		local totalLen = dataLen + bufferLen
		if totalLen >= HEADER_LENGTH then
			if bufferLen < HEADER_LENGTH then
				-- 缓存加上收到的数据才够包头，把包头数据写完
				writeBytes(self.buffer, buf, HEADER_LENGTH - bufferLen)
				dataLen = dataLen - (HEADER_LENGTH - bufferLen)
				bufferLen = self.buffer:getLen()
			end
			
			local bodyLen = parseHeader(self.buffer)
			local packageLen = HEADER_LENGTH + bodyLen

			if bodyLen > 0 then
				if totalLen >= packageLen then
					if bufferLen < packageLen then
						-- 缓存加上收到的数据才够包体，把包体写完
						writeBytes(self.buffer, buf, packageLen - bufferLen)
						dataLen = dataLen - (packageLen - bufferLen)
					end

					-- print("[socket package] " .. self.buffer:toString())

					result[#result+1],headResult[#headResult+1] = parseBody(self.buffer)
					self:reset()
				else
					-- 没收到完整包体，全部写入缓存
					writeBytes(self.buffer, buf, dataLen)
				end
			elseif bodyLen == 0 then
				-- 包体为空
				result[#result+1] = {["bodyLength"] = 0}
				self:reset()
			else
				-- 数据错误，直接返回，断开链接重连
	            self:reset()
				return false
			end
		else
			-- 没有收到完整包头，全部写入缓存
			writeBytes(self.buffer, buf, dataLen)  
		end
	end
	
	return result,headResult
end

function Parser:reset( )
	self.buffer = nil
end

return Parser