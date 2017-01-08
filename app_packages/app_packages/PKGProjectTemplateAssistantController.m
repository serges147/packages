/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "PKGProjectTemplateAssistantController.h"

#import "PKGApplicationPreferences.h"

#import "PKGProjectAssistantTemplateChoiceViewController.h"

#import "PKGProjectTemplateAssistantSettingsKeys.h"

#import "PKGProjectTemplateDefaultValuesSettings.h"

#import "PKGProjectTemplateTransformer.h"

@interface PKGProjectTemplateAssistantController ()
{
	IBOutlet NSButton * _showOnLaunchCheckBox;
}

- (IBAction)switchShowOnLaunch:(id) sender;

- (IBAction)cancel:(id) sender;

@end

@implementation PKGProjectTemplateAssistantController

- (instancetype)init
{
	self=[super init];
	
	if (self!=nil)
	{
		[self.assistantSettings registerDefaults:@{PKGProjectTemplateAssistantSettingsProjectNameKey:@"",
												   PKGProjectTemplateAssistantSettingsProjectDirectoryKey:@"~/"
												   }];
	}
	
	return self;
}

- (NSViewController *)rootViewController
{
	return [PKGProjectAssistantTemplateChoiceViewController new];
}

#pragma mark -

- (void)WB_viewWillAppear
{
	[super WB_viewWillAppear];
	
	[_showOnLaunchCheckBox setState:([PKGApplicationPreferences sharedPreferences].dontShowProjectAssistantOnLaunch==NO) ? NSOnState : NSOffState];
}

#pragma mark -

- (IBAction)switchShowOnLaunch:(id) sender
{
	[PKGApplicationPreferences sharedPreferences].dontShowProjectAssistantOnLaunch=([sender state]==NSOffState);
}

- (IBAction)cancel:(id) sender
{
	[NSApp stopModal];
	
	[self.view.window orderOut:self];
}

#pragma mark -

- (void)finalizeAssistant
{
	PKGProjectTemplateTransformer * tTransformer=[PKGProjectTemplateTransformer new];
	NSString * tProjectDirectory=[self.assistantSettings objectForKey:PKGProjectTemplateAssistantSettingsProjectDirectoryKey];
	
	tTransformer.inputProjectTemplate=[self.assistantSettings objectForKey:PKGProjectTemplateAssistantSettingsProjectTemplateKey];
	tTransformer.outputDocumentName=[self.assistantSettings objectForKey:PKGProjectTemplateAssistantSettingsProjectNameKey];
	tTransformer.outputDirectory=tProjectDirectory;
	
	tTransformer.completionHandler=^(NSString * bProjectFilePath){
		
		[NSApp stopModal];
	 
		[self.view.window orderOut:self];
		
		NSError * tError;
		
		[[NSFileManager defaultManager] setAttributes:@{NSFileExtensionHidden:@(YES)} ofItemAtPath:bProjectFilePath error:&tError];
		
		/*[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:bProjectFilePath]
																			   display:YES
																	 completionHandler:^(NSDocument * bDocument,BOOL bDocumentWasAlreadyOpen, NSError * bError){
		
			// A COMPLETER
		}];*/
	};
	
	tTransformer.errorHandler=^(NSError *bError,PKGProjectTemplateTransformationStep bStep){
		
		NSBeep();
		
		NSAlert * tAlert=[NSAlert alertWithError:bError];
		
		switch(bStep)
		{
			case PKGTransformationDirectoryCreationStep:
				
				// A COMPLETER
				
				tAlert.messageText=[NSString stringWithFormat:NSLocalizedString(@"Packages is not able to create the project directory at \"%@\".",@"No comment"),tProjectDirectory];
				tAlert.informativeText=NSLocalizedString(@"Check that you have the required write privileges",@"No comment");
				
				break;
				
			case PKGTransformationTemplateReadStep:
				
				// A COMPLETER
				
				break;
				
			case PKGTransformationTemplatePreprocessStep:
				
				// A COMPLETER
				
				break;
				
			case PKGTransformationProjectObjectificationStep:
				
				// A COMPLETER
				
				break;
				
			case PKGTransformationProjectPreprocessStep:
				
				// A COMPLETER
				
				break;
				
			case PKGTransformationProjectWriteStep:
				
				// A COMPLETER
				
				break;
		}
		
		[tAlert beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
	};
	
	[tTransformer transform];
}

@end
