rem ---------- ---------- ---------- Entry point ---------- ---------- ----------

call %*
exit /B

rem ---------- ---------- ---------- Init ---------- ---------- ----------

rem Usage: Init
:Init

if "%LNK%" == "" (
    echo:[Error] Use linker.bat to load '%~nx0'
    exit /B 1
)

if "%VID%" == "" (
    set VID=%~f0
) else (
    exit /B 0
)

%LnkLoad% "log" "filesystem"
if ERRORLEVEL 1 ( exit /B )

rem Functions

set VidConvert=call "%VID%" :Convert
set VidCut=call "%VID%" :Cut
set VidConcat=call "%VID%" :Concat

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: Convert <input> <output> [mode]
:Convert
@setlocal

set INPUT_OPTIONS=-analyzeduration 10000000
set OUTPUT_OPTIONS=-c copy -sn -dn -map 0 -ignore_unknown

%LogInfo% "Converting..."

call :FFmpeg "%~1" "%~2" "%INPUT_OPTIONS%" "%OUTPUT_OPTIONS%" "%~3"
if ERRORLEVEL 1 (
    %LogError% "Conversion failed"
    exit /B 1
)

exit /B 0

rem Usage: Cut <input> <output> <start_time> <end_time> [mode]
:Cut
@setlocal

set INPUT_OPTIONS=-ss %~3 -to %~4
set OUTPUT_OPTIONS=-c copy -map 0
rem set OUTPUT_OPTIONS=-c:v libx264 -c:a copy -map 0 -strict strict -preset ultrafast

%LogInfo% "Cutting..."

call :FFmpeg "%~1" "%~2" "%INPUT_OPTIONS%" "%OUTPUT_OPTIONS%" "%~5"
if ERRORLEVEL 1 (
    %LogError% "Cutting failed"
    exit /B 1
)

exit /B 0

rem Usage: Concat <input> <output> [mode]
:Concat
@setlocal

set INPUT_OPTIONS=-f concat -safe 0
set OUTPUT_OPTIONS=-c copy -map 0
rem set OUTPUT_OPTIONS=-c copy -map 0 -movflags faststart

%LogInfo% "Concatening..."

call :FFmpeg "%~1" "%~2" "%INPUT_OPTIONS%" "%OUTPUT_OPTIONS%" "%~3"
if ERRORLEVEL 1 (
    %LogError% "Concatenation failed"
    exit /B 1
)

exit /B 0

rem ---------- ---------- ---------- Private ---------- ---------- ----------

rem Usage: FFmpeg <input> <output> <input_options> <output_options> [mode]
:FFmpeg

%FsIsProgram% "ffmpeg"
if ERRORLEVEL 1 ( exit /B )

%LogInfo% "Input: '%~f1'"

%FsProcessFile% "%~1" "%~2" "%~5"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )

%LogInfo% "Input options: '%~3'"
%LogInfo% "Output options: '%~4'"

ffmpeg -hide_banner %~3 -i "%~f1" %~4 "%~f2"
if ERRORLEVEL 1 ( exit /B 1 )

%LogInfo% "Output: '%~f2'"
exit /B 0
