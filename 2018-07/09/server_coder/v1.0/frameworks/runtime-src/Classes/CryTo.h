//
//  CryTo.h
//  doushisnew
//
//  Created by Arthur on 17/12/7.
//
//

#ifndef CryTo_h
#define CryTo_h

#include <stdio.h>
#include <string>

using namespace std;


class CryTo
{
private:
#define uint8  unsigned char
#define uint32 unsigned long int
    
    struct md5_context
    {
        uint32 total[2];
        uint32 state[4];
        uint8 buffer[64];
    };
    
    void md5_starts( struct md5_context *ctx );
    void md5_process( struct md5_context *ctx, uint8 data[64] );
    void md5_update( struct md5_context *ctx, uint8 *input, uint32 length );
    void md5_finish( struct md5_context *ctx, uint8 digest[16] );
    
public:
    //! construct a MD5 from any buffer
    void GenerateMD5(unsigned char* buffer,int bufferlen);
    
    //! construct a MD5
    CryTo();
    
    //! construct a md5src from char *
    CryTo(const char * md5src);
    
    //! construct a MD5 from a 16 bytes md5
    CryTo(unsigned long* md5src);
    
    //! add a other md5
    CryTo operator +(CryTo adder);
    
    //! just if equal
    bool operator ==(CryTo cmper);
    
    //! give the value from equer
    // void operator =(MD5 equer);
    
    //! to a string
    string ToString();
    
    unsigned long m_data[4];
    static string Md5(string str);
};


#endif /* CryTo_h */
