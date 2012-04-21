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
    NSString *_tableDirectoryPath;
}

@property(retain) NSString *rootPath;
@property(retain) NSArray *children;
@property(retain) NSString *tableDirectoryPath;

- initWithRootPath:(NSString *)rootPath error:(NSError **)outError;

- (BOOL)isLeaf;

@end

@interface KTFolderCategory : NSObject {
    KTRoot *_root;
    NSArray *_children;

    NSString *_name;
    NSString *_localizedName;
    NSString *_folderPattern;
    NSString *_tableFilePattern;
    NSString *_filePattern;
    NSString *_tableDirectoryPath;
    BOOL _useLongFileName;
}

@property(assign) KTRoot *root;
@property(retain) NSArray *children;

@property(retain) NSString *name;
@property(retain) NSString *localizedName;
@property(retain) NSString *folderPattern;
@property(retain) NSString *tableFilePattern;
@property(retain) NSString *filePattern;
@property(retain) NSString *tableDirectoryPath;
@property(assign) BOOL useLongFileName;

- initWithName:(NSString *)name
    folderPattern:(NSString *)folderPattern
    tableFilePattern:(NSString *)tableFilePattern
    filePattern:(NSString *)filePattern
    useLongFileName:(BOOL)lf
    root:(KTRoot *)root;

- (BOOL)addFolder:(NSString *)name;

- (BOOL)isLeaf;
- (NSDictionary *)browserValue;

@end

@interface KTFolderInfo : NSObject {
    NSFileHandle *_tableFileHandle;
    NSMutableData *_tableFileData;
    BOOL _filesUpdated;

    KTFolderCategory *_parent;
    NSArray *_children;
    NSString *_tablePath;
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
- initWithNewFolderAtPath:(NSString *)folderPath
              displayName:(NSString *)displayName
            tableFilePath:(NSString *)tablePath
                   parent:(KTFolderCategory *)parent;

- (NSString *)absolutePath;
- (BOOL)checkTable;
- (void)updateTable;
- (off_t)offsetForFileInfo:(KTFileInfo *)file;

- (KTFileInfo *)addFile:(NSString *)path;
- (BOOL)removeFile:(KTFileInfo *)file;

- (void)openFolder;

- (BOOL)isLeaf;
- (NSDictionary *)browserValue;

@end

@interface KTFileInfo : NSObject {
    NSMutableData *_tableFileData;

    KTFolderInfo *_parent;
    NSString *_fileName;
    size_t _fileSize;
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

- initWithData:(NSData *)data parent:(KTFolderInfo *)parent;
- initWithFileName:(NSString *)fileName originalPath:(NSString *)path parent:(KTFolderInfo *)parent;
- (NSString *)absolutePath;
- (NSImage *)fileIcon;
- (BOOL)checkTable;
- (void)updateTable;

- (void)openFile;

- (BOOL)isLeaf;
- (NSDictionary *)browserValue;

@end
