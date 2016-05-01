//
//  BoardSquare2D.m
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

#import "BoardSquare2D.h"

@implementation BoardCell

@synthesize xReference;
@synthesize yReference;
@synthesize xPosition;
@synthesize yPosition;
@synthesize isObstacle;
@synthesize isInPath;

- (NSString *) description {
    return [NSString stringWithFormat:@"Board cell at x=%i, y=%i", xReference,yReference];
}

// Makes a BoardCell object with the specified values. It defaults to isObstacle.
- (id) initWithXReference:(int)xR WithYReference:(int)yR WithXPosition:(int)xP WithYPosition:(int)yP {
    self = [super init];
    if (self) {
        xReference = xR;
        yReference = yR;
        xPosition = xP;
        yPosition = yP;
        isObstacle = YES;
        isInPath = NO;
    }
    return self;
}

// makePassageForMaze just flips the given BoardCell object from isObstacle to isNotObstacle.
// Feeding in a pointer to the board object exposes the maximum row/column dimensions but
// I could probably do better checking beforehand and make it unnecessary.
- (void) makePassageForMaze:(Board2D *)board {
    if (self.xReference != 0 &&
        self.xReference != board.boardSizeInX &&
        self.yReference != 0 &&
        self.yReference != board.boardSizeInY) {
            isObstacle = NO;
    }
}

- (void) makePassage {
    isObstacle = NO;
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation Board2D

@synthesize boardSizeInX;
@synthesize boardSizeInY;

// getter and setter for boardSizeInX:
- (void) setBoardSizeInX:(int)columns {
    boardSizeInX = columns;
}
- (int) boardSizeInX {
    return boardSizeInX - 1; //0-indexed array
}

// getter and setter for boardSizeInY:
- (void) setBoardSizeInY:(int)rows {
    boardSizeInY = rows;
}
- (int) boardSizeInY {
    return boardSizeInY - 1;
}

//setupBoardWithRows sets up a 2-dimensional array with a BoardCell object
// at each intersection. The board starts out with every square an obstacle.
- (void) setupBoardWithRows:(int)rows WithColumns:(int)columns {
    contentWidth = 640 / columns;
    contentHeight = 960 / rows;
    boardSizeInX = columns;
    boardSizeInY = rows;

    theRows = [NSMutableArray arrayWithCapacity:columns]; //autorelease
    for ( int i=0; i < columns; i++ )
    {
        NSMutableArray * eachColumn = [NSMutableArray arrayWithCapacity:rows]; //autoreleased
        for ( int j=0; j < rows; j++ )
        {
            BoardCell * thisCell = [[BoardCell alloc] initWithXReference:i 
                                                          WithYReference:j
                                                           WithXPosition:i * contentWidth
                                                           WithYPosition:j * contentHeight];
            [eachColumn addObject:thisCell];
            //[BoardCell release]; //Do not need explicit release in ARC
        }
        [theRows   addObject:eachColumn];
    }
}

// addToWallList:NeighborsOfCellAtRow:Column does exactly what it says.
// This method is called from createMazeFromBoard to populate its wallList
// as it carves out the maze.
- (void) addToWallList:(NSMutableArray *)wallList NeighborsOfCellAtRow:(int)row Column:(int)column{
    BoardCell *up = nil;
    BoardCell *down = nil;
    BoardCell *left = nil;
    BoardCell *right = nil;
    
    if ( row-1 >= 0 ) {
        up = [self getCellAtRow:row-1 Column:column];
        if ( up.isObstacle ) {
            [wallList addObject:[NSArray arrayWithObjects:up, @"up", nil]];
        }
    }
    if ( row+1 < boardSizeInY ) {
        down = [self getCellAtRow:row+1 Column:column];
        if ( down.isObstacle ) {
            [wallList addObject:[NSArray arrayWithObjects:down, @"down", nil]];
        }
    }
    if ( column-1 >= 0 ) {
        left=[self getCellAtRow:row Column:column-1];
        if ( left.isObstacle ) {
            [wallList addObject:[NSArray arrayWithObjects:left, @"left", nil]];
        }
    }
    if ( column+1 < boardSizeInX ) {
        right=[self getCellAtRow:row Column:column+1];
        if ( right.isObstacle ) {
            [wallList addObject:[NSArray arrayWithObjects:right, @"right", nil]];
        }
    }
}

// createMazeFromBoard uses a modified Prim's algorithm to carve a "maze" out of an
// initialized board. Don't call it before initBoard
- (void) createMazeFromBoard {
    //Pick a random initial node
    int frx = arc4random_uniform(boardSizeInX-2)+1; //1,max-1
    int fry = arc4random_uniform(boardSizeInY-2)+1; //1,max-1
    
    //Initialize a mazeList and a wallList
    //make mazeList NSMutableSet, unordered but faster membership testing.
    NSMutableSet *mazeList = [NSMutableSet setWithCapacity:boardSizeInX*boardSizeInY];
    NSMutableArray *wallList = [NSMutableArray arrayWithCapacity:boardSizeInX*boardSizeInY];
    
    //Make the initial node a passage
    [[self getCellAtRow:fry Column:frx] makePassage];
    
    //Put the initial node on the mazeList
    [mazeList addObject:[self getCellAtRow:fry Column:frx]];
    
    //Put the neighbors on the wallList
    [self addToWallList:wallList NeighborsOfCellAtRow:fry Column:frx];
    
    while ( [wallList count] > 0 ) {

        int wallCount = (int)[wallList count]; //Explicit cast to int
        int randomWallFromList = arc4random_uniform(wallCount);
        
        NSArray *aRandomWall = [NSArray arrayWithArray:[wallList objectAtIndex:randomWallFromList]];
        BoardCell *aRandomCell = [aRandomWall objectAtIndex:0];
        NSString *aRandomDirection = [aRandomWall objectAtIndex:1];
        BoardCell *nextSquare;
        
        if ( [aRandomDirection  isEqual: @"up"] && aRandomCell.yReference-1 >= 0 ) {
            //step into this square from the south
            nextSquare = [self getCellAtRow:aRandomCell.yReference-1 Column:aRandomCell.xReference];
            
            //make sure nextSquare isn't already on the mazeList
            if ( ! [mazeList containsObject:nextSquare] ) {
                //Make cell a passage and add to mazeList
                [aRandomCell makePassage];
                [mazeList addObject:aRandomCell];
                [mazeList addObject:nextSquare];
                [self addToWallList:wallList NeighborsOfCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference];
            }
            
        } else if ( [aRandomDirection  isEqual: @"down"] && aRandomCell.yReference+1 < boardSizeInY ) {
            //step into this square from the north
            nextSquare = [self getCellAtRow:aRandomCell.yReference+1 Column:aRandomCell.xReference];
            
            if ( ! [mazeList containsObject:nextSquare] ) {
                [aRandomCell makePassage];
                [mazeList addObject:aRandomCell];
                [mazeList addObject:nextSquare];
                [self addToWallList:wallList NeighborsOfCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference];
            }
            
        } else if ( [aRandomDirection  isEqual: @"left"] && aRandomCell.xReference -1 >= 0 ) {
            //step into this square from the east
            nextSquare = [self getCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference-1];

            if ( ! [mazeList containsObject:nextSquare] ) {
                [aRandomCell makePassage];
                [mazeList addObject:aRandomCell];
                [mazeList addObject:nextSquare];
                [self addToWallList:wallList NeighborsOfCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference];
            }
        } else if ( [aRandomDirection  isEqual: @"right"] && aRandomCell.xReference +1 < boardSizeInX) {
            //step into this square from the west
            nextSquare = [self getCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference+1];
            
            if ( ! [mazeList containsObject:nextSquare] ) {
                [aRandomCell makePassageForMaze:self];
                [mazeList addObject:aRandomCell];
                [mazeList addObject:nextSquare];
                [self addToWallList:wallList NeighborsOfCellAtRow:aRandomCell.yReference Column:aRandomCell.xReference];
            }
        } //end if
        
        //Remove all instances of aRandomCell from wallList
        //This might be a little faster if wallList was NSMutableSet
        //and could use [NSMutableSet minusSet:toDelete].
        NSMutableArray *toDelete = [NSMutableArray array];
        for ( NSArray *a in wallList) {
            if ( [a objectAtIndex:0] == aRandomCell ) {
                [toDelete addObject:a];
            }
        }
        [wallList removeObjectsInArray:toDelete];
        
        toDelete = nil;
        nextSquare = nil;
    } // while
}

// getRows returns the main board array
- (NSMutableArray *) getRows {
    return theRows;
}

// getCellAtRow:Column returns the object at that intersection
- (BoardCell *) getCellAtRow:(int)row Column:(int)column {
    //TODO try/catch this
    if ( row > boardSizeInY || column > boardSizeInX ) {
        NSLog(@"Coordinate %i, %i is out of bounds", column,row);
    }
    return [[theRows objectAtIndex:column] objectAtIndex:row];
}

// drawMaze generates an ASCII representation of the maze with NSLog
- (NSString *) drawMaze {
    NSMutableString *aString = [NSMutableString stringWithString:@"\n"];
    
    for (int i=0; i < boardSizeInY; i++) {
        for (int j=0; j < boardSizeInX; j++) {
            NSString *toAppend = ( [self getCellAtRow:i Column:j].isObstacle ) ? @"X" : @".";
            [aString appendString:toAppend];
        }
        [aString appendString:@"\n"];
    }
    return aString;
}

- (NSString *) drawPathThroughMaze:(NSArray *)path {
    NSMutableString *aString = [NSMutableString stringWithString:@"\n"];

    for (NSDictionary *pathNode in path){
        int theX = [[pathNode valueForKey:@"x"] intValue];
        int theY = [[pathNode valueForKey:@"y"] intValue];
        
        [self getCellAtRow:theY Column:theX].isInPath = YES;
    }
    
    for (int i=0; i < boardSizeInY; i++) {
        for (int j=0; j < boardSizeInX; j++) {
            NSString *toAppend = @".";
            
            if ( [self getCellAtRow:i Column:j].isObstacle ) {
                toAppend = @"X";
            } else if ([self getCellAtRow:i Column:j].isInPath ) {
                toAppend = @"!";
            }
            
            [aString appendString:toAppend];
            
        }
        [aString appendString:@"\n"];
    }

    return aString;
}
@end
