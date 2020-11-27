rem ---------- ---------- ---------- Entry point ---------- ---------- ----------

call %*
exit /B

rem ---------- ---------- ---------- Init ---------- ---------- ----------

rem Usage: Init
:Init

if "%LNK%" == "" (
    set LNK=%~f0
) else (
    exit /B 0
)

rem Functions

set LnkLoad=call "%LNK%" :Load

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: Load [library]...
:Load

for %%A in (%*) do (
    call "%~dp0%%A.bat" :Init
    if ERRORLEVEL 1 ( exit /B )
)

exit /B 0
