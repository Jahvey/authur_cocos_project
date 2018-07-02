//
//  DownManger.cpp
//  doushisnew
//
//  Created by Arthur on 17/12/7.
//
//

#include "DownManger.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <errno.h>
    #include <stdio.h>
#endif
#include "unzip/unzip.h"
#include <string.h>
#include "curl/curl.h"



#define BUFFER_SIZE    8192
#define MAX_FILENAME 512
#define LOW_SPEED_LIMIT 1L
#define LOW_SPEED_TIME 5L
DownManger *DownManger::instance = NULL;
DownManger* DownManger::getInstance(){
    if (!instance)
    {
        instance = new DownManger();
        //s_SharedDowntool->_curl = curl_easy_init();
        instance->writepath = FileUtils::getInstance()->getWritablePath();
        instance->NetTypenotification();
    }
    return instance;
}
DownManger::DownManger(){
    downerror = 0;
    unerror = 0;
    downpross = -1;
}
DownManger::~DownManger(){
    
}
bool DownManger::createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, NULL);
    if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
    {
        return false;
    }
    return true;
#endif
}
void DownManger::NetTypenotification(){
    Director::getInstance()->getScheduler()->schedule(CC_SCHEDULE_SELECTOR(DownManger::EveryFrameupdate), this, 0, false);
}
void DownManger::EveryFrameupdate(float dt){
    if (downerror != 0){
        EventCustom* event =  new EventCustom("downtool_downfile");
        if (downerror == 1){
            event->setDataString("1");
        }else{
            event->setDataString("-1");
        }
        Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
        downerror = 0;
    }
    if (unerror != 0){
        EventCustom* event =  new EventCustom("downtool_unfile");
        if (unerror == 1){
            event->setDataString("1");
        }else{
            event->setDataString("-1");
        }
        Director::getInstance()->getEventDispatcher()->dispatchEvent(event);
        unerror = 0;
    }
}

int DownManger::getdownProssgress(){
    return downpross;
}

bool DownManger::downLoad(string url)
{
    downerror = 0;
    unerror = 0;
    downpross = -1;
    this->downurl = url;
    if(pthread_create(&pid,NULL,start_threaddownSingleFile,(void*)0)!=0)                 //创建一个线程(线程函数必须是全局函数)
    {
        return true;
    }
    return false;
}


static size_t Writefile(void *ptr, size_t size, size_t nmemb, void *userdata)
{
    FILE *fp = (FILE*)userdata;
    size_t written = fwrite(ptr, size, nmemb, fp);
    return written;
}

int Perprogress(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
    static int percent = 0;
    int tmp = (int)(nowDownloaded / totalToDownload * 100);
    
    if (percent != tmp)
    {
        percent = tmp;
        
        DownManger::getInstance()->downpross = percent;
        
    }
    
    return 0;
}
void* DownManger::start_threaddownSingleFile(void *arg){
    // Create a file to save package.
    auto _curl = curl_easy_init();
    
    if (! _curl)
    {
        DownManger::getInstance()->downerror = -1;
        return nullptr;
    }
    string createpath = DownManger::getInstance()->writepath + "appdata/";
    DownManger::getInstance()->createDirectory(createpath.c_str());
    const string outFileName = DownManger::getInstance()->writepath + "appdata/1.zip";
    FILE *fp = fopen(outFileName.c_str(), "wb");
    if (! fp)
    {
        
        DownManger::getInstance()->downerror = -1;
        return nullptr;
    }
    
    // Download pacakge
    CURLcode res;
    curl_easy_setopt(_curl, CURLOPT_URL, DownManger::getInstance()->downurl.c_str());
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, Writefile);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
    curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
    curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, Perprogress);
    curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, DownManger::getInstance());
    curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
    curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
    curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);
    curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1 );
    
    res = curl_easy_perform(_curl);
    curl_easy_cleanup(_curl);
    if (res != 0)
    {
        fclose(fp);
        DownManger::getInstance()->downerror = -1;
        return nullptr;
    }
    
    
    fclose(fp);
    DownManger::getInstance()->downerror = 1;
    return (void*)1;
}



//解压文件线程
void* start_threadunfile(void *arg){
    string path = DownManger::getInstance()->writepath;
    path=path +"appdata/1.zip";
    
    if (DownManger::getInstance()->uncomFile(path)){
        
    }
    return (void*)1;
}
//创建解压文件线程
void DownManger::Uncompresszip(){
    if(pthread_create(&pid,NULL,start_threadunfile,(void*)0)!=0)                 //创建一个线程(线程函数必须是全局函数)
    {
        return ;
    }
    //this->release();
    return ;
}


bool DownManger::uncomFile(string outFileName){
    // Open the zip file
    unzFile zipfile = unzOpen(outFileName.c_str());
    if (! zipfile)
    {
        CCLOG("can not open downloaded zip file %s", outFileName.c_str());
        unerror = -1;
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", outFileName.c_str());
        unzClose(zipfile);
        unerror = -1;
        return false;
    }
    
    // Buffer to hold data read from the zip file
    char readBuffer[BUFFER_SIZE];
    
    CCLOG("start uncompressing");
    
    // Loop to extract all files.
    uLong i;
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  NULL,
                                  0,
                                  NULL,
                                  0) != UNZ_OK)
        {
            CCLOG("can not read file info");
            unzClose(zipfile);
            unerror = -1;
            return false;
        }
        
        
        // Check if this entry is a directory or a file.
        
        const size_t filenameLength = strlen(fileName);
        for (int j =0 ; j<filenameLength; j++) {
            if(fileName[j] == '\\'){
                fileName[j] = '/';
            }
        }
        //cout<<fileName[filenameLength-1]<<endl;
        string fullPath = writepath+ "appdata/"+fileName;
        CCLOG("解压文件%s",fullPath.c_str());
        if (fileName[filenameLength-1] == '/')
        {
            // Entry is a direcotry, so create it.
            // If the directory exists, it will failed scilently.
            if (!createDirectory(fullPath.c_str()))
            {
                CCLOG("can not create directory %s", fullPath.c_str());
                unzClose(zipfile);
                unerror = -1;
                return false;
            }
        }
        else
        {
            // Entry is a file, so extract it.
            
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not open file %s", fileName);
                continue;
                unzClose(zipfile);
                unerror = -1;
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(fullPath.c_str(), "wb");
            if (! out)
            {
                CCLOG("can not open destination file %s", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                unerror = -1;
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("can not read zip file %s, error code is %d", fileName, error);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    unerror = -1;
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while(error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i+1) < global_info.number_entry)
        {
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not read next file");
                unzClose(zipfile);
                unerror = -1;
                return false;
            }
        }
    }
    
    CCLOG("end uncompressing");
    unerror = 1;
    return true;
    
}



