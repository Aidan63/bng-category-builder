# BallisticNG Category Builder

CLI program which will generate a ShipCategories.bin file for [BallisticNG](http://store.steampowered.com/app/473770/BallisticNG/) based on the directory structure of the users custom ships folder.

## Usage

This program accepts one argument which is the location of the games UserData folder. It will scan the `MyShips` folder and create a ShipCategories.bin file with categories based on folders and files in that directory.

Example

 * `cat-builder /path/to/game/UserData/`

## Building

This program is built with [haxe](https://haxe.org/) and has no dependencies on external libraries.

To build the program run `haxe build-neko.hxml` or `haxe build-cpp.hxml`. The resulting program will be built in the `bin/neko` or `bin/cpp` folders depending on which build file was used.
