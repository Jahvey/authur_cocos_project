//
//  IMskdNode.hpp
//  doushisnew
//
//  Created by Arthur on 17/12/11.
//
//

#ifndef IMskdNode_hpp
#define IMskdNode_hpp

#include <stdio.h>
#include <stdio.h>
#include "cocos2d.h"
#include "YunVaSDK/YVTool.h"
using namespace YVSDK;
using namespace std;
using namespace cocos2d;
class IMskdNode:public cocos2d::Node,
public  YVListern::YVDownLoadFileListern,
public  YVListern::YVUpLoadFileListern,
public  YVListern::YVFinishPlayListern,
public  YVListern::YVFinishSpeechListern,
public  YVListern::YVStopRecordListern,
public  YVListern::YVReConnectListern,
public  YVListern::YVLoginListern,
public YVListern::YVRecordVoiceListern,
public YVListern::YVDownloadVoiceListern,
public YVListern::YVFlowListern
{
public:
    bool init()
    {
        isschedule = false;
        return  Node::init();
    }
    CREATE_FUNC(IMskdNode);
    void stopDispatch()
    {
        if (!isschedule) return;
        isschedule = false;
        cocos2d::Director::getInstance()->getScheduler()->unscheduleUpdate(this);
    }
    
    void startDispatch()
    {
        if (isschedule) return;
        isschedule = true;
        cocos2d::Director::getInstance()->getScheduler()->scheduleUpdate(this, 0, false);
        YVTool::getInstance()->addDownLoadFileListern(this);
        YVTool::getInstance()->addFinishPlayListern(this);
        YVTool::getInstance()->addFinishSpeechListern(this);
        YVTool::getInstance()->addLoginListern(this);
        YVTool::getInstance()->addReConnectListern(this);
        YVTool::getInstance()->addStopRecordListern(this);
        YVTool::getInstance()->addUpLoadFileListern(this);
        YVTool::getInstance()->addRecordVoiceListern(this);
        YVTool::getInstance()->addDownloadVoiceListern(this);
        YVTool::getInstance()->addFlowListern(this);
    }
    
    void update(float dt)
    {
        YVTool::getInstance()->dispatchMsg(dt);
    }
    
   
    
    virtual void onFlowListern(YunvaflowRespond*);
    static void cpLogin(string name);
    static bool startRecord();
    static void stopRecord();
    static bool playRecord(string name);
    static void playFromUrl(string url);
    static void upLoadFile(std::string path);
    static bool isPlaying();
    
    static void stopPlay();
    
    
    virtual void onLoginListern(CPLoginResponce*) ;
    
    virtual void onReConnectListern(ReconnectionNotify*);
    
    virtual void onStopRecordListern(RecordStopNotify*) ;
    
    virtual void onFinishSpeechListern(SpeechStopRespond*);
    
    virtual void onFinishPlayListern(StartPlayVoiceRespond*);
    
    virtual void onUpLoadFileListern(UpLoadFileRespond*);
    
    virtual void onDownLoadFileListern(DownLoadFileRespond*);
    
    virtual void onRecordVoiceListern(RecordVoiceNotify*);
    
    virtual void onDownloadVoiceListern(DownloadVoiceRespond*);
    
    
private:
    bool isschedule;
    
};
#endif /* IMskdNode_hpp */
