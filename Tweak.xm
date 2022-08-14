#import <Tweak.h>

NSString *prev;

%hook AVOutputDevice

-(id)availableBluetoothListeningModes {
	if ([preferences boolForKey:@"Enabled"] && [self.name isEqual:(NSString *)[preferences objectForKey:@"HeadphonesName"]]){
		NSArray *options = [NSArray arrayWithObjects:@"AVOutputDeviceBluetoothListeningModeNormal",
							@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
							@"AVOutputDeviceBluetoothListeningModeAudioTransparency",
							nil];
		return options;
	}
	return %orig;
}

-(BOOL)setCurrentBluetoothListeningMode:(id)arg1 error:(id*)arg2  {

	if ([preferences boolForKey:@"Enabled"] && [self.name isEqual:(NSString *)[preferences objectForKey:@"HeadphonesName"]]) {
		SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];

		if ([arg1 isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"] && [mediaController isPlaying]) {
			[mediaController pauseForEventSource: 0];
			prev = arg1;
		}
		else if ([mediaController isPaused] && [prev isEqual:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"]){
			[mediaController playForEventSource: 0];
		}
		
		NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		for (EAAccessory *accessory in accessories) {
			if ([[self valueForKey:@"ID"] containsString:[accessory valueForKey:@"macAddress"]]){
				if ([accessory.protocolStrings containsObject:@"jp.co.sony.songpal.mdr.link"]){
					[[SonyController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:NO withPreferences:preferences];
				} else if ([accessory.protocolStrings containsObject:@"jp.co.sony.songpal.mdr.link2"]){
					[[SonyController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:YES withPreferences:preferences];
				} else if ([accessory.protocolStrings containsObject:@"com.bose.bmap"]){
					[[BoseController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:NO];
				} else if ([accessory.protocolStrings containsObject:@"com.bose.bmap2"]){
					[[BoseController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:YES];
				}
				return YES;
			}
		}
		[[JabraController sharedInstance] setCurrentBluetoothListeningMode:arg1];
		[[SoundcoreController sharedInstance] setCurrentBluetoothListeningMode:arg1];
		return YES;
	}
	return %orig;
}

-(id)currentBluetoothListeningMode {
	if ([preferences boolForKey:@"Enabled"] && [self.name isEqual:(NSString *)[preferences objectForKey:@"HeadphonesName"]]) {
		// currently not being used
		return nil;
	}
	return %orig;
}
%end

%ctor {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.semvis.sonituspreferences"];
	[preferences registerDefaults:@{
		@"Enabled": @YES,
		@"HeadphonesName": @"WH-1000XM3",
		@"SonyWindReductionSupport": @YES,
		@"SonyNCValue": @0,
		@"SonyfocusOnVoiceNC": @NO,
		@"SonyASMValue": @20,
		@"SonyFocusOnVoiceASM": @NO
	}];
}
