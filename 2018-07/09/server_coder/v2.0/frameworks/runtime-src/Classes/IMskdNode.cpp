//
//  IMskdNode.cpp
//  doushisnew
//
//  Created by Arthur on 17/12/11.
//
//

#include "IMskdNode.h"
#include "SimpleAudioEngine.h"
using namespace cocos2d;
using namespace std;
using namespace CocosDenshion;
#define BUFFER_SIZE    8192
#define MAX_FILENAME 512
#define RECODEPATH (cocos2d::FileUtils::getInstance()->getWritablePath()+"test.amr")
#define DOWNPATH (cocos2d::FileUtils::getInstance()->getWritablePath()+"dwtest.amr")
static std::string url = "";
static std::string YUNurl = "";
static int TIMEVOICE = 0;
static int PATHNUM = 1;

void IMskdNode::onLoginListern(CPLoginResponce* r )
{
    std::string str;
    if (r->result != 0)
    {
        str.append("login Error:");
        str.append(r->msg);
    }
    else
    {
        YVTool::getInstance()->setRecord(60, true);
        std::stringstream ss;
        ss << "login succeed" << "UId:";
        ss << r->userid;
        str.append(ss.str());
    }
    //CCLOG(str.c_str());
    //label->setString(str);
}

void IMskdNode::cpLogin(string name){
    cout<<name.c_str()<<endl;
    YVTool::getInstance()->cpLogin(name, name);
}

bool IMskdNode::startRecord(){
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    return YVTool::getInstance()->startRecord(RECODEPATH,0);
}
void IMskdNode::stopRecord(){
    YVTool::getInstance()->stopRecord();
}
bool IMskdNode::playRecord(string name){
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    return YVTool::getInstance()->playRecord(url,RECODEPATH);
}

void IMskdNode::playFromUrl(string url){
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    return YVTool::getInstance()->playFromUrl(url);
}
void IMskdNode::stopPlay(){
    YVTool::getInstance()->stopPlay();
}

void IMskdNode::onReConnectListern(ReconnectionNotify* r)
{
    std::stringstream ss;
    ss << "ReConnect, UI:";
    ss << r->userid;
    cout<<"=-----------------------"<<endl;
    cout<<ss.str()<<endl;
    //    label->setString(ss.str());
    //    reSetLablePos();
}

void IMskdNode::upLoadFile(std::string path){
    //YVFilePathPtr strfilepath = YVSDK::YVPlatform::getSingletonPtr()->getYVPathByLocal(path);;
    YVTool::getInstance()->upLoadFile(path);
}

void IMskdNode::onStopRecordListern(RecordStopNotify* r)
{
    std::stringstream ss;
    ss << " time:" << r->time << " \npath:" << r->strfilepath;
    cout<<"=-----------------------"<<endl;
    cout<<ss.str()<<endl;
    char ttStr1[500] = { 0 };
    const char* ttFormat = "{\"time\":\"%d\",\"path\":\"%s\"}";
    if( r->time > 1000){
        TIMEVOICE =r->time;
    }
    
    sprintf(ttStr1, ttFormat, r->time, r->strfilepath.c_str());
    auto  event = new EventCustom("yvsdk_onstop");
    event->setDataString(ttStr1);
    Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
    //label->setString(ss.str());
    //reSetLablePos();
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

void IMskdNode::onFinishSpeechListern(SpeechStopRespond* r)
{
    std::stringstream ss;
    
    std::string str;
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    //	r->result = GBKToUTF8(r->result.c_str());
#endif
    
    ss << "<FinishSpeech>" << "\n err_id:" << r->err_id << "\n Erro msg:" << r->err_msg
    << "\n result:" << r->result;
    cout<<"=-----------------------"<<endl;
    cout<<ss.str()<<endl;
}

void IMskdNode::onFinishPlayListern(StartPlayVoiceRespond* r)
{
    
    std::stringstream ss;
    if(r->result == 0)
        ss << "<Finish Play>";
    else
        ss << "<Play fail>";
    cout<<"=-----------------------"<<endl;
    cout<<ss.str()<<endl;
    auto  event = new EventCustom("yvsdk_finshed");
    char ttStr1[200] = { 0 };
    const char* ttFormat = "%d";
    sprintf(ttStr1, ttFormat, r->result);
    event->setDataString(ttStr1);
    Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
    //    label->setString(ss.str());
    //    reSetLablePos();
    
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

void IMskdNode::onUpLoadFileListern(UpLoadFileRespond* r)
{
    std::stringstream ss;
    ss << "<UpLoad File>" << " result id:" << r->result
    << " erro Msg:" << r->msg << " url:"
    << r->fileurl << " \n percent:" << r->percent;
    cout<<"=-----------------------"<<endl;
    cout<<ss.str()<<endl;
    if (r->result == 0)
    {
        url.clear();
        url.append(r->fileurl);
        YUNurl.clear();
        YUNurl.append(r->fileurl);
    }
    auto  event = new EventCustom("yvsdk_upload");
    if(r->result == 0){
        cocos2d::log("upfile successful:%s",r->fileurl.c_str());
        char ttStr1[200] = { 0 };
        const char* ttFormat = "{\"result\":\"%d\",\"url\":\"%s\",\"time\":\"%d\"}";
        sprintf(ttStr1, ttFormat, r->result, r->fileurl.c_str(),TIMEVOICE);
        event->setDataString(ttStr1);
    }else{
        cocos2d::log("upfile fail:%s",r->msg.c_str());
        char ttStr1[200] = { 0 };
        const char* ttFormat = "{\"result\":\"%d\",\"url\":\"%s\"}";
        sprintf(ttStr1, ttFormat, r->result, r->msg.c_str());
        event->setDataString(ttStr1);
    }
    Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
}

void IMskdNode::onDownLoadFileListern(DownLoadFileRespond* r)
{
    std::stringstream ss;
    ss << "<DownLoad File>" << " result id:" << r->result
    << "  erro Msg:" << r->msg << " \npath:"
    << r->filename << "\n percent:" << r->percent;
    auto  event = new EventCustom("yvsdk_download");
    char ttStr1[200] = { 0 };
    const char* ttFormat = "{\"result\":\"%d\",\"msg\":\"%s\"}";
    sprintf(ttStr1, ttFormat, r->result, r->msg.c_str());
    event->setDataString(ttStr1);
    Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
    
}












void IMskdNode::onRecordVoiceListern(RecordVoiceNotify* r)
{
    //layerCorlor->changeHeight(250 * (r->volume / 100.0f));
    cout<<"--------音量"<< (r->volume / 100.0f)<<endl;
}














void IMskdNode::onDownloadVoiceListern(DownloadVoiceRespond* r)
{
    if (r)
    {
        printf("percent = %d \n", r->percent);
    }
}













void IMskdNode::onFlowListern(YunvaflowRespond* r)
{
    if (r->result == 0)
    {
        std::stringstream ss;
        ss << "<Flow File>" << " upflow:" << r->upflow
        << "  downflow:" << r->downflow << " \allflow:"
        << r->allflow << "\n";
    }
}

bool IMskdNode::isPlaying(){
    return YVTool::getInstance()->_isPlaying;
}
