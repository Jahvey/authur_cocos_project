
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false
CONFIG_SCREEN_WIDTH = 1280
CONFIG_SCREEN_HEIGHT = 720
-- for module display
CC_DESIGN_RESOLUTION = {
    width = CONFIG_SCREEN_WIDTH,
    height = CONFIG_SCREEN_HEIGHT,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        -- local ratio = framesize.width / framesize.height
        -- if ratio <= 1.34 then
        --     -- iPad 768*1024(1536*2048) is 4:3 screen
        --     return {autoscale = "SHOW_ALL"}
        -- end
        -- local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
        if framesize.width / framesize.height > CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
            return  {autoscale = "FIXED_HEIGHT"}
        else
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}
FONTNAME_DEF = "cocostudio/res/fonts/DFYuanW7-GB2312.ttf"


CONFIG_REC_VERSION = 9
--是否是审核包 服务器控制的
--SHENHEBAO = true
SHENHEBAONEEDHTTP =false

