//
//  Analysis.m
//  RunnersCompass
//
//  Created by Geoff MacDonald on 2013-03-11.
//  Copyright (c) 2013 Geoff MacDonald. All rights reserved.
//

#import "Analysis.h"

@implementation Analysis

@synthesize weeklyMeta,weeklyRace,monthlyMeta,monthlyRace;
@synthesize runMeta;

-(id)setupFakeWithRuns:(NSMutableArray *)runToAnalyze
{
    runMeta = runToAnalyze;
    
    weeklyRace = [[NSMutableArray alloc] initWithCapacity:4];
    monthlyRace = [[NSMutableArray alloc] initWithCapacity:4];
    weeklyMeta = [[NSMutableArray alloc] initWithCapacity:4];
    monthlyMeta = [[NSMutableArray alloc] initWithCapacity:4];
    
    //init arrays within arrays representing week/month units
    for(int i = 0; i < 4; i++)
    {
        NSMutableArray * arrayToAdd = [[NSMutableArray alloc] initWithCapacity:100];
        NSMutableArray * arrayToAdd2 = [[NSMutableArray alloc] initWithCapacity:100];
        NSMutableArray * arrayToAdd3 = [[NSMutableArray alloc] initWithCapacity:100];
        NSMutableArray * arrayToAdd4 = [[NSMutableArray alloc] initWithCapacity:100];
        [weeklyRace addObject:arrayToAdd];
        [weeklyMeta addObject:arrayToAdd2];
        [monthlyMeta addObject:arrayToAdd3];
        [monthlyRace addObject:arrayToAdd4];
    }
    
    
    //for the last 100 weeks fill out zeros
    for(NSMutableArray * array1 in weeklyMeta)
    {
        for(int i = 0; i < 100; i++)
        {
            NSNumber * value = [NSNumber numberWithInt:0];
            [array1 addObject:value];
        }
    }
    
    
    NSDate * today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSWeekOfYearCalendarUnit|NSYearCalendarUnit fromDate:today];
    NSInteger startWeek = components.weekOfYear;
    NSInteger startYear = components.year;
    
    //for each run, aggregrate race and meta
    for(RunEvent * run in runToAnalyze)
    {
        //find date to place in arrays
        NSDateComponents *runDate = [calendar components:NSWeekOfYearCalendarUnit|NSYearCalendarUnit  fromDate:run.date];
        NSInteger weeksFromStart = startWeek - runDate.weekOfYear;
        NSInteger yearsFromStart = startYear - runDate.year;
        
        
        NSInteger indexToInsert;
        
        if(yearsFromStart == 0)
            indexToInsert = weeksFromStart;
        else
            indexToInsert = (yearsFromStart * 52) - (52 - weeksFromStart);

        if(indexToInsert >=0)
        {
            
            //modify the value for this in each metric
            for(NSInteger i = MetricTypeDistance; i <= MetricTypeCalories; i++)
            {
                NSMutableArray * array = [weeklyMeta objectAtIndex:i-1];
                
                //set the value of this index, increment previously added runs in week
                NSNumber * currentDistance = [array objectAtIndex:indexToInsert];
                NSNumber * newValue;
                switch(i)
                {
                    case MetricTypeDistance:
                        newValue = [NSNumber numberWithFloat:[currentDistance floatValue] + (run.distance/1000)];
                        break;
                    case MetricTypePace:
                        //need to figure this one out
                        newValue = [NSNumber numberWithFloat:[currentDistance floatValue] + run.avgPace];
                        break;
                    case MetricTypeTime:
                        newValue = [NSNumber numberWithFloat:[currentDistance floatValue] + run.time];
                        break;
                    case MetricTypeCalories:
                        newValue = [NSNumber numberWithFloat:[currentDistance floatValue] + run.calories];
                        break;
                }
                //replace value
                [array replaceObjectAtIndex:indexToInsert withObject:newValue];
            }
            
        }
    }
    
    
    return self;
    
}

@end
