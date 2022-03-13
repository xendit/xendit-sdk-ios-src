//
//  IDFAHelper.m
//  Xendit
//
//  Created by Vladimir Lyukov on 22/11/2018.
//

#import "IDFAHelper.h"

NSString * _Nullable XENweakGetIDFA(void) {
    NSString *idfa;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");

    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        idfa = [advertisingIdentifier UUIDString];
    }
    return idfa;
}
