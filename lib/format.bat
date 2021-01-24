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

if "%FMT%" == "" (
    set FMT=%~f0
) else (
    exit /B 0
)

rem Functions

set FmtPrint=call "%FMT%" :Print

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: Print <message>
:Print
echo:%~1
exit /B 0
