local moveVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float ratio; \n"..
"uniform float radius; \n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec4 v_fragmentColor;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..

"   float halfPeri = radius * 3.14159; \n"..
"   float hr = height * ratio;\n"..
"   if(hr > 0.0 && hr <= halfPeri){\n"..
"         if(tmp_pos.y < hr){\n"..
"               float rad = hr/ 3.14159;\n"..
"               float arc = (hr-tmp_pos.y)/rad;\n"..
"               tmp_pos.y = hr - sin(arc)*rad;\n"..
"               tmp_pos.z = rad * (1.0-cos(arc)); \n"..
"          }\n"..
"   }\n"..
"   if(hr > halfPeri){\n"..
"        float straight = (hr - halfPeri)/2.0;\n"..
"        if(tmp_pos.y < straight){\n"..
"            tmp_pos.y = hr  - tmp_pos.y;\n"..
"            tmp_pos.z = radius * 2.0; \n"..
"        }\n"..
"        else if(tmp_pos.y < (straight + halfPeri)) {\n"..
"            float dy = halfPeri - (tmp_pos.y - straight);\n"..
"            float arc = dy/radius;\n"..
"            tmp_pos.y = hr - straight - sin(arc)*radius;\n"..
"            tmp_pos.z = radius * (1.0-cos(arc)); \n"..
"        }\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    float y1 = tmp_pos.y;\n"..
"    float z1 = tmp_pos.z;\n"..
"    float y2 = height;\n"..
"    float z2 = 0.0;\n"..
"    float sinRat = sin(rotation);\n"..
"    float cosRat = cos(rotation);\n"..
"    tmp_pos.y=(y1-y2)*cosRat-(z1-z2)*sinRat+y2;\n"..
"    tmp_pos.z=(z1-z2)*cosRat+(y1-y2)*sinRat+z2;\n"..
"    tmp_pos.y = tmp_pos.y - height/2.0*(1.0-cosRat);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = a_texCoord;\n"..
"}\n";

local smoothVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float cl = height/5.0;\n"..
"    float sl = (height - cl)/2.0;\n"..
"    float radii = (cl/rotation)/2.0;\n"..
"    float sinRot = sin(rotation);\n"..
"    float cosRot = cos(rotation);\n"..
"    float distance = radii*sinRot;\n"..
"    float centerY = height/2.0;\n"..
"    float poxY1 = centerY - distance;\n"..
"    float poxY2 = centerY + distance;\n"..
"    float posZ = sl*sinRot;\n"..
"    if(tmp_pos.y <= sl){\n"..
"       float length = sl - tmp_pos.y;\n"..
"       tmp_pos.y = poxY1 - length*cosRot;\n"..
"       tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    else if(tmp_pos.y < (sl+cl)){\n"..
"       float el = tmp_pos.y - sl;\n"..
"       float rotation2 = -el/radii;\n"..
"       float x1 = poxY1;\n"..
"       float y1 = posZ;\n"..
"       float x2 = centerY;\n"..
"       float y2 = posZ - radii*cosRot;\n"..
"       float sinRot2 = sin(rotation2);\n"..
"       float cosRot2 = cos(rotation2);\n"..
"       tmp_pos.y=(x1-x2)*cosRot2-(y1-y2)*sinRot2+x2;\n"..
"       tmp_pos.z=(y1-y2)*cosRot2+(x1-x2)*sinRot2+y2;\n"..
"    }\n"..
"    else if(tmp_pos.y <= height){\n"..
"        float length = tmp_pos.y - cl - sl;\n"..
"        tmp_pos.y = poxY2 + length*cosRot;\n"..
"        tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, 1.0-a_texCoord.y);\n"..
"}\n"

local endVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, 1.0-a_texCoord.y);\n"..
"}\n"

local strFragSource =
"varying vec2 v_texCoord;\n"..
"void main()\n"..
"{\n"..
    "//TODO, 这里可以做些片段着色特效\n"..
    "gl_FragColor = texture2D(CC_Texture0, v_texCoord);\n"..
"}\n"

local RubCardLayer_Pai = 3.141592
local RubCardLayer_State_Move = 1
local RubCardLayer_State_Smooth = 2
local RubCardLayer_RotationFrame = 10
local RubCardLayer_RotationAnger = RubCardLayer_Pai/3
local RubCardLayer_SmoothFrame = 10
local RubCardLayer_SmoothAnger = RubCardLayer_Pai/6

local RubCardLayer = {}

local function EJExtendUserData(luaCls, cObj)
    local t = tolua.getpeer(cObj)
    if not t then
        t = {}
        tolua.setpeer(cObj, t)
    end
    setmetatable(t, luaCls)
    return cObj 
end

function RubCardLayer:create(szBack, szFont, posX, posY,scale, endCallBack)
    local layer = EJExtendUserData(RubCardLayer, cc.Layer:create())
    self.__index = self
    layer:__init(szBack, szFont, posX, posY, scale,endCallBack)
    return layer
end

function RubCardLayer:__init(szBack, szFont, posX, posY, scale,endCallBack)
    self.posX = posX
    self.posY = posY
    self.szFont = szFont
    self.endCallBack = endCallBack
    self.scale = scale

    local glNode = gl.glNodeCreate()
    self.glNode = glNode
    self:addChild(glNode)

    local moveGlProgram = cc.GLProgram:createWithByteArrays(moveVertSource, strFragSource)
    self.moveGlProgram = moveGlProgram
    moveGlProgram:retain()
    moveGlProgram:updateUniforms()
    
    local smoothGlProgram = cc.GLProgram:createWithByteArrays(smoothVertSource, strFragSource)
    self.smoothGlProgram = smoothGlProgram
    smoothGlProgram:retain()
    smoothGlProgram:updateUniforms()

    local endGlProgram = cc.GLProgram:createWithByteArrays(endVertSource, strFragSource)
    self.endGlProgram = endGlProgram
    endGlProgram:retain()
    endGlProgram:updateUniforms()
    self:__createLb()
    self:__registerTouchEvent()

    self.state = RubCardLayer_State_Move

    local backSprite = cc.Sprite:create(szBack)
    self.backSprite = backSprite
    backSprite:retain()
    local id1, texRange1, sz1 = self:__getRange(backSprite)
    self.sz1 = sz1
    local msh1, nVerts1 = self:__initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)

    local frontSprite = cc.Sprite:create(szFont)
    self.frontSprite = frontSprite
    frontSprite:retain()
    local id2, texRange2, sz2 = self:__getRange(frontSprite)
    local msh2, nVerts2 = self:__initCardVertex(cc.size(sz2[1] * scale, sz2[2] * scale), texRange2, false)

    self.ratioVal = 0
    self.radiusVal = sz1[2]*scale/10;

    self.pokerHeight = sz1[2] * scale

    self.offx = self.posX - self.sz1[1]/2*self.scale
    self.offy = self.posY - self.sz1[2]/2*self.scale
    --牌的渲染信息 
    local cardMesh = {{id1, msh1, nVerts1},{id2, msh2, nVerts2} }
    self.cardMesh = cardMesh
    -- OpenGL绘制函数
    local function draw(transform, transformUpdated)
        if self.state == RubCardLayer_State_Move then
            self:__drawByMoveProgram(0)
        elseif self.state == RubCardLayer_State_Smooth then
            if self.smoothFrame == nil then
                self.smoothFrame = 1
            end
            if self.smoothFrame <= RubCardLayer_RotationFrame then
                self:__drawByMoveProgram(-RubCardLayer_RotationAnger*self.smoothFrame/RubCardLayer_RotationFrame)
            elseif self.smoothFrame < (RubCardLayer_RotationFrame+RubCardLayer_SmoothFrame) then
                local scale = (self.smoothFrame - RubCardLayer_RotationFrame)/RubCardLayer_SmoothFrame
                self:__drawBySmoothProgram(math.max(0.01,RubCardLayer_SmoothAnger*(1-scale)))
            else
                if self.endCallBack then
                    self.endCallBack()
                    self.endCallBack = nil
                end
                if not self.isCreateNum then
                    --self:__createNum()
                    self.isCreateNum = true
                end
                self:__drawByEndProgram()
            end
            self.smoothFrame = self.smoothFrame + 1
        end
    end
    glNode:registerScriptDrawHandler(draw)
end

function RubCardLayer:__createNum()
    local numPicRight = cc.Sprite:create(self.szNum)
    local pokerSize = numPicRight:getContentSize()
    local pokerWidth = pokerSize.width
    local pokerHeight = pokerSize.height
    numPicRight:setRotation(90)
    numPicRight:setPosition(self.posX+self.sz1[1]/2-pokerHeight/2, self.posY+self.sz1[2]/2-pokerWidth/2)
    self:addChild(numPicRight,10)

    local leftPicRight = cc.Sprite:create(self.szNum)
    leftPicRight:setRotation(-90)
    leftPicRight:setPosition(self.posX-self.sz1[1]/2+pokerHeight/2, self.posY-self.sz1[2]/2+pokerWidth/2)
    self:addChild(leftPicRight,10)

    numPicRight:setOpacity(0)
    leftPicRight:setOpacity(0)
    local fadeInTime = 0.1
    numPicRight:runAction(cc.FadeIn:create(fadeInTime))
    leftPicRight:runAction(cc.FadeIn:create(fadeInTime))
end

function RubCardLayer:__createLb()
    local label = cc.Label:createWithTTF("test", FONTNAME_DEF, 32)
    self:addChild(label, 2)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setOpacity(0)
    label:setPosition( 0,0)
end

function RubCardLayer:__drawByMoveProgram(rotation)
    local glProgram = self.moveGlProgram
    gl.enable(gl.CULL_FACE)
    glProgram:use()
    glProgram:setUniformsForBuiltins()
    local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
    glProgram:setUniformLocationF32(rotationLc, rotation)
    local ratio = gl.getUniformLocation(glProgram:getProgram(), "ratio")
    glProgram:setUniformLocationF32(ratio, self.ratioVal)
    local radius = gl.getUniformLocation(glProgram:getProgram(), "radius")
    glProgram:setUniformLocationF32(radius, self.radiusVal)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local height = gl.getUniformLocation(glProgram:getProgram(), "height")
    glProgram:setUniformLocationF32(height, self.sz1[2]*self.scale)
    for _, v in ipairs(self.cardMesh) do 
        gl._bindTexture(gl.TEXTURE_2D, v[1])
        self:__drawArrays(v)
    end
end

function RubCardLayer:__drawBySmoothProgram(rotation)
    local glProgram = self.smoothGlProgram
    glProgram:use()
    glProgram:setUniformsForBuiltins()

    local v = self.cardMesh[2]
    gl._bindTexture(gl.TEXTURE_2D, v[1])
    local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
    glProgram:setUniformLocationF32(rotationLc, rotation)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local height = gl.getUniformLocation(glProgram:getProgram(), "height")
    glProgram:setUniformLocationF32(height, self.sz1[2]*self.scale)
    self:__drawArrays(v)
end

function RubCardLayer:__drawByEndProgram()
    local glProgram = self.endGlProgram
    glProgram:use()
    glProgram:setUniformsForBuiltins()
    local v = self.cardMesh[2]
    gl._bindTexture(gl.TEXTURE_2D, v[1])
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    self:__drawArrays(v)
end

function RubCardLayer:__drawArrays(v)
    gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
    gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1])
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION,2,gl.FLOAT,false,0,0)
    gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2])
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD,2,gl.FLOAT,false,0,0)
    gl.drawArrays(gl.TRIANGLES, 0, v[3])
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
end

function RubCardLayer:__registerTouchEvent()
    local function onNodeEvent(event)
        if "exit" == event then
            self.moveGlProgram:release()
            self.smoothGlProgram:release()
            self.endGlProgram:release()
            self.backSprite:release()
            self.frontSprite:release()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    local function touchBegin(touch, event)
        posNow = touch:getLocation()
        return true
    end
    local function touchMove(touch, event)
        local location = touch:getLocation()
        self.ratioVal = (location.y-self.offy)/self.pokerHeight
        self.ratioVal = math.max(0, self.ratioVal)
        self.ratioVal = math.min(1, self.ratioVal)
        return true
    end
    local function touchEnd(touch, event)
        if self.ratioVal >= 1 then
            self.state = RubCardLayer_State_Smooth
        else
            self.ratioVal = 0
        end
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function RubCardLayer:__getRange(sprite)
    local size = sprite:getContentSize()
    local tex = sprite:getTexture()
    local id = tex:getName() --纹理ID
    local bigWide = tex:getPixelsWide() --plist图集的宽度
    local bigHigh = tex:getPixelsHigh()
    return id, {0, 1, 1, 0}, {size.height, size.width}
end

function RubCardLayer:__initCardVertex(size, texRange, isBack)
    local nDiv = 20 --将宽分成100份
    
    local verts = {} --位置坐标
    local texs = {} --纹理坐标
    local dh = size.height/nDiv
    local dw = size.width

    --计算顶点位置
    for c = 1, nDiv do 
        local x, y = 0, (c-1)*dh
        local quad = {}
        if isBack then
            quad = {x, y, x+dw, y, x, y+dh, x+dw, y, x+dw, y+dh, x, y+dh}
        else
            quad = {x, y, x, y+dh, x+dw, y, x+dw, y, x, y+dh, x+dw, y+dh}
        end
        for i=1,6 do
            local quadX = quad[i*2-1]
            local quadY = quad[i*2]
            table.insert(texs, 1 - quadY/size.height)
            table.insert(texs, quadX/size.width)
        end
        for _, v in ipairs(quad) do table.insert(verts, v) end
    end

    local res = {}
    local tmp = {verts, texs}
    for _, v in ipairs(tmp) do 
        local buffid = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
        gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
        gl.bindBuffer(gl.ARRAY_BUFFER, 0)
        table.insert(res, buffid)
    end
    return res, (#verts/2)
end

return RubCardLayer