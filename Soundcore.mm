#import "Soundcore.h"

@implementation SoundcoreController {}


+(SoundcoreController *)sharedInstance {
	static SoundcoreController *soundcoreController = nil;
	if (soundcoreController == nil) {
		soundcoreController = [SoundcoreController new];
	}

	return soundcoreController;
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode {
	pid_t pid;
	const char *args[] = {"killall", "-9", "SoundCore", NULL};
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
		[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"DAF51A01"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
	}
}

-(void)setListeningMode:(NSString *)listeningMode forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic initializeConnection:(BOOL)initialize {
	bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
	bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
	self.shouldChangeTolisteningMode = nil;
	if (initialize) {
		Byte initializeCommand[] = {0x08, 0xee, 0x00, 0x00, 0x00, 0x01, 0x01, 0x0a, 0x00, 0x02};
		NSData *initializeData = [NSData dataWithBytes:initializeCommand length:sizeof(initializeCommand)];
		[peripheral writeValue:initializeData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
		Byte initializeCommand2[] = {0x08, 0xee, 0x00, 0x00, 0x00, 0x05, 0x01, 0x0a, 0x00, 0x06};
		NSData *initializeData2 = [NSData dataWithBytes:initializeCommand2 length:sizeof(initializeCommand2)];
		[peripheral writeValue:initializeData2 forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
	}

	Byte command[] = { 0x08, 0xee, 0x00, 0x00, 0x00, 0x06, 0x81, 0x0e, 0x00, static_cast<Byte>(isOff ? 0x02 : isNC ? 0x00 : 0x01), 0x00, 0x01, 0x00, static_cast<Byte>(isOff ? 0x8e : isNC ? 0x8c : 0x8d)};
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
		if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"7777"]]) {
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
