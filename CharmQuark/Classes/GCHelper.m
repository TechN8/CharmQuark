//
//  GCHelper.m
//
//  Copyright 2012 Aether Theory LLC.
//  Portions copyright 2011 Ray Wenderlich.
//

#import "cocos2d.h"
#import "GCHelper.h"
#import "GCDatabase.h"
#import "Constants.h"
#import "RemoveFromParentAction.h"
#import "AchievementPopup.h"
#import "GameManager.h"

@implementation GCHelper

@synthesize scoresToReport;
@synthesize achievementsToReport;
@synthesize achievementProgress;
@synthesize achievementDescriptions;
@synthesize isUserAuthenticated = userAuthenticated;
@synthesize category;
@synthesize timeScope;

#pragma mark - Loading/Saving

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance
{
    @synchronized([GCHelper class])
    {
        if (!sharedHelper) {
            sharedHelper = [loadData(@"GameCenterData") retain];
            if (!sharedHelper) {
                [[self alloc]
                 initWithScoresToReport:[NSMutableArray array]
                 achievementsToReport:[NSMutableArray array]
                 timeScope: GKLeaderboardTimeScopeToday
                 category: nil];
            }
        }
        return sharedHelper;
    }
    return nil;
}

- (void)save
{
    saveData(self, @"GameCenterData");
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)initWithScoresToReport:(NSMutableArray *)theScoresToReport
        achievementsToReport:(NSMutableArray *)theAchievementsToReport
                   timeScope:(GKLeaderboardTimeScope)theTimeScope
                    category:(NSString *)theCategory
{
    if ((self = [super init])) {
        self.scoresToReport = theScoresToReport;
        self.achievementsToReport = theAchievementsToReport;
        self.timeScope = theTimeScope;
        self.category = theCategory;
        achievementProgress = [[NSMutableDictionary alloc] init];
        achievementDescriptions = [[NSMutableDictionary alloc] init];
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

#pragma mark - Internal functions

- (void)loadAchievementsWithCompletionHandler:(void (^)())completionHandler
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error == nil)
        {
            for (GKAchievement* achievement in achievements) {
                [achievementProgress setObject: achievement forKey: achievement.identifier];
            }
            [self retrieveAchievmentMetadataWithCompletionHandler:completionHandler];
        }
    }];
}

- (void) retrieveAchievmentMetadataWithCompletionHandler:(void (^)())completionHandler
{
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:
     ^(NSArray *descriptions, NSError *error) {
         if (error == nil) {
             if (descriptions != nil) {
                 for (GKAchievementDescription *description in descriptions) {
                     [achievementDescriptions setObject:description forKey:description.identifier];
                 }
             }
             completionHandler();
         }
     }];
}

- (void)sendScore:(GKScore *)score
{
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSLog(@"Successfully sent score!");
                [scoresToReport removeObject:score];
                [self save]; // Don't repeat.
            } else {
                NSLog(@"Score failed to send... will try again later.  Reason: %@", error.localizedDescription);
            }
        });
    }];
}

- (void)showAchievementNotification:(GKAchievement *)achievement
{
    CCNode *notificationNode = [[CCDirector sharedDirector] notificationNode];
    if (nil != notificationNode) {
        GKAchievementDescription *description
        = [achievementDescriptions objectForKey:achievement.identifier];
        
        if (nil != description) {
            [description loadImageWithCompletionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
                if (nil == error) {
                    [notificationNode addChild:
                     [AchievementPopup popupWithDescription:description image:image]];
                }
            }];
        }
    }
}

- (void)sendAchievement:(GKAchievement *)achievement
{
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == NULL) {
                NSLog(@"Successfully sent archievement!");
                [achievementsToReport removeObject:achievement];
                [self save]; // Don't repeat.
                [self showAchievementNotification:achievement];
            } else {
                NSLog(@"Achievement failed to send... will try again \
                      later.  Reason: %@", error.localizedDescription);
            }
        });
    }];
}

- (void)resendData
{
    [GKAchievement reportAchievements:achievementsToReport withCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == NULL) {
                NSLog(@"Successfully sent archievement!");
                [achievementsToReport removeAllObjects];
                [self save]; // Don't repeat.
            } else {
                NSLog(@"Achievement failed to send... will try again \
                      later.  Reason: %@", error.localizedDescription);
            }
        });
    }];
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
    for (GKScore *score in scoresToReport) {
        [self sendScore:score];
    }
}

- (void)loadScore:(NSString *)aCategory
        sceneType:(SceneTypes)sceneType
completionHandler:(void (^)())completionHandler
{
    NSArray *players = [NSArray arrayWithObject:[GKLocalPlayer localPlayer]];
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayers:players] autorelease];
    leaderboardRequest.identifier = aCategory;
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error == nil) {
                if (scores != nil) {
                    // process the score information.
                    for (GKScore *score in scores) {
                        [[GameManager sharedGameManager] setHighScore:(NSInteger)score.value
                                                       forSceneWithID:sceneType];
                    }
                }
                completionHandler();
            }
        }];
    }
}

- (void)authenticationChanged
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            NSLog(@"Authentication changed: player authenticated.");
            userAuthenticated = TRUE;
            // This runs a chain of items, one at a time.
            [self loadScore:kLeaderboardAccelerator
                  sceneType:kGameSceneSurvival
          completionHandler:^{
              [self loadScore:kLeaderboardTimeAttack
                    sceneType:kGameSceneTimeAttack
            completionHandler:^{
                [self loadAchievementsWithCompletionHandler:^{
                    [self resendData];
                }];
            }];
          }];
        } else if (userAuthenticated) {
            NSLog(@"Authentication changed: player not authenticated");
            userAuthenticated = FALSE;
        }
    });
}

#pragma mark - User functions

- (void)authenticateLocalUser
{
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
            [[CCDirector sharedDirector] presentViewController: viewController animated:YES completion:nil];
        }
        else if (localPlayer.isAuthenticated)
        {
            //authenticatedPlayer: is an example method name. Create your own method that is called after the local player is authenticated.
            NSLog(@"Already authenticated!");
        }
        else
        {
            // No GameCenter?
        }
    };
}

- (void)reportScore:(NSString *)identifier score:(long)rawScore
{
    GKScore *score = [[[GKScore alloc]
                       initWithLeaderboardIdentifier:identifier] autorelease];
    score.value = rawScore;
    [scoresToReport addObject:score];
    [self save];
    
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
}

- (void)reportAchievement:(NSString *)identifier
          percentComplete:(double)percentComplete
{
    // Check for progress.
    GKAchievement* achievement = [achievementProgress objectForKey:identifier];
    if (nil == achievement) {
        achievement = [[[GKAchievement alloc]
                        initWithIdentifier:identifier] autorelease];
        [achievementProgress setObject:achievement forKey:identifier];
    }
    // If new report is greater, send to Game Center.
    if (percentComplete > achievement.percentComplete) {
        achievement.percentComplete = percentComplete;
        [achievementsToReport addObject:achievement];
        [self save];
        
        if (!gameCenterAvailable || !userAuthenticated) return;
        [self sendAchievement:achievement];
    }
}

- (void) resetAchievements
{
    // Clear all locally saved achievement objects.
    [achievementProgress removeAllObjects];
    
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil) {
             // handle errors
         }
     }];
}

- (void) showLeaderboard
{
    if (!gameCenterAvailable || !userAuthenticated) return;
    
    // Show the leaderboard.
    GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.gameCenterDelegate = self;
        leaderboardController.viewState = GKGameCenterViewControllerStateLeaderboards;
        leaderboardController.leaderboardIdentifier = category;
        leaderboardController.leaderboardTimeScope = timeScope;
        [[CCDirector sharedDirector] presentViewController: leaderboardController animated: YES completion: nil];
    }
}

- (void) showAchievements
{
    if (!gameCenterAvailable || !userAuthenticated) return;
    
    GKGameCenterViewController *achievements = [[GKGameCenterViewController alloc] init];
    if (achievements != nil)
    {
        achievements.gameCenterDelegate = self;
        achievements.viewState = GKGameCenterViewControllerStateAchievements;
        [[CCDirector sharedDirector] presentViewController: achievements animated: YES completion:nil];
    }
    [achievements release];
}

#pragma mark - GKGameCenterViewControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
    self.timeScope = viewController.leaderboardTimeScope;
    self.category = viewController.leaderboardIdentifier;
    [self save];
}

# pragma mark - GKGameCenterViewControllerDelegate

- (void)achievementViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:scoresToReport forKey:@"ScoresToReport"];
    [encoder encodeObject:achievementsToReport
                   forKey:@"AchievementsToReport"];
    [encoder encodeObject:[NSNumber numberWithLong:timeScope]
                   forKey:@"LastTimeScope"];
    [encoder encodeObject:category forKey:@"LastCategory"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSMutableArray * theScoresToReport =
    [decoder decodeObjectForKey:@"ScoresToReport"];
    NSMutableArray * theAchievementsToReport =
    [decoder decodeObjectForKey:@"AchievementsToReport"];
    GKLeaderboardTimeScope theTimeScope
    = [[decoder decodeObjectForKey:@"LastTimeScope"] intValue];
    NSString *theCategory = [decoder decodeObjectForKey:@"LastCategory"];
    return [self initWithScoresToReport:theScoresToReport
                   achievementsToReport:theAchievementsToReport
                              timeScope:theTimeScope
                               category:theCategory];
}

#pragma mark - NSObject

+(id)alloc
{
    @synchronized ([GCHelper class])
    {
        NSAssert(sharedHelper == nil, @"Attempted to allocated a \
                 second instance of the GCHelper singleton");
        sharedHelper = [super alloc];
        return sharedHelper;
    }
    return nil;
}

-(void)dealloc
{
    [super dealloc];
    [achievementProgress release];
    [achievementsToReport release];
    [scoresToReport release];
    [category release];
}

@end
