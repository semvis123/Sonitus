
#import "SessionController.h"

NSString *SessionDataReceivedNotification = @"SessionDataReceivedNotification";

@implementation SessionController

@synthesize accessory = _accessory;
@synthesize protocolString = _protocolString;
@synthesize receiveDataCondition = _receiveDataCondition;
@synthesize writeDataCondition = _writeDataCondition;

// low level write method - write data to the accessory while there is space available and data to write
-(void)_writeData {
	while (_session != nil && [[_session outputStream] hasSpaceAvailable] && ([_writeData length] > 0)) {
		NSInteger bytesWritten = [[_session outputStream] write:static_cast<const unsigned char *>([_writeData bytes]) maxLength:[_writeData length]];
		if (bytesWritten == -1) {
			NSLog(@"write error");
			break;
		} else if (bytesWritten > 0) {
			//  [_writeData replaceBytesInRange:NSMakeRange(0, MIN([_writeData length], bytesWritten)) withBytes:NULL length:0]; // seems to crash sometimes
			[_writeData setData:[NSData dataWithBytes:NULL length:0]]; // clear the whole mutatableData instead, by setting it to an empty NSData
		}
	}
	[_writeDataCondition signal];
}

// low level read method - read data while there is data and space available in the input buffer
-(void)_readData {
	if (_session) {
		uint8_t buf[128];
		while ([[_session inputStream] hasBytesAvailable]) {
			NSInteger bytesRead = [[_session inputStream] read:buf maxLength:128];
			if (_readData == nil) {
				_readData = [[NSMutableData alloc] init];
			}

			[_readData appendBytes:(void *)buf length:bytesRead];
			NSLog(@"read %ld bytes from input stream", bytesRead);
			NSLog(@"read %@ bytes from input stream", _readData);
		}

		[_receiveDataCondition signal];
		[[NSNotificationCenter defaultCenter] postNotificationName:SessionDataReceivedNotification object:self userInfo:nil];
	}
}


+(SessionController *)sharedController {
	static SessionController *sessionController = nil;
	if (sessionController == nil) {
		sessionController = [[SessionController alloc] init];
	}

	return sessionController;
}

-(void)dealloc {
	[self closeSession];
	[self setupControllerForAccessory:nil withProtocolString:nil];
}

// initialize the accessory with the protocolString
-(void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString {
	_accessory = accessory;
	_protocolString = protocolString;
	_receiveDataCondition = [[NSCondition alloc] init];
	_writeDataCondition = [[NSCondition alloc] init];
}

// open a session with the accessory and set up the input and output stream on the default run loop
-(bool)openSession {
	if (_session == nil && _protocolString && _accessory) {
		[_accessory setDelegate:self];
		_session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];

		if (_session) {
			[[_session inputStream] setDelegate:self];
			[[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session inputStream] open];

			[[_session outputStream] setDelegate:self];
			[[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[[_session outputStream] open];
		} else {
			NSLog(@"creating session failed");
		}
	}
	return (_session != nil);
}

-(bool)sessionIsOpen {
	return (_session != nil);
}

// close the session with the accessory.
-(void)closeSession {
	if (_session != nil) {
		[[_session inputStream] close];
		[[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[[_session inputStream] setDelegate:nil];
		[[_session outputStream] close];
		[[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[[_session outputStream] setDelegate:nil];
	}
	_session = nil;
	_writeData = nil;
	_readData = nil;
}

// high level write data method
- (void)writeData:(NSData *)data {
	if (_writeData == nil) {
		_writeData = [[NSMutableData alloc] init];
	}

	[_writeData appendData:data];
	[self _writeData];
}

// high level read method 
-(NSData *)readData:(NSUInteger)bytesToRead {
	NSData *data = nil;
	if ([_readData length] >= bytesToRead) {
		NSRange range = NSMakeRange(0, bytesToRead);
		data = [_readData subdataWithRange:range];
		[_readData replaceBytesInRange:range withBytes:NULL length:0];
	}
	return data;
}

// get number of bytes read into local buffer
-(NSUInteger)readBytesAvailable {
	return [_readData length];
}

-(long)writeDataLength {
	return [_writeData length];
}

-(bool)hasSpaceAvailable {
	return [[_session outputStream] hasSpaceAvailable];
}

// asynchronous NSStream handleEvent method
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	switch (eventCode) {
		case NSStreamEventNone:
			break;
		case NSStreamEventOpenCompleted:
			break;
		case NSStreamEventHasBytesAvailable:
			[self _readData];
			break;
		case NSStreamEventHasSpaceAvailable:
			[self _writeData];
			break;
		case NSStreamEventErrorOccurred:
			break;
		case NSStreamEventEndEncountered:
			break;
		default:
			break;
	}
}

@end
