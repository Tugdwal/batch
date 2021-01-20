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

if "%FS%" == "" (
    set FS=%~f0
) else (
    exit /B 0
)

%LnkLoad% "log"
if ERRORLEVEL 1 ( exit /B )

rem Values

set FsModeKeep=keep
set FsModeOverwrite=overwrite

rem Functions

set FsIsValidPath=call "%FS%" :IsValidPath
set FsIsDirectoryPath=call "%FS%" :IsDirectoryPath
set FsIsFilePath=call "%FS%" :IsFilePath

set FsIsValid=call "%FS%" :IsValidPath
set FsIsDirectory=call "%FS%" :IsDirectory
set FsIsFile=call "%FS%" :IsFile
set FsIsProgram=call "%FS%" :IsProgram

set FsMakeDirectory=call "%FS%" :MakeDirectory
set FsProcessFile=call "%FS%" :ProcessFile

set FsDelete=call "%FS%" :Delete
set FsCopy=call "%FS%" :Copy

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: IsValidPath <path>
:IsValidPath
@setlocal
if "%~a1" == "" ( exit /B 1 )
exit /B 0

rem Usage: IsDirectoryPath <path>
:IsDirectoryPath
@setlocal
set ATTRIBUTES=%~a1
if "%ATTRIBUTES:~0,1%" == "d" ( exit /B 0 )
exit /B 1

rem Usage: IsFilePath <path>
:IsFilePath
@setlocal
set ATTRIBUTES=%~a1
if "%ATTRIBUTES:~0,1%" == "d" ( exit /B 1 )
exit /B 0

rem Usage: IsValid <path>
:IsValid
@setlocal

call :IsValidPath "%~1"
if ERRORLEVEL 1 (
    %LogError% "File or directory not found: '%~f1'"
    exit /B 1
)

exit /B 0

rem Usage: IsDirectory <path>
:IsDirectory
@setlocal

call :IsValidPath "%~1"
if ERRORLEVEL 1 (
    %LogError% "Directory not found: '%~f1'"
    exit /B 1
)

call :IsDirectoryPath "%~1"
if ERRORLEVEL 1 (
    %LogError% "Path does not point to a directory: '%~f1'"
    exit /B 1
)

exit /B 0

rem Usage: IsFile <path>
:IsFile
@setlocal

call :IsValidPath "%~1"
if ERRORLEVEL 1 (
    %LogError% "File not found: '%~f1'"
    exit /B 1
)

call :IsFilePath "%~1"
if ERRORLEVEL 1 (
    %LogError% "Path does not point to a file: '%~f1'"
    exit /B 1
)

exit /B 0

rem Usage: IsProgram <program>
:IsProgram
@setlocal

where "%~1" > nul 2>&1
if ERRORLEVEL 1 (
    %LogError% "Program not found: '%~1'"
    exit /B 1
)

exit /B 0

rem Usage: MakeDirectory <path>
:MakeDirectory
@setlocal

call :IsValidPath "%~1"
if ERRORLEVEL 1 (
    mkdir "%~f1"
    if ERRORLEVEL 1 ( exit /B 1 )
    exit /B 0
)

call :IsDirectoryPath "%~1"
if ERRORLEVEL 1 (
    %LogError% "Path already points to a file: '%~f1'"
    exit /B 1
)

exit /B 0

rem Usage: ProcessFile <input> <output> [mode]
:ProcessFile
@setlocal

if not "%~1" == "" (
    call :IsFile "%~1"
    if ERRORLEVEL 1 (
        exit /B 2
    )
)

if "%~2" == "" (
    %LogError% "Empty path provided"
    exit /B 2
)

if "%~f1" == "%~f2" (
    %LogError% "Cannot overwrite input: '%~f1'"
    exit /B 2
)

call :MakeDirectory "%~dp2"
if ERRORLEVEL 1 ( exit /B 2 )

call :IsValidPath "%~2"
if ERRORLEVEL 1 (
    exit /B 0
)

call :IsFilePath "%~2"
if ERRORLEVEL 1 (
    %LogError% "Path does not point to a file: '%~f2'"
    exit /B 2
)

if "%~3" == "" (
    %LogInfo% "Output already exist: '%~f2'"
    exit /B 1
)

if "%~3" == "%FsModeKeep%" (
    %LogInfo% "Output already exist: '%~f2'"
    exit /B 1
)

if "%~3" == "%FsModeOverwrite%" (
    call :Delete "%~2"
    if ERRORLEVEL 1 ( exit /B 2 )
    exit /B 0
)

%LogDebug% "Invalid mode: '%~3'"
exit /B 2

rem Usage: Delete <input>
:Delete

call :IsValidPath "%~1"
if ERRORLEVEL 1 ( exit /B )

call :IsFilePath "%~1"
if ERRORLEVEL 1 (
    %LogError% "Path does not point to a file: '%~f1'"
    exit /B
)

del "%~f1" > nul 2>&1
if ERRORLEVEL 1 (
    %LogError% "Unable to delete file: '%~f1'"
    exit /B 1
)

%LogInfo% "File deleted: '%~f1'"
exit /B 0

rem Usage: Copy <input> <output> [mode]
:Copy

%FsProcessFile% "%~1" "%~2" "%~3"
if ERRORLEVEL 1 ( exit /B )

copy /B "%~f1" "%~f2" > nul 2>&1
if ERRORLEVEL 1 ( exit /B 2 )

exit /B 0
