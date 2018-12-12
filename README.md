# YAR - Yet Another Raycaster

![Yet Another Raycaster](https://github.com/aburguera/YAR/blob/master/RES/YAR.PNG)

A basic Raycaster coded in MC68000 assembly language using the EASy68K environment. It is aimed at providing students an example of medium-to-high complexity code.

[Video of game with full specs](https://youtu.be/-s0D5Uo2v7I)
[Video of game with basic graphics](https://youtu.be/jE3DPqrf9jY)

## Executing the game

This game is coded in MC68000 assembly language but it relies on the graphics, sound and file system simulated by EASy68K. If you want to play the game you need the EASy68K assembler and simulator available at www.easy68k.com.

Please take into account that the provided code is NOT complete, since it is part of a lab assignment. The missing part is SYSTEM.X68. If you want to execute this game you first have to complete SYSTEM.X68. Instructions on how to complete it are within the file itself. The game will NOT run unless a properly programmed SYSTEM.X68 is coded.

Providing that you have properly coded SYSTEM.X68, you just have to open MAIN.X68 from EASy68K editor and run it.

## Editing the game

Aside of modifying the code itself, which requires MC68000 and EASy68K knowledge, this program is provided with some basic editing capabilities.

### Changing graphics quality

Given the particular way in which EASy68K implements the graphic system, this game may be particularly slow in some computers. If this is your case, please open CONST.X68 and set to zero the conditional assembly flags. Just search the configuration that better suits your computer.

Contrarily to intuition, disabling textures will not greatly improve performance. If you really need more performance, try disabling minimap or color gradation. Also, you can reduce resolution, but this requires two changes: modifying SCRWIDTH and SCRHEIGH in SYSCONST.X68 and regenerating RCTPXANG in RCTDATA.X68 as described later.

### Editing the map

The map is defined in DATA/MAPDATA.X68 and has three parts parts:

* **MAPDATAO** is the map itself. It is a matrix of 64x64 where each value represents a particular block. Comments in the file are self-explanatory.
* **MAPPLRIX** and **MAPPLRIY** are the initial coordinates of the player within the map. They are 16 bit fixed point values, whereas the most significant byte denotes the initial cell and the least significant byte is the position within that cell.
* **MAPNUMTR** represents the number of treasures (fuel capsules). That is, the number of blocks with ID=2.

You can manually rewrite this file to modify the map. However, if you want to easily experiment, you can use the provided TILED interface. TILED is a map editor that can be downloaded in www.mapeditor.org. With TILED you can open and graphically edit the provided RES/MAPDATA.TMX.

Then, you can execute the provided Python script (SCRIPTS/create_map.py). This script will create a new DATA/MAPDATA.X68 that will overwrite DATA/MAPDATA.X68. Please note that in order to execute create_map.py you have to install this library: https://pypi.org/project/tmx/

When editing the map, please take into account that:

* Only one player can be placed within it.
* You have to put at least one fuel capsule (green tile).
* The map must be fully closed to avoid the player or the rays go out of it.

### Changing textures

Textures are not fully fledged. They are 1D textures. This means that only one color per raycaster column is allowed. That is, a texture can be seen as an image of 256x1. Every column of a projected map cell can have different colors, but only one color per column is allowed.

Applying fully fledged textures is not programmatically complex, but extremely time demanding given the way in which EASy68K implements graphics. So, it has not been done here.

The textures are defined in DATA/TEXDATA.X68 and have the following format:

* **TEXDATA** is just a list of pointers to the actual textures. There is one pointer per block ID except for block ID 0. So, the first one is used for block ID 1, the second one for block ID 2 and the third one for block ID 3.
* **.TEX00**, **.TEX01**, **.TEX02** are the actual texture data. Texture data is a set of 256 longs, each one representing the RGB code of one column. The RGB code is represented in the EASy68K color format, which is $00BBGGRR.

You can either modify the texture data by hand or use the provided image interface as follows.

There are three images within the RES folder: TEXT1.PNG, TEXT2.PNG and TEXT3.PNG.

![TEXT1.PNG](https://github.com/aburguera/YAR/blob/master/RES/TEXT1.PNG)
![TEXT2.PNG](https://github.com/aburguera/YAR/blob/master/RES/TEXT2.PNG)
![TEXT3.PNG](https://github.com/aburguera/YAR/blob/master/RES/TEXT3.PNG)

You can modify them freely as long as the image remains 256 pixels wide. Take into account that only the first row of each image will be used as texture. The remaining rows are unused. In the provided images, rows 1 to 255 are repetitions of row 0 to ease viasualizing the final aspect.

Once you have prepared the three abovementioned images, you can run the script SCRIPT/create_textures.py. This script will overwrite DATA/TEXTDATA.X68 with the data corresponding to your images. Afterwards, the game will run with your own textures.

Please note that in order to execute create_textures.py you have to install the Python Image Library (PIL): http://www.pythonware.com/products/pil/

### Canging texts

Texts are defined in DATA/STRDATA.X68. Depending on where they are used, the text data is stored as:

* **Strings**. Just zero-terminated strings.
* **Lists of strings**. A list of pointers to strings followed by the strings themselves.
* **Pages**. A list of pointers to lists of strings, followed by the lists of strings followed by the strings.

### Changing the logo

The logo graphics are stored within DATA/GFXDATA.X68. This data is plotted by the code in GFX.X68. Please refer to the comments in GFX.X68 to understand the meaning of GFXDATA.X68

### Recording a game

The game implements an attract mode which is, basically, the ability to reproduce a game automatically by means of pre-recorded key presses. By default, the attract mode is a tutorial. However, you can record your own game as follows.

First, open CONST.X68 and set ATRSAVE to 1. Then execute the game and play. When you want to stop recording just press P to set the end of record mark and then press M to actually save the data. Nothing will happen, but you can now stop the game. Please note that if you win or reach a game over condition, the game will not be properly saved.

Pressing P sets the mark of end of recording and pressing M creates the file DATA/KEYSTROK.DAT. Please note that the existing KEYSTROK.DAT will be overwritten. Don't stay too long between P and M or the size of KEYSTROK.DAT will unnecesarily increase.

To see the recorded game, just change ATRSAVE back to 0, execute the game again and wait in the title screen until the recorded game begins.

### Changing the game behavior

The source code is fully commented so that you can figure out how it works. Actually, the "game" code is almost independent of the Raytracer. So, you can easily implement 3D versions of games that don't really require moving enemies, such as Snake or TRON.

## Math files

The raycaster strongly relies on some pre-computed mathematical tables. These tables, which are within DATA/RCTDATA.X68, are:

* **RCTSINTB**: A table of sinus. Values are represented in 16 bit fixed point with an 8 bit integer part and an 8 bit fractional part. Angles are represented as a single byte where 0 denotes an angle of 0 degrees, 128 an angle of 180 degrees and so on. The table holds 360+90 degrees, where the last 90 degrees make it easy to take profit of the relationship COS(X)=SIN(X+90DEG) to compute cosinus using the same table.
* **RCTCOSTB**: The table of cosinus points to the table of sinus with an offset of 64 positions (90 degrees) as explained before.
* **RCTPXANG**: A table of angles. Each position contains the angle relative to the viewpoint of each screen column. So, it has as many values as the screen width. Angles are expressed as values between 0 and 255 and words are used instead of bytes to prevent some sign-related issues during the raycaster execution. Also, these angles assume a particular distance from the player to the screen.
* **RCTFNTAN**: A table of tangents for angles between 0 and 90 with a resolution of 1/2048 degrees. The data is stored as 16 bit fixed point with 8 bit for the integer part and 8 bit for the fractional part.
* **RCTSTAR**: Random coordinates to plot the background stars. Each star is represented by three words: X, Y and size. These are just random numbers to avoid computing them during the game execution.

These tables can be re-created with SCRIPT/create_data.py. When running create_data.py you can also change the distance from the player to the screen used when building RCTPXANG. Also, if you change the resolution within the game (SCRWIDTH within SYSCONST.X68), you must regenerate RCTPXANG with the same resolution.

## Raycaster operation

Raycasting is an efficient method to draw 3D environments. Efficiency comes from three ways: pre-computed trigonometric functions, use of fixed point math and viewpoint constraints. As for these constraints, they are:

* All obstacles have the same height.
* The camera is always parallel to the floor. No pitch and no roll. Just yaw.
* The camera is always at half the height of obstacles. So, one single level in height. No up, no down.
* The map is a 2D grid and each cell is a rectangle (a square in our case) aligned with the main axes.

These limitations bring some interesting properties:

* The projection of every obstacle will lead to a vertical line on screen, since there is no pitch nor roll.
* A closer obstacle will always hide a farther obstacle in the line of sight, since all have the same height.
* The vanishing point will always be at the center of the screen, since the camera is at half the obstacles height.
* Detecting distances to obstacles is simplified thanks to the grid structure of the map.

The rough algorithm is:

* For each column in screen (from 0 to 639 in our case):
  * Trace (cast) a line (ray) that passes through the player position and through the column. Hence the name of Raycaster.
  * Compute the first intersection of this line with an obstacle in the map.
  * Compute the distance from the player position to this intersection.
  * Compute the height of the obstacle from the distance (height=K/distance).
  * Draw a vertical line, centered on the Y axis, in the current screen column with the computed height.
* End for

Note that the distance to compute is not the Euclidean distance to the player, but the perpendicular distance to the screen. This is simply to avoid a fish-eye effect.

To improve visual appearance, our implementation applies the following tricks:

* The color of each column is darkened depending on the associated distance. This simulates attenuation of light with distance.
* The color of each column is slightly changed depending on the side of the obstacle in which ray collided. This adds some depth illusion.
* When using textures, the color of each column is chosen from a pre-defined table of textures.

The following links are strongly recommended to fully understand Raycasting:

* [**SIMPLE RAYCASTING**](http://retro-system.com/raycast2.htm): A really nice implementation of a Raycaster in plain C which served as starting point for this MC68000 assembly code.
* [**LODE'S COMPUTER GRAPHICS TUTORIAL - RAYCASTING**](https://lodev.org/cgtutor/raycasting.html): A complete and comprehensive tutorial on Raycasting with C sources.
* [**WOLFENSTEIN 3D'S MAP RENDERER**](https://youtu.be/eOCQfxRQ2pY): A video explaining in detail how the actual Wolfenstein 3D works.
* [**WOLFENSTEIN 3D SOURCE CODE**](https://github.com/id-Software/wolf3d): Where it all began.

## Troubleshooting

A substantial loss of speed may appear in some computers due to graphics. In some cases, running the game in a laptop relying on battery will lead to an extremely slow game whilst running the game in the same laptop connected to A/C will run at the correct speed. If the games runs really slow in your computer, please change the graphics quality as described above.

In some cases, if the graphics computational load is too high, the timer used to simulate VSYNC may just stop working.

While playing, some glitches may appear in some walls. These glitches are due to wrongly detected collisions between casted rays and map, and are caused by the tangent table RCTFNTAN. Basically, the adopted fixed point notation (8 bit integer, 8 bit fractional) cannot properly represent the tangents close to 90 degrees. Because of that, these values are trimmed in the table. This could be fixed by either adopting a different numerical representation or by considering these angles case-by-case within the code. Please note that there is no fixed point notation able to represent tangent values arbitrarily close to 90 degrees. However, given the used angular resolution, probably a 16.16 fixed point notation would suffice.

Finally, please note that some subroutines, such as the DMM ones within SYSTEM.X68 are not used and are provided for the sake of completeness.

## Credits

Game design, graphics and coding:

* Antoni Burguera Burguera. Contact: My family name followed by the at symbol followed by gmail and ending with a dot and a com.

Music and sound effects:

* [**Pain (wall hit sound) by thecheeseman**](http://soundbible.com/1454-Pain.html)
* [**Power bots loop (attract mode music) by DL Sounds**](https://www.dl-sounds.com/royalty-free/power-bots-loop/)
* [**Right channel scramble (oxygen block sound) by Mike Koenig**](http://soundbible.com/417-Right-Channel-Scramble.html)
* [**Light saber turn on (fuel block sound)**](http://soundbible.com/562-Lightsaber-Turn-On.html)
* **The Terminator (initial percussion)**