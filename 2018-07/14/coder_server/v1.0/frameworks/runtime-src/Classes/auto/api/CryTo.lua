
--------------------------------
-- @module CryTo
-- @parent_module 

--------------------------------
--  construct a MD5 from any buffer
-- @function [parent=#CryTo] GenerateMD5 
-- @param self
-- @param #unsigned char buffer
-- @param #int bufferlen
-- @return CryTo#CryTo self (return value: CryTo)
        
--------------------------------
--  just if equal
-- @function [parent=#CryTo] operator== 
-- @param self
-- @param #CryTo cmper
-- @return bool#bool ret (return value: bool)
        
--------------------------------
--  add a other md5
-- @function [parent=#CryTo] operator+ 
-- @param self
-- @param #CryTo adder
-- @return CryTo#CryTo ret (return value: CryTo)
        
--------------------------------
--  to a string
-- @function [parent=#CryTo] ToString 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#CryTo] Md5 
-- @param self
-- @param #string str
-- @return string#string ret (return value: string)
        
--------------------------------
-- @overload self, char         
-- @overload self         
-- @overload self, unsigned long         
-- @function [parent=#CryTo] CryTo
-- @param self
-- @param #unsigned long md5src
-- @return CryTo#CryTo self (return value: CryTo)

return nil
