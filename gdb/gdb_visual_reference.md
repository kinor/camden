# GDB Visual Reference - What You'll See

This document shows **actual output** students will see when using GDB.

---

## Starting GDB

```bash
$ gdb ./vulnerable
GNU gdb (Ubuntu 12.1-0ubuntu1~22.04) 12.1
Reading symbols from ./vulnerable...
(gdb) 
```

---

## Setting a Breakpoint

```gdb
(gdb) break check_password
Breakpoint 1 at 0x1189: file vulnerable.c, line 11.
```

---

## Running the Program

```gdb
(gdb) run
Starting program: /home/student/vulnerable 
=== Buffer Overflow Demonstration ===
Buffer size: 8 bytes

Breakpoint 1, check_password () at vulnerable.c:11
11      {
```

---

## Viewing Local Variables (Before Input)

```gdb
(gdb) info locals
buffer = "\000\000\000\000\000\000\000"
authenticated = 0
```

**What this means:**
- `buffer` is uninitialized (null bytes or garbage)
- `authenticated` is 0 (false) ✓

---

## Finding Variable Addresses

```gdb
(gdb) print &buffer
$1 = (char (*)[8]) 0x7fffffffe410

(gdb) print &authenticated
$2 = (int *) 0x7fffffffe418
```

**Key insight:**
```
0x7fffffffe418 - 0x7fffffffe410 = 0x8 = 8 bytes

Buffer is 8 bytes, authenticated is RIGHT AFTER!
```

---

## Memory View (Before Input)

```gdb
(gdb) x/16xb &buffer
0x7fffffffe410: 0x00  0x00  0x00  0x00  0x00  0x00  0x00  0x00
0x7fffffffe418: 0x00  0x00  0x00  0x00  0xf0  0xe4  0xff  0xff
                ↑ buffer (8 bytes) ↑ authenticated (4 bytes)
```

---

## Test 1: Normal Input "hello"

### After Input
```gdb
(gdb) next
Enter password: hello
14          int authenticated = 0;

(gdb) print buffer
$3 = "hello\000\000"

(gdb) print authenticated
$4 = 0
```

### Memory View
```gdb
(gdb) x/16xb &buffer
0x7fffffffe410: 0x68  0x65  0x6c  0x6c  0x6f  0x00  0x00  0x00
                 h     e     l     l     o    \0   (unused)
0x7fffffffe418: 0x00  0x00  0x00  0x00  0xf0  0xe4  0xff  0xff
                ↑ authenticated = 0 (still zero!) ↑
```

**Result:** No overflow! Everything looks good. ✓

---

## Test 2: Overflow with "AAAAAAAABBBB"

### After Input (12 characters)
```gdb
(gdb) run
Starting program: /home/student/vulnerable 

Breakpoint 1, check_password () at vulnerable.c:11

(gdb) next
Enter password: AAAAAAAABBBB

(gdb) print buffer
$5 = "AAAAAAAA"

(gdb) print authenticated
$6 = 1111638594     ← WOW! This changed!
```

### Memory View
```gdb
(gdb) x/16xb &buffer
0x7fffffffe410: 0x41  0x41  0x41  0x41  0x41  0x41  0x41  0x41
                 A     A     A     A     A     A     A     A
0x7fffffffe418: 0x42  0x42  0x42  0x42  0x00  0xe4  0xff  0xff
                 B     B     B     B    ← authenticated corrupted!
```

### As 4-byte Words
```gdb
(gdb) x/4xw &buffer
0x7fffffffe410: 0x41414141  0x41414141  ← buffer (8 A's)
0x7fffffffe418: 0x42424242  0xffffe400  ← authenticated = 0x42424242
```

**Hexadecimal breakdown:**
- 0x42 = ASCII 'B'
- 0x42424242 = "BBBB" = 1,111,638,594 in decimal

**Result:** Buffer overflow! Authenticated variable corrupted! 🚨

### Program Behavior
```gdb
(gdb) continue
Continuing.
✓ Access granted!    ← Access granted WITHOUT correct password!
Program ending normally.
[Inferior 1 (process 1234) exited normally]
```

---

## Test 3: Massive Overflow (32 A's)

### Memory View After Input
```gdb
(gdb) run
Breakpoint 1, check_password () at vulnerable.c:11

(gdb) next
Enter password: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

(gdb) x/40xb &buffer
0x7fffffffe410: 0x41  0x41  0x41  0x41  0x41  0x41  0x41  0x41
0x7fffffffe418: 0x41  0x41  0x41  0x41  0x41  0x41  0x41  0x41
0x7fffffffe420: 0x41  0x41  0x41  0x41  0x41  0x41  0x41  0x41
0x7fffffffe428: 0x41  0x41  0x41  0x41  0x41  0x41  0x41  0x41
0x7fffffffe430: 0x00  0x55  0x55  0x55  0x55  0x55  0x00  0x00
                 ↑ Everything is A's! (0x41) Stack corrupted!
```

### Continue Execution
```gdb
(gdb) continue
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0x00007fff41414141 in ?? ()
```

**What happened?**
- Return address overwritten with A's (0x41)
- CPU tried to jump to 0x41414141
- Invalid address → CRASH!

### View the Crash
```gdb
(gdb) backtrace
#0  0x00007fff41414141 in ?? ()
#1  0x4141414141414141 in ?? ()
#2  0x4141414141414141 in ?? ()
#3  0x0000000000000000 in ?? ()
```

**All stack frames corrupted with A's!** 💥

---

## Memory Layout Diagram

```
Higher Addresses
┌─────────────────────────┐
│  Return Address         │ ← +24: Overwritten by massive overflow
├─────────────────────────┤
│  Saved RBP              │ ← +16: Frame pointer
├─────────────────────────┤
│  Padding (alignment)    │ ← +12: 4 bytes
├─────────────────────────┤
│  authenticated (4 bytes)│ ← +8:  Overwritten by 12-char overflow
├─────────────────────────┤
│  buffer[7]              │ ← +7
│  buffer[6]              │ ← +6
│  buffer[5]              │ ← +5
│  buffer[4]              │ ← +4
│  buffer[3]              │ ← +3
│  buffer[2]              │ ← +2
│  buffer[1]              │ ← +1
│  buffer[0]              │ ← +0:  Buffer starts here
└─────────────────────────┘
Lower Addresses
```

---

## Summary: Three Overflow Scenarios

### Scenario 1: Normal (5 bytes)
```
Input: "hello"
Buffer: [h][e][l][l][o][\0][ ][ ]
authenticated: [0][0][0][0]  ✓ SAFE
```

### Scenario 2: Medium Overflow (12 bytes)
```
Input: "AAAAAAAABBBB"
Buffer: [A][A][A][A][A][A][A][A]
authenticated: [B][B][B][B]  ✗ CORRUPTED
Result: Access granted (wrong!)
```

### Scenario 3: Large Overflow (32 bytes)
```
Input: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
Buffer: [A][A][A][A][A][A][A][A]
authenticated: [A][A][A][A]
padding: [A][A][A][A]
saved rbp: [A][A][A][A][A][A][A][A]
return addr: [A][A][A][A][A][A][A][A]
Result: SEGMENTATION FAULT 💥
```

---

## Understanding the Numbers

### ASCII to Hex Conversion
| Character | Hex | Decimal |
|-----------|-----|---------|
| 'A' | 0x41 | 65 |
| 'B' | 0x42 | 66 |
| 'h' | 0x68 | 104 |
| 'e' | 0x65 | 101 |
| 'l' | 0x6c | 108 |
| 'o' | 0x6f | 111 |

### Why 1,111,638,594?
```
"BBBB" in memory = 0x42424242
0x42424242 in decimal = 1,111,638,594
```

---

## Tips for Reading GDB Output

1. **Addresses always change** - Your addresses will differ from examples
2. **Look for patterns** - Multiple 0x41's = lots of A's
3. **Little endian** - Bytes are backwards (0x41424344 = "DCBA")
4. **NULL terminator** - 0x00 marks end of string
5. **Stack grows down** - Higher addresses are earlier in stack

---

## Common GDB Commands Used in This Lab

```gdb
break check_password     # Set breakpoint
run                      # Start program  
next                     # Execute next line
continue                # Continue execution
info locals             # Show variables
print var               # Show value
print &var              # Show address
x/16xb &var            # Show 16 bytes hex
x/4xw &var             # Show 4 words hex
backtrace              # Show call stack
quit                   # Exit GDB
```

---

## Practice Exercise

Try to answer before looking at GDB:

**If buffer starts at 0x7fffffffe410 and we enter "TESTDATA", what will memory look like?**

<details>
<summary>Click to reveal answer</summary>

```
0x7fffffffe410: 0x54  0x45  0x53  0x54  0x44  0x41  0x54  0x41
                 T     E     S     T     D     A     T     A
0x7fffffffe418: 0x00  0x00  0x00  0x00  ...
                ↑ authenticated unchanged (8 bytes exactly)
```

No overflow! "TESTDATA" is exactly 8 bytes.
</details>

---

**This visual reference should help you understand what you're seeing in GDB!**
