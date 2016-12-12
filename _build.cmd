@ECHO Budowanie instalacji...
@set install_dir=..\instalacja
@if not exist %install_dir% mkdir %install_dir%
@rem FOR %%f IN (%1) DO @7za.exe a -t7z "..\..\archiwum\%%~nf@%release%.%major%.%minor%-%subminor%T%date%.7z" "%%f" -mx1
@7za.exe a -t7z "%install_dir%\%1@%release%.%major%.%minor%-%subminor%T%date%.7z" %2 %3 %4 %5 %6 %7 %8 %9 -mx1