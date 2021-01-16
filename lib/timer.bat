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

if "%TIMER%" == "" (
    set TIMER=%~f0
) else (
    exit /B 0
)

%LnkLoad% "log"
if ERRORLEVEL 1 ( exit /B )

rem Functions

set TimerStart=call "%TIMER%" :Start
set TimerEnd=call "%TIMER%" :End
set TimerDiff=call "%TIMER%" :Diff

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: Start
:Start
set TIMER_PRIVATE_START_TIME=%TIME%
exit /B 0

rem Usage: End
:End
set TIMER_PRIVATE_END_TIME=%TIME%
exit /B 0

rem Usage: Diff
:Diff
@setlocal
call :DiffTimer DIFF_TIME "%TIMER_PRIVATE_START_TIME%" "%TIMER_PRIVATE_END_TIME%"
%LogInfo% "Execution time: %DIFF_TIME%"
exit /B 0

rem ---------- ---------- ---------- Private ---------- ---------- ----------

rem Usage: SplitTimer <HOURS> <MINUTES> <SECONDS> <MILLISECONDS> <timer>
:SplitTimer

for /f "tokens=1-4 delims=:.," %%A in ("%~5") do (
    set %~1=%%A
    set /A %~2=100%%B %% 100
    set /A %~3=100%%C %% 100
    set /A %~4=100%%D %% 100
)

exit /B 0

rem Usage: DiffTimer <DIFF> <start> <end>
:DiffTimer

call :SplitTimer START_H START_M START_S START_MS "%~2"
call :SplitTimer END_H END_M END_S END_MS "%~3"

set /A DIFF_H=%END_H% - %START_H%
set /A DIFF_M=%END_M% - %START_M%
set /A DIFF_S=%END_S% - %START_S%
set /A DIFF_MS=%END_MS% - %START_MS%

if %DIFF_MS% lss 0 (
    set /A DIFF_S=%DIFF_S% - 1
    set /A DIFF_MS=100 + %DIFF_MS%
)

if %DIFF_S% lss 0 (
    set /A DIFF_M=%DIFF_M% - 1
    set /A DIFF_S=60 + %DIFF_S%
)

if %DIFF_M% lss 0 (
    set /A DIFF_H=%DIFF_H% - 1
    set /A DIFF_M=60 + %DIFF_M%
)

if %DIFF_H% lss 0 (
    set /A DIFF_H=24 + %DIFF_H%
)

set DIFF_H=0%DIFF_H%
set DIFF_H=%DIFF_H:~-2%

set DIFF_M=0%DIFF_M%
set DIFF_M=%DIFF_M:~-2%

set DIFF_S=0%DIFF_S%
set DIFF_S=%DIFF_S:~-2%

set DIFF_MS=0%DIFF_MS%
set DIFF_MS=%DIFF_MS:~-2%

set %~1=%DIFF_H%:%DIFF_M%:%DIFF_S%.%DIFF_MS%

exit /B 0
