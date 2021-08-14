#import <Preferences/PSListController.h>
#import "spawn.h"
#import <BluetoothManager/BluetoothManager.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface SPBRootListController : HBRootListController
@end

@interface PSSpecifier : NSObject
-(void)setValues:(id)arg1 titles:(id)arg2;
@end