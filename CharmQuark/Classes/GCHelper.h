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

@interface GCHelper : NSObject <NSCoding, GKLeaderboardViewControllerDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
    GKLeaderboardTimeScope timeScope;
    NSString *category;
}

@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;
@property (retain) NSString *category;
@property (assign) GKLeaderboardTimeScope timeScope;
@property (readonly) BOOL isUserAuthenticated; 

+ (GCHelper *) sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
- (void)save;
- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport 
        achievementsToReport:(NSMutableArray *)achievementsToReport;
- (void)reportAchievement:(NSString *)identifier 
          percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int)score;
- (void)showLeaderboard;

@end
