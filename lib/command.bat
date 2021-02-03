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

if "%CMD%" == "" (
    set CMD=%~f0
) else (
    exit /B 0
)

%LnkLoad% "format" "log"
if ERRORLEVEL 1 ( exit /B )

rem Values

set CmdFlagOn=true
set CmdFlagOff=false

rem Functions

set CmdSetOptions=call "%CMD%" :SetOptions
set CmdSetPositionalArguments=call "%CMD%" :SetPositionalArguments
set CmdSetExtraArguments=call "%CMD%" :SetExtraArguments
set CmdSetHelpAction=call "%CMD%" :SetHelpAction

set CmdParseArgument=call "%CMD%" :ParseArgument
set CmdParseArguments=call "%CMD%" :ParseArguments

set CmdIsOptionEnabled=call "%CMD%" :IsOptionEnabled

set CmdPrintOptions=call "%CMD%" :PrintOptions

exit /B 0

rem ---------- ---------- ---------- Public ---------- ---------- ----------

rem Usage: SetOptions [flag,value]...
rem Flag format: [variable[:F]/name[:t[rue],f[alse]][/help string]]...
rem Value format: [variable:V/name[:default][/help string]]...
:SetOptions
set CMD_GLOBAL_OPTIONS=%*
call :SetOptionsDefault
exit /B 0

rem Usage: SetPositionalArguments [variable:value]...
:SetPositionalArguments
set CMD_GLOBAL_POSITIONAL_ARGUMENTS=%*
exit /B 0

rem Usage: SetExtraArguments [variable]
:SetExtraArguments
set CMD_GLOBAL_EXTRA_ARGUMENTS=%~1
set CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS=
exit /B 0

rem Usage: SetHelpAction <variable>
:SetHelpAction
set CMD_GLOBAL_HELP_ACTION=%~1
exit /B 0

rem Usage: ParseArgument <argument>
:ParseArgument

call :ParseArg "%~1"
if ERRORLEVEL 1 (
    if not "%CMD_GLOBAL_HELP_ACTION%" == "" (
        set "%CMD_GLOBAL_HELP_ACTION%=%CmdFlagOn%"
    )
    exit /B 1
)

exit /B 0

rem Usage: ParseArguments [argument]...
:ParseArguments

for %%A in (%*) do (
    call :ParseArgument "%%~A"
)

exit /B

rem Usage: IsOptionEnabled [option]...
:IsOptionEnabled

for %%A in (%*) do (
    if "%%~A" == "%CmdFlagOn%" (
        exit /B 0
    )
)

exit /B 1

rem Usage: PrintOptions
:PrintOptions
@setlocal
echo:Options:
call :ForOptions :PrintOption
exit /B

rem ---------- ---------- ---------- Private ---------- ---------- ----------

rem Usage: ForOptions <function> [<option> [value]]
:ForOptions

rem A=B/C/D=variable:type/name:default/help
rem B=E:F=variable:type
rem C=G:H=name:default
rem D=help
rem E=variable
rem F=type
rem G=name
rem H=default
for %%A in (%CMD_GLOBAL_OPTIONS%) do (
    for /F "tokens=1,2,* delims=/" %%B in ("%%~A") do (
        rem echo B=%%B
        rem echo C=%%C
        rem echo D=%%D
        for /F "tokens=1-2 delims=:" %%E in ("%%B") do (
            for /F "tokens=1-2 delims=:" %%G in ("%%C") do (
                rem echo D=%%D
                rem echo E=%%E
                rem echo F=%%F
                rem echo G=%%G
                rem echo H=%%H
                if "%~2" == "" (
                    call %1 "%%E" "%%F" "%%G" "%%H" "%%D"
                ) else (
                    if /I "%~2" == "%%G" (
                        call %1 "%%E" "%%F" "%%G" "%%H" "%~3"
                        exit /B
                    )
                )
            )
        )
    )
)

if not "%~2" == "" (
    %LogError% "Unknown option: '%~2'"
    exit /B 1
)

exit /B 0

rem Usage: SetOptionsDefault
:SetOptionsDefault
call :ForOptions :SetOptionDefault
exit /B

rem Usage: SetOptionDefault <variable> <type> <option> [default]
:SetOptionDefault

if "%~2" == "" (
    call :SetFlagDefault "%~1" "%~3" "%~4"
    exit /B
)
if "%~2" == "F" (
    call :SetFlagDefault "%~1" "%~3" "%~4"
    exit /B
)
if "%~2" == "V" (
    call :SetValueDefault "%~1" "%~4"
    exit /B
)

exit /B 0

rem Usage: SetFlagDefault <variable> <option> [default]
:SetFlagDefault

if "%~3" == "" (
    set "%~1=%CmdFlagOff%"
    exit /B 0
) else (
    if /I "%~3" == "%CmdFlagOn%" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
    if /I "%~3" == "%CmdFlagOff%" (
        set "%~1=%CmdFlagOff%"
        exit /B 0
    )
    if /I "%~3" == "%CmdFlagOn:~0,1%" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
    if /I "%~3" == "%CmdFlagOff:~0,1%" (
        set "%~1=%CmdFlagOff%"
        exit /B 0
    )

    %LogError% "Invalid default value for flag '%~2'"
    exit /B 1
)

exit /B 0

rem Usage: SetValueDefault <variable> [default]
:SetValueDefault
set "%~1=%~2"
exit /B 0

rem Usage: PrintOption <variable> <type> <option> [default] [help]
:PrintOption
@setlocal

if "%~4" == "" (
    %FmtPrint% "    --%~3"
) else (
    %FmtPrint% "    --%~3 (%~4)"
)

if not "%~5" == "" (
    %FmtPrint% "        %~5"
)

echo:

exit /B 0

rem Usage: ParseOption <option> [value]
:ParseOption

if "%~1" == "" (
    %LogError% "Missing option name"
    exit /B 1
)

call :ForOptions :SetOption "%~1" "%~2"
exit /B

rem Usage: SetOption <variable> <type> <option> [default] [value]
:SetOption

if "%~2" == "" (
    call :SetFlag "%~1" "%~3" "%~4" "%~5"
    exit /B
)
if "%~2" == "F" (
    call :SetFlag "%~1" "%~3" "%~4" "%~5"
    exit /B
)
if "%~2" == "V" (
    call :SetValue "%~1" "%~3" "%~5"
    exit /B
)

%LogError% "Invalid option type: '%~2'"
exit /B 1

rem Usage: SetFlag <variable> <option> [default] [value]
:SetFlag

if "%~4" == "" (
    if "%~3" == "" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
    if /I "%~3" == "%CmdFlagOff%" (
        set "%~1=%CmdFlagOff%"
        exit /B 0
    )
    if /I "%~3" == "%CmdFlagOff%" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
) else (
    if /I "%~4" == "%CmdFlagOn%" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
    if /I "%~4" == "%CmdFlagOff%" (
        set "%~1=%CmdFlagOff%"
        exit /B 0
    )
    if /I "%~4" == "%CmdFlagOn:~0,1%" (
        set "%~1=%CmdFlagOn%"
        exit /B 0
    )
    if /I "%~4" == "%CmdFlagOff:~0,1%" (
        set "%~1=%CmdFlagOff%"
        exit /B 0
    )

    %LogError% "Invalid value for flag: '%~2'"
    exit /B 1
)

exit /B 0

rem Usage: SetValue <variable> <option> [value]
:SetValue

if "%~3" == "" (
    %LogError% "Missing value for option: '%~2'"
    exit /B 1
) else (
    set "%~1=%~3"
    exit /B 0
)

exit /B 0

rem Usage: ParseArg <argument>
:ParseArg

set CMD_PRIVATE_ARGUMENT=%~1

if "%CMD_PRIVATE_ARGUMENT:~0,2%" == "--" (
    for /F "tokens=1,* delims=:" %%A in ("%CMD_PRIVATE_ARGUMENT:~2%") do (
        call :ParseOption "%%A" "%%B"
        if ERRORLEVEL 1 ( exit /B )
    )
) else (
    call :ParsePositionalArgument "%CMD_PRIVATE_ARGUMENT%"
    if ERRORLEVEL 1 ( exit /B )
)

exit /B 0

rem Usage: ParsePositionalArgument <argument>
:ParsePositionalArgument

for %%A in (%CMD_GLOBAL_POSITIONAL_ARGUMENTS%) do (
    for /F "tokens=1,* delims=:" %%B in ("%%~A") do (
        if "%%C" == "" (
            set "%%B=%~1"
            exit /B 0
        )
    )
)

if "%CMD_GLOBAL_EXTRA_ARGUMENTS%" == "" (
    %LogError% "Too many arguments passed to command line: '%~1'"
    exit /B 1
) else (
    call :AppendExtraArgument "%~1"
    exit /B 0
)

exit /B 0

rem Usage: AppendExtraArgument <argument>
:AppendExtraArgument

if "%CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS%" == "" (
    set CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS="%~1"
) else (
    set CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS=%CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS% "%~1"
)

set "%CMD_GLOBAL_EXTRA_ARGUMENTS%=%CMD_GLOBAL_PRIVATE_EXTRA_ARGUMENTS%"

exit /B 0
