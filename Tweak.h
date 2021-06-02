#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import <SessionController.h>

bool focusOnVoiceNC = false;
bool focusOnVoiceASM = false;
bool windReductionSupport = true;
bool isEnabled = true;
char pingPong = 0x00;
char NCValue = 0x0;
char ASMValue = 0x14;
NSString *headphonesName = @"WH-1000XM3";
NSString *currentListeningMode = @"AVOutputDeviceBluetoothListeningModeNormal";
dispatch_source_t closeSessionTimer = nil;

@interface NSDistributedNotificationCenter : NSNotificationCenter
+(id)defaultCenter;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
-(void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

@interface AVOutputDevice : NSObject
-(NSString *)name;
@end

@interface UIApplication (Private)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
@end
