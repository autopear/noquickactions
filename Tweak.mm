#import <UIKit/UIKit.h>

#define PreferencesName "com.autopear.noquickactions"
#define PreferencesChangedNotification "com.autopear.noquickactions.preferenceschanged"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.autopear.noquickactions.plist"

@interface SBApplication : NSObject
-(NSString *)bundleIdentifier;
@end

@interface SBApplicationShortcutMenu : UIView
@property(retain, nonatomic) SBApplication *application;
@end

static BOOL enabled = YES;
static NSArray *blacklist = nil;

static BOOL readPreferenceBOOL(NSString *key, BOOL defaultValue) {
    return !CFPreferencesCopyAppValue((__bridge CFStringRef)key, CFSTR(PreferencesName)) ? defaultValue : [(id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, CFSTR(PreferencesName))) boolValue];
}

static void LoadPreferences() {
    enabled = readPreferenceBOOL(@"enabled", YES);

    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];

    NSMutableArray *list = [NSMutableArray array];
    for (NSString *key in [dict allKeys]) {
        if ([key hasPrefix:@"NQA-"] && [[dict objectForKey:key] boolValue])
            [list addObject:[key substringFromIndex:4]];
    }
    if (blacklist)
        [blacklist release];

    blacklist = [list retain];

    [dict release];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LoadPreferences();
}

%hook SBApplicationShortcutMenu

- (BOOL)_canDisplayShortcutItem:(id)item {
    if (enabled && blacklist && self.application && [blacklist containsObject:[self.application bundleIdentifier]])
        return NO;
    else
        return %orig(item);
}

%end

%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

        LoadPreferences();
    }
}
