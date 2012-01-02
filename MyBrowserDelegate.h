//
//  MyBrowserDelegate.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 18/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KeitaiDocument, FolderInfoPanelController, FileInfoPanelController;

@interface MyBrowserDelegate : NSObject <NSBrowserDelegate> {
    IBOutlet KeitaiDocument *doc;
    IBOutlet FolderInfoPanelController *folderInfoPanel;
    IBOutlet FileInfoPanelController *fileInfoPanel;
}

- (IBAction)browserClick:(NSBrowser *)sender;

@end
