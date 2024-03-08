# MySQL Workbench build env

``` shell
nix develop
unpackPhase
cd $sourceRoot
patchPhase
exit
cd source
xcodebuild -project MySQLWorkbench.xcodeproj -target parsers -configuration Release -arch x86_64
xcodebuild -project MySQLWorkbench.xcodeproj -target parsers -configuration Release -arch x86_64
xcodebuild -project MySQLWorkbench.xcodeproj -target db.mysql.parser.grt -configuration Release -arch x86_64
xcodebuild -project MySQLWorkbench.xcodeproj -target MySQLWorkbench -configuration Release -arch x86_64

xcodebuild -project MySQLWorkbench.xcodeproj -target parsers -configuration Release -arch arm64
xcodebuild -project MySQLWorkbench.xcodeproj -target parsers -configuration Release -arch arm64
xcodebuild -project MySQLWorkbench.xcodeproj -target db.mysql.parser.grt -configuration Release -arch arm64
xcodebuild -project MySQLWorkbench.xcodeproj -target MySQLWorkbench -configuration Release -arch arm64
```
