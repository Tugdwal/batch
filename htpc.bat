@echo off
@setlocal
chcp 65001 > nul
call :Main %*
chcp 850 > nul
exit /B 0

rem Usage: Main
:Main
@setlocal

call "%~dp0lib\linker.bat" :Init
%LnkLoad% "log" "filesystem" "command" "pvr" "video" "timer"
if ERRORLEVEL 1 ( exit /B 1 )

%TimerStart%
call :Execute %*
%TimerEnd%
%TimerDiff%

exit /B 0

rem Usage: Execute
:Execute
@setlocal

set OPTION_HELP=ACTION_HELP/help/display this help and exit

set OPTION_RECORDINGS=ACTION_RECORDINGS/recordings/create a recordings (.xml) file from all recording (.xml) files in a directory
set OPTION_EDLFILE=ACTION_EDLFILE/edlfile/create an edl (.edl) file from an MPEG-4 (.mp4) file
set OPTION_CUTFILE=ACTION_CUTFILE/cutfile/create a cut (.cut) file from an edl (.edl) file
set OPTION_JOINFILE=ACTION_JOINFILE/joinfile/create a join (.join) file from a part (.part) file
set OPTION_CONVERT=ACTION_CONVERT/convert/convert an MPEG Transport Stream (.ts) file to an MPEG-4 (.mp4) file
set OPTION_CUT=ACTION_CUT/cut/cut an MPEG-4 (.mp4) file into parts according to a cutfile (.cut)
set OPTION_CONCAT=ACTION_CONCAT/concat/concat all MPEG-4 (.mp4) parts into a single MPEG-4 (.mp4) file using a joinfile (.join)
set OPTION_COPY=ACTION_COPY/copy/copy the resulting MPEG-4 (.mp4) file to the output directory
set OPTION_CLEAN=ACTION_CLEAN/clean/delete temporary files
set OPTION_ALL=ACTION_ALL/all/enable all actions except --recordings

set OPTION_OVERWRITE=FLAG_OVERWRITE/overwrite/overwrite existing output files
set OPTION_CSV=FLAG_CSV/csv/use a csv (.csv) file as input ; only used to create an edl (.edl) file
set OPTION_OUT=OUTPUT_PATH:V/out:.

set OPTION_LIST="%OPTION_HELP%" "%OPTION_RECORDINGS%" "%OPTION_EDLFILE%" "%OPTION_CUTFILE%" "%OPTION_JOINFILE%" "%OPTION_CONVERT%" "%OPTION_CONCAT%" "%OPTION_CUT%" "%OPTION_COPY%" "%OPTION_CLEAN%" "%OPTION_ALL%" "%OPTION_OVERWRITE%" "%OPTION_CSV%" "%OPTION_OUT%"

%CmdSetOptions% %OPTION_LIST%
%CmdSetExtraArguments% "ARGUMENTS"
%CmdSetHelpAction% "ACTION_HELP"

for %%A in (%*) do (
    %CmdParseArgument% "%%~A"
)

if "%ACTION_ALL%" == "%CmdFlagOn%" (
    set ACTION_CONVERT=%CmdFlagOn%
    set ACTION_EDLFILE=%CmdFlagOn%
    set ACTION_CUTFILE=%CmdFlagOn%
    set ACTION_CUT=%CmdFlagOn%
    set ACTION_JOINFILE=%CmdFlagOn%
    set ACTION_CONCAT=%CmdFlagOn%
    set ACTION_COPY=%CmdFlagOn%
    set ACTION_CLEAN=%CmdFlagOn%
)

%CmdIsOptionEnabled% "%ACTION_RECORDINGS%" "%ACTION_CONVERT%" "%ACTION_EDLFILE%" "%ACTION_CUTFILE%" "%ACTION_CUT%" "%ACTION_JOINFILE%" "%ACTION_CONCAT%" "%ACTION_COPY%" "%ACTION_CLEAN%"
if ERRORLEVEL 1 (
    set ACTION_CONVERT=%CmdFlagOn%
    set ACTION_EDLFILE=%CmdFlagOn%
    set ACTION_CUTFILE=%CmdFlagOn%
    set ACTION_CUT=%CmdFlagOn%
    set ACTION_JOINFILE=%CmdFlagOn%
    set ACTION_CONCAT=%CmdFlagOn%
)

if "%ACTION_HELP%" == "%CmdFlagOn%" (
    call :Help
    exit /B 0
)

if "%FLAG_OVERWRITE%" == "%CmdFlagOn%" (
    set MODE=%FsModeOverwrite%
) else (
    set MODE=%FsModeKeep%
)

if [%ARGUMENTS%] == [] (
    set ARGUMENTS=.
)

if "%ACTION_RECORDINGS%" == "%CmdFlagOn%" (
    for %%A in (%ARGUMENTS%) do (
        %PvrCreateRecordingsFile% "%%~A" "%MODE%"
        exit /B
    )
)

for %%A in (%ARGUMENTS%) do (
    %FsIsValid% "%%~A"
    if ERRORLEVEL 1 ( exit /B )

    %FsIsFilePath% "%%~A"
    if ERRORLEVEL 1 (
        for /F "delims=" %%B in ('dir /b /s "%%~A\*.ts"') do (
            call :EditVideo "%%~B" "%OUTPUT_PATH%" "%MODE%"
            if ERRORLEVEL 1 ( exit /B )
        )
    ) else (
        call :EditVideo "%%~A" "%OUTPUT_PATH%" "%MODE%"
        if ERRORLEVEL 1 ( exit /B )
    )
)

exit /B 0

rem Usage: EditVideo <video> <output_path> [mode]
:EditVideo

if "%ACTION_CONVERT%" == "%CmdFlagOn%" (
    %PvrConvertVideo% "%~1" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_EDLFILE%" == "%CmdFlagOn%" (
    if "%FLAG_CSV%" == "%CmdFlagOn%" (
        %PvrCreateEdlFileFromCsv% "%~1" "%~3"
        if ERRORLEVEL 1 ( exit /B )
    ) else (
        %PvrCreateEdlfile% "%~1" "%~3"
        if ERRORLEVEL 1 ( exit /B )
    )
)

if "%ACTION_CUTFILE%" == "%CmdFlagOn%" (
    %PvrCreateCutFile% "%~1" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_CUT%" == "%CmdFlagOn%" (
    %PvrCutVideo% "%~1" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_JOINFILE%" == "%CmdFlagOn%" (
    %PvrCreateJoinFile% "%~1" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_CONCAT%" == "%CmdFlagOn%" (
    %PvrConcatVideo% "%~1" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_COPY%" == "%CmdFlagOn%" (
    %PvrCopyVideo% "%~1" "%~2" "%~3"
    if ERRORLEVEL 1 ( exit /B )
)

if "%ACTION_CLEAN%" == "%CmdFlagOn%" (
    %PvrClean% "%~1"
    if ERRORLEVEL 1 ( exit /B )
)

exit /B 0

rem Usage: Help
:Help

echo:
echo:Usage: pvr [--flag[:t,true,f,false]... [--option:value]... ^<file^|directory^>
echo:
%CmdPrintOptions%
echo:Author
echo:    Written by Tugdwal - tudal.le.bot@gmail.com
echo:
echo:Version
echo:    1.0
echo:

exit /B 0
