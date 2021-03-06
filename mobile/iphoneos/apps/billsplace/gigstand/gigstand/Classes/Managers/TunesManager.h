//
//  TunesManager.h
//  GigStand
//
//  Created by bill donner on 2/22/11.
//  Copyright 2011 gigstand.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
@class TuneInfo,InstanceInfo,GigBaseInfo,SnapshotInfo;


@interface TunesManager : NSObject {

	NSInteger dummy;
	NSString *lastTitle;
}
@property (nonatomic) NSInteger dummy;


@property (nonatomic, retain) NSString *lastTitle;



+ (TunesManager *) sharedInstance;

+(void) setup;

+(void) dumpRelatedInstances:(NSString *)tune;

+(void) setLastTitle:(NSString *)title;
+(NSString *) lastTitle;


//+(void) dumpTuneDB;

+(NSUInteger) tuneCount;
+(NSUInteger) instancesCount;
+(NSArray *) allTitles;
+(NSArray *) allTitlesFromArchive:(NSString *)archive;

+(TuneInfo *) findTune: (NSString *)tune;
+(TuneInfo *) tuneInfo:(NSString *) tune;
+(TuneInfo *) findTuneInfo:(NSString *)tune;
+(InstanceInfo *) insertInstanceUnique:(NSString *)tune  archive:(NSString *)archive filePath:(NSString *)filepath;
+(InstanceInfo *) findInstance: (NSString *)archive filePath: (NSString *)filepath forTune: (NSString *)tune;
+(NSArray *) allVariantsFromTitle:(NSString *)title;

+(TuneInfo *) insertTuneUnique:(NSString *) tune lastArchive:(NSString *) lastarchive lastFilePath:(NSString *) lastfilepath;

+(TuneInfo *) insertTune:(NSString *) tune lastArchive:(NSString *) lastarchive lastFilePath:(NSString *) lastfilepath;
+(InstanceInfo *) insertInstance:(NSString *)tune  archive:(NSString *)archive filePath:(NSString *)filepath;

+(void) addTuneInfo:(NSString *)title withLongPath:(NSString *)longpath;
+(void) insertGigBaseInfo;
+(void) updateGigBaseInfo;

+(void) titlePurgeCheck:(NSString *)title;

+(SnapshotInfo *) findSnapshotInfo: (NSString *)tune;
+(void) insertSnapshotInfo:(NSString *)filepath title:(NSString *)titl;

+ (NSUInteger) snapshotCount;
+(NSArray *) allSnapshotInfos;

+(BOOL) removeOldestSnapshot;
@end

