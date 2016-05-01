//
//  main.m
//  MazeFinder
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

#import <Foundation/Foundation.h>
#import "BoardSquare2D.h"
#import "Pathfinder.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        //Initialize a Board2D object
        Board2D * myBoard = [[Board2D alloc] init];
        
        //Setup an X by Y board.
        [myBoard setupBoardWithRows:30 WithColumns:30];
        
        //Carve a maze out of the board
        [myBoard createMazeFromBoard];
        
        //Draw out the resulting maze in ASCII
        //        NSLog(@"%@", [myBoard drawMaze]);
        
        //Find a path from 1,1 to 28,28
        Pathfinder * myPathfinder = [[Pathfinder alloc] init];
        NSArray *myPath = [myPathfinder findPathThroughMaze:myBoard fromX:1 fromY:1 toX:28 toY:28];
        
        //        NSLog(@"%@", myPath);
        if ( [myPath count] > 0 ) {
            NSLog(@"Pathfinding complete!");
            NSLog(@"%@", [myBoard drawPathThroughMaze:myPath]);
        } else {
            NSLog(@"Path not found!");
            NSLog(@"%@", [myBoard drawMaze]);
        }
        
        //We're done with the board
        //Removing explicit releases for compatibility with ARC
        //[myPathfinder release];
        //[myBoard release];
    }
    return 0;
}

