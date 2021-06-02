#import <Tweak.h>

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
					pingPong = pingPong && closeSessionTimer != nil? 0x00: 0x01;
					if (closeSessionTimer == nil) {
						[[SessionController sharedController] closeSession];
					}
					[[SessionController sharedController] setupControllerForAccessory:accessory withProtocolString:@"jp.co.sony.songpal.mdr.link"];
					[[SessionController sharedController] openSession];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * (closeSessionTimer==nil? 450 : 0)), dispatch_get_main_queue(), ^{						
						char sendStatus = [arg1 isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"] ? 0x00 : 0x11; 
						char ncAsmValue = [arg1 isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"] ? NCValue : ASMValue;
						char focusOnVoice = [arg1 isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"] ? focusOnVoiceNC : focusOnVoiceASM;
						char dualSingleValue = ncAsmValue == 0 ? (windReductionSupport? 0x2: 0x1) : (ncAsmValue == 1 ? 0x1 : 0x0);
						char settingType = !windReductionSupport && ncAsmValue == 0 ? 0x0 : 0x2;
						char command[] = {0x0c, pingPong, 0x00, 0x00, 0x00, 0x08, 0x68, 0x2, sendStatus, settingType, dualSingleValue, !!settingType, focusOnVoice, ncAsmValue};
						
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

						if (closeSessionTimer != nil){
							dispatch_source_cancel(closeSessionTimer);
							closeSessionTimer = nil;
						}
						closeSessionTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
						if (closeSessionTimer) {
							dispatch_source_set_timer(closeSessionTimer, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 10 ), DISPATCH_TIME_FOREVER, (1ull * NSEC_PER_SEC) / 10);
							dispatch_source_set_event_handler(closeSessionTimer, ^{
								[[SessionController sharedController] closeSession];
							});
							dispatch_resume(closeSessionTimer);
						}
				});
			}
		}
		return true;
	}
	return %orig;
}

-(id)currentBluetoothListeningMode {
	// if (isEnabled && [self.name isEqual:headphonesName]){
	// 	return currentListeningMode; 
	// }
	return %orig;
}
%end

void updatePrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.semvis123.headphonifypreferences.plist"];
	if(prefs)
	{
		isEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : isEnabled;
		focusOnVoiceASM = [prefs objectForKey:@"focusOnVoiceASM"] ? [[prefs objectForKey:@"focusOnVoiceASM"] boolValue] : focusOnVoiceASM;
		headphonesName = [prefs objectForKey:@"headphonesName"] ? [prefs objectForKey:@"headphonesName"] : headphonesName;
		focusOnVoiceNC = [prefs objectForKey:@"focusOnVoiceNC"] ? [[prefs objectForKey:@"focusOnVoiceNC"] boolValue] : focusOnVoiceNC;
		NCValue = [prefs objectForKey:@"NCValue"] ? [[prefs objectForKey:@"NCValue"] intValue] : NCValue;
		ASMValue = [prefs objectForKey:@"ASMValue"] ? [[prefs objectForKey:@"ASMValue"] intValue] : ASMValue;
		windReductionSupport = [prefs objectForKey:@"windReductionSupport"] ? [[prefs objectForKey:@"windReductionSupport"] boolValue] : windReductionSupport;
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs, CFSTR("com.semvis123.headphonifypreferences/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();

}