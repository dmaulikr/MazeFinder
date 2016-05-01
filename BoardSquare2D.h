//
//  BoardSquare2D.h
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
#import <Foundation/Foundation.h>
//Forward declaration for the classes in this header
@class Board2D;
@class BoardCell;

////////////////////////////////////////////////////////////////////////////////

@interface BoardCell : NSObject {
}
@property int xReference;
@property int yReference;
@property int xPosition;
@property int yPosition;
@property BOOL isObstacle;
@property BOOL isInPath;

//methods
- (id) initWithXReference:(int)xR WithYReference:(int)yR WithXPosition:(int)xP WithYPosition:(int)yP;
- (void) makePassageForMaze:(Board2D *)board;
- (void) makePassage;
@end

////////////////////////////////////////////////////////////////////////////////

@interface Board2D : NSObject {
@private
    int contentWidth;
    int contentHeight;
    NSMutableArray *theRows;
}
@property int boardSizeInX;
@property int boardSizeInY;

//methods

- (void) setupBoardWithRows:(int)rows WithColumns:(int)columns;
- (void) createMazeFromBoard;
- (NSString*) drawMaze;
- (NSString*) drawPathThroughMaze:(NSArray *)path;
- (void) addToWallList:(NSMutableArray *)wallList NeighborsOfCellAtRow:(int)row Column:(int)column;
//- (BOOL) isCell:(BoardCell *)cell inMaze:(NSMutableArray *)list;
- (BoardCell *) getCellAtRow:(int)row Column:(int)column;
- (NSMutableArray *) getRows;
@end



