//
//  FolderInfo.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 11/05/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KTFileInfo;


@interface KTRoot : NSObject {
    NSString *_rootPath;
    NSArray *_children;
}

@property(retain) NSString *rootPath;
@property(retain) NSArray *children;

- initWithRootPath:(NSString *)rootPath error:(NSError **)outError;

- (BOOL)isLeaf;

@end

@interface KTFolderCategory : NSObject {
    KTRoot *_root;
    NSArray *_children;

    NSString *_name;
    NSString *_folderPattern;
    BOOL _useLongFileName;
}

@property(assign) KTRoot *root;
@property(retain) NSArray *children;

@property(retain) NSString *name;
@property(retain) NSString *localizedName;
@property(retain) NSString *folderPattern;
@property(retain) NSString *filePattern;
@property(assign) BOOL useLongFileName;

- initWithName:(NSString *)name folderPattern:(NSString *)pattern filePattern:(NSString *)filePattern useLongFileName:(BOOL)lf root:(KTRoot *)root;

- (BOOL)isLeaf;
- (NSString *)displayName;

@end

@interface KTFolderInfo : NSObject {
    NSFileHandle *_tableFileHandle;
    NSMutableData *_tableFileData;
    BOOL _filesUpdated;
/*
    KTFolderCategory *_parent;
    NSArray *_children;
    NSString *_folderPath;
    NSString *_tablePath;
*/
}

@property(assign) KTFolderCategory *parent;
@property(retain) NSArray *children;
@property(assign,readonly) NSFileHandle *tableFileHandle;

@property(retain) NSString *folderPath;
@property(retain) NSDate *mtime;
@property(retain) NSString *deviceName;
@property(retain) NSString *tablePath;
@property(retain) NSString *displayName;
@property(assign) NSUInteger unknownValue1;
@property(assign) NSUInteger unknownValue2;
@property(assign) NSUInteger unknownValue3;
@property(assign) NSUInteger unknownValue4;

- initWithTablePath:(NSString *)tablePath parent:(KTFolderCategory *)parent;

- (NSString *)absolutePath;
- (BOOL)checkTable;
- (void)updateTable;

- (KTFileInfo *)addFile:(NSString *)path;
- (BOOL)removeFile:(KTFileInfo *)file;

- (void)openFolder;

- (BOOL)isLeaf;

@end

@interface KTFileInfo : NSObject {
    off_t _offset;
    NSMutableData *_tableFileData;
/*
    KTFolderInfo *_parent;
    NSString *_fileName;
*/
}

@property(assign) KTFolderInfo *parent;

@property(retain) NSString *displayName;
@property(retain) NSString *fileName;
@property(retain) NSDate *mtime;
@property(assign) size_t fileSize;
@property(retain) NSString *deviceName;
@property(retain) NSString *comment;
@property(assign) int rating;
@property(assign) int viewCount;

- initWithData:(NSData *)data offset:(off_t)offset parent:(KTFolderInfo *)parent;
- initWithFileName:(NSString *)fileName originalPath:(NSString *)path offset:(off_t)offset parent:(KTFolderInfo *)parent;
- (NSString *)absolutePath;
- (BOOL)checkTable;
- (void)updateTable;

- (void)openFile;

- (BOOL)isLeaf;

@end
