#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString *EADSessionDataReceivedNotification;

@interface SessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
    EAAccessory *_accessory;
    EASession *_session;
    NSString *_protocolString;
    NSMutableData *_writeData;
    NSMutableData *_readData;
}

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

+(SessionController *)sharedController;
-(void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
-(BOOL)openSession;
-(void)closeSession;
-(void)writeData:(NSData *)data;
-(NSUInteger)readBytesAvailable;
-(NSData *)readData:(NSUInteger)bytesToRead;

@end