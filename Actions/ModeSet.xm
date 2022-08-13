#import <libpowercuts/libpowercuts.h>
#import <ModeSet.h>

id getOutputDevice(){
	id routingController = [[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"];
	id outputDevice = [[[routingController pickedRoute] logicalLeaderOutputDevice] valueForKey:@"_avOutputDevice"];
	return outputDevice;
}

NSDictionary *modes = @{
  @"Noise cancelling": @"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation",
  @"Hear through": @"AVOutputDeviceBluetoothListeningModeAudioTransparency",
  @"Inactive": @"AVOutputDeviceBluetoothListeningModeNormal"
};

NSString *key = @"mode";

@interface ModeSet : PCAction
@end
@implementation ModeSet
-(void) performActionForIdentifier:(NSString*)identifier withParameters:(NSDictionary*)parameters {
  if (modes[parameters[key]]) {
    [getOutputDevice() setCurrentBluetoothListeningMode:modes[parameters[key]]];
  NSLog(@"done actions %@, parameter %@, set mode %@", identifier, parameters[key] ,modes[parameters[key]]);

  } else {
    NSLog(@"Incorrect mode %@", parameters[key]);
  }

}

-(NSString*) nameForIdentifier:(NSString*)identifier {
    return @"Set Sonitus audio mode";
}
-(NSString*) descriptionSummaryForIdentifier:(NSString*)identifier {
    return @"Set the audio mode for Sonitus tweak";
}
-(NSArray*) parametersDefinitionForIdentifier:(NSString*)identifier {
    return @[
        @{
            @"type" : @"enum",
            @"key" : @"mode",
            @"label" : @"Mode:",
            @"defaultValue" : @"Noise cancelling",
            @"items" : @[ @"Noise cancelling", @"Hear through", @"Inactive" ]
        }
    ];
}

-(NSString*) associatedAppBundleIdForIdentifier:(NSString*)identifier {
    return @"com.semvis.sonitus";
}

@end

%ctor {
   //Register a fake application for your tweak
    PCApplication *Sonitus = [[PCApplication alloc] initWithBundleId:@"com.semvis.sonitus" name:@"Sonitus" iconPath:@"/Library/PreferenceBundles/sonitusPreferences.bundle/icon.png"];
    [[PowercutsManager sharedInstance] registerFakeApplication:Sonitus];

    [[PowercutsManager sharedInstance] registerActionWithIdentifier:@"com.semvis.sonitus.action.modeset" action:[ModeSet new]];
}