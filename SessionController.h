#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString *SessionDataReceivedNotification;

@interface SessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
	EAAccessory *_accessory;
	EASession *_session;
	NSString *_protocolString;
	NSMutableData *_writeData;
	NSMutableData *_readData;
}

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;
@property (nonatomic, strong, readonly) NSCondition *receiveDataCondition;
@property (nonatomic, strong, readonly) NSCondition *writeDataCondition;

+(SessionController *)sharedController;
-(void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
-(bool)openSession;
-(void)closeSession;
-(bool)sessionIsOpen;
-(void)writeData:(NSData *)data;
-(NSUInteger)readBytesAvailable;
-(bool)hasSpaceAvailable;
-(long)writeDataLength;
-(NSData *)readData:(NSUInteger)bytesToRead;

@end