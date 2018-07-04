#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "DownManger.h"

// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "YunVaSDK/YVTool.h"
#include "lua_mylua_auto.hpp"
using namespace YVSDK;
#endif

#include "lua_mycrytoauto.hpp"
USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    m_dispathMsgNode = NULL;
#endif
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (m_dispathMsgNode != NULL) {
        m_dispathMsgNode->stopDispatch();
        m_dispathMsgNode->release();
        m_dispathMsgNode = NULL;
    }
#endif
}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages(lua_State* L)
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    register_all_mylua(L);
//    register_youmeim_manual(L);
#endif
    register_all_mycryto(L);
    
    
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//    CrashReport::setAppVersion("yvsdk1.0_121917");
//    CrashReport::initCrashReport("1000905", false);
//#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (m_dispathMsgNode == NULL)
    {
        YVTool::getInstance()->initSDK(1000905, FileUtils::getInstance()->getWritablePath(), false, false);
        m_dispathMsgNode = IMskdNode::create();
        m_dispathMsgNode->retain();
        m_dispathMsgNode->startDispatch();
    }
#endif
    
    string path1 = FileUtils::getInstance()->getWritablePath()+"appdata/";
    string path2 = FileUtils::getInstance()->getWritablePath()+"appdata/src/";
    string path3 = FileUtils::getInstance()->getWritablePath()+"appdata/res/";
    string path4 = FileUtils::getInstance()->getWritablePath()+"appdata/src/protobuf/";
    string path5 = FileUtils::getInstance()->getWritablePath()+"appdata/src/app/proto/";
    string path6 = FileUtils::getInstance()->getWritablePath()+"appdata/res/cocostudio/";
    //FileUtils::getInstance()->addSearchResolutionsOrder("appdata/");
    
    FileUtils::getInstance()->addSearchPath(path1.c_str());
    FileUtils::getInstance()->addSearchPath(path2.c_str());
    FileUtils::getInstance()->addSearchPath(path3.c_str());
    FileUtils::getInstance()->addSearchPath(path4.c_str());
    FileUtils::getInstance()->addSearchPath(path5.c_str());
    FileUtils::getInstance()->addSearchPath(path6.c_str());
    FileUtils::getInstance()->addSearchPath("appdata/");
    FileUtils::getInstance()->addSearchPath("res/");
    
    
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    register_all_packages(L);

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("SSQ5110w", strlen("SSQ5110w"), "XXTEA", strlen("XXTEA"));

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());
    
//#if CC_64BITS
//    FileUtils::getInstance()->addSearchPath("src/64bit");
//#endif
    FileUtils::getInstance()->addSearchPath("src");
    FileUtils::getInstance()->addSearchPath("res");
    engine->addSearchPath("src");
    engine->addSearchPath("src/protobuf");
    engine->addSearchPath("src/app/proto");
    
    if (engine->executeScriptFile("main.lua"))
    {
        return false;
    }

    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    //MyIM::Inst()-> OnPause();
#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
     LuaEngine::getInstance()->executeGlobalFunction("goBackGround");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
     //MyIM::Inst()-> OnResume();
#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
    LuaEngine::getInstance()->executeGlobalFunction("enterBackGround");
}
