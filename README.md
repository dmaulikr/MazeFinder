About MazeFinder
================
This program implements a "maze" creator and solver.

These features are implemented as BoardSquare2D and as Pathfinder.

The main program, when compiled, will produce an example command-line application that produces a random maze and solves it. The maze and the path through the maze are printed to STDOUT as ASCII with "X" representing walls, "." representing open space, and "!" representing the path through the maze from the upper left to the lower right squares.

BoardSquare2D
-------------
BoardSquare2D implements a Board2D and a BoardCell class to generate and define a "maze" of arbitrary size. This uses a modified Prim's Algorithm to generate a maze based on a random starting point within the specified dimensions.

Unlike Prim's, this "maze" consists of both corridors and large open spaces.

Pathfinder
----------
Pathfinder is an implementation of the A* pathfinding algorithm to solve a path between any two cells in a Board2D object.

Example Output
==============
```
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X!.X..........X.....X........X
X!.XX..XXXXX..X.....X......X.X
X!!!!!!!!!!!!!!!!!!....XX....X
X............XXX.X!!!!!.XX...X
XXX....X.X.XX....X...X!!!!...X
X...XXX...XX...XX..XX.XXX!...X
X...X.......XXXX...X.....!.X.X
XXXXXXX..X.....XXXXX..X.X!.XXX
X........XXXX..X.X...XX.X!...X
X.......XX.........X.X...!...X
X......XX.....X....X.X...!...X
X...X..XXXXXXXX....XX.X..!X..X
X...XXX............XX....!!..X
X...XXX........XX.X......X!..X
X...X.XX...XXX....X...X...!..X
X.XX....XX.X..X.X.X...X..X!..X
X.X.......XX.....XX...X..X!..X
XXX....X...........X...XXX!..X
X......X...X.......X......!.XX
X....X.X...X....X..X.X....!!!X
X.X..XXXX..XX.X.X.XX.X...XXX!X
XXXX..X.....X.X.X..X...X...X!X
X..X...X....X...X.X....X...X!X
X...........X...X.X...XX..X.!X
XXXXX..XX.XXX...X..XX...XXX.!X
X....X.X....X...XX....XXXX..!X
XXX.........X.......X....XXX!X
X....X............X........X!X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

LICENSE
=======
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
