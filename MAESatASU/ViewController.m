//
//  ViewController.m
//  MAESatASU
//
//  Created by Leonardo Andrade Osorio on 3/12/15.
//  Copyright (c) 2015 Leonardo Andrade Osorio. All rights reserved.
//

#import "ViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface ViewController ()
@property NSMutableData *responseData;
@end

@implementation ViewController

static NSString * const kClientID = @"594199546874-0at5t7kn50cpebm933vrf2eg0i4rvmvi.apps.googleusercontent.com";
static NSString * const kCalendarID = @"asu.edu_fmkaonrpk9ol7eujjf7pe0pq9o@group.calendar.google.com/events";

NSString * accessToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES; //comment to not get the user's email
    
    //use the previously set kClientID
    signIn.clientID = kClientID;
    
    //uncomment of the these two statements for the scope
    //signIn.scopes = @[ kGTLAuthScopePlusLogin]; // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];          // "profile" scope
    signIn.scopes = @[@"https://www.googleapis.com/auth/calendar"];
    
    //Optional: declare signIn.actions
    signIn.delegate = self;
    
    [signIn trySilentAuthentication]; //silent authentication method
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    //NSLog(@"Received error %@ and auth object %@", error, auth);
    if (error) {
        //do some error handling here
        NSLog(@"Authentication failed");
    } else {
        //NSLog(@"The access token is: %@",auth);
        //NSLog(@"id token is: %@", [GPPSignIn sharedInstance].authentication);
        
        GTMOAuth2Authentication *information = auth;
        accessToken = [information accessToken];
        [self refreshInterfaceBasedOnSignIn];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshInterfaceBasedOnSignIn{
    if ([[GPPSignIn sharedInstance] authentication]) {
        //the user is signed in
        self.signInButton.hidden = YES;
        [self performSegueWithIdentifier:@"segueToSplashPage" sender:self];
        
    } else{
        self.signInButton.hidden = NO;
      }
}

- (void) signOut { //method to sign out user
    [[GPPSignIn sharedInstance] signOut];
}

- (void) disconnect { //method to disconnect user
    [[GPPSignIn sharedInstance] disconnect];
}

- (void) didDisconnectWithError:(NSError *)error{
    if (error){
        NSLog(@"Received error %@", error);
    } else{
        //the user is signed out and disconnected.
        //Clean up user data as specified by Google+ terms
    }
}

- (IBAction)signOutPressed:(id)sender { //method to sign out user
    [self signOut];
    [self refreshInterfaceBasedOnSignIn];
}

- (IBAction)getInfo:(id)sender { //method wired to button on main view controller to fetch data from calendar
    self.responseData = [NSMutableData data]; //data is where the info from the response will go to
    //url to query the calendar api including the calendar id at the end
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@",kCalendarID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"authorization"];
    (void) [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    // Store desired values in an NSDictionary
    NSDictionary *results = [response valueForKey:@"items"];
    //Store events and times into arrays
    NSArray *events = [results valueForKey:@"summary"];
    NSArray *times = [results valueForKey:@"start"];
    
    NSLog(@"The events are: %@",events);
    NSLog(@"The times are: %@", times);
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
