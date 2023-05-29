#import "spawn.h"
#import <BluetoothManager/BluetoothManager.h>
#import <Cephei/HBPreferences.h>
#import <CepheiPrefs/CepheiPrefs.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface SPBRootListController : HBRootListController
@end

@interface PSSpecifierCustom : PSSpecifier
- (void)setValues:(id)arg1 titles:(id)arg2;
@end
