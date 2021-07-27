#import <Tweak.h>

bool isEnabled = true;
NSString *headphonesName = @"WH-1000XM3";

#define headphonesController SonyController
#define useExternalAccessory false

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
		if (useExternalAccessory){
			NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
			for (EAAccessory *accessory in accessories) {
				if ([[self valueForKey:@"ID"] containsString:[accessory valueForKey:@"macAddress"]]){
					if ([accessory.protocolStrings containsObject:@"jp.co.sony.songpal.mdr.link"]){
						[[SonyController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:NO];
					} else if ([accessory.protocolStrings containsObject:@"jp.co.sony.songpal.mdr.link2"]){
						[[SonyController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:YES];
					} else if ([accessory.protocolStrings containsObject:@"com.bose.bmap"]){
						[[BoseController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:NO];
					} else if ([accessory.protocolStrings containsObject:@"com.bose.bmap2"]){
						[[BoseController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory v2:YES];
					}
				}
			}
		} else {
			[[SoundcoreController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:nil];
		}
		return true;
	}
	return %orig;
}

-(id)currentBluetoothListeningMode {
	if (isEnabled && [self.name isEqual:headphonesName]){
		// NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		// for (EAAccessory *accessory in accessories) {
		// 	if ([[self valueForKey:@"ID"] containsString:[accessory valueForKey:@"macAddress"]]){
		// 		return [[SonyController sharedInstance] getCurrentListeningModeOfAccessory:accessory];
		// 	}
		// }
		return nil;
	}
	return %orig;
}
%end

void updatePrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.headphonifypreferences.plist"];
	if(prefs)
	{
		isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
		headphonesName = [prefs objectForKey:@"headphonesName"] ? [prefs objectForKey:@"headphonesName"] : headphonesName;
		[[headphonesController sharedInstance] useSettings:prefs];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, CFSTR("com.semvis123.headphonifypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();
}
