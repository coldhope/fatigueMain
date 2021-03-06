//
//  UpdateTreatmentPageViewController.h
//  MSPatient
//
//  Generated by AnyPresence, Inc on 2013-03-02
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APSDK/PatientTreatment.h>
#import <APSDK/TreatmentType.h>
#import <APSDK/DosageUom.h>
#import <APSDK/IngestionMethod.h>
#import <APSDK/TreatmentSchedule.h>
#import <APSDK/Medication.h>
#import "BaseFormViewController.h"

@class UpdateTreatmentPageViewController;

@protocol UpdatePatientPageViewControllerDelegate <NSObject>
-(void)userInteractedWithViewController:(UpdateTreatmentPageViewController *)controller;
@end

@interface UpdateTreatmentPageViewController : BaseFormViewController {
}

@property (nonatomic, strong) PatientTreatment * patientTreatment;
@property (nonatomic, weak) id <UpdatePatientPageViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *dosageData;

@property (weak, nonatomic) IBOutlet UITableViewCell *medicationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dosageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ingestionMethodCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *scheduleCell;

@property (weak, nonatomic) IBOutlet UIButton *chartButton;


@property (strong, nonatomic) DosageUom *dosageUom;
@property (strong, nonatomic) NSNumber *dosage;
@property (strong, nonatomic) Medication *medication;
@property (strong, nonatomic) TreatmentType *treatmentType;
@property (strong, nonatomic) IngestionMethod *ingestionMethod;
@property (strong, nonatomic) TreatmentSchedule *treatmentSchedule;

@property (strong, nonatomic) NSDate *currentScheduleDate;
@property (strong, nonatomic) NSDate *nextScheduleDate;

- (IBAction)buttonPressedStartDateMsg;

@end