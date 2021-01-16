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
