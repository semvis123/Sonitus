#import "SessionController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <Cephei/HBPreferences.h>

@interface SonyController : NSObject
+(SonyController *)sharedInstance;
-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL)v2 withPreferences:(HBPreferences *)preferences;
-(NSString *)getCurrentListeningModeOfAccessory:(EAAccessory *)accessory;
@end
