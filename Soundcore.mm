#import "Soundcore.h"

@implementation SoundcoreController {}

+(SoundcoreController *)sharedInstance {
	static SoundcoreController *soundcoreController = nil;
	if (soundcoreController == nil) {
		soundcoreController = [SoundcoreController new];
	}

	return soundcoreController;
}

-(void)useSettings: (NSMutableDictionary *)settings {
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory {
	self.shouldChangeTolisteningMode = listeningMode;
	if (self.centralManager == nil) {
		self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	}
	if (self.peripheral != nil && self.foundCharacteristic != nil) {
		if ([self.peripheral valueForKey:@"isConnected"]) {
			[self setListeningMode:listeningMode forPeripheral:self.peripheral forCharacteristic:self.foundCharacteristic];
		} else {
			[self.centralManager connectPeripheral:self.peripheral options:nil];
		}
	} else {
		[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"DAF51C01"]] options:nil];
	}
}

-(void)setListeningMode:(NSString *)listeningMode forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic {
	bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
	bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
	self.shouldChangeTolisteningMode = nil;

	Byte command[] = { 0x08, 0xee, 0x00, 0x00, 0x00, 0x06, 0x81, 0x0e, 0x00, static_cast<Byte>(isOff ? 0x02 : isNC ? 0x00 : 0x01), 0x00, 0x01, 0x00, static_cast<Byte>(isOff ? 0x8e : isNC ? 0x8c : 0x8d)};
	NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
	[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

-(NSString *)getCurrentListeningModeOfAccessory: (EAAccessory *)accessory {
	return nil;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
	if (central.state == CBManagerStatePoweredOn) {
		NSArray<CBUUID *> *serviceUUIDs = @[[CBUUID UUIDWithString:@"DAF51C01"]];
		[self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:nil];
	}
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	if (![peripheral valueForKey:@"isConnected"]) {
		self.peripheral = peripheral;
        peripheral.delegate = self;
		[self.centralManager connectPeripheral:self.peripheral options:nil];
    } else {
		if (self.shouldChangeTolisteningMode != nil) {
			if (self.foundCharacteristic != nil) {
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic];
			} else {
				peripheral.delegate = self;
				[peripheral discoverServices:nil];
			}
		}
	}
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	peripheral.delegate = self;
	[peripheral discoverServices:nil];
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"7777"]]) {
			if (self.shouldChangeTolisteningMode != nil) {
				self.foundCharacteristic = characteristic;
				[self.centralManager stopScan];
				[self setListeningMode:self.shouldChangeTolisteningMode forPeripheral:peripheral forCharacteristic:self.foundCharacteristic];
			}
        }
    }
}
@end
