#import <Tweak.h>

bool isEnabled = true;
NSString *headphonesName = @"WH-1000XM3";

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
			if ([[accessory modelNumber] isEqual:headphonesName]){
				[[SonyController sharedInstance] setCurrentBluetoothListeningMode:arg1 forAccessory:accessory];
			}
		}
		return true;
	}
	return %orig;
}

-(id)currentBluetoothListeningMode {
	if (isEnabled && [self.name isEqual:headphonesName]){
		NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
		for (EAAccessory *accessory in accessories) {
			if ([[accessory modelNumber] isEqual:headphonesName]){
				return [[SonyController sharedInstance] getCurrentListeningModeOfAccessory:accessory];
			}
		}
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
		[[SonyController sharedInstance] useSettings:prefs];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, CFSTR("com.semvis123.headphonifypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();
}
