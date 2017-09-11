
import haxe.io.Path;
import haxe.io.BytesOutput;
import sys.FileSystem;
import sys.io.File;
using Main;

class Main
{
    public static function main()
    {
        var args = Sys.args();
        if (args.length == 0)
        {
            printHelp();
        }

        scanUserData(args[0]);
    }

    private static function scanUserData(_userDataPath : String)
    {
        var myShipDir = Path.join([ _userDataPath, "MyShips" ]);
        if (!FileSystem.exists(myShipDir))
        {
            Log.error('Unable to find "MyShips" folder');
            Log.print('Please ensure you have provided the correct path to the "UserData" folder');
            Sys.exit(2);
        }

        var categories = new Array<Category>();

        // Add all ship files not in their own sub folder into the 'uncategorized' category
        categories.push({
            name  : 'Uncategorized',
            files : FileSystem.readDirectory(myShipDir).filter(function(_file : String) : Bool {
                var path = Path.join([ myShipDir, _file ]);
                return (!FileSystem.isDirectory(path) && Path.extension(path) == 'shp');
            })
        });

        // Look in all sub directories.
        for (item in FileSystem.readDirectory(myShipDir))
        {
            var itemPath = Path.join([ myShipDir, item ]);
            if (!FileSystem.isDirectory(itemPath)) continue;

            categories.push({
                name  : item,
                files : FileSystem.readDirectory(itemPath).filter(function(_file : String) : Bool {
                    var path = Path.join([ itemPath, _file ]);
                    return (!FileSystem.isDirectory(path) && Path.extension(path) == 'shp');
                })
            });
        }

        // Write the categories to a file.
        var bytes = new BytesOutput();

        bytes.writeInt32(categories.length);
        for (cat in categories)
        {
            bytes.writeCSharpString(cat.name);
            bytes.writeInt32(cat.files.length);

            if (cat.files.length == 0) continue;

            for (ship in cat.files)
            {
                var path = Path.join([ myShipDir, cat.name, ship ]);
                if (cat.name == 'Uncategorized') path = Path.join([ myShipDir, ship ]);

                bytes.writeCSharpString(path);
            }
        }

        File.saveBytes(Path.join([ _userDataPath, 'ShipCategories.bin' ]), bytes.getBytes());
    }

    /**
     *  Function to write strings which C#'s binary reader can understand.
     *  Before the string is written to the stream a 7 bit encoded UInt of the strings length is written.
     *  
     *  @param _output - The BytesOutput stream to write to.
     *  @param _string - The string to write.
     */
    private static function writeCSharpString(_output : BytesOutput, _string : String)
    {
        // Write the strings length as a 7 bit encoded UInt (1 byte every 127 chars)
        var num : UInt = cast _string.length;
        while(num >= 0x80)
        {
            _output.writeByte(num | 0x80);
            num = num >> 7;
        }
        _output.writeByte(num);

        // Then write the actual string
        _output.writeString(_string);
    }

    private static function printHelp()
    {
        Log.info('BallisticNG Ship Category Builder');
        Log.print('This program scans the MyShips folder and builds a ShipCategory.bin file which matches the folder structure.');
        Log.print('To use this program provide the location to the "UserData" folder and the file will be created automatically.');
        Log.print('');
        Log.print('E.g.    cat-builder /path/to/game/UserData/');

        Sys.exit(1);
    }
}

typedef Category = {
    var name : String;
    var files : Array<String>;
}
