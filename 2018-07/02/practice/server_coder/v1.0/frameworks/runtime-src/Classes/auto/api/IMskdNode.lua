
--------------------------------
-- @module IMskdNode
-- @extend Node,YVDownLoadFileListern,YVUpLoadFileListern,YVFinishPlayListern,YVFinishSpeechListern,YVStopRecordListern,YVReConnectListern,YVLoginListern,YVRecordVoiceListern,YVDownloadVoiceListern,YVFlowListern
-- @parent_module 

--------------------------------
-- 
-- @function [parent=#IMskdNode] stopDispatch 
-- @param self
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onRecordVoiceListern 
-- @param self
-- @param #mylua.RecordVoiceNotify 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onFlowListern 
-- @param self
-- @param #mylua.YunvaflowRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onFinishSpeechListern 
-- @param self
-- @param #mylua.SpeechStopRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onStopRecordListern 
-- @param self
-- @param #mylua.RecordStopNotify 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] update 
-- @param self
-- @param #float dt
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] init 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onDownLoadFileListern 
-- @param self
-- @param #mylua.DownLoadFileRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onReConnectListern 
-- @param self
-- @param #mylua.ReconnectionNotify 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] startDispatch 
-- @param self
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onUpLoadFileListern 
-- @param self
-- @param #mylua.UpLoadFileRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onFinishPlayListern 
-- @param self
-- @param #mylua.StartPlayVoiceRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onLoginListern 
-- @param self
-- @param #mylua.CPLoginResponce 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] onDownloadVoiceListern 
-- @param self
-- @param #mylua.DownloadVoiceRespond 
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] stopPlay 
-- @param self
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] stopRecord 
-- @param self
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] playFromUrl 
-- @param self
-- @param #string url
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] upLoadFile 
-- @param self
-- @param #string path
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] create 
-- @param self
-- @return IMskdNode#IMskdNode ret (return value: IMskdNode)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] playRecord 
-- @param self
-- @param #string name
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] startRecord 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] isPlaying 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#IMskdNode] cpLogin 
-- @param self
-- @param #string name
-- @return IMskdNode#IMskdNode self (return value: IMskdNode)
        
return nil
