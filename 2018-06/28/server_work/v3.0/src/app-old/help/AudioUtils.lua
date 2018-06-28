--
-- AudioUtils.lua
-- yc
-- 2016-11-2

AudioUtils = {}
local function playMP3( name,loop )
	return audio.playSound('sound/' .. name .. '.mp3', loop)
end

function AudioUtils.playEffect( name, loop )
	if loop then
		return playMP3(name, true)
	else
		return playMP3(name, false)
	end
end
-- 播放语音 分0 男 1 女 2 未知  默认女生
function AudioUtils.playVoice(name,sex,loop)
	if not loop then
		loop = false
	end
	-- print("性别 ===",sex)

	if sex == 0 then
		return audio.playSound('effectsound/man/'.. name ..'.mp3', loop)
	else
		-- return audio.playSound('effectsound/women/' .. name ..'.mp3',loop)
		return audio.playSound('effectsound/wowen/' .. name ..'.mp3', loop)
	end	
end
function AudioUtils.playMusic( music,isloop)
	if isloop == nil then
		isloop = false
	end
	if device.platform == "windows" or device.platform == "mac" then 
		AudioUtils.stopMusic(true)
		AudioUtils.stopAllSounds()
		return true
	end
	AudioUtils.localmp3 = music
	if music == nil then
		audio.playMusic('sound/bgm1.mp3', true)
	else
		audio.playMusic('sound/'..music..'.mp3', isloop)
	end
end
function AudioUtils.setSoundsVolume(value)
	if value > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",value)
    elseif value == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",-1)
    end

 	audio.setSoundsVolume(value/100)
 	cc.UserDefault:getInstance():flush()
end

function AudioUtils.getSoundsVolume()
	local value = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    if value == 0 then
        value = 100
    elseif value == -1 then
        value = 0 
    end 
	return value
end

function AudioUtils.setMusicVolume(value)
    if value > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",value)
    elseif value == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",-1)
    end
  
	audio.setMusicVolume(value/100)
	cc.UserDefault:getInstance():flush()
end

function AudioUtils.getMusicVolume()
	local value = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    if value == 0 then
        value = 100
    elseif value == -1 then
        value = 0 
    end
 	return value
end
function AudioUtils.stopMusic(bol)
	audio.stopMusic(bol)
end

function AudioUtils.stopAllSounds()
	audio.stopAllSounds()
end


return AudioUtils