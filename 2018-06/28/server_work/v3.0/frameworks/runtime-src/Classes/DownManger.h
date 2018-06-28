//
//  DownManger.h
//  doushisnew
//
//  Created by Arthur on 17/12/7.
//
//

#ifndef DownManger_h
#define DownManger_h

#include <stdio.h>

#include <iostream>
#include "cocos2d.h"
#include <fstream>
#include "pThread.h"


using namespace cocos2d;
using namespace std;
using std::ifstream;


class DownManger:public Ref{
public:
    static DownManger *getInstance();
    DownManger();
    ~DownManger();
    //创建解压第一次登陆里面的资源线程
    void Uncompresszip();
    //解压文件
    bool uncomFile(string outFileName);
    //创建文件夹
    bool createDirectory(const char *path);
    //void executeGlobalFunction(const char* functionName,int type);
    bool downLoad(string url);
    void NetTypenotification();
    void EveryFrameupdate(float dt);
    static void *start_threaddownSingleFile(void *arg);
    int getdownProssgress();
    string writepath;
    string downurl;
    int downpross;
private:
    pthread_t pid;
    void *_curl;
    int downerror;
    int unerror;
    //单例
    static DownManger *instance;
};


#endif /* DownManger_h */
