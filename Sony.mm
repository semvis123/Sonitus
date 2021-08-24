#import "Sony.h"

@implementation SonyController {
	bool focusOnVoiceNC;
	bool focusOnVoiceASM;
	bool windReductionSupport;
	char pingPong;
	char NCValue;
	char ASMValue;
	dispatch_source_t closeSessionTimer;
}

+(SonyController *)sharedInstance {
	static SonyController *sonyController = nil;
	if (sonyController == nil) {
		sonyController = [SonyController new];
	}

	return sonyController;
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL)v2 withPreferences:(HBPreferences *)preferences {
	pingPong = pingPong && [[SessionController sharedController] sessionIsOpen]? 0x00: 0x01;

	[[SessionController sharedController] setupControllerForAccessory:accessory withProtocolString: v2 ? @"jp.co.sony.songpal.mdr.link2": @"jp.co.sony.songpal.mdr.link"];
	[[SessionController sharedController] openSession];

	dispatch_queue_t queue = dispatch_queue_create("com.semvis.sonitus.queue", NULL);

	dispatch_async(queue, ^{
		[[[SessionController sharedController] writeDataCondition] lock];
		while (![[SessionController sharedController] hasSpaceAvailable] && [[SessionController sharedController] writeDataLength] != 0) {
			[[[SessionController sharedController] writeDataCondition] wait];
		}
		[[[SessionController sharedController] writeDataCondition] unlock];
		bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
		bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
		char sendStatus = v2? 0x1 : isOff ? 0x00 : 0x11;
		char ncAsmValue = isNC? [preferences integerForKey:@"SonyNCValue"] : [preferences integerForKey:@"SonyASMValue"];
		char focusOnVoice = isNC? [preferences integerForKey:@"SonyFocusOnVoiceNC"] : [preferences integerForKey:@"SonyFocusOnVoiceASM"];
		char dualSingleValue = ncAsmValue == 0 ? ([preferences boolForKey:@"SonyWindReductionSupport"]? 0x2: 0x1) : (ncAsmValue == 1 ? 0x1 : 0x0);
		char settingType = ![preferences boolForKey:@"SonyWindReductionSupport"] && ncAsmValue == 0 ? 0x0 : 0x2;
		char inquiredType = v2? 0x15 : 0x2;
		char command[] = {0x0c, pingPong, 0x00, 0x00, 0x00, 0x08, 0x68, inquiredType, sendStatus, static_cast<char>(v2 ? !isOff : settingType), static_cast<char>(v2 ? !isNC : dualSingleValue), static_cast<char>(v2 ? focusOnVoice? 0x5 : 0x2 : !!settingType), focusOnVoice, ncAsmValue};

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
		[[[SessionController sharedController] writeDataCondition] lock];
		while (![[SessionController sharedController] hasSpaceAvailable] && [[SessionController sharedController] writeDataLength] != 0){
			[[[SessionController sharedController] writeDataCondition] wait];
		}
		[[[SessionController sharedController] writeDataCondition] unlock];

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

-(NSString *)getCurrentListeningModeOfAccessory: (EAAccessory *)accessory {
	return nil;
}
@end
