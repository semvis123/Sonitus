#import <Foundation/Foundation.h>
#import "Sony.h"
#import "Bose.h"
#import "Soundcore.h"
#import "Jabra.h"
#import "Sennheiser.h"
#import <Cephei/HBPreferences.h>

@interface SBMediaController
- (BOOL)playForEventSource:(long long)arg1;
- (BOOL)pauseForEventSource: (long long)arg1;
+ (id)sharedInstance;
- (BOOL)isPaused;
- (BOOL)isPlaying;
@end

HBPreferences *preferences;

@interface NSDistributedNotificationCenter : NSNotificationCenter
+(id)defaultCenter;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
-(void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
-(void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

@interface AVOutputDevice : NSObject
-(NSString *)name;
-(NSString *)ID;
@end
