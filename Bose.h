#import "SessionController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface BoseController : NSObject
+(BoseController *)sharedInstance;
-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL) v2;
-(void)useSettings:(NSMutableDictionary *)settings;
-(NSString *)getCurrentListeningModeOfAccessory:(EAAccessory *)accessory;
@end
