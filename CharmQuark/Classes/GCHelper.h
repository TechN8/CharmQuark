//
//  GCHelper.h
//
//  Copyright 2012 Aether Theory LLC.
//  Portions copyright 2011 Ray Wenderlich.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementFirstMatch @"CQ1_FIRSTMATCH"
#define kAchievementTimeAttack @"CQ1_TIMEATTACK"
#define kAchievementAccelerator @"CQ1_ACCELERATOR"
#define kAchievementMeditation @"CQ1_MEDITATION"
#define kAchievementCombo2X @"CQ1_COMBO2X"
#define kAchievementCombo3X @"CQ1_COMBO3X"
#define kAchievementCombo4X @"CQ1_COMBO4X"
#define kAchievementCombo5X @"CQ1_COMBO5X"
#define kAchievementCombo6X @"CQ1_COMBO6X"
#define kAchievementBonus2X @"CQ1_BONUS2X"
#define kAchievementBonus3X @"CQ1_BONUS3X"
#define kAchievementTimeAttack100K @"CQ1_TIMEATTACK_100K"
#define kAchievementAccelerator100K @"CQ1_ACCELERATOR_100K"
#define kAchievementNoBalls @"CQ1_NOBALLS"

#define kLeaderboardTimeAttack @"CQ1_TIMEATTACK"
#define kLeaderboardAccelerator @"CQ1_ACCELERATOR"



@interface GCHelper : NSObject <NSCoding, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
    NSMutableDictionary *achievementProgress;
    GKLeaderboardTimeScope timeScope;
    NSString *category;
}

@property (retain) NSMutableArray *scoresToReport;
@property (nonatomic, retain) NSMutableDictionary *achievementProgress;
@property (retain) NSMutableArray *achievementsToReport;
@property (retain) NSString *category;
@property (assign) GKLeaderboardTimeScope timeScope;
@property (readonly) BOOL isUserAuthenticated; 

+ (GCHelper *) sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
- (void)save;
- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport 
        achievementsToReport:(NSMutableArray *)achievementsToReport
                   timeScope:(GKLeaderboardTimeScope)timeScope
                    category:(NSString*)category;
- (void)reportAchievement:(NSString *)identifier 
          percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int)score;
- (void)showAchievements;
- (void)showLeaderboard;

@end
