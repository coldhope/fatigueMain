//
//  EditExacerbationPageViewController.m
//  MSPatient
//
//  Generated by AnyPresence, Inc on 2013-02-26
//  Copyright (c) 2013. All rights reserved.
//
//  Modiffied by Roverto Vera

#import <APSDK/AuthManager.h>
#import <APSDK/PatientExacerbation+Remote.h>
#import <APSDK/Symptom+Remote.h>
#import <APSDK/User.h>
#import "AuthManager+Rules.h"
//------Comments these two out cause it was complaing it coudn't find it. --rvera 3/6/15
//#import "AuthManager.h"
//------rvera
#import "EditExacerbationPageViewController.h"
#import "MBProgressHUD.h"
#import "UIViewController+UI.h"
#import "PikConstants.h"
#import "SymptomsViewController.h"
//#import "FrequencyViewController.h"
#import "UIColor+APColorExtension.h"
#import "DCRoundSwitch.h"
#import <APSDK/APObject+Remote.h>
#import <APSDK/Setting+Remote.h>
#import <APSDK/APObject+RemoteRelationships.h>
#import "ExacerbationsListViewController.h"
#import "ConfigurationManager.h"


@interface EditExacerbationPageViewController () < UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UITextField * endOnTextField;
@property (nonatomic, weak) IBOutlet UITextField * intensityTextField;
@property (nonatomic, weak) IBOutlet UITextField * startOnTextField;
@property (nonatomic, weak) IBOutlet UITextField * symptomIdTextField;
@property (nonatomic, weak) IBOutlet UITextField * symptomListTextField;


@property (nonatomic, strong) DCRoundSwitch * concurrentInfSwitch;
@property (nonatomic, strong) DCRoundSwitch * heatExpSwitch;
@property (nonatomic, strong) DCRoundSwitch * stressSwitch;
@property (nonatomic, strong) DCRoundSwitch * fatigueSwitch;



@property (nonatomic, strong, readonly) UIPickerView * inputIntensityPicker;

- (BOOL)saveTapped;
- (void)refresh;


@end

@implementation EditExacerbationPageViewController


@synthesize inputIntensityPicker = _inputIntensityPicker;
@synthesize intensity;
@synthesize symptom = _symptom;
@synthesize intensityData;


#pragma mark - Public

- (void)setPatientExacerbation:(PatientExacerbation *)patientExacerbation {
    if (_patientExacerbation != patientExacerbation) {
        _patientExacerbation = patientExacerbation;
        
        if ([self isViewLoaded])
            [self refresh];
    }
}


#pragma mark - Actions
-(void)userInteraction {
    [self.delegate userInteractedWithViewController:self];
//    (ExacerbationsListViewController *)self.delegate.reloadDataOnLoad = YES;
//    self.reloadDataOnLoad = YES;
    //    [self.concurrentInfSwitch.  ]
}
- (BOOL)saveTapped {
    
    
//    NSLog(@"self.editMode = %d", self.editMode);
    //Nothing Changed, Don't Save
//    if (!((ExacerbationsListViewController *)self.delegate).reloadDataOnLoad)return true;
    
    if (self.startOnTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"A start day is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return false;
        
    }
    
 if (self.symptomIdTextField.text.length == 0) {
   // if ( self.symptomListTextField.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"A symptom is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return false;
        
    }
    
    if (self.intensityTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An intensity is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return false;
        
    }
    
    if (self.editMode) {

        self.patientExacerbation.endOn = [[self configureDateFormatter:self.dateFormatter field:self.endOnTextField] dateFromString:self.endOnTextField.text];
        self.patientExacerbation.intensity = self.intensity;
        self.patientExacerbation.startOn = [[self configureDateFormatter:self.dateFormatter field:self.startOnTextField] dateFromString:self.startOnTextField.text];
        self.patientExacerbation.symptom = self.symptom;
        self.patientExacerbation.concurrentInfection = [NSNumber numberWithBool:[self concurrentInfSwitch].isOn];
        self.patientExacerbation.heatExposure = [NSNumber numberWithBool:[self heatExpSwitch].isOn];
        self.patientExacerbation.stress = [NSNumber numberWithBool:[self stressSwitch].isOn];
        self.patientExacerbation.fatigability = [NSNumber numberWithBool:[self fatigueSwitch].isOn];
        
        
        NSLog(@" concurrentInfSwitch %@", [NSNumber numberWithBool:[self concurrentInfSwitch].isOn]);
        
        if ([self.patientExacerbation.startOn compare:self.patientExacerbation.endOn] == NSOrderedDescending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Start date can not be later than end date." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return false;
        }
        
        
        [self pushBusyOperation];
        NSError *err = nil;
        [self.patientExacerbation update:&err];
        [self popBusyOperation];

        if (err) {
            if(ERROR_CODE_401(err)) {
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app showSessionTerminatedAlert];
            }
            else [self showMessage:@"Exacerbation record failed to save."];
            return false;
        }
        else {
            //[_self showMessage:@"Exacerbation record successfully saved."];
//            [self.navigationController popViewControllerAnimated:YES];
            return true;
        }
    }
    else {
        PatientExacerbation *patientExacerbation = [PatientExacerbation new];        
        patientExacerbation.patientId = ((User *)[AuthManager defaultManager].currentCredentials).id;
        patientExacerbation.endOn = [[self configureDateFormatter:self.dateFormatter field:self.endOnTextField] dateFromString:self.endOnTextField.text];
        patientExacerbation.startOn = [[self configureDateFormatter:self.dateFormatter field:self.startOnTextField] dateFromString:self.startOnTextField.text];
        
        Symptom *sym = [Symptom new];
        sym.id = self.symptom.id;
        sym.symptomCat = self.symptom.symptomCat;
        //sym.category = self.symptom.category; //RV comented case API have new  Symtoms Cat in API  
        sym.inactive = self.symptom.inactive;
        sym.name = self.symptom.name;
        sym.sortId = self.symptom.sortId;
        
        patientExacerbation.symptom = sym;
        patientExacerbation.intensity = self.intensity;
        patientExacerbation.concurrentInfection = [NSNumber numberWithBool:[self concurrentInfSwitch].isOn];
        patientExacerbation.heatExposure = [NSNumber numberWithBool:[self heatExpSwitch].isOn];
        patientExacerbation.stress = [NSNumber numberWithBool:[self stressSwitch].isOn];
        patientExacerbation.fatigability = [NSNumber numberWithBool:[self fatigueSwitch].isOn];
        
        if ([patientExacerbation.startOn compare:patientExacerbation.endOn] == NSOrderedDescending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Start date can not be later than end date." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return false;
        }
        
        
        [self pushBusyOperation];
        NSError *err = nil;
        [patientExacerbation create:&err];
        [self popBusyOperation];
        if (err) {
            [self popBusyOperation];
            if(ERROR_CODE_401(err)) {
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app showSessionTerminatedAlert];
            }
            else [self showMessage:@"Exacerbation record failed to add."];
            return false;
        } else {            
            //[_self showMessage:@"Exacerbation record successfully added."];
            //[_self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            return true;
        };
    }
}



- (UIPickerView *)inputIntensityPicker {
    if (!_inputIntensityPicker) {
        _inputIntensityPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];

        _inputIntensityPicker.delegate = self;
        _inputIntensityPicker.dataSource = self;
        _inputIntensityPicker.showsSelectionIndicator = YES;

        [_inputIntensityPicker sizeToFit];
    }
    
    return _inputIntensityPicker;
}


- (void)refresh {

    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    for (Symptom *symptom in ad.symptomData) {
        if ([symptom.id intValue] == [self.patientExacerbation.symptomId intValue]) {
            self.symptom = symptom;
            break;
        }
    }
    self.intensity = self.patientExacerbation.intensity;
    self.concurrentInfSwitch.on = [self.patientExacerbation.concurrentInfection boolValue];
    self.heatExpSwitch.on = [self.patientExacerbation.heatExposure boolValue];
    self.stressSwitch.on = [self.patientExacerbation.stress boolValue];
    self.fatigueSwitch.on = [self.patientExacerbation.fatigability boolValue];
    
    self.endOnTextField.text = [[self configureDateFormatter:self.dateFormatter field:self.endOnTextField] stringFromDate:self.patientExacerbation.endOn];
    self.intensityTextField.text = [self.patientExacerbation.intensity description];
    self.startOnTextField.text = [[self configureDateFormatter:self.dateFormatter field:self.startOnTextField] stringFromDate:self.patientExacerbation.startOn];
    self.symptomIdTextField.text = self.symptom.name;
    //self.symptomListTextField.text = self.symptom.name;

}


- (void)symptomSelected:(NSNotification *) notification
{
        [self.delegate userInteractedWithViewController:self];
    if ([[notification name] isEqualToString:@"selectedSymptom"]){
        
        [self.navigationController popViewControllerAnimated:YES];
        
        NSDictionary *userInfo = notification.userInfo;
        
        self.symptom = [userInfo objectForKey:@"symptom"];
        self.symptomIdTextField.text = self.symptom.name;
        //self.symptomListTextField.text = self.symptom.name;

        [self.tableView reloadData];
    }
}


#pragma mark - PickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.intensityData.count;
}


-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [self.intensityData objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.intensityTextField.text = [[NSNumber numberWithLong:row + 1] stringValue];
    self.intensity = [NSNumber numberWithLong:row + 1]; //indexed from 1
        [self.delegate userInteractedWithViewController:self];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *headerView;
    
    if (section == 1) {
        headerView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 30)];
        headerView.backgroundColor = [UIColor clearColor];
        
        headerView.textColor = [UIColor whiteColor];
        headerView.numberOfLines = 2;
        [headerView setFont:[UIFont fontWithName:@"Helvetica" size:kMediumFontSize]];
        headerView.textAlignment = NSTextAlignmentCenter;
        
        BOOL shouldShowHeaderTitle = TRUE;
        
        //RV-3/20/14  
        //added the condition bellow to NOT show the switch buttons
        switch ([[[ConfigurationManager sharedManager] appID] integerValue] ) {
//            case Diabetes:    It's true only for these 2
//            case MM:
            case COPD:
            case MS:
            case RA:
            case HepC:
            case PD:
            case IPF:
            case Asthma:
            case AAPA:
                 shouldShowHeaderTitle = FALSE;
                break;
                
            default:
                break;
        }
        
//        if (   [[[ConfigurationManager sharedManager] appID] integerValue] == RA
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == MS
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == COPD
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == IPF
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == HepC
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == PD
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == Asthma
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == AAPA
//            
//            // It's true only for these 2 so need to comment out to show up
//            //|| [[[ConfigurationManager sharedManager] appID] integerValue] == Diabetes
//            //|| [[[ConfigurationManager sharedManager] appID] integerValue] == MM
//            
//            ) {
//            shouldShowHeaderTitle = FALSE;
//        }

        if (shouldShowHeaderTitle) {
            headerView.text = @"Have you had any of the following?";
        }
    }
    
    return headerView;
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    [self.delegate userInteractedWithViewController:self];
    if (textField.tag == kFormViewControllerFieldDateTime) {
        if (textField.text.length > 0) {
            NSDateFormatter * formatter = [self configureDateFormatter:self.dateFormatter field:textField];
            self.inputViewDatePicker.date = [formatter dateFromString:textField.text];
        }
        else {
            NSDateFormatter * formatter = [self configureDateFormatter:self.dateFormatter field:textField];
            textField.text = [formatter stringFromDate:self.inputViewDatePicker.date];
        }
        
        self.inputViewDatePicker.datePickerMode = UIDatePickerModeDateAndTime;

    }
    
    
    if (textField == self.intensityTextField) {
        if (textField.text.length > 0) {
            
            [self.inputIntensityPicker selectRow:[textField.text intValue] - 1 inComponent:0 animated:YES];
        }
        else {
            self.intensity = [NSNumber numberWithInt:1];
            textField.text = @"1";
        }
    }

    
    return YES;
}



#pragma mark - UIViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"SymptomsSegue"])
    {
        SymptomsViewController *controller = (SymptomsViewController *)[segue destinationViewController];
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        controller.tableData = ad.symptomData;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch ([[[ConfigurationManager sharedManager] appID] integerValue] ) {
        
        case Diabetes:{
                NSString *title = @"My Diabetes";
                self.navigationItem.title = title;
            }break;
            
        case MM:{
                NSString * title = @"My MM";
                self.navigationItem.title = title;
            }break;
        
        case COPD:{
                NSString * title = @"My COPD";
                self.navigationItem.title = title;
            }break;
        
        case MS:{
                NSString * title = @"My Exacerbations";
                self.navigationItem.title = title;
            }break;
        
        case RA:{
                NSString * title = @"My RA";
                self.navigationItem.title = title;
            }break;
        
        case HepC:{
                NSString * title = @"My HepC";
                self.navigationItem.title = title;
            }break;
        
        case PD:{
                NSString * title = @"My Exacerbations";
                self.navigationItem.title = title;
            }break;
        
        case IPF:{
                NSString * title = @"My Exacerbations";
                self.navigationItem.title = title;
            }break;
        
        case Asthma:{
                NSString * title = @"My Exacerbations"; //My Asthma";
                self.navigationItem.title = title;
            }break;
        
        case AAPA:{
                NSString * title = @"My Exacerbations"; //My Asthma";
                self.navigationItem.title = title;
            }break;
        
        case BC:{
            NSString * title = @"My Exacerbations"; //My Asthma";
            self.navigationItem.title = title;
        }break;
            
        case MDD:{
            NSString * title = @"My Exacerbations"; //My Asthma";
            self.navigationItem.title = title;
        }break;
            
        case MDSAML:{
            NSString * title = @"My Exacerbations"; //My Asthma";
            self.navigationItem.title = title;
        }break;
            
        default:
            break;
    }

    
    
//    if ([[[ConfigurationManager sharedManager] appID] integerValue] == MS) {
//    NSString * title = @"My Exacerbations";
//    self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == Diabetes) {
//    NSString * title = @"My Diabetes";
//    self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == COPD) {
//        NSString * title = @"My COPD";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == MM) {
//        NSString * title = @"My MM";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == RA) {
//        NSString * title = @"My RA";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == HepC) {
//        NSString * title = @"My HepC";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == PD) {
//        NSString * title = @"My PD";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == IPF) {
//        NSString * title = @"My IPF";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == Asthma) {
//        NSString * title = @"My Exacerbations"; //My Asthma";
//        self.navigationItem.title = title;
//    }
//    else if ([[[ConfigurationManager sharedManager] appID] integerValue] == AAPA) {
//        NSString * title = @"My Exacerbations"; //My Asthma";
//        self.navigationItem.title = title;
//    }
//
    

    self.startOnTextField.placeholder = kFieldPlaceHolderText;
    self.endOnTextField.placeholder = kFieldPlaceHolderText;
    self.intensityTextField.placeholder = kFieldPlaceHolderText;
    
    BOOL shouldShowSwitch = FALSE;

    //Added the condition bellow to show the 4 switch buttons on exacerbation Page
    switch ([[[ConfigurationManager sharedManager] appID] integerValue] ) {

        case Diabetes:
            shouldShowSwitch = TRUE;
        break;
            
        default:
            break;
    }

//    if (   [[[ConfigurationManager sharedManager] appID] integerValue] == RA
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == MS
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == COPD
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == HepC
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == PD
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == IPF
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == Asthma
//            || [[[ConfigurationManager sharedManager] appID] integerValue] == AAPA
//            //|| [[[ConfigurationManager sharedManager] appID] integerValue] == MM //Not for MM
//        ) {
//        shouldShowSymptonSwitch = FALSE;
//    }

    
//    *************************************************
     // Added per trello board           - svaz 9/29/14
    BOOL shouldShowConcurrentInfSwitch = TRUE;
    BOOL shouldShowHeatExpSwitch = TRUE;
    BOOL shouldShowStressSwitch= TRUE;
    BOOL shouldShowFatigueSwitch= TRUE;
    
    if ([[[ConfigurationManager sharedManager] appID] integerValue] == MS){
        
    
        if (shouldShowConcurrentInfSwitch) {
            self.concurrentInfSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 240  , 79, 27)];
            self.concurrentInfSwitch.onText = @"YES";
            self.concurrentInfSwitch.offText = @"NO";
            self.concurrentInfSwitch.onTintColor = [UIColor darkBlue];
            [self.concurrentInfSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:self.concurrentInfSwitch];
        }
        
        if (shouldShowHeatExpSwitch) {
            self.heatExpSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 285, 79, 27)];
            self.heatExpSwitch.onText = @"YES";
            self.heatExpSwitch.offText = @"NO";
            self.heatExpSwitch.onTintColor = [UIColor darkBlue];
            [self.heatExpSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:self.heatExpSwitch];
        }
        
        if (shouldShowStressSwitch) {
            self.stressSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 330  , 79, 27)];
            self.stressSwitch.onText = @"YES";
            self.stressSwitch.offText = @"NO";
            self.stressSwitch.onTintColor = [UIColor darkBlue];
            [self.stressSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:self.stressSwitch];
        }
        
        if (shouldShowFatigueSwitch)     {
            self.fatigueSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 370  , 79, 27)];
            self.fatigueSwitch.onText = @"YES";
            self.fatigueSwitch.offText = @"NO";
            self.fatigueSwitch.onTintColor = [UIColor darkBlue];
            [self.fatigueSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:self.fatigueSwitch];
        }
    }
    //    End Added        - svaz 9/29/14
    //******************************************
    
    
    if (shouldShowSwitch) {
        self.concurrentInfSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 196 + 70, 79, 27)];
        self.concurrentInfSwitch.onText = @"YES";
        self.concurrentInfSwitch.offText = @"NO";
        self.concurrentInfSwitch.onTintColor = [UIColor darkBlue];
        [self.concurrentInfSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:self.concurrentInfSwitch];
    }
    
    if (shouldShowSwitch) {
        self.heatExpSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 240 + 70, 79, 27)];
        self.heatExpSwitch.onText = @"YES";
        self.heatExpSwitch.offText = @"NO";
        self.heatExpSwitch.onTintColor = [UIColor darkBlue];
        //[self.heatExpSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.heatExpSwitch];
    }
    
    if (shouldShowSwitch) {
        self.stressSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 284 + 70, 79, 27)];
        self.stressSwitch.onText = @"YES";
        self.stressSwitch.offText = @"NO";
        self.stressSwitch.onTintColor = [UIColor darkBlue];
        //[self.stressSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.stressSwitch];
    }
    
    if (shouldShowSwitch) {
        self.fatigueSwitch = [[DCRoundSwitch alloc]initWithFrame:CGRectMake(210, 328 + 70, 79, 27)];
        self.fatigueSwitch.onText = @"YES";
        self.fatigueSwitch.offText = @"NO";
        self.fatigueSwitch.onTintColor = [UIColor darkBlue];
        //[self.fatigueSwitch addTarget:self action:@selector(userInteraction) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.fatigueSwitch];
    }
    
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(symptomSelected:) name:@"selectedSymptom" object:nil];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frequencySelected:) name:@"selectedFrequency" object:nil];

    self.intensityData = @[@"1 Low", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10 High"];
    
    self.endOnTextField.tag = kFormViewControllerFieldDateTime;
    self.startOnTextField.tag = kFormViewControllerFieldDateTime;
    self.intensityTextField.tag = kFormViewControllerFieldNumber;

    self.fields = @[self.startOnTextField, self.endOnTextField, self.intensityTextField];
    
    for (UITextField * field in self.fields) {
        field.inputAccessoryView = self.inputAccessoryViewToolbar;

        if (field.tag  == kFormViewControllerFieldDateTime){
            self.inputViewDatePicker.datePickerMode = UIDatePickerModeDateAndTime;

            field.inputView = self.inputViewDatePicker;
        }
        
        if (field.tag == kFormViewControllerFieldNumber){
            field.inputView = self.inputIntensityPicker;
        }
    }
    
    [self refresh];
    
    if (!self.editMode) {
      AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if ([ad.symptomData count] > 0)
            self.symptom = [ad.symptomData objectAtIndex:0];
        self.intensity = [NSNumber numberWithInt:1];
        
        NSDictionary *params = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:[[ConfigurationManager sharedManager] appID], nil] forKeys:[NSArray arrayWithObjects:@"app_id", nil]];
        [Setting exactMatchWithParams:params offset:0 limit:10 async:^(NSArray *objects, NSError *error) {
            //Setting *globals;
            //for (Setting *stg in objects)
                if (!error) {
                    if ([objects count] > 0) {
                        //globals = [objects objectAtIndex:0]; // there should only be one
                        UIAlertView *alert = [[UIAlertView alloc]init];
                        alert.title = @"Warning!";
                        alert.message = @"Please call your physician if these symptoms are occurring, which is an indication of an exacerbation."; //globals.severeSymptomMsg;
                        [alert addButtonWithTitle:@"OK"];
                        [alert setCancelButtonIndex:0];
                        [alert setTag:1];
                        [alert show];
                        //NSLog(@"%@",stg);
                    }
                }
            
        }];
        
    }
    

}



-(void)back{
    if([self saveTapped])
        [super back];
//        self.navigationItem.leftBarButtonItem.enabled = NO;
    else return;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedSymptom" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedFrequency" object:nil];
    
}



@end