@set name=egbid_v8
@set name_v8=egbid
@set release=1
@set major=0
@set minor=0

@set MS=c:\win32app\ustation.v8\Program\MicroStation
@set INCLUDE=%MS%\mdl\include;%INCLUDE%
@set LIB=%MS%\mdl\library
@set MDL_COMP=-i%MS%\mdl\include -i%cd% -i%cd%\%lang% -i%MS%\mdl\include\stdlib
@set BMAKE_OPT=-I%MS%\mdl\include
@set PATH=;%MS%;%MS%\mdl\bin\;%PATH%
@set MLINK_STDLIB=%MS%\mdl\library\builtin.dlo %MS%\mdl\library\dgnfileio.dlo %MS%\mdl\library\toolsubs.dlo %MS%\mdl\library\ditemlib.dlo %MS%\mdl\library\mdllib.dlo %MS%\mdl\library\mtg.dlo %MS%\mdl\library\rdbmslib.dlo

@if exist %name%.ma del %name%.ma

@echo #if !defined (H_VER)>app-ver.h
@echo #define H_VER>>app-ver.h
@echo #define C_ID_APPNAME "%name%" >>app-ver.h
@echo #define C_ID_RELEASE %release% >>app-ver.h

@for /F %%v in (app-build.txt) do @set /a subminor=%%v+1

@echo #define C_ID_MAJOR %major% >>app-ver.h
@echo #define C_ID_MINOR %minor% >>app-ver.h
@echo #define C_ID_SUBMINOR %subminor% >>app-ver.h
@echo #define C_ID_APPTITLE "%name%@%release%.%major%.%minor%" >>app-ver.h
@echo #define C_ID_APPTITLE_BUILD "%name%@%release%.%major%.%minor%.%subminor%" >>app-ver.h
@echo #endif>>app-ver.h

@echo %name% %release%.%major%.%minor%-%subminor%

@echo -a%name%.mp>mlink.txt

@echo Kompilacja lib\*.mc

@cd lib
@for /F %%f in (..\lib-mlink.txt) do @cd %%f && (for %%g in (*.mc) do @echo lib\%%f\%%~ng.mo>>..\..\mlink.txt && mcomp -b %%g) && cd ..
@cd ..

@rem rsctype ui-cfg.mt

@echo Kompilacja *.r

@rem rcomp -fwinNT %mdl_comp% -h ui-cmd.r
@rcomp -fwinNT %mdl_comp% ui.r
@rem rcomp -fwinNT %mdl_comp% ui-cfg.r

@echo Kompilacja *.mc
@for %%f in (*.mc) do @echo %%~nf.mo>>mlink.txt && mcomp -b %%f
@rem echo %MS%\mdl\library\rdbmslib.ml>>mlink.txt
@rem echo %MS%\mdl\library\mdllib.ml>>mlink.txt

@echo Linkowanie
@mlink @mlink.txt

@rlib -fwinNT -o%name%.ma %name%.mp ui.rsc
@rem ui-cmd.rsc
@rem ui-cfg.rsc

@if exist %name%.ma echo %subminor% >app-build.txt
@if exist %name%.ma copy /Y %name%.ma %MS%\mdlapps\%name_v8%.ma
@rem if exist %name%.ma call _build.cmd %name% %name%.ma

@for /R %%f in (*.mo) do @del "%%f"
@for %%f in (*.rsc) do @del %%f
@del mlink.txt
@del %name%.mp

@cd lib
@for %%f in (*.mo) do @del %%f
@cd ..

@pause