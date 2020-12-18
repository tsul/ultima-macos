//
//  IndexedMULReader.m
//  Ultima
//
//  Created by Taylor Sullivan on 12/4/20.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "IndexedMULReader.h"

@implementation IndexedMULReader {
    NSFileHandle *_dataHandle;
    NSFileHandle *_indexHandle;
}

-(instancetype)initWithDataFilename:(NSString *)dataFilename indexFilename:(NSString *)indexFilename {
    return [self initWithDataFilename:dataFilename ofType:@"mul" indexFilename:indexFilename ofType:@"mul"];
}

-(instancetype)initWithDataFilename:(NSString *)dataFilename ofType:(NSString *)dataType indexFilename:(NSString *)indexFilename ofType:(NSString *)indexType {
    self = [super init];
    
    if (self) {
        NSBundle* mainBundle = [NSBundle mainBundle];

        NSString* dataPath = [mainBundle pathForResource:dataFilename ofType:dataType];
        NSString* indexPath = [mainBundle pathForResource:indexFilename ofType:indexType];

        NSFileHandle* dataHandle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
        NSFileHandle* indexHandle = [NSFileHandle fileHandleForReadingAtPath:indexPath];
        
        NSAssert(dataHandle && indexHandle, @"Could not acquire file handles");

        _dataHandle = dataHandle;
        _indexHandle = indexHandle;
    }
    
    return self;
}


-(IndexedMULEntry)getEntryForId:(NSUInteger)entryId {
    NSError *error;
    
    IndexedMULEntry entry;
    MULIndexMetadata metadata;
    
    [_indexHandle seekToOffset:entryId * sizeof(metadata) error:&error];
    
    NSData* entryData = [_indexHandle readDataUpToLength:sizeof(metadata) error:&error];
    [entryData getBytes:&metadata length:sizeof(metadata)];
    
    NSData *data;
    
    if (metadata.offset != 0xFFFFFFFF) {
        [_dataHandle seekToOffset:metadata.offset error:&error];
        data = [_dataHandle readDataUpToLength:metadata.length error:&error];
    } else {
        data = nil;
    }
    
    entry.metadata = metadata;
    entry.data = data;
    
    return entry;
}

@end
