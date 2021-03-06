//
//  EditLabResultPageViewController.h
//  MSPatient
//
//  Generated by AnyPresence, Inc on 2013-02-26
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APSDK/PatientLabResult.h>
#import <APSDK/TestType.h>
#import <APSDK/LabResultStat.h>
#import "BaseFormViewController.h"

@class EditLabResultPageViewController;

@protocol EditLabResultPageViewControllerDelegate <NSObject>
-(void)userInteractedWithViewController:(EditLabResultPageViewController *)controller;
@end

@interface EditLabResultPageViewController : BaseFormViewController {
}

@property (nonatomic, strong) PatientLabResult * patientLabResult;

@property (nonatomic, weak) id <EditLabResultPageViewControllerDelegate> delegate;
@property (strong, nonatomic) TestType *testType;
@property (strong, nonatomic) LabResultStat *labResultStatus;

@end