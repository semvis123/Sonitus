#import <Preferences/PSListController.h>
#import "spawn.h"
#import <BluetoothManager/BluetoothManager.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <Preferences/PSSpecifier.h>

@interface SPBRootListController : HBRootListController
@end

@interface PSSpecifierCustom : PSSpecifier
-(void)setValues:(id)arg1 titles:(id)arg2;
@end