//
//  ExacerbationsListViewController.m
//  MSPatient
//
//  Generated by AnyPresence, Inc on 2013-02-26
//  Copyright (c) 2013. All rights reserved.
//

#import <APSDK/AuthManager.h>
#import <APSDK/PatientExacerbation+Remote.h>
#import <APSDK/User.h>
#import "AuthManager+Rules.h"
#import "EditExacerbationPageViewController.h"
#import "ExacerbationsListViewController.h"
#import "LoadingTableViewCell.h"
#import "MBProgressHUD.h"
#import "UIView+APViewExtensions.h"
#import "UIViewController+UI.h"
#import "DatedContentCell.h"
#import <APSDK/APObject+Remote.h>
#import <APSDK/Setting+Remote.h>
#import "ConfigurationManager.h"
//#import "APNavigationController.h"
#import <APSDK/APObject+RemoteRelationships.h>
#import "PikConstants.h"


@interface ExacerbationsListViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem * addExacerbationButtonBarButtonItem;

- (IBAction)addExacerbationButtonTapped;
- (void)reloadExacerbationsListDataAnimated:(BOOL)animated;

@end

@implementation ExacerbationsListViewController


@synthesize reloadDataOnLoad; 


#pragma mark - Actions

- (IBAction)addExacerbationButtonTapped {
    [self.toolBar showHideToolBarInView:self.view animated:YES];
    if(self.toolBar.hidden) [self.tableView setEditing:NO animated:YES];
}
-(void)toolBarAdd{
    
    [self performSegueWithIdentifier:@"ShowAddExacerbationPageViewController" sender:self];
    [self.toolBar hideToolBarInView:self.view animated:NO];
    [self.tableView setEditing:NO animated:YES];
    [self.tutorialView dismissViewAnimated:NO completion:nil];
}
-(void)toolBarDelete{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

#pragma mark - Private
- (void)reloadExacerbationsListDataAnimated:(BOOL)animated
{
    
    if ([AppDelegate hasConnectivity])
    {
        
        if (self.reloadDataOnLoad){
            [self.tableData removeAllObjects];
        }
        
        [self pushBusyOperation];
        //__block NSArray *history = [self.tableData copy];
       [PatientExacerbation query:@"my_unarchived_exacerbations" params:nil offset:self.tableData.count limit:kListLength async:^(NSArray * objects, NSError * error) {
            if (self.navigationController.topViewController == self) {
            self.listDataState = kDataStateReady;
            if (error) {
                [self popBusyOperation];
                if(ERROR_CODE_401(error)) {
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app showSessionTerminatedAlert];
                }
                else [self showMessage:[error localizedDescription] ? : @"Error"];
            } else {
                    //[self.tableData removeAllObjects];
                    //[self.tableData addObjectsFromArray:history];
                    [self.tableData addObjectsFromArray:objects];
                    if (objects.count > kListLength - 1) {
                        [self.tableData removeLastObject];
                    } else {
                        self.listDataState = kDataStateFull;
                    }

                        [self.tableView reloadData];
//                        [self resize:self.tableView
//                                  to:CGSizeMake(CGRectGetWidth(self.tableView.frame),
//                                                self.tableData.count * self.tableView.rowHeight +
//                                                (self.listDataState == kDataStateFull ? 0 : self.tableView.rowHeight))
//                            animated:animated];
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
                                
                                //rvera - Added only for RA - my flares insted of exacerbations
                                if ([[[ConfigurationManager sharedManager] appID] integerValue] == RA) {
                                    UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(30+tutorialX, 200, 300, 40)];
                                    newLabel.text = @"Tap to start adding flares";
                                    newLabel.backgroundColor = [UIColor clearColor];
                                    newLabel.textColor = [UIColor whiteColor];
                                    [self.tutorialView addSubview:newLabel];
                                }
                                else {
                                    UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(30+tutorialX, 200, 300, 40)];
                                    newLabel.text = @"Tap to start adding exacerbations";
                                    newLabel.backgroundColor = [UIColor clearColor];
                                    newLabel.textColor = [UIColor whiteColor];
                                    [self.tutorialView addSubview:newLabel];
                                }
                                
                                Arrow *newArrow = [[Arrow alloc]init];
                                newArrow.head = CGPointMake(105+tutorialX, 5);
                                newArrow.tail = CGPointMake(105+tutorialX, 200);
                                [self.tutorialView addArrow:newArrow];
                             
                        }

            }
            } else [self popBusyOperation];
        }];
    }
    else
    {
        [AppDelegate showNoConnecttivityAlert];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
            
        }
        else {
            DatedContentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
            PatientExacerbation * object = [self.tableData objectAtIndex:indexPath.row];
            NSString *dateString = [self.dateFormatter stringFromDate:object.startOn];
            
            
            //   *****         -  iOs 8 cleanup svaz 1/16/2015   -  To move cell from left edge
//            CGRect frame = cell.dateLabel.frame;
//            frame.origin.x=40;
//            cell.dateLabel.frame = frame;
            //   *****         -  iOs 8 cleanup svaz 1/16/2015   -end
            
            cell.dateLabel.text =  dateString;
            
            //            -  MSAA cleanup svaz 11/27/14
            //Label fixes
//            CGRect frame = cell.dateLabel.frame;
//            frame.origin.x = 15;
//            cell.dateLabel.frame = frame;
//            
//            frame = cell.contentLabel.frame;
//            frame.origin.x = 110;
//            cell.contentLabel.frame = frame;
            //        end    -  MSAA cleanup svaz 11/27/14
            
            
            cell.contentLabel.text = object.symptomDenormalized;
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
           
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
            [self reloadExacerbationsListDataAnimated:YES];
        }
        else {
            
            [self performSegueWithIdentifier:@"ShowEditExacerbationPageViewController" sender:[self.tableData objectAtIndex:indexPath.row]];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 44.0;
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        if ([AppDelegate hasConnectivity])
        {
            PatientExacerbation * patientExacerbation = [self.tableData objectAtIndex:indexPath.row];
            
            patientExacerbation.archived = @1;
            [self pushBusyOperation];
            __unsafe_unretained ExacerbationsListViewController * _self = self;
            
            [patientExacerbation updateAsync:^(id obj, NSError * error) {
                if (error) {
                    [_self popBusyOperation];
                    if(ERROR_CODE_401(error)) {
                        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [app showSessionTerminatedAlert];
                    }
                    else [_self showMessage:@"Treatment record failed to delete."];
                } else {
                    [_self popBusyOperation];
                    
                    //[_self showMessage:@"Treatment record successfully deleted."];
                    [_self.tableData removeAllObjects];
                    [_self reloadExacerbationsListDataAnimated:NO];
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
    
    if ([segue.identifier isEqualToString:@"ShowEditExacerbationPageViewController"]) {
        ((EditExacerbationPageViewController *)segue.destinationViewController).patientExacerbation = sender;
        ((EditExacerbationPageViewController *)segue.destinationViewController).editMode = YES;
        ((EditExacerbationPageViewController *)segue.destinationViewController).delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ShowAddExacerbationPageViewController"]) {
        EditExacerbationPageViewController *controller = (EditExacerbationPageViewController *)[((UINavigationController *)segue.destinationViewController).viewControllers objectAtIndex:0];
        controller.editMode = NO;
        controller.delegate = self;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableData = [[NSMutableArray alloc]init];
    self.reloadDataOnLoad = YES;
    
    switch ([[[ConfigurationManager sharedManager] appID] integerValue] ) {
        case MS:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case Diabetes:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Diabetes", @"My Diabetes")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case COPD:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case MM:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My MM", @"My MM")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case RA:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My RA", @"My RA")]; //My RA
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case HepC:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Hep C", @"My Hep C")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case PD:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My PD", @"My PD")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case IPF:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My IPF", @"My IPF")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case Asthma:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Asthma", @"My Asthma")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case AAPA:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case BC:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case MDD:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
        case MDSAML:
            self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
            break;
            
        default:
            break;
    }
    
    //            -  iPad cleanup rvera 4/27/14
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.frame = self.view.bounds;
    //        end     -  iPad cleanup rvera 4/27/14
    
//    if ([[[ConfigurationManager sharedManager] appID] integerValue] == MS) {
//    self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == Diabetes) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Diabetes", @"My Diabetes")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == COPD) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == MM) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My MM", @"My MM")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == RA) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My RA", @"My RA")]; //My RA
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == HepC) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Hep C", @"My Hep C")]; 
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == PD) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My PD", @"My PD")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == IPF) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My IPF", @"My IPF")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == Asthma) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Asthma", @"My Asthma")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == AAPA) {
//        self.navigationItem.title = [AppDelegate interpolateString:NSLocalizedString(@"My Exacerbations", @"My Exacerbations")];
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil  action:nil];
//    }
    
    //[self loadExacerbationFrequencyData];
    //[self loadSymptomData];

}

- (void) viewDidAppear:(BOOL)animated{
    
    NSLog(@" Size of tableview =%@", NSStringFromCGRect(self.tableView.bounds));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(reloadDataOnLoad){
        [self reloadExacerbationsListDataAnimated:animated];
        self.reloadDataOnLoad = NO;
    }
    
        [self addObservers];
}


#pragma mark - Data

-(void)userInteractedWithViewController:(EditExacerbationPageViewController *)controller {
    self.reloadDataOnLoad = YES;
}

@end
