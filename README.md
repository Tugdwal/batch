# batch

Windows Batch linker and utility libraries

## Linker

### Initialization

```bat
call "lib\linker.bat" :Init
```

### Load

Load a library. If a library fails to load, it returns immediately and errorlevel is unchanged.

```bat
%LnkLoad% "log"
if ERRORLEVEL 1 ( exit /B )
```

## Format

### Loading

```bat
%LnkLoad% "format"
```

### Print

May be used instead of the builtin `echo` command inside blocks to avoid syntax errors when writing parenthesis.

```bat
%FmtPrint% "Message"
```

## Logging

### Loading

```bat
%LnkLoad% "log"
```

### Error

```bat
%LogError% "Message"
```

### Info

```bat
%LogInfo% "Message"
```

## Timer

### Loading

```bat
%LnkLoad% "timer"
```

### Start

Start or restart the timer.

```bat
%TimerStart%
```

### End

Stop the timer.

```bat
%TimerEnd%
```

### Diff

Show the elapsed time.

```bat
%TimerDiff%
```

## Filesystem

### Loading

```bat
%LnkLoad% "filesystem"
```

### IsValidPath

Returns with errorlevel 1 if `path` does not point to an existing file or directory.

```bat
%FsIsValidPath% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsValid

Same as `IsValidPath` but also reports the error.

```bat
%FsIsValid% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsDirectoryPath

Returns with errorlevel 1 if `path` does not point to an existing directory.

```bat
%FsIsDirectoryPath% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsDirectory

Same as `IsDirectoryPath` but also reports the error.

```bat
%FsIsDirectory% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsFilePath

Returns with errorlevel 1 if `path` does not point to an existing file.

```bat
%FsIsFilePath% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsFile

Same as `IsFilePath` but also reports the error.

```bat
%FsIsFile% "path"
if ERRORLEVEL 1 ( exit /B )
```

### IsProgram

Returns with errorlevel 1 if `program` is not found.

```bat
%FsIsProgram% "program"
if ERRORLEVEL 1 ( exit /B )
```

### MakeDirectory

Returns with errorlevel 1 if `path` cannot be created and reports an error if it points to an existing file.

```bat
%FsMakeDirectory% "path"
if ERRORLEVEL 1 ( exit /B )
```

### ProcessFile

* Returns with errorlevel 2 if `input` is not empty and does not point to an existing file.
* Returns with errorlevel 2 if `input` and `output` are equal.
* Returns with errorlevel 2 if `output` is empty.
* Returns with errorlevel 2 if `output` points to an existing directory.
* Returns with errorlevel 2 if the path to `output` cannot be created.

```bat
%FsProcessFile% "input" "output"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

This function supports multiple output processing modes.

* `Default` mode / `Keep` mode : Returns with errorlevel 1 if `output` already exists.
* `Overwrite` mode : Returns with errorlevel 0 if `output` already exists and deletes it. Returns with errorlevel 2 if deletion fails.

```bat
%FsProcessFile% "input" "output" %FsModeKeep%
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

```bat
%FsProcessFile% "input" "output" %FsModeOverwrite%
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

### Delete

* Returns with errorlevel 1 if `input` does not exist or does not point to a file.
* Returns with errorlevel 1 if `input` cannot be deleted.

```bat
%FsDelete% "input"
if ERRORLEVEL 1 ( exit /B )
```

### Copy

* Returns with the same error level as `ProcessFile` if an error occurs.
* Returns with errorlevel 2 if `input` cannot be copied.

```bat
%FsCopy% "input" "output"
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

This function supports the same output processing modes as `ProcessFile`.

```bat
%FsCopy% "input" "output" %FsModeKeep%
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

```bat
%FsCopy% "input" "output" %FsModeOverwrite%
if ERRORLEVEL 2 ( exit /B 1 )
if ERRORLEVEL 1 ( exit /B 0 )
```

## Command parser

### Loading

```bat
%LnkLoad% "command"
```
