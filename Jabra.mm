#import "Jabra.h"

@implementation JabraController {}


+(JabraController *)sharedInstance {
	static JabraController *jabraController = nil;
	if (jabraController == nil) {
		jabraController = [JabraController new];
	}

	return jabraController;
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode {
	pid_t pid;
	const char *args[] = {"killall", "-9", "JabraMoments", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);

	self.shouldChangeTolisteningMode = listeningMode;
	if (self.centralManager == nil) {
		self.centralQueue = dispatch_queue_create("com.semvis.sonitus", DISPATCH_QUEUE_SERIAL);
		self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue];
	}
	if (self.peripheral != nil && self.foundCharacteristic != nil) {
		if (self.peripheral.state == CBPeripheralStateConnected) {
			[self setListeningMode:listeningMode forPeripheral:self.peripheral forCharacteristic:self.foundCharacteristic initializeConnection:NO];
		} else {
			[self.centralManager connectPeripheral:self.peripheral options:nil];
		}
	} else {
		[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FEFF"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
	}
}

-(void)setListeningMode:(NSString *)listeningMode forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic initializeConnection:(BOOL)initialize {
	bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
	bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
	bool isTP = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"];

if (isTP || isNC || isOff){
	self.shouldChangeTolisteningMode = nil;

	// if (initialize) {
	// 	Byte initializeCommand[] = {0x08, 0xee, 0x00, 0x00, 0x00, 0x01, 0x01, 0x0a, 0x00, 0x02};
	// 	NSData *initializeData = [NSData dataWithBytes:initializeCommand length:sizeof(initializeCommand)];
	// 	[peripheral writeValue:initializeData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
	// 	Byte initializeCommand2[] = {0x08, 0xee, 0x00, 0x00, 0x00, 0x05, 0x01, 0x0a, 0x00, 0x06};
	// 	NSData *initializeData2 = [NSData dataWithBytes:initializeCommand2 length:sizeof(initializeCommand2)];
	// 	[peripheral writeValue:initializeData2 forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
	// }

	Byte command[] = {0x0d, 0x09, 0x00, 0x88, 0x13, 0xbe, 0x01, static_cast<Byte>(isOff ? 0x01 : isNC ? 0x04 : 0x02)};
	[peripheral writeValue:[NSData dataWithBytes:command length:sizeof(command)] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];

	Byte cap[] = {0x0d, 0x09, 0x00, 0x47, 0x13, 0xbe, 0x01};
	[peripheral writeValue:[NSData dataWithBytes:cap length:sizeof(cap)] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];

	if (isTP || isNC){
		cap[6] = static_cast<Byte> (isTP ? 0x02 : 0x03);
		[peripheral writeValue:[NSData dataWithBytes:cap length:sizeof(cap)] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
	}

	if (isNC || isOff) {
		Byte ack[] = {0x0d, 0x09, 0x00, 0x46, 0x13, 0x76};
		for (int i = 0; i < 2; i++) {
			[peripheral writeValue:[NSData dataWithBytes:ack length:sizeof(ack)] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
		}
	}
}
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
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic initializeConnection:NO];
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
		if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"8B5B80C0-AC6D-11E4-BAEF-0002A5D5C51B"]]) {
			self.foundCharacteristic = characteristic;
			if (self.shouldChangeTolisteningMode != nil) {
				[self.centralManager stopScan];
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic initializeConnection:YES];
			}
			break;
		}
	}
}
@end
