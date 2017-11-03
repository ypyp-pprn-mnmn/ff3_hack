@echo off
svn export --force release "../released files/pack"
cd "../released files/pack"
"F:\Program Files\7-Zip\7z" a -tzip "ff3_hack.zip" "*" -x!*.nes -x!.svn -x!*.zip -x!todo.txt
cd "../../work"
@echo on