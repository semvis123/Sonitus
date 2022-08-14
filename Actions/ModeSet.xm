#import <ModeSet.h>

id getOutputDevice(){
	id routingController = [[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"];
	id outputDevice = [[[routingController pickedRoute] logicalLeaderOutputDevice] valueForKey:@"_avOutputDevice"];
	
  NSLog(@"{sonitus} output device %@", outputDevice);
  
  return outputDevice;
}

NSDictionary *modes = @{
  @"Noise cancelling": @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
  @"Transparency mode": @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
  @"Normal": @"AVOutputDeviceBluetoothListeningModeNormal"
};

NSString *mode = @"mode";
NSString *headphone = @"headphone";

@interface ModeSet : PCAction
@end
@implementation ModeSet
-(void) performActionForIdentifier:(NSString*)identifier withParameters:(NSDictionary*)parameters {
  
  if (modes[parameters[mode]]) {
    [getOutputDevice() setCurrentBluetoothListeningMode:modes[parameters[mode]]];
    [prefs setObject:parameters[headphone] forKey:@"HeadphonesName"];
    
    // NSLog(@"{sonitus}: done actions %@, parameter %@, set mode %@, %@", identifier, parameters[mode] ,modes[parameters[mode]], [prefs objectForKey:@"HeadphonesList"]);

  } 
  // else {
  //   NSLog(@"{sonitus} Incorrect mode or headphone name %@", parameters[mode]);
  // }

}

-(NSString*) nameForIdentifier:(NSString*)identifier {
    return @"Set noise control";
}

-(NSArray<NSString*>*) keywordsForIdentifier:(NSString*)identifier {
    return @[@"set", @"sonitus", @"audio", @"mode", @"Noise cancelling", @"Transparency mode", @"Normal"];
}

-(NSString*) descriptionSummaryForIdentifier:(NSString*)identifier {
    return @"Set the noise control mode for Sonitus tweak";
}

-(NSArray*) parametersDefinitionForIdentifier:(NSString*)identifier {
		// NSArray *btDevices = [[BluetoothManager sharedInstance] pairedDevices];

    return @[
        @{
            @"type" : @"text",
            @"key" : headphone,
            @"label" : @"Headphones",
            @"defaultValue" : (NSString *)[prefs objectForKey:@"HeadphonesName"]
        },
        @{
            @"type" : @"enum",
            @"key" : mode,
            @"label" : @"Mode:",
            @"defaultValue" : @"Noise cancelling",
            @"items" : @[ @"Noise cancelling", @"Transparency mode", @"Normal" ]
        }
    ];
}

-(NSString*) parameterSummaryForIdentifier:(NSString*)identifier {
    return [NSString stringWithFormat:@"Switch ${%@} to ${%@}", headphone, mode];
}

-(NSString*) associatedAppBundleIdForIdentifier:(NSString*)identifier {
    return @"com.semvis.sonitus";
}

-(NSString*) iconPathForIdentifier:(NSString*)identifier {
    return @"/Library/PreferenceBundles/sonitusPreferences.bundle/icon.png";
}

@end

%ctor {
  prefs = [[HBPreferences alloc] initWithIdentifier:@"com.semvis.sonituspreferences"];

   //Register a fake application for the tweak
    PCApplication *Sonitus = [[PCApplication alloc] initWithBundleId:@"com.semvis.sonitus" name:@"Sonitus" iconPath:@"/Library/PreferenceBundles/sonitusPreferences.bundle/icon.png"];
    [[PowercutsManager sharedInstance] registerFakeApplication:Sonitus];

    [[PowercutsManager sharedInstance] registerActionWithIdentifier:@"com.semvis.sonitus.action.modeset" action:[ModeSet new]];
}