//
//  KeitaiDocument.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class KTRoot;
@class FolderInfoPanelController, FileInfoPanelController;

@interface KeitaiDocument : NSDocument <QLPreviewPanelDelegate, QLPreviewPanelDataSource> {
    IBOutlet FolderInfoPanelController *folderInfoPanel;
    IBOutlet FileInfoPanelController *fileInfoPanel;
    IBOutlet NSTreeController *treeController;
    IBOutlet NSBrowser *browser;
    IBOutlet NSWindow *newFolderSheet;
    IBOutlet NSTextField *newFolderName;
    KTRoot *_root;
    id _selectedItem;
    QLPreviewPanel *previewPanel;
}

@property(retain) KTRoot *root;
@property(retain) id selectedItem;

- (IBAction)newFolder:(id)sender;
- (IBAction)removeFolder:(id)sender;
- (IBAction)addFile:(id)sender;
- (IBAction)removeFile:(id)sender;

@end
