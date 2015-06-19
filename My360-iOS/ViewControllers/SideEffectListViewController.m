//
//  SideEffectListViewController.m
//  MSPatient
//
//  Generated by AnyPresence, Inc on 2013-02-26
//  Copyright (c) 2013. All rights reserved.
//

#import <APSDK/AuthManager.h>
#import <APSDK/PatientSideEffect+Remote.h>
#import <APSDK/User.h>
#import <APSDK/SideEffect.h>
#import <APSDK/PatientTreatment.h>
#import <APSDK/PatientSideEffectMedication.h>
#import <APSDK/Medication.h>
#import "AuthManager+Rules.h"
#import "EditSideEffectContentPageViewController.h"
#import "LoadingTableViewCell.h"
#import "SideEffectListViewController.h"
#import "UIView+APViewExtensions.h"
#import "UIViewController+UI.h"
#import "DatedContentCell.h"
#import <APSDK/APObject+Remote.h>
//#import "APNavigationController.h"
#import <APSDK/APObject+RemoteRelationships.h>
#import <APSDK/TreatmentType+Remote.h>
#import "PikConstants.h"
#import "ConfigurationManager.h"   //svaz added for alert
#import <APSDK/Setting+Remote.h> //svaz added for alert



@interface SideEffectListViewController () 

@property (nonatomic, weak) IBOutlet UIBarButtonItem * addSideEffectButtonBarButtonItem;

- (IBAction)addSideEffectButtonTapped;
- (void)reloadSideEffectListDataAnimated:(BOOL)animated;

@end

@implementation SideEffectListViewController
@synthesize patientTreatmentMedicationData;
@synthesize reloadDataOnLoad;


#pragma mark - Actions

- (IBAction)addSideEffectButtonTapped {
    [self.toolBar showHideToolBarInView:self.view animated:YES];
    if(self.toolBar.hidden) [self.tableView setEditing:NO animated:YES];
}

-(void)toolBarAdd{
    [self.toolBar hideToolBarInView:self.view animated:NO];
    [self.tutorialView dismissViewAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"ShowAddSideEffectPageViewController" sender:self];
}
-(void)toolBarDelete{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}



#pragma mark - Private
- (void)reloadSideEffectListDataAnimated:(BOOL)animated {
    
    if ([AppDelegate hasConnectivity])
    {
        [self pushBusyOperation];
        if (reloadDataOnLoad){
            [self.tableData removeAllObjects];
            [self.tableView reloadData];
        }
        __block NSArray *history = [self.tableData copy];
        NSNumber *uid = ((User *)[AuthManager defaultManager].currentCredentials).id;
        // TODO PIK Example
        [PatientSideEffect myUnarchivedSideeffectsWithId:uid appId:nil offset:self.tableData.count limit:kListLength async:^(NSArray *objects, NSError *error) {
            self.listDataState = kDataStateReady;
            if (error) {
                [self popBusyOperation];
                if(ERROR_CODE_401(error)) {
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app showSessionTerminatedAlert];
                }
                else [self showMessage:[error localizedDescription] ? : @"Error"];
            } else {
                [self.tableData removeAllObjects];
                [self.tableData addObjectsFromArray:history];
                [self.tableData addObjectsFromArray:objects];
                if (objects.count > kListLength - 1) {
                    [self.tableData removeLastObject];
                } else {
                    self.listDataState = kDataStateFull;
                }
                [self.tableView reloadData];
//            - ios cleanup svaz 1/12/15
//                [self resize:self.tableView
//                          to:CGSizeMake(CGRectGetWidth(self.tableView.frame),
//                                        self.tableData.count * self.tableView.rowHeight +
//                                        (self.listDataState == kDataStateFull ? 0 : self.tableView.rowHeight))
//                    animated:animated];
//   *****         -  iOs 8 cleanup svaz 1/16/2015   -end
                
                [self popBusyOperation];
                
                if(!HAS_DATA){
                    [self.toolBar showToolBarInView:self.view animated:NO];
                    //   HIDE TUTORIAL FOR IPAD         -  MSAA cleanup svaz 11/27/14
                    int tutorialX = 0;
                    if (IS_IPAD) {
                        tutorialX =+150;
                    }
                    
                        CGRect frame = self.view.bounds;
                        frame.origin.y += self.toolBar.frame.size.height;
                    
                        self.tutorialView = [[TutorialView alloc]initWithFrame:frame];
                        [self.view addSubview:self.tutorialView];
                        
                        UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(30+tutorialX, 200, 300, 40)];
                        newLabel.text = @"Tap to start adding side effects";
                        newLabel.backgroundColor = [UIColor clearColor];
                        newLabel.textColor = [UIColor whiteColor];
                        [self.tutorialView addSubview:newLabel];
                        
                        Arrow *newArrow = [[Arrow alloc]init];
                        newArrow.head = CGPointMake(105+tutorialX, 5);
                        newArrow.tail = CGPointMake(105+tutorialX, 200);
                        [self.tutorialView addArrow:newArrow];
                    
                }
            }
        }];
        
        /*[PatientSideEffect myUnarchivedSideeffectsWithId:uid offset:self.tableData.count limit:kListLength async:^(NSArray *objects, NSError *error) {
            self.listDataState = kDataStateReady;
            if (error) {
                [self popBusyOperation];
                if(ERROR_CODE_401(error)) {
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app showSessionTerminatedAlert];
                }
                else [self showMessage:[error localizedDescription] ? : @"Error"];
            } else {
                    [self.tableData removeAllObjects];
                    [self.tableData addObjectsFromArray:history];
                    [self.tableData addObjectsFromArray:objects];
                    if (objects.count > kListLength - 1) {
                        [self.tableData removeLastObject];
                    } else {
                        self.listDataState = kDataStateFull;
                    }
                        [self.tableView reloadData];
                        [self resize:self.tableView
                                  to:CGSizeMake(CGRectGetWidth(self.tableView.frame),
                                                self.tableData.count * self.tableView.rowHeight +
                                                (self.listDataState == kDataStateFull ? 0 : self.tableView.rowHeight))
                            animated:animated];
                        [self popBusyOperation];
                        
                        if(!HAS_DATA){
                            [self.toolBar showToolBarInView:self.view animated:NO];
                            CGRect frame = self.view.bounds;
                            frame.origin.y += self.toolBar.frame.size.height;
                            self.tutorialView = [[TutorialView alloc]initWithFrame:frame];
                            [self.view addSubview:self.tutorialView];
                            
                            UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 200, 300, 40)];
                            newLabel.text = @"Tap to start adding side effects";
                            newLabel.backgroundColor = [UIColor clearColor];
                            newLabel.textColor = [UIColor whiteColor];
                            [self.tutorialView addSubview:newLabel];
                            
                            Arrow *newArrow = [[Arrow alloc]init];
                            newArrow.head = CGPointMake(105, 5);
                            newArrow.tail = CGPointMake(105, 200);
                            [self.tutorialView addArrow:newArrow];
                        }
            }
        }];*/
    }
    else
    {
        [AppDelegate showNoConnecttivityAlert];
    }
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 1) {
            LoadingTableViewCell * cell = (LoadingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Loading"];
            
            if (self.listDataState == kDataStateLoading) {
                cell.state = kLoadingTableViewCellStateBusy;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.state = kLoadingTableViewCellStateReady;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            
            return cell;
        } else {
            DatedContentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
            PatientSideEffect * object = [self.tableData objectAtIndex:indexPath.row];
            NSString *dateString = [[self dateFormatterWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]] stringFromDate:object.sideEffectOn];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            //   *****         -  iOs 8 cleanup svaz 1/16/2015   -  To move cell from left edge
//            CGRect frame = cell.dateLabel.frame;
//            frame.origin.x=40;
//            cell.dateLabel.frame = frame;
            //   *****         -  iOs 8 cleanup svaz 1/16/2015   -end
            
            
            cell.dateLabel.text =  dateString;
            cell.contentLabel.text = object.sideEffectDenormalized;
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (indexPath.section == 1 && self.listDataState == kDataStateReady) {
            ((LoadingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).state = kLoadingTableViewCellStateBusy;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            self.listDataState = kDataStateLoading;
            [self reloadSideEffectListDataAnimated:YES];
        }
        else {
            
            [self performSegueWithIdentifier:@"ShowEditSideEffectContentPageViewController" sender:[self.tableData objectAtIndex:indexPath.row]];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        if ([AppDelegate hasConnectivity])
        {
            PatientSideEffect * patientSideEffect = [self.tableData objectAtIndex:indexPath.row];
            
            patientSideEffect.archived = @1;//true
            [self pushBusyOperation];
            __unsafe_unretained SideEffectListViewController * _self = self;
                        
            
            [patientSideEffect updateAsync:^(id obj, NSError * error) {
                if (error) {
                    [_self popBusyOperation];
                    if(ERROR_CODE_401(error)) {
                        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [app showSessionTerminatedAlert];
                    }
                    else [_self showMessage:@"Side effect record failed to delete."];
                } else {
                    [_self popBusyOperation];
                    
                    //[_self showMessage:@"Side effect record successfully deleted."];
                    [_self.tableData removeAllObjects];
                    [_self reloadSideEffectListDataAnimated:NO];
                }
            }];
        }
        else
        {
            [AppDelegate showNoConnecttivityAlert];
        }
    }
}



#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEditSideEffectContentPageViewController"]){
        ((EditSideEffectContentPageViewController *)segue.destinationViewController).patientSideEffect = sender;
        ((EditSideEffectContentPageViewController *)segue.destinationViewController).patientTreatmentMedicationData = self.patientTreatmentMedicationData;
        ((EditSideEffectContentPageViewController *)segue.destinationViewController).editMode = YES;
        ((EditSideEffectContentPageViewController *)segue.destinationViewController).delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ShowAddSideEffectPageViewController"]) {
        EditSideEffectContentPageViewController *controller = (EditSideEffectContentPageViewController*)[((UINavigationController *)segue.destinationViewController).viewControllers objectAtIndex:0];
        controller.patientTreatmentMedicationData = self.patientTreatmentMedicationData;
        controller.editMode = NO;
        controller.delegate = self;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reloadDataOnLoad = YES;
    self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Side Effects", @"My Side Effects")];

    [self loadPatientTreatmentMedicationData];
    
    //            -  iPad cleanup rvera 4/27/15
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.frame = self.view.bounds;
    //        end     -  iPad cleanup rvera 4/27/15

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObservers];
    
    if(reloadDataOnLoad){
        [self reloadSideEffectListDataAnimated:animated];
        self.reloadDataOnLoad = NO;
    }
}



#pragma mark - Data

- (void)loadPatientTreatmentMedicationData
{
    NSArray * cache = [PatientTreatment query:@"my_medications" params:nil async:^(NSArray * objects, NSError * error) {
        
        if (error == nil) {
            self.patientTreatmentMedicationData = [[NSArray alloc]initWithArray:objects];
        }
        else {
            if(ERROR_CODE_401(error)) {
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app showSessionTerminatedAlert];
            }
        }
    }];
    if(cache.count > 0){
        self.patientTreatmentMedicationData = [[NSArray alloc]initWithArray:cache];
    }
}

-(void)userInteractedWithViewController:(EditSideEffectContentPageViewController *)controller {
    self.reloadDataOnLoad = YES;
}


//- (void)loadPatientTreatmentMedicationData
//{
//         //[MedicalCondition query:@"active_medical_condition" params:nil async:^(NSArray * objects, NSError * error) {
//        //NSArray * cache = [PatientTreatment query:@"my_medications" params:nil async:^(NSArray * objects, NSError * error) {
//    __block NSArray * cache = [NSArray new];
////        [PatientTreatment query:@"my_medications" params:nil async:^(NSArray * objects, NSError * error) {
//    
//        if (error == nil) {
//            // SORT QUERY BY NAME i.e medicalCondition.name - svaz
//            
//            // Added to sort by Name insensetively - svaz
////            NSSortDescriptor *sortDescriptor;
////            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
////                                                         ascending:YES
////                                                          selector:@selector(localizedCaseInsensitiveCompare:)];
////            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
////            NSArray *sortedArray = [objects sortedArrayUsingDescriptors:sortDescriptors];
//            //cache = [objects sortedArrayUsingDescriptors:sortDescriptors];
//            
//            //end to sort - svaz
//            self.patientTreatmentMedicationData = [[NSArray alloc]initWithArray:objects];
//            //self.patientTreatmentMedicationData = [[NSArray alloc]initWithArray:cache];
//            if(cache.count > 0){
//                self.patientTreatmentMedicationData =  cache ;
//            }
//
//        }
//        else {
//            if(ERROR_CODE_401(error)) {
//                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                [app showSessionTerminatedAlert];
//            }
//        }
//    }];
//   if(cache.count > 0){
//        self.patientTreatmentMedicationData = [[NSArray alloc]initWithArray:cache];
//    }
//}

//-(void)userInteractedWithViewController:(EditSideEffectContentPageViewController *)controller {
//    self.reloadDataOnLoad = YES;
//}


@end