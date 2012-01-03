//
//  FolderInfoPanelController.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 20/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KTFolderInfo, KTFileInfo, KeitaiDocument;

@interface FolderInfoPanelController : NSObject {
    IBOutlet NSView *rightPane;
    IBOutlet NSView *panel;
    IBOutlet KeitaiDocument *document;
    KTFolderInfo *selectedFolderInfo;
}

@property(retain) KTFolderInfo *selectedFolderInfo;

- (void)showFolderInfoPanel:(KTFolderInfo *)folderInfo;
- (void)hideFolderInfoPanel;

- (IBAction)revertToSaved:(id)sender;
- (IBAction)applyChanges:(id)sender;
- (IBAction)open:(id)sender;

@end

@interface FileInfoPanelController : NSObject {
    IBOutlet NSView *rightPane;
    IBOutlet NSView *panel;
    IBOutlet KeitaiDocument *document;
    KTFileInfo *selectedFileInfo;
}

@property(retain) KTFileInfo *selectedFileInfo;

- (void)showFileInfoPanel:(KTFileInfo *)fileInfo;
- (void)hideFileInfoPanel;

- (IBAction)revertToSaved:(id)sender;
- (IBAction)applyChanges:(id)sender;
- (IBAction)open:(id)sender;

@end
