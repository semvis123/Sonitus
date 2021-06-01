#import <Preferences/PSListController.h>
#include "spawn.h"
#import <BluetoothManager/BluetoothManager.h>

@interface SPBRootListController : PSListController

@property(nonatomic, retain)UIView *headerView;
@property(nonatomic, retain)UIImageView *headerImageView;

@end

@interface PSSpecifier : NSObject
-(void)setValues:(id)arg1 titles:(id)arg2;
@end