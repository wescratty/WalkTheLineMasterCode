//
//  Graph1.m
//  sampleTabBar
//
//  Created by Wes Cratty on 1/2/15.
//  Copyright (c) 2015 Wes Cratty. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <math.h>

@implementation NSArray (StaticArray)

+(NSMutableArray *)sharedInstance{
    
    static dispatch_once_t pred;
    static NSMutableArray *sharedArray = nil;
    dispatch_once(&pred, ^{ sharedArray = [[NSMutableArray alloc] init]; });
    return sharedArray;
}
@end

@interface FirstViewController ()
@property (nonatomic, retain) IBOutlet UILabel *label_a;
@property (nonatomic, retain) IBOutlet UILabel *label_b;
@property (nonatomic, retain) IBOutlet UILabel *label_c;
@property (nonatomic, retain) IBOutlet UILabel *label_d;

@property (weak, nonatomic) IBOutlet UILabel *gSwitchLabel;
@property (nonatomic, retain) IBOutlet UISlider *slider_a;
@property (nonatomic, retain) IBOutlet UISlider *slider_b;
@property (nonatomic, retain) IBOutlet UISlider *slider_c;
@property (nonatomic, retain) IBOutlet UISlider *slider_d;
@property (weak, nonatomic) IBOutlet UISlider *plotsNumSlider;
@property (weak, nonatomic) IBOutlet UILabel *plotsNumLabel;
@property (weak, nonatomic) IBOutlet UISwitch *gSwitch;


-(void) compareLines;
-(void) loadMainGraph;
-(void) loadSmallGraph;

- (IBAction)sliderListener:(id)sender;
- (IBAction)switchListener:(id)sender;

@end

@implementation FirstViewController

int sizeofMyarray = 0;
int records = 5;
int graphsMade =0;
int smallgraphsMade =0;
int plotsSliderNum =10;
bool switchIsOn = TRUE;
bool dontNeedHelp = FALSE;
bool compareGraphs = TRUE;

double A=-1;
double B=-2;
double C=2;
double D=5;
double tabItemIndex =0;

NSNumber *max =0;


CPTGraphHostingView* hostView;
CPTGraph* graph;
CPTGraph* graph2;
CPTScatterPlot* plot;
CPTScatterPlot* plot2;
CPTXYAxisSet *axisSet ;
CPTXYAxis *y;
CPTXYAxis *x;
CPTXYPlotSpace *plotSpace;


//===========================================================================
-(void) viewDidAppear:(BOOL)animated{
    tabItemIndex=self.tabBarController.selectedIndex;
    
    
    if(tabItemIndex==3)
    {
        if(!switchIsOn){
            [self.gSwitch setOn:NO animated:YES];
        }
        if (smallgraphsMade>0) {
            [graph2 reloadData];
            
        }else{
            [self loadSmallGraph];
        }
    }else if (tabItemIndex==0){
        printf("\n\n\nmade graph tab =  %d\n\n\n",graphsMade);
        
        
        if (graphsMade>0) {
            
            [self clearGraph];
            [self getArraySize];
            [graph reloadData];
            
            if (sizeofMyarray>2) {
                if(compareGraphs){
                    [self compareLines];
                    [self clientMessage];
                }
            }
        }else{
            
            if(dontNeedHelp){
                [self loadMainGraph];
                
            }else{
                max =[NSNumber numberWithDouble:-10.0];
                [self clientMessage];
            }
        }
    }
}



//===========================================================================
-(void) clearGraph
{
    int tempplots = 0;
    int interval = 1;
    tempplots =plotsSliderNum;
    
    plotsSliderNum = 0;
    [graph reloadData];
    plotsSliderNum = tempplots;

    [self getArraySize];
    if (sizeofMyarray>25 && sizeofMyarray<=99) {
        interval = 5;
    
    }else if (sizeofMyarray>99){
        interval = 10;
    }
    
    x.labelingPolicy                = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength           = CPTDecimalFromDouble(interval);
    
    [graph.defaultPlotSpace scaleToFitPlots:[graph allPlots]];
    
    
//    if (compareGraphs) {
//        plotsSliderNum = tempplots;
//    }
}


//===========================================================================
// Finds differance between the two lines and stores in max
-(void) compareLines
{
    NSNumber *funct1 =0;
    NSNumber *location1 =0;
    NSNumber *difference=[NSNumber numberWithDouble:0.0];
    NSNumber *accumulation = [NSNumber numberWithDouble:0.0];
    printf(" comparing lines");
    [self getArraySize];
    
    if (sizeofMyarray>0) {
        //check arrays for closeness to line created from user data.
        for (int i=0; i<sizeofMyarray-1; i++){
            
            funct1 =[NSNumber numberWithInt: (A*(pow(i+B,C))+D)];
            if (funct1.intValue<0) {
                funct1=[NSNumber numberWithInt:0];
            }
            
            location1 =([NSNumber numberWithDouble: [[[NSArray sharedInstance] objectAtIndex:i]doubleValue]]);
            difference = [NSNumber numberWithDouble:([funct1 floatValue] - [location1 floatValue])];
            difference = [NSNumber numberWithDouble:fabs([difference doubleValue])];
            
            accumulation = [NSNumber numberWithDouble: [accumulation doubleValue] + [difference doubleValue]];
        }
        max = accumulation;
    }
}


//===========================================================================
// Returns number of points to plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    [self getArraySize];
    if (sizeofMyarray>1 ) {
        return sizeofMyarray;
    }else{
        return plotsSliderNum;
    }
}



//===========================================================================
// Depending on which graph is needed it creates the x vals or returns x vals from array
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    int x = (int)index ;
    NSNumber  *tempint = 0;
    
    
    if ([[plot identifier] isEqual:@"plot"]&& switchIsOn)
    {
        if(fieldEnum == CPTScatterPlotFieldX)
        {
            return [NSNumber numberWithInt: x];
        } else {
            tempint =[NSNumber numberWithInt: (A*(pow(x+B,C))+D)];
            if (tempint.intValue<0) {
                tempint=[NSNumber numberWithInt:0];
            }
            return tempint;
        }
    }
    else if ([[plot identifier] isEqual:@"plot2"]&& [[NSArray sharedInstance] count]>1)//askedForResults)
    {
        if(fieldEnum == CPTScatterPlotFieldX)
        {
            return [NSNumber numberWithInt: x];
        } else {
            
            tempint =[NSNumber numberWithInt: [[[NSArray sharedInstance] objectAtIndex:index]doubleValue]];
            if (tempint.intValue<0) {
                tempint=[NSNumber numberWithInt:0];
            }
            return tempint;
        }
    }
    else if ([[plot identifier] isEqual:@"plot3"]&& [[NSArray sharedInstance] count]>1)//askedForResults)
    {
        if(fieldEnum == CPTScatterPlotFieldX)
        {
            return [NSNumber numberWithInt: x-1];
        } else {
                tempint=[NSNumber numberWithInt:-1];
            return tempint;
        }
    }else{
        return 0;
    }
}



//===========================================================================
// Builds main graph
-(void) loadMainGraph
{
    int size = 0;
    [self getArraySize];
    if (sizeofMyarray>1 ) {
        size = sizeofMyarray;
    }else{
        size = plotsSliderNum;
    }

    graphsMade++;
    
    //------------- Sets up graph -----------------------------------------------------------
    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -2 ) length:CPTDecimalFromFloat( 10 )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -1 ) length:CPTDecimalFromFloat( size )]];
    
    axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    
    y = axisSet.yAxis;
    x = axisSet.xAxis;
//    x.majorTickLength               = 4.0f;
//    x.minorTickLength               = 2.0f;
//    x.preferredNumberOfMajorTicks   = 2.0;
//    x.labelingPolicy                = CPTAxisLabelingPolicyFixedInterval;
//    x.majorIntervalLength           = CPTDecimalFromDouble(1);
//
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    
    y.labelFormatter = formatter;
    x.labelFormatter = formatter;
    
    y.title = @"Speed MPH";
    x.title = @"Time";
    x.titleOffset = 20.0f;
    y.titleOffset = 20.0f;
    
    CPTMutableLineStyle *dottedStyle=[CPTMutableLineStyle lineStyle];
    dottedStyle.dashPattern=[NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:.5], [NSDecimalNumber numberWithInt:3], nil];
    dottedStyle.patternPhase=0.0f;
    dottedStyle.lineColor = [CPTColor lightGrayColor];
                             
    // set the majorGridLinestyleProperty by this line as.
                             
    axisSet.yAxis.majorGridLineStyle = dottedStyle;
    axisSet.xAxis.majorGridLineStyle = dottedStyle;
    
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // - Enable user interactions for plot space
    plotSpace.allowsUserInteraction = YES;
    
    
    //-------------- plot ------------------------------
    // Create the plot
    plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.interpolation = CPTScatterPlotInterpolationCurved;
    
    [plot setIdentifier:@"plot"];
    [plot setDelegate:self];
    
    plot.dataSource = self;
//    plot.areaFill = [CPTFill fillWithColor:[CPTColor cyanColor]];
//    plot.areaBaseValue = CPTDecimalFromInteger(0);
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle        = -90.0f;
    plot.areaFill= [CPTFill fillWithGradient:areaGradient];
    plot.areaBaseValue = CPTDecimalFromString(@"0");
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    
    CPTMutableLineStyle *mainPlotLineStyle = [[plot dataLineStyle] mutableCopy];
    [mainPlotLineStyle setLineWidth:1.0f];
    [mainPlotLineStyle setLineColor:[CPTColor colorWithCGColor:[[UIColor greenColor] CGColor]]];
    
    [plot setDataLineStyle:mainPlotLineStyle];
    //-------------- End plot ------------------------------
    
    
    //-------------- plot2 ------------------------------
    // Create plot2 (from user location data)
    CPTScatterPlot* plot2 = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot2.interpolation = CPTScatterPlotInterpolationCurved;

    
    [plot2 setIdentifier:@"plot2"];
    [plot2 setDelegate:self];
    
    plot2.dataSource = self;
//    plot2.areaFill = [CPTFill fillWithColor:[CPTColor magentaColor]];
//    plot2.areaBaseValue = CPTDecimalFromInteger(0);
    
    // Put an area gradient under the plot above
    CPTColor *area2Color       = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:10.0];
    CPTGradient *area2Gradient = [CPTGradient gradientWithBeginningColor:area2Color endingColor:[CPTColor clearColor]];
    area2Gradient.angle               = -90.0f;
    plot2.areaFill= [CPTFill fillWithGradient:area2Gradient];
    plot2.areaBaseValue = CPTDecimalFromString(@"0");
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot2 toPlotSpace:graph.defaultPlotSpace];
    
    
    CPTMutableLineStyle *mainPlotLineStyle2 = [[plot2 dataLineStyle] mutableCopy];
    [mainPlotLineStyle2 setLineWidth:1.0f];
    [mainPlotLineStyle2 setLineColor:[CPTColor colorWithCGColor:[[UIColor blueColor] CGColor]]];
    
    [plot2 setDataLineStyle:mainPlotLineStyle2];
    //-------------- plot2 ------------------------------
    
    //-------------- plot3 ------------------------------
    // Create the plot
    CPTScatterPlot* plot3 = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot3.interpolation = CPTScatterPlotInterpolationCurved;
    
    [plot3 setIdentifier:@"plot3"];
    [plot3 setDelegate:self];
    
    plot3.dataSource = self;
    //    plot.areaFill = [CPTFill fillWithColor:[CPTColor cyanColor]];
    //    plot.areaBaseValue = CPTDecimalFromInteger(0);
    
    // Put an area gradient under the plot above
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot3 toPlotSpace:graph.defaultPlotSpace];
    
    CPTMutableLineStyle *mainPlotLineStyle3 = [[plot dataLineStyle] mutableCopy];
    [mainPlotLineStyle3 setLineWidth:0.0f];
    [mainPlotLineStyle3 setLineColor:[CPTColor colorWithCGColor:[[UIColor clearColor] CGColor]]];
    
    [plot3 setDataLineStyle:mainPlotLineStyle3];
    //-------------- End plot3 ------------------------------

}

//===========================================================================
-(void) loadSmallGraph
{
    smallgraphsMade++;
    hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    graph2 = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    hostView.hostedGraph = graph2;
    
    CPTXYPlotSpace *plotSpace3 = (CPTXYPlotSpace *) graph2.defaultPlotSpace;
//    CPTAxisLabelingPolicyEqualDivisions
    
    [plotSpace3 setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 10 )]];
    [plotSpace3 setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 10 )]];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    
    CPTXYAxis *y = axisSet.yAxis;
    CPTXYAxis *x = axisSet.xAxis;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    
    y.labelFormatter = formatter;
    x.labelFormatter = formatter;
    
    [graph2.plotAreaFrame setPaddingTop:70.0f];
    [graph2.plotAreaFrame setPaddingLeft:340.0f];
    [graph2.plotAreaFrame setPaddingBottom:50.0f];
    [graph2.plotAreaFrame setPaddingRight:5.0f];
    
    // - Disable user interactions for plot space
    plotSpace3.allowsUserInteraction = NO;
    
    
    //-------------- plot ------------------------------
    // Create the plot
    plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.interpolation = CPTScatterPlotInterpolationCurved;
    
    [plot setIdentifier:@"plot"];
    [plot setDelegate:self];
    
    plot.dataSource = self;
//    plot.areaFill = [CPTFill fillWithColor:[CPTColor redColor]];
//    plot.areaBaseValue = CPTDecimalFromInteger(0);
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle               = -90.0f;
    plot.areaFill= [CPTFill fillWithGradient:areaGradient];
    plot.areaBaseValue = CPTDecimalFromString(@"0");
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph2 addPlot:plot toPlotSpace:graph2.defaultPlotSpace];
    
    
    CPTMutableLineStyle *mainPlotLineStyle = [[plot dataLineStyle] mutableCopy];
    [mainPlotLineStyle setLineWidth:2.0f];
    [mainPlotLineStyle setLineColor:[CPTColor colorWithCGColor:[[UIColor greenColor] CGColor]]];
    
    [plot setDataLineStyle:mainPlotLineStyle];
    //-------------- End plot ------------------------------
    
    [self.view bringSubviewToFront:_slider_a];
    [self.view bringSubviewToFront:_slider_b];
    [self.view bringSubviewToFront:_slider_c];
    [self.view bringSubviewToFront:_slider_d];
    [self.view bringSubviewToFront:_plotsNumSlider];
    [self.view bringSubviewToFront:_gSwitch];
}

//===========================================================================
// Displays alert view for instruction and scoring
-(void) clientMessage
{
    NSString *title;
    NSString *string;
    NSString *string3;
    NSString *button1 =@"I don't know" ;
    NSString *button2 = @"Go my own way";
    NSString *button3 = @"Walk the line";
    int caseval = [max integerValue];
    
    switch (caseval)
    {
        case -10:
        {
            title = @"What to do?";
            string =@"Pick a path! ";
            break;
        }
        case 0 ... 5:
        {
            title = @"Perfect!";
            string =@"Best score possible, less than 6 ";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case 6 ... 10:
        {
            title = @"Results";
            string =@"Nice work ";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case 11 ... 15:
        {
            title = @"Results";
            string =@"Pretty good ";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case 16 ... 20:
        {
            title = @"Results";
            string =@"Getting Closer";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case 21 ... 25:
        {
            title = @"Results";
            string =@"So So ";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case 26 ... 30:
        {
            title = @"Results";
            string =@"You could probably do better ";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case -20:
        {
            title = @"Track your movements";
            string =@" When you press start your speed will begin to be recorded. Try speeding up and slowing down. After you have moved around a bit press stop. To see a graph of your movements select \"Graph Lines\" from the tab bar. You can make a new graph by pressing \"Reset Data\"";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;
        }
        case -100:
        {
            title = @"Get ready";
            string =@" Study the graph provided and then proceed to \"Track Location\" and try to match your speed to that of the graph or go to \"Create Line\" and make your own.";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            max = [NSNumber numberWithDouble:-10.0];
            break;
        }
        default:{
            title = @"Results";
            string =@"Rookie";
            button1=@"ok";
            button2 = nil;
            button3 = nil;
            break;

        }
    }
    if (caseval>0) {
        string3 = [NSString stringWithFormat:@"%d",caseval];
        string = [string stringByAppendingString:@", the area between graphs is ≈ "];
        string = [string stringByAppendingString:string3];
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: title
                                                   message: string
                                                  delegate: self
                                         cancelButtonTitle: button1
                                         otherButtonTitles:button2,button3,nil];
    [alert setTag:1];
    [alert show];
    title = @"Results";
}



//===========================================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"I don't know"]){
        NSLog(@"I don't know was selected.");
        [self.tabBarController setSelectedIndex:2];
        
    }else if([title isEqualToString:@"Go my own way"]){
        NSLog(@"Go my own way was selected.");
        switchIsOn = FALSE;
        compareGraphs = FALSE;
        [self.tabBarController setSelectedIndex:1];
        max = [NSNumber numberWithDouble:-20.0];
        [self clientMessage];
        
        
    }else if([title isEqualToString:@"Walk the line"]){
        NSLog(@"Walk the line was selected.");
        dontNeedHelp = TRUE;
        [self loadMainGraph];
        compareGraphs = TRUE;
        max = [NSNumber numberWithDouble:-100.0];
        [self clientMessage];
        
    }else if([title isEqualToString:@"Start over"]){
        NSLog(@"Start over was selected.");
        max = [NSNumber numberWithDouble:-10.0];
        [self clientMessage];
        
    }
    dontNeedHelp = TRUE;
}



//===========================================================================
- (IBAction)switchListener:(id)sender {
    
    if(self.gSwitch.on)
    {
        self.gSwitchLabel.text =@"Compare graphs \"On\"";
        switchIsOn= TRUE;
        compareGraphs = TRUE;
        printf("switched on\n");
        [self sliderListener: _plotsNumSlider];
        
    }else{
        self.gSwitchLabel.text =@"Compare graphs \"Off\"";
        switchIsOn= FALSE;
        compareGraphs = FALSE;
        printf("switched off\n");
        plotsSliderNum =0;
        [self clearGraph];
    }
}



//===========================================================================
- (IBAction)sliderListener:(id)sender {
    UISlider * slider = (UISlider *)sender;
    
    int c =0;
    
    if(switchIsOn){
        switch (slider.tag)
        {
            case 1:
            {
                A = slider.value;
                self.label_a.text = [NSString stringWithFormat:@"%.1f", A];
            }
                break;
            case 2:
            {
                B = slider.value;
                self.label_b.text = [NSString stringWithFormat:@"%.1f", B];
            }
                break;
            case 3:
            {
                C = slider.value;
                c = C/2;
                C = c;
                self.label_c.text = [NSString stringWithFormat:@"%.1d", c];
            }
                break;
            case 4:
            {
                D = slider.value;
                self.label_d.text = [NSString stringWithFormat:@"%.1f", D];
            }
                break;
            case 5:
            {
                plotsSliderNum = slider.value ;
                self.plotsNumLabel.text = [NSString stringWithFormat:@"%d", plotsSliderNum-1];
            }
                break;
        }
        
        [graph2 reloadData];
    }
}



//===========================================================================

-(void) getArraySize
{
    sizeofMyarray=(int)[[NSArray sharedInstance] count];
}

@end
