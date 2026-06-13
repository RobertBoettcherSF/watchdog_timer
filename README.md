# Watchdog Timer – Safety-critical heartbeat monitor

A **safety-critical watchdog timer** implementation in **Ada/SPARK** for embedded and real-time systems. This package ensures that a system or process is functioning correctly by requiring periodic "kicks" (resets). If the watchdog is not kicked within a configured timeout period, it triggers a safety action (e.g., system reset, logging, or shutdown).

## Features

- **Configurable Timeout**: Set the maximum allowed time between kicks.
- **Custom Safety Action**: Define a procedure to execute on timeout (e.g., reset the system).
- **State Management**: Track the watchdog state (`Armed`, `Triggered`, `Disabled`).
- **SPARK-Compatible**: Designed for formal verification with **GNATprove** (SPARK Ada).
- **Real-Time Support**: Uses `Ada.Real_Time` for precise timing.

## Files

| File | Description |
|------|-------------|
| [`watchdog.ads`](watchdog.ads) | Ada specification (interface) |
| [`watchdog.adb`](watchdog.adb) | Ada implementation (body) |
| [`watchdog.gpr`](watchdog.gpr) | GNAT Project file for compilation |

## Usage

### 1. Define a Safety Action

```ada
with Watchdog;

procedure My_Safety_Action is
begin
   --  Example: Log an error or reset the system
   Put_Line("Watchdog timeout! Taking safety action...");
end My_Safety_Action;
```

### 2. Initialize the Watchdog

```ada
with Watchdog;
with Ada.Real_Time; use Ada.Real_Time;

declare
   Wd : Watchdog.Watchdog_Instance;
   Config : Watchdog.Watchdog_Configuration :=
      (Timeout => Milliseconds(1000),  --  1 second timeout
       Action  => My_Safety_Action'Access);
begin
   Watchdog.Initialize(Wd, Config);
end;
```

### 3. Kick the Watchdog (Reset Timer)

```ada
Watchdog.Kick(Wd);  --  Call this periodically to prevent timeout
```

### 4. Check Timeout and Trigger Safety Action

```ada
Watchdog.Check_Timeout(Wd);  --  Check if timeout occurred and trigger action
```

### 5. Query Watchdog State

```ada
if Watchdog.Has_Triggered(Wd) then
   Put_Line("Watchdog has triggered!");
end if;

case Watchdog.Get_State(Wd) is
   when Watchdog.Armed =>
      Put_Line("Watchdog is armed.");
   when Watchdog.Triggered =>
      Put_Line("Watchdog has triggered!");
   when Watchdog.Disabled =>
      Put_Line("Watchdog is disabled.");
end case;
```

### 6. Enable/Disable the Watchdog

```ada
Watchdog.Disable(Wd);  --  Disable for maintenance
Watchdog.Enable(Wd);   --  Re-enable after maintenance
```

### 7. Get Remaining Time

```ada
declare
   Remaining : Time_Span := Watchdog.Time_Remaining(Wd);
begin
   Put_Line("Time remaining: " & Remaining'Image);
end;
```

## Compilation

### Using GPRbuild

```bash
# Compile the project
gprbuild -P watchdog.gpr

# Compile with SPARK verification (GNATprove)
gnatprove -P watchdog.gpr --level=4 --timeout=0 --no-inlining --report=all
```

### Build Scenarios

The `watchdog.gpr` file includes compiler flags for safety-critical code:
- `-gnatw.e`: Warn on unreachable code
- `-gnatw.m`: Warn on modified but unused variables
- `-gnatw.u`: Warn on unused variables
- `-gnatw.x`: Warn on unused exceptions
- `-O2`: Optimization level 2

## API Reference

### Types

| Type | Description |
|------|-------------|
| `Watchdog_Configuration` | Configuration record with `Timeout` (Time_Span) and `Action` (access procedure). |
| `Watchdog_State` | Enumeration: `Armed`, `Triggered`, `Disabled`. |
| `Watchdog_Instance` | Limited private type representing a watchdog instance. |

### Procedures

| Procedure | Description |
|-----------|-------------|
| `Initialize(Instance, Config)` | Initialize the watchdog with a configuration. |
| `Kick(Instance)` | Reset the watchdog timer. |
| `Disable(Instance)` | Disable the watchdog. |
| `Enable(Instance)` | Enable the watchdog. |
| `Check_Timeout(Instance)` | Check if timeout occurred and trigger the safety action. |

### Functions

| Function | Description |
|----------|-------------|
| `Has_Triggered(Instance)` | Returns `True` if the watchdog has triggered. |
| `Get_State(Instance)` | Returns the current state (`Armed`, `Triggered`, `Disabled`). |
| `Time_Remaining(Instance)` | Returns the remaining time until timeout. |

## License

MIT License – Copyright (c) 2026 Sternenfisch

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss the proposed changes.
