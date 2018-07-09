#include "lua_mylua_auto.hpp"
#include "IMskdNode.h"
#include "DownManger.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

int lua_mylua_IMskdNode_stopDispatch(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_stopDispatch'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_stopDispatch'", nullptr);
            return 0;
        }
        cobj->stopDispatch();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:stopDispatch",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_stopDispatch'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onRecordVoiceListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onRecordVoiceListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::RecordVoiceNotify* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR RecordVoiceNotify*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onRecordVoiceListern'", nullptr);
            return 0;
        }
        cobj->onRecordVoiceListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onRecordVoiceListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onRecordVoiceListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onFlowListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onFlowListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::YunvaflowRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR YunvaflowRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onFlowListern'", nullptr);
            return 0;
        }
        cobj->onFlowListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onFlowListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onFlowListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onFinishSpeechListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onFinishSpeechListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::SpeechStopRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR SpeechStopRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onFinishSpeechListern'", nullptr);
            return 0;
        }
        cobj->onFinishSpeechListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onFinishSpeechListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onFinishSpeechListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onStopRecordListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onStopRecordListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::RecordStopNotify* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR RecordStopNotify*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onStopRecordListern'", nullptr);
            return 0;
        }
        cobj->onStopRecordListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onStopRecordListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onStopRecordListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_update(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_update'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "IMskdNode:update");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_update'", nullptr);
            return 0;
        }
        cobj->update(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:update",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_update'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_init(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_init'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_init'", nullptr);
            return 0;
        }
        bool ret = cobj->init();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:init",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_init'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onDownLoadFileListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onDownLoadFileListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::DownLoadFileRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR DownLoadFileRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onDownLoadFileListern'", nullptr);
            return 0;
        }
        cobj->onDownLoadFileListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onDownLoadFileListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onDownLoadFileListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onReConnectListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onReConnectListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::ReconnectionNotify* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR ReconnectionNotify*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onReConnectListern'", nullptr);
            return 0;
        }
        cobj->onReConnectListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onReConnectListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onReConnectListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_startDispatch(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_startDispatch'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_startDispatch'", nullptr);
            return 0;
        }
        cobj->startDispatch();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:startDispatch",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_startDispatch'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onUpLoadFileListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onUpLoadFileListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::UpLoadFileRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR UpLoadFileRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onUpLoadFileListern'", nullptr);
            return 0;
        }
        cobj->onUpLoadFileListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onUpLoadFileListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onUpLoadFileListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onFinishPlayListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onFinishPlayListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::StartPlayVoiceRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR StartPlayVoiceRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onFinishPlayListern'", nullptr);
            return 0;
        }
        cobj->onFinishPlayListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onFinishPlayListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onFinishPlayListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onLoginListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onLoginListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::CPLoginResponce* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR CPLoginResponce*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onLoginListern'", nullptr);
            return 0;
        }
        cobj->onLoginListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onLoginListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onLoginListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_onDownloadVoiceListern(lua_State* tolua_S)
{
    int argc = 0;
    IMskdNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (IMskdNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_IMskdNode_onDownloadVoiceListern'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        YVSDK::DownloadVoiceRespond* arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR DownloadVoiceRespond*
        ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_onDownloadVoiceListern'", nullptr);
            return 0;
        }
        cobj->onDownloadVoiceListern(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "IMskdNode:onDownloadVoiceListern",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_onDownloadVoiceListern'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_IMskdNode_stopPlay(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_stopPlay'", nullptr);
            return 0;
        }
        IMskdNode::stopPlay();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:stopPlay",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_stopPlay'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_stopRecord(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_stopRecord'", nullptr);
            return 0;
        }
        IMskdNode::stopRecord();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:stopRecord",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_stopRecord'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_playFromUrl(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "IMskdNode:playFromUrl");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_playFromUrl'", nullptr);
            return 0;
        }
        IMskdNode::playFromUrl(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:playFromUrl",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_playFromUrl'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_upLoadFile(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "IMskdNode:upLoadFile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_upLoadFile'", nullptr);
            return 0;
        }
        IMskdNode::upLoadFile(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:upLoadFile",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_upLoadFile'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_create'", nullptr);
            return 0;
        }
        IMskdNode* ret = IMskdNode::create();
        object_to_luaval<IMskdNode>(tolua_S, "IMskdNode",(IMskdNode*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_create'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_playRecord(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "IMskdNode:playRecord");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_playRecord'", nullptr);
            return 0;
        }
        bool ret = IMskdNode::playRecord(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:playRecord",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_playRecord'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_startRecord(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_startRecord'", nullptr);
            return 0;
        }
        bool ret = IMskdNode::startRecord();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:startRecord",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_startRecord'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_isPlaying(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_isPlaying'", nullptr);
            return 0;
        }
        bool ret = IMskdNode::isPlaying();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:isPlaying",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_isPlaying'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_IMskdNode_cpLogin(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"IMskdNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "IMskdNode:cpLogin");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_IMskdNode_cpLogin'", nullptr);
            return 0;
        }
        IMskdNode::cpLogin(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "IMskdNode:cpLogin",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_IMskdNode_cpLogin'.",&tolua_err);
#endif
    return 0;
}
static int lua_mylua_IMskdNode_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (IMskdNode)");
    return 0;
}

int lua_register_mylua_IMskdNode(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"IMskdNode");
    tolua_cclass(tolua_S,"IMskdNode","IMskdNode","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"IMskdNode");
        tolua_function(tolua_S,"stopDispatch",lua_mylua_IMskdNode_stopDispatch);
        tolua_function(tolua_S,"onRecordVoiceListern",lua_mylua_IMskdNode_onRecordVoiceListern);
        tolua_function(tolua_S,"onFlowListern",lua_mylua_IMskdNode_onFlowListern);
        tolua_function(tolua_S,"onFinishSpeechListern",lua_mylua_IMskdNode_onFinishSpeechListern);
        tolua_function(tolua_S,"onStopRecordListern",lua_mylua_IMskdNode_onStopRecordListern);
        tolua_function(tolua_S,"update",lua_mylua_IMskdNode_update);
        tolua_function(tolua_S,"init",lua_mylua_IMskdNode_init);
        tolua_function(tolua_S,"onDownLoadFileListern",lua_mylua_IMskdNode_onDownLoadFileListern);
        tolua_function(tolua_S,"onReConnectListern",lua_mylua_IMskdNode_onReConnectListern);
        tolua_function(tolua_S,"startDispatch",lua_mylua_IMskdNode_startDispatch);
        tolua_function(tolua_S,"onUpLoadFileListern",lua_mylua_IMskdNode_onUpLoadFileListern);
        tolua_function(tolua_S,"onFinishPlayListern",lua_mylua_IMskdNode_onFinishPlayListern);
        tolua_function(tolua_S,"onLoginListern",lua_mylua_IMskdNode_onLoginListern);
        tolua_function(tolua_S,"onDownloadVoiceListern",lua_mylua_IMskdNode_onDownloadVoiceListern);
        tolua_function(tolua_S,"stopPlay", lua_mylua_IMskdNode_stopPlay);
        tolua_function(tolua_S,"stopRecord", lua_mylua_IMskdNode_stopRecord);
        tolua_function(tolua_S,"playFromUrl", lua_mylua_IMskdNode_playFromUrl);
        tolua_function(tolua_S,"upLoadFile", lua_mylua_IMskdNode_upLoadFile);
        tolua_function(tolua_S,"create", lua_mylua_IMskdNode_create);
        tolua_function(tolua_S,"playRecord", lua_mylua_IMskdNode_playRecord);
        tolua_function(tolua_S,"startRecord", lua_mylua_IMskdNode_startRecord);
        tolua_function(tolua_S,"isPlaying", lua_mylua_IMskdNode_isPlaying);
        tolua_function(tolua_S,"cpLogin", lua_mylua_IMskdNode_cpLogin);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(IMskdNode).name();
    g_luaType[typeName] = "IMskdNode";
    g_typeCast["IMskdNode"] = "IMskdNode";
    return 1;
}

int lua_mylua_DownManger_NetTypenotification(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_NetTypenotification'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_NetTypenotification'", nullptr);
            return 0;
        }
        cobj->NetTypenotification();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:NetTypenotification",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_NetTypenotification'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_uncomFile(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_uncomFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DownManger:uncomFile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_uncomFile'", nullptr);
            return 0;
        }
        bool ret = cobj->uncomFile(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:uncomFile",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_uncomFile'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_Uncompresszip(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_Uncompresszip'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_Uncompresszip'", nullptr);
            return 0;
        }
        cobj->Uncompresszip();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:Uncompresszip",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_Uncompresszip'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_EveryFrameupdate(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_EveryFrameupdate'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "DownManger:EveryFrameupdate");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_EveryFrameupdate'", nullptr);
            return 0;
        }
        cobj->EveryFrameupdate(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:EveryFrameupdate",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_EveryFrameupdate'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_downLoad(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_downLoad'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DownManger:downLoad");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_downLoad'", nullptr);
            return 0;
        }
        bool ret = cobj->downLoad(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:downLoad",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_downLoad'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_createDirectory(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_createDirectory'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "DownManger:createDirectory"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_createDirectory'", nullptr);
            return 0;
        }
        bool ret = cobj->createDirectory(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:createDirectory",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_createDirectory'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_getdownProssgress(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (DownManger*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mylua_DownManger_getdownProssgress'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_getdownProssgress'", nullptr);
            return 0;
        }
        int ret = cobj->getdownProssgress();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:getdownProssgress",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_getdownProssgress'.",&tolua_err);
#endif

    return 0;
}
int lua_mylua_DownManger_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_getInstance'", nullptr);
            return 0;
        }
        DownManger* ret = DownManger::getInstance();
        object_to_luaval<DownManger>(tolua_S, "DownManger",(DownManger*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DownManger:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_DownManger_start_threaddownSingleFile(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DownManger",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        void* arg0;
        #pragma warning NO CONVERSION TO NATIVE FOR void*
		ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_start_threaddownSingleFile'", nullptr);
            return 0;
        }
        void* ret = DownManger::start_threaddownSingleFile(arg0);
        #pragma warning NO CONVERSION FROM NATIVE FOR void*;
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DownManger:start_threaddownSingleFile",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_start_threaddownSingleFile'.",&tolua_err);
#endif
    return 0;
}
int lua_mylua_DownManger_constructor(lua_State* tolua_S)
{
    int argc = 0;
    DownManger* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mylua_DownManger_constructor'", nullptr);
            return 0;
        }
        cobj = new DownManger();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"DownManger");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "DownManger:DownManger",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_mylua_DownManger_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_mylua_DownManger_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (DownManger)");
    return 0;
}

int lua_register_mylua_DownManger(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"DownManger");
    tolua_cclass(tolua_S,"DownManger","DownManger","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"DownManger");
        tolua_function(tolua_S,"new",lua_mylua_DownManger_constructor);
        tolua_function(tolua_S,"NetTypenotification",lua_mylua_DownManger_NetTypenotification);
        tolua_function(tolua_S,"uncomFile",lua_mylua_DownManger_uncomFile);
        tolua_function(tolua_S,"Uncompresszip",lua_mylua_DownManger_Uncompresszip);
        tolua_function(tolua_S,"EveryFrameupdate",lua_mylua_DownManger_EveryFrameupdate);
        tolua_function(tolua_S,"downLoad",lua_mylua_DownManger_downLoad);
        tolua_function(tolua_S,"createDirectory",lua_mylua_DownManger_createDirectory);
        tolua_function(tolua_S,"getdownProssgress",lua_mylua_DownManger_getdownProssgress);
        tolua_function(tolua_S,"getInstance", lua_mylua_DownManger_getInstance);
        tolua_function(tolua_S,"start_threaddownSingleFile", lua_mylua_DownManger_start_threaddownSingleFile);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(DownManger).name();
    g_luaType[typeName] = "DownManger";
    g_typeCast["DownManger"] = "DownManger";
    return 1;
}
TOLUA_API int register_all_mylua(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);

	lua_register_mylua_DownManger(tolua_S);
	lua_register_mylua_IMskdNode(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

