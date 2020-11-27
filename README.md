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
