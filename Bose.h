#import "SessionController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface BoseController : NSObject
+(BoseController *)sharedInstance;
-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL) v2;
-(NSString *)getCurrentListeningModeOfAccessory:(EAAccessory *)accessory;
@end
