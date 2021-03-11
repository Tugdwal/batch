rem ---------- ---------- ---------- Entry point ---------- ---------- ----------

rem Entry point
call %*
exit /B

rem ---------- ---------- ---------- Init ---------- ---------- ----------

rem Usage: Init
:Init

if "%LNK%" == "" (
    echo:[Error] Use linker.bat to load '%~nx0'
    exit /B 1
)

if "%PVR%" == "" (
    set PVR=%~f0
) else (
    exit /B 0
)

%LnkLoad% "log" "filesystem" "video"
if ERRORLEVEL 1 ( exit /B )

rem Functions

set PvrCreateRecordingsFile=call "%PVR%" :CreateRecordingsFile

set PvrCreateEdlFile=call "%PVR%" :CreateEdlFile
set PvrCreateEdlFileFromCsv=call "%PVR%" :CreateEdlFileFromCsv
set PvrCreateCutFile=call "%PVR%" :CreateCutFile
set PvrCreateJoinFile=call "%PVR%" :CreateJoinFile

set PvrConvertVideo=call "%PVR%" :ConvertVideo
set PvrCutVideo=call "%PVR%" :CutVideo
set PvrConcatVideo=call "%PVR%" :ConcatVideo
set PvrCopyVideo=call "%PVR%" :CopyVideo

set PvrClean=call "%PVR%" :Clean

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: CreateRecordingsFile <directory> [mode]
:CreateRecordingsFile
call :CreateRecordings "%~1\*.xml" "%~1\recordings.xml" "%~2"
exit /B

rem Usage: CreateEdlFile <video> [mode]
:CreateEdlFile
call :CreateEdl "%~dpn1.mp4" "%~dpn1.edl" "%~2"
exit /B

rem Usage: CreateEdlFileFromCsv <video> [mode]
:CreateEdlFileFromCsv
call :CreateEdl "%~dpn1.csv" "%~dpn1.edl" "%~2"
exit /B

rem Usage: CreateCutFile <video> [mode]
:CreateCutFile
call :EdlToCut "%~dpn1.edl" "%~dpn1.cut" "%~2"
exit /B

rem Usage: CreateJoinFile <video> [mode]
:CreateJoinFile
call :PartToJoin "%~dpn1.part" "%~dpn1.join" "%~2"
exit /B

rem Usage: ConvertVideo <video> [mode]
:ConvertVideo
%VidConvert% "%~dpn1.ts" "%~dpn1.mp4" "%~2"
exit /B

rem Usage: CutVideo <video> [mode]
:CutVideo
call :Cut "%~dpn1.mp4" "%~dpn1.cut" "%~dpn1.part" "%~2"
exit /B

rem Usage: ConcatVideo <video> [mode]
:ConcatVideo
%VidConcat% "%~dpn1.join" "%~dpn1_out.mp4" "%~2"
exit /B

rem Usage: CopyVideo <video> <directory> [mode]
:CopyVideo

set DIRECTORY=%~2

if "%DIRECTORY:~-1%" == "\" (
    set "DIRECTORY=%DIRECTORY:~0,-1%"
)

call :Copy "%~dpn1_out.mp4" "%DIRECTORY%\%~n1\%~n1.mp4" "%~3"
exit /B

rem Usage: Clean <video>
:Clean

%FsIsFilePath% "%~dpn1_out.mp4"
if ERRORLEVEL 1 ( exit /B 0 )

%FsDelete% "%~dpn1.mp4"
%FsDelete% "%~dpn1.cut"
call :CleanParts "%~dpn1.part"
%FsDelete% "%~dpn1.part"
%FsDelete% "%~dpn1.join"
%FsDelete% "%~dpn1_out.mp4"

exit /B 0

rem ---------- ---------- ---------- Private ---------- ---------- ----------

rem Usage: CreateRecordings <filter> <output> [mode]
:CreateRecordings
@setlocal

%LogInfo% "Creating recordings..."
%LogInfo% "Input: '%~dp1'"

%FsIsDirectory% "%~dp1"
if ERRORLEVEL 1 ( exit /B )

%FsProcessFile% "" "%~f2" "%~3"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

echo:^<?xml version="1.0" encoding="UTF-8"?^>>>"%~f2"
echo:^<recordings^>>>"%~f2"

for /F "delims=" %%A in ('dir /s /b "%~f1"') do (
    if not "%%~A" == "%~f2" (
        for /F "usebackq skip=1 delims=" %%B in ("%%~A") do (
            echo:  %%B>>"%~f2"
        )
    )
)

echo:^</recordings^>>>"%~f2"

%LogInfo% "Output: '%~f2'"
exit /B 0

rem Usage: CreateEdl <video|csvfile> <edlfile> [mode]
:CreateEdl
@setlocal

%LogInfo% "Creating edlfile..."
%LogInfo% "Input: '%~f1'"

%FsIsProgram% "comskip"
if ERRORLEVEL 1 ( exit /B )

%FsProcessFile% "%~1" "%~2" "%~3"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

comskip "%~f1" > nul 2>&1
if ERRORLEVEL 2 ( exit /B 1 )

%LogInfo% "Output: '%~f2'"
exit /B 0

rem Usage: EdlToCut <edlfile> <cutfile> [mode]
:EdlToCut
@setlocal

%LogInfo% "Creating cutfile..."
%LogInfo% "Input: '%~f1'"

%FsProcessFile% "%~1" "%~2" "%~3"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

set EDL_CONTENT=

for /F "usebackq tokens=1,2" %%A in ("%~f1") do (
    call set "EDL_CONTENT=%%EDL_CONTENT%%-%%A %%B"
)

set EDL_CONTENT=%EDL_CONTENT:~1%

set LINE=0

for %%A in (%EDL_CONTENT%) do (
    for /F "tokens=1,2 delims=-" %%B in ("%%A") do (
        if not "%%C" == "" (
            call :WriteEdlFile "%~2" "%%B" "%%C"
        )
    )
)

%LogInfo% "Output: '%~f2'"
exit /B 0

rem Usage: WriteEdlFile <edlfile> <start_time> <end_time>
:WriteEdlFile
set /A LINE+=1
echo:%LINE% %~2 %~3>>"%~f1"
exit /B 0

rem Usage: PartToJoin <partfile> <joinfile> [mode]
:PartToJoin

%LogInfo% "Creating joinfile..."
%LogInfo% "Input: '%~f1'"

%FsProcessFile% "%~1" "%~2" "%~3"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

for /F "usebackq tokens=1 delims=" %%A in ("%~f1") do (
    call :WriteJoinFile "%~2" "%%A"
)

%LogInfo% "Output: '%~f2'"
exit /B 0

rem Usage: WriteJoinFile <joinfile> <part>
:WriteJoinFile
@setlocal
set PART_PATH=%~2
set PART_PATH=%PART_PATH:'='\''%
echo:file '%PART_PATH%'>>"%~f1"
exit /B 0

rem Usage: Cut <video> <cutfile> <partfile> [mode]
:Cut

%FsProcessFile% "%~2" "%~3" "%~4"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

for /F "usebackq tokens=1-3" %%A in ("%~f2") do (
    call :CutPart "%~1" "%~dpn1_%%A%~x1" "%~3" "%%B" "%%C" "%~4"
    if ERRORLEVEL 1 ( exit /B )
)

exit /B 0

rem Usage: CutPart <video> <output> <partfile> <start_time> <end_time> [mode]
:CutPart
%VidCut% "%~1" "%~2" "%~4" "%~5" "%~6"
if ERRORLEVEL 1 ( exit /B )
echo:%~f2>>"%~f3"
exit /B 0

rem Usage: Copy <input> <output> [mode]
:Copy

%LogInfo% "Copying video..."
%LogInfo% "Input: '%~f1'"

%FsCopy% "%~1" "%~2" "%~3"
if ERRORLEVEL 2 (
    %LogError% "Copy failed"
    exit /B 1
)
if ERRORLEVEL 1 ( exit /B 0 )

%LogInfo% "Output: '%~f2'"
exit /B 0

rem Usage: CleanParts <partfile>
:CleanParts

dir /b "%~dpn1_*.mp4" > nul 2>&1
if ERRORLEVEL 1 ( exit /B 0 )

for /F "delims=" %%A in ('dir /b "%~dpn1_*.mp4"') do (
    %FsDelete% "%%A"
)

exit /B 0
