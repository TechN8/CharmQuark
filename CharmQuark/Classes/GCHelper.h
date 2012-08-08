//
//  GCHelper.h
//
//  Copyright 2012 Aether Theory LLC.
//  Portions copyright 2011 Ray Wenderlich.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementExample @"com.aethertheory.charmquark..."
#define kLeaderboardTimeAttack @"CQ1_TIMEATTACK"
#define kLeaderboardAccelerator @"CQ1_ACCELERATOR"

@interface GCHelper : NSObject <NSCoding> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}

@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;

+ (GCHelper *) sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
- (void)save;
- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport 
        achievementsToReport:(NSMutableArray *)achievementsToReport;
- (void)reportAchievement:(NSString *)identifier 
          percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int)score;
- (int)retrieveScore:(NSString *)identifier;

@end
