#import <CoreBluetooth/CoreBluetooth.h>
#import <ExternalAccessory/ExternalAccessory.h>

@interface SoundcoreController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
+(SoundcoreController *)sharedInstance;
-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory;
-(void)useSettings:(NSMutableDictionary *)settings;
-(NSString *)getCurrentListeningModeOfAccessory:(EAAccessory *)accessory;
-(void)setListeningMode:(NSString *)listeningMode forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *foundCharacteristic;
@property (nonatomic, strong) NSString *shouldChangeTolisteningMode;
@end
