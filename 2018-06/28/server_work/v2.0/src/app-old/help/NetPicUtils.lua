--
-- NetPicUtils.lua
-- 网络图片下载
-- yc
--

NetPicUtils = {}
local PIC_PATH = "download_pic"

local downloadMap = {}
setmetatable(downloadMap, {__mode = "k"})

local function getLocalPic( url )
	local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.. PIC_PATH .. device.directorySeparator
	-- print("NetPicUtils.getLocalPic "..path)
	local FileUtils = cc.FileUtils:getInstance()

	-- if not io.exists(path) then
	if not FileUtils:isDirectoryExist(path) then	
		-- require "lfs"	
		--目录不存在，创建此目录
		if FileUtils:createDirectory(path) then
			print("创建成功")
			return
		else
			print("创建失败")	
		end	
	end
	local picPath = path..CryTo:Md5(url)
	-- if io.exists(picPath) then
	if FileUtils:isFileExist(picPath) then
		print("NetPicUtils.getLocalPic suc "..picPath)
		return picPath
	else
		return
	end
end

local function downloadPic( picurl, imageView)
	if string.find(picurl, "http") == nil or not imageView then
		--print("not find")
		return 
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", picurl)
	local function onDownloadImage()
	    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   	  	local fileData = xhr.response
	        -- local file = io.open(fullFileName,"wb")
	        -- file:write(fileData)
	        -- file:close()
	       	-- local picPath = cc.FileUtils:getInstance():getWritablePath().."2.jpg"
	        local picPath = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.. PIC_PATH .. device.directorySeparator .. CryTo:Md5(picurl)
	       	-- local picPath = cc.FileUtils:getInstance():getWritablePath()..PIC_PATH.."/".."2.jpg"
	        io.writefile(picPath,fileData)
	     	for i,v in ipairs(downloadMap[picurl]) do
				if not tolua.isnull(v) then
					v:loadTexture(picPath, ccui.TextureResType.localType)
					v:setVisible(true)
					--下载完毕默认调用
					if v.downcallback then
						v.downcallback(v)
					end
				end
			end
			downloadMap[picurl] = nil
		else
			print("failed")	
			for i,v in ipairs(downloadMap[picurl]) do
				if not tolua.isnull(v) then
					v:loadTexture("common/null.png", ccui.TextureResType.localType)
					v:setVisible(true)
					--下载完毕默认调用
					if v.downcallback then
						v.downcallback(v)
					end
				end
			end
	    end
	end
	xhr:registerScriptHandler(onDownloadImage)
	xhr:send()
end

-- 获取网络图片，下载成功后会自动更新图片
-- imageView:需要下载图片的view，类型必须是ccui.ImageView,默认下载完毕调用 图片的 downcallback函数
-- url:图片的url
function NetPicUtils.getPic( imageView, url)
	-- print("url:"..url)
	if url and string.len(url) > 0 then
		print("local pic ")
		local pic = getLocalPic(url)
		if pic then
			--print(pic)
			local image = cc.Director:getInstance():getTextureCache():addImage(pic)
			if image == nil then
				return
			end
			-- if pic 
			imageView:loadTexture(pic, ccui.TextureResType.localType)

			imageView:setVisible(true)
			--下载完毕默认调用
			if imageView.downcallback then
				imageView.downcallback(imageView)
			end
			return
		else
			print("down pic")
			local num
			-- cc(imageView):addNodeEventListener(cc.NODE_EVENT, function(event)
	  --           if event.name == "exit" then
	  --           	if downloadMap[url] then
	  --           		table.remove(downloadMap[url], num)
	  --           	end 
	  --           end
	  --       end)

			imageView:registerScriptHandler(function(tag)

					if tag == "enter" then
						print("enter")
					elseif tag == "exit" then
						print("exit")
						if downloadMap[url] then
	            			table.remove(downloadMap[url], num)
	            		end 
					end			
			end)

	        if downloadMap[url] then
				table.insert(downloadMap[url], imageView)
				num = #downloadMap[url]
				return
			end
			downloadMap[url] = {}
			setmetatable(downloadMap[url], {__mode = "k"})
			table.insert(downloadMap[url], imageView)
			num = #downloadMap[url]

			downloadPic(url, imageView)

			return
		end
	else
		return
	end
end

function NetPicUtils.removeFile( url )
	local path = getLocalPic(url)
	if path then
		local textureCache = cc.Director:getInstance():getTextureCache()
		cc.FileUtils:getInstance():removeFile(path)
		textureCache:removeTextureForKey(path)
	end
end

return NetPicUtils