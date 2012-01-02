//
//  KeitaiDocument.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeitaiDocument.h"
#import "FolderInfo.h"
#import "MyWindowController.h"
#import "FolderInfoPanelController.h"

@implementation KeitaiDocument

@synthesize root;

- (void)awakeFromNib {
    NSLog(@"KeitaiDocument -awakeFromNib");
}

- (void)dealloc {
    [self setRoot:nil];
    NSLog(@"KeitaiDocument -dealloc");
    [super dealloc];
}

- (void)finalize {
    NSLog(@"KeitaiDocument -finalize");
    [super finalize];
}

/*
- (void)makeWindowControllers {
    [self addWindowController:[[MyWindowController new] autorelease]];
}
*/
- (NSString *)windowNibName {
    return @"KeitaiDocument";
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"KeitaiDocument readFromURL:%@",absoluteURL);
    if (outError) {
        *outError = nil;
    }
    KTRoot *r = [[KTRoot alloc] initWithRootPath:[absoluteURL path] error:outError];
    if (r) {
        self.root = [r autorelease];
        return YES;
    } else {
        return NO;
    }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    return YES;
}


- (IBAction)newFolder:(id)sender {
    NSLog(@"newFolder (not implemented)");
}
- (IBAction)removeFolder:(id)sender {
    NSLog(@"removeFolder (not implemented)");
}
- (IBAction)addFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    //[panel setAllowedFileTypes:[NSArray arrayWithObjects:nil]];
    [panel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = [[panel URL] path];
            KTFolderInfo *selectedFolder
                = self->fileInfoPanel.selectedFileInfo
                ? self->fileInfoPanel.selectedFileInfo.parent
                : self->folderInfoPanel.selectedFolderInfo;
            if (selectedFolder) {
                KTFileInfo *info = [selectedFolder addFile:path];
                if (!info) {
                    NSLog(@"addFile: failed");
                }
            } else {
                NSLog(@"addFile: folder not selected");
            }
        } else {
            NSLog(@"addFile: user cancelled");
        }
    }];
}
- (IBAction)removeFile:(id)sender {
    NSLog(@"removeFile (not implemented)");
}


@end
