#import "Bose.h"

@implementation BoseController {
	dispatch_source_t closeSessionTimer;
}

+(BoseController *)sharedInstance {
	static BoseController *boseController = nil;
	if (boseController == nil) {
		boseController = [BoseController new];
	}

	return boseController;
}

-(void)setCurrentBluetoothListeningMode:(NSString *)listeningMode forAccessory:(EAAccessory *)accessory v2: (BOOL) v2 {
	[[SessionController sharedController] setupControllerForAccessory:accessory withProtocolString: v2 ? @"com.bose.bmap2" : @"com.bose.bmap"];
	[[SessionController sharedController] openSession];
	// create a new dispatch queue
	dispatch_queue_t queue = dispatch_queue_create("com.semvis.sonitus.queue", NULL);

	dispatch_async(queue, ^{
		[[[SessionController sharedController] writeDataCondition] lock];
		while (![[SessionController sharedController] hasSpaceAvailable] && [[SessionController sharedController] writeDataLength] != 0){
			[[[SessionController sharedController] writeDataCondition] wait];
		}
		[[[SessionController sharedController] writeDataCondition] unlock];
		bool isOff = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeNormal"];
		bool isNC = [listeningMode isEqual:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];

		char command[] = {0x01,
		 static_cast<char>(v2 ? 0x05 : 0x06),
		 0x02,
		 static_cast<char>(v2 ? 0x02 : 0x01),
		 static_cast<char>(isNC ? (v2 ? 0x00 : 0x01) : isOff ? (v2? 0x00 : 0x00) : (v2 ? 0x0a : 0x03)),
		 static_cast<char>(v2 ? (isOff? 0x00 : 0x01) : NULL)
		 };

		[[SessionController sharedController] writeData:[NSData dataWithBytes:command length:sizeof(command) - (v2? 0 : 1)]];
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
