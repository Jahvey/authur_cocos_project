
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	a={"hello","world","a",a=1,b=2,c=3,d=4,"good","body"}
	for k,v in pairs(a) do
		print(k,v)
	end
	print("=============")
	for i,v in ipairs(a) do
		print(i,v)
	end

    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World adonai!!!!", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
