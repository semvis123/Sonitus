#import <Tweak.h>

bool isEnabled = true;
bool dataRead = false;
NSString *headphonesName = @"WH-1000XM3";
NSString *currentListeningMode = @"AVOutputDeviceBluetoothListeningModeNormal";

%hook AVOutputDevice

-(id)availableBluetoothListeningModes {
	if (isEnabled && [self.name isEqual:headphonesName]){
		NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
							@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
							@"AVOutputDeviceBluetoothListeningModeAudioTransparency",
							nil];
		return options;
	}
	return %orig;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {
	if (isEnabled && [self.name isEqual:headphonesName]){
		NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		for (EAAccessory *accessory in accessories) {
			if ([[accessory modelNumber] isEqual: @"WH-1000XM3"]){
				[[SessionController sharedController] setupControllerForAccessory:accessory
					withProtocolString:@"jp.co.sony.songpal.mdr.link"]; 
				[[SessionController sharedController] openSession];
				[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.45]]; // We need this timeout, otherwise the headset won't respond to our command.
				char NCValue = 0;
				bool windReductionSupport = true;
				bool focusOnVoiceNC = false;
				char NCDualSingleValue = NCValue == 0 ? (windReductionSupport? 0x2: 0x1) : (NCValue == 1 ? 0x1 : 0x0);
				// char ASMDualSingleValue = ASMValue == 0 ? (windReductionSupport? 0x2: 0x1) : (ASMValue == 1 ? 0x1 : 0x0);
				char NCSettingType = !windReductionSupport && NCValue == 0 ? 0x0 : 0x2;
				// char ASMSettingType = !windReductionSupport && ASMValue == 0 ? 0x0 : 0x2;

				char command[] = {0x0c, 0x00, 0x00, 0x00, 0x00, 0x08, 0x68, 0x2, 0x11, NCSettingType, NCDualSingleValue, !!NCSettingType, focusOnVoiceNC, NCValue};
				// char dataASMOn[] = {0x0c, 0x00, 0x00, 0x00, 0x00, 0x08, 0x68, 0x2, 0x11, ASMSettingType, ASMDualSingleValue, !!ASMSettingType, focusOnVoiceASM, ASMValue};
				// char dataASMOff[] = {0x0c, 0x00, 0x00, 0x00, 0x00, 0x08, 0x68, 0x2, 0x0, 0x2, 0x0, 0x1, 0x0, 0x14};

				// const char command[] = { 0x0c, 0x00, 0x00, 0x00, 0x00, 0x08, 0x68, 0x02, 0x11, 0x02, 0x00, 0x01, 0x00, 0x14 };

				unsigned char sum = 0;
				for (int i = 0; i < sizeof(command); i++){
					sum += command[i];
				}

				char commandPacked[1 + sizeof(command) + 2];
				commandPacked[0] = 0x3e;
				memcpy(&commandPacked[1], command, sizeof(command));
				commandPacked[1 + sizeof(command)] = sum;
				commandPacked[1 + sizeof(command) + 1] = 0x3c;

				[[SessionController sharedController] writeData:[NSData dataWithBytes:commandPacked length:sizeof(commandPacked)]];
				[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
				[[SessionController sharedController] closeSession];
			}
		}
		return true;
	}
	return %orig;
}

-(id)currentBluetoothListeningMode {
	if (isEnabled && [self.name isEqual:headphonesName]){
		return currentListeningMode; 
	}
	return %orig;
}
%end
