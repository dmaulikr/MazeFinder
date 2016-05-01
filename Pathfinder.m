//
//  Pathfinder.m
//
//Copyright 2016 Toby Jennings
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//

#import "Pathfinder.h"
#import "BoardSquare2D.h"

@implementation Pathfinder

- (NSArray *) reconstructPathFromList:(NSMutableArray *)closedList {
    //pass the closedList to this method to reconstruct the path

    NSMutableIndexSet *pathIndexSet = [NSMutableIndexSet indexSet];
    [pathIndexSet addIndex:[closedList count]-1];
    while ([pathIndexSet firstIndex] > 0) {
        NSUInteger parentIndex2 = [pathIndexSet firstIndex];
        NSUInteger parentNode2 = [[[closedList objectAtIndex:parentIndex2] valueForKey:@"par"] intValue];
        [pathIndexSet addIndex:parentNode2];
        
    }
        
    NSMutableArray *path = [NSMutableArray arrayWithCapacity:[pathIndexSet count]];
    
    [pathIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [path addObject:[closedList objectAtIndex:idx]];
    }];

    //return the reconstructed path;
    return path;
}

// Find a path from start to target through board using A* pathfinding algorithm.
- (NSArray *) findPathThroughMaze:(Board2D *)board fromX:(int)startX fromY:(int)startY toX:(int)endX toY:(int)endY {
    
    // board size in X is the number of columns on the board
    int boardSizeInX = [board boardSizeInX]+1; //it's 0-indexed
    int boardSizeInY = [board boardSizeInY]+1;
    int totalBoardSize = boardSizeInX * boardSizeInY;
    
    //
    NSNumber *endXAsNumber = [NSNumber numberWithInt:endX];
    NSNumber *endYAsNumber = [NSNumber numberWithInt:endY];
    //
    
    // h(x) is a heuristic estimate of distance from start to target.
    int tempH = abs( startX - endX ) + abs( startY - endY );
    
    // g(x) is the optimized path from start to current node
    int tempG = 0;
    
    // f(x) is g(x) + h(x) or the heuristic estimate of distance from start to target through this node
    int tempF = tempG + tempH; //Of course this starts off == tempH.
    
    // The openList holds the list of possible moves
    // Order is important for the openList, so we'll use NSMutableArray
    NSMutableArray *openList = [NSMutableArray arrayWithCapacity:totalBoardSize];
    
    // The closedList holds the nodes that have been evaluated.
    // Since order is important we'll use NSMutableArray instead of NSMutableSet
    NSMutableArray *closedList = [NSMutableArray arrayWithCapacity:totalBoardSize];
    
    // Every object in the openList should have properties
    // x,y of cell reference; g, h, and f values; parent node
    // We'll start by using an NSDictionary for each object
    
    //For forward reference, maybe we should model an array of the key values?
    NSArray *openListMemberObjectKeys = [NSArray arrayWithObjects:@"x", @"y", @"g", @"h", @"f", @"par",nil];
    
    //Then for each node being added to the openList we can create an array of its values
    NSArray *openListStartingNodeValues = [NSArray arrayWithObjects:
                                           [NSNumber numberWithInt:startX],
                                           [NSNumber numberWithInt:startY],
                                           [NSNumber numberWithInt:tempG],
                                           [NSNumber numberWithInt:tempH],
                                           [NSNumber numberWithInt:tempF],
                                           [NSNumber numberWithInt:0],
                                           nil];
    //And finally build a dictionary from the keys and values
    NSDictionary *startingNode = [NSDictionary dictionaryWithObjects:openListStartingNodeValues forKeys:openListMemberObjectKeys];
    
    // Prime openList with the starting square.
    [openList addObject:startingNode];
    
    NSUInteger currentSquareIndex; //The index of the current square in the openList, should also be [openList count] - 1
    id currentSquare; //The actual object at the currentSquareIndex in openList
    
    while ( [openList count] > 0 ) {
        
        //currentSquareIndex = [openList count] - 1; //0-indexed
        currentSquareIndex = [openList indexOfObject:[openList lastObject]];
        
        //
        int lowestFValue = [[[openList objectAtIndex:currentSquareIndex] valueForKey:@"f"] intValue];
        //Look through openList to find a lowerFValue than lowestFValue
        //guess we'll use fast enumeration to go through the openList
        for (NSArray *a in openList) {
            int thisFValue = [[a valueForKey:@"f"] intValue];
            if ( thisFValue < lowestFValue ) {
                lowestFValue = thisFValue;
                currentSquareIndex = [openList indexOfObject:a];
            }
        }
        //At the end of this loop we have the currentSquareIndex pointing to the node with the lowestFValue.
        // The FValue itself is of no further use.

        //Add the node we just found to the closed list.
        [closedList addObject:[openList objectAtIndex:currentSquareIndex]];
        
        //Move our currentSquare pointer to what we just did
        currentSquare = [closedList lastObject];
        //NSUInteger currentSquareIndexOnClosedList = [closedList indexOfObject:currentSquare];
        NSInteger currentSquareIndexOnClosedList = [closedList count] - 1;
        
        //Is that square the goal square?
//        if ( [[currentSquare valueForKey:@"x"] intValue] == endX && [[currentSquare valueForKey:@"y"] intValue] == endY ) {
        if ( [[currentSquare valueForKey:@"x"] isEqualToNumber:endXAsNumber] && 
             [[currentSquare valueForKey:@"y"] isEqualToNumber:endYAsNumber])
        {
            //We're done, return the closedList and get out of here.
            // Nothing to release, but we would make sure to do it here!
            return [self reconstructPathFromList:closedList];
        }
        
        //Increment our G value with a tentative heuristic
        tempG = [[currentSquare valueForKey:@"g"] intValue] + 1;
        
        //Now we need to build a list of the cells that neighbor currentSquare.
        
        //We'll build four neighbor objects using the NSDictionary template we created for our nodes.
        NSMutableDictionary *leftNeighbor = [NSMutableDictionary dictionaryWithObjects:
                                      [NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"x"] intValue]-1],
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"y"] intValue]],
                                       [NSNumber numberWithInt:tempG],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       nil]
                                                                forKeys:openListMemberObjectKeys];
        NSMutableDictionary *rightNeighbor = [NSMutableDictionary dictionaryWithObjects:
                                      [NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"x"] intValue]+1],
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"y"] intValue]],
                                       [NSNumber numberWithInt:tempG],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       nil]
                                                                 forKeys:openListMemberObjectKeys];
        NSMutableDictionary *upNeighbor = [NSMutableDictionary dictionaryWithObjects:
                                      [NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"x"] intValue]],
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"y"] intValue]-1],
                                       [NSNumber numberWithInt:tempG],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       nil]
                                                                 forKeys:openListMemberObjectKeys];
        NSMutableDictionary *downNeighbor = [NSMutableDictionary dictionaryWithObjects:
                                      [NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"x"] intValue]],
                                       [NSNumber numberWithInt:[[currentSquare valueForKey:@"y"] intValue]+1],
                                       [NSNumber numberWithInt:tempG],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       [NSNumber numberWithInt:0],
                                       nil]
                                                                 forKeys:openListMemberObjectKeys];

        //Neighborlist will be an NSArray with 4 objects.
        NSArray *neighborList = [NSArray arrayWithObjects:leftNeighbor,rightNeighbor,upNeighbor,downNeighbor,nil];
        
        //For each neighbor on the NeighborList
        for (NSDictionary *a in neighborList) {
            int neighborX = [[a valueForKey:@"x"] intValue];
            int neighborY = [[a valueForKey:@"y"] intValue];
            BOOL neighborIsObstacle = [[board getCellAtRow:neighborY Column:neighborX] isObstacle];
            
            BOOL neighborIsOnClosedList = [closedList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return ([[obj valueForKey:@"x"] intValue] == neighborX && [[obj valueForKey:@"y"] intValue] == neighborY);
            }];
            BOOL neighborIsOnOpenList = [openList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return ([[obj valueForKey:@"x"] intValue] == neighborX && [[obj valueForKey:@"y"] intValue] == neighborY);
            }];
            
            //TODO Other indicators that cell is not a valid move, e.g., it is occupied
                //That should be the job of the BoardCell object in its isObstacle method.
            
            //...make sure neighbor is legal square on board
            if ( neighborX < 0 || neighborX > boardSizeInX || neighborY < 0 || neighborY > boardSizeInY || neighborIsObstacle )
            {
                //do nothing
                continue;
            } else //...if it is, make sure it's not on closedList
            if ( neighborIsOnClosedList >= 0 )
            {
                //do nothing
                continue;
            } else //...or on the openList already
            if ( neighborIsOnOpenList >= 0 )
            {
                //Is it a better move from here? is the new f(g) < old f(g)?
                NSInteger oldG = [[[openList objectAtIndex:neighborIsOnOpenList] valueForKey:@"g"] intValue];
                NSInteger newG = [[a valueForKey:@"g"] intValue];
                if ( oldG > newG ) {
                    tempH = abs( [[a valueForKey:@"x"] intValue] - endX ) + abs( [[a valueForKey:@"y"] intValue] - endY);
                    [[openList objectAtIndex:neighborIsOnOpenList] setValue:[NSNumber numberWithInteger:tempH] forKey:@"h"];
                    [[openList objectAtIndex:neighborIsOnOpenList] setValue:[NSNumber numberWithInteger:newG] forKey:@"g"];
                    [[openList objectAtIndex:neighborIsOnOpenList] setValue:[NSNumber numberWithInteger:newG+tempH] forKey:@"f"];
                    [[openList objectAtIndex:neighborIsOnOpenList] setValue:[NSNumber numberWithInteger:currentSquareIndexOnClosedList] forKey:@"par"];
                }
                continue;
            } else //...if it's legal, not on closedList or openList,
            {
                //put it on the openList
                tempH = abs( [[a valueForKey:@"x"] intValue] - endX ) + abs( [[a valueForKey:@"y"] intValue] - endY);
                tempG = [[a valueForKey:@"g"] intValue];
                [a setValue:[NSNumber numberWithInteger:tempH] forKey:@"h"];
                [a setValue:[NSNumber numberWithInteger:tempG+tempH] forKey:@"f"];
                [a setValue:[NSNumber numberWithInteger:currentSquareIndexOnClosedList] forKey:@"par"];
                [openList addObject:a];
            }
        }
        
        //Finally, remove the current square from the openList
        [openList removeObject:currentSquare];
    }
    
    //if we get here there was no path found
    //return empty array
    return [NSArray array];
}

@end
