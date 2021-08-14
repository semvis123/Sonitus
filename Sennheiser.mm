#import "Sennheiser.h"

@implementation SennheiserController {}


+(SennheiserController *)sharedInstance {
	static SennheiserController *sennheiserController = nil;
	if (sennheiserController == nil) {
		sennheiserController = [SennheiserController new];
	}

	return sennheiserController;
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode {
	// pid_t pid;
	// const char *args[] = {"killall", "-9", "SoundCore", NULL};
	// posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);

	self.shouldChangeTolisteningMode = listeningMode;
	if (self.centralManager == nil) {
		self.centralQueue = dispatch_queue_create("com.semvis.sonitus", DISPATCH_QUEUE_SERIAL);
		self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue];
	}
	if (self.peripheral != nil && self.foundCharacteristic != nil) {
		if (self.peripheral.state == CBPeripheralStateConnected) {
			[self setListeningMode:listeningMode forPeripheral:self.peripheral forCharacteristic:self.foundCharacteristic];
		} else {
			[self.centralManager connectPeripheral:self.peripheral options:nil];
		}
	} else {
		[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FDCE"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
	}
}

-(void)setListeningMode:(NSString *)listeningMode forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic {
	// bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
	bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
	self.shouldChangeTolisteningMode = nil;
	Byte command[] = { 0x04, 0x94, 0x07, 0x08, 0x00, static_cast<Byte>(isNC? 0x00 : 0x01) };
	NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
	[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

-(NSString *)getCurrentListeningMode {
	return nil;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	self.peripheral = peripheral;
	self.peripheral.delegate = self;
	if (peripheral.state != CBPeripheralStateConnected) {
		[self.centralManager connectPeripheral:self.peripheral options:nil];
	} else {
		if (self.shouldChangeTolisteningMode != nil) {
			if (self.foundCharacteristic != nil) {
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic];
			} else {
				[self.peripheral discoverServices:nil];
			}
		}
	}
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	peripheral.delegate = self;
	[peripheral discoverServices:nil];
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	if (error) return;

	for (CBService *service in peripheral.services) {
		peripheral.delegate = self;
		[peripheral discoverCharacteristics:nil forService:service];
	}
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	if (error) return;

	for (CBCharacteristic *characteristic in service.characteristics) {
		if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"63331338-23C1-11E5-B696-FEFF819CDC9F"]]) {
			if (self.shouldChangeTolisteningMode != nil) {
				self.foundCharacteristic = characteristic;
				[self.centralManager stopScan];
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic];
			}
		}
	}
}
@end
