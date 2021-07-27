#import "SessionController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface SonyController : NSObject
+(SonyController *)sharedInstance;
-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL)v2;
-(void)useSettings:(NSMutableDictionary *)settings;
-(NSString *)getCurrentListeningModeOfAccessory:(EAAccessory *)accessory;
@end
