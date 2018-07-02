--
-- PackageBuilder.lua
-- 将要发送的数据按协议格式打包
-- liyanzi
--

local PackageBuilder = class("PackageBuilder")

function PackageBuilder:ctor( )
	self:init()
end

function PackageBuilder:init( )
    self.msgIds = {}
    require "poker_msg_pb"
    for i,v in ipairs(poker_msg_pb.PBCSMSG.fields) do
        self.msgIds[v.name] = v.number
    end
end

-- 打包数据
-- 格式：
-- | int , char , char                                  | int , binary                                 | int , binary                                 |
-- | 包长度（不包含自身int的四字节）, 两个标志位"X","X" | protobuf包头数据长度，protobuf包头二进制数据 | protobuf包体数据长度，protobuf包体二进制数据 |
-- param 为额外参数
function PackageBuilder:buildPackage( msgName, msg ,param)
    local utils = require("cocos.utils.init")
	local data = utils.ByteArray.new(utils.ByteArray.ENDIAN_BIG)

    local headLen = 6
    local intLen = 4

	-- 写包头，包长度先写0
    data:writeUInt(0)                          -- 包体长度
	data:writeStringBytes("XX")				  -- XX
	
    -- protobuf包头
    data:writeUInt(0)
    data:writeStringBytes(self:buildHeader( msgName ,param))
    local pbHeadLen = data:getLen() - (headLen + intLen)
    -- 修改protobuf包头长度
    data:setPos(headLen + 1)
    data:writeUInt(pbHeadLen)

    -- protobuf包体
    local dataStartPos = data:getLen() + 1
	data:setPos(dataStartPos)
    data:writeUInt(0)
    -- print("msg:"..string.len(msg:SerializeToString()))
    data:writeStringBytes(msg:SerializeToString())
    local pbDataLen = data:getLen() - (headLen + intLen + pbHeadLen + intLen)
    -- 修改protobuf包体长度
    data:setPos(dataStartPos)
    data:writeUInt(pbDataLen)

    -- 修改包长度，包长度不包含长度字节本身占的四个字节
    data:setPos(1)
    data:writeUInt(data:getLen() - intLen)

	return data
end

function PackageBuilder:buildHeader( msgName ,param)
    local msg = poker_msg_pb.PBHead()

    msg.main_version = 1
    msg.sub_version = 1
    msg.imei = "11"
    msg.cmd = self.msgIds[msgName]
    msg.channel_id = CLIENT_QUDAO
    msg.device_name = device.platform
    msg.device_id = "ssssss"
    msg.band = "1"
    msg.proto_version = 1

    if param  then
        if param.json_msg_id then
            msg.json_msg_id = param.json_msg_id
        end
        if param.json_msg then
            msg.json_msg = param.json_msg
        end 
    end    

    local data = msg:SerializeToString()
    
    return data
end

return PackageBuilder