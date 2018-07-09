#include "lua_mycrytoauto.hpp"
#include "CryTo.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

int lua_mycryto_CryTo_GenerateMD5(lua_State* tolua_S)
{
    int argc = 0;
    CryTo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CryTo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CryTo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mycryto_CryTo_GenerateMD5'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        unsigned char* arg0;
        int arg1;

        #pragma warning NO CONVERSION TO NATIVE FOR unsigned char*
		ok = false;

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "CryTo:GenerateMD5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mycryto_CryTo_GenerateMD5'", nullptr);
            return 0;
        }
        cobj->GenerateMD5(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CryTo:GenerateMD5",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mycryto_CryTo_GenerateMD5'.",&tolua_err);
#endif

    return 0;
}
int lua_mycryto_CryTo_ToString(lua_State* tolua_S)
{
    int argc = 0;
    CryTo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CryTo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CryTo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mycryto_CryTo_ToString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mycryto_CryTo_ToString'", nullptr);
            return 0;
        }
        std::string ret = cobj->ToString();
        lua_pushlstring(tolua_S,ret.c_str(),ret.length());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CryTo:ToString",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mycryto_CryTo_ToString'.",&tolua_err);
#endif

    return 0;
}
int lua_mycryto_CryTo_Md5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"CryTo",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "CryTo:Md5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mycryto_CryTo_Md5'", nullptr);
            return 0;
        }
        std::string ret = CryTo::Md5(arg0);
        lua_pushlstring(tolua_S,ret.c_str(),ret.length());
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "CryTo:Md5",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mycryto_CryTo_Md5'.",&tolua_err);
#endif
    return 0;
}
int lua_mycryto_CryTo_constructor(lua_State* tolua_S)
{
    int argc = 0;
    CryTo* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 1) {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "CryTo:CryTo"); arg0 = arg0_tmp.c_str();

            if (!ok) { break; }
            cobj = new CryTo(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"CryTo");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 0) {
            cobj = new CryTo();
            tolua_pushusertype(tolua_S,(void*)cobj,"CryTo");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            unsigned long* arg0;
            #pragma warning NO CONVERSION TO NATIVE FOR unsigned long*
		ok = false;

            if (!ok) { break; }
            cobj = new CryTo(arg0);
            tolua_pushusertype(tolua_S,(void*)cobj,"CryTo");
            tolua_register_gc(tolua_S,lua_gettop(tolua_S));
            return 1;
        }
    }while(0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n",  "CryTo:CryTo",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_mycryto_CryTo_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_mycryto_CryTo_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (CryTo)");
    return 0;
}

int lua_register_mycryto_CryTo(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"CryTo");
    tolua_cclass(tolua_S,"CryTo","CryTo","",nullptr);

    tolua_beginmodule(tolua_S,"CryTo");
        tolua_function(tolua_S,"new",lua_mycryto_CryTo_constructor);
        tolua_function(tolua_S,"GenerateMD5",lua_mycryto_CryTo_GenerateMD5);
        tolua_function(tolua_S,"ToString",lua_mycryto_CryTo_ToString);
        tolua_function(tolua_S,"Md5", lua_mycryto_CryTo_Md5);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CryTo).name();
    g_luaType[typeName] = "CryTo";
    g_typeCast["CryTo"] = "CryTo";
    return 1;
}
TOLUA_API int register_all_mycryto(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);

	lua_register_mycryto_CryTo(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

