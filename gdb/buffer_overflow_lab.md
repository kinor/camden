# Buffer Overflow Lab Activity
## Operating Systems Concepts - Rutgers Camden

---

## Objective
Understand how buffer overflow vulnerabilities work by exploiting a simple C program in a controlled environment.

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

void secret_function() {
    printf("\n🔓 SECRET FUNCTION EXECUTED! 🔓\n");
    printf("This function was NOT supposed to be called!\n");
    printf("The buffer overflow changed the program's execution flow.\n\n");
}

void check_password() {
    char buffer[8];  // Small buffer - only 8 bytes
    int authenticated = 0;
    
    printf("Enter password: ");
    gets(buffer);  // VULNERABLE FUNCTION - no bounds checking!
    
    if (strcmp(buffer, "pass123") == 0) {
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
    printf("Buffer size: 8 bytes\n\n");
    
    check_password();
    
    printf("Program ending normally.\n");
    return 0;
}
```

### Step 2: Compile with Vulnerable Settings
Modern compilers have protections against buffer overflows. We need to disable them for this educational demonstration.

**Simple version (works everywhere):**
```bash
gcc -fno-stack-protector -o vulnerable vulnerable.c
```

**Linux/WSL with extra flags (optional):**
```bash
gcc -fno-stack-protector -z execstack -no-pie -o vulnerable vulnerable.c
```

**What these flags do:**
- `-fno-stack-protector` - Disables stack canaries (main protection we're bypassing)
- `-z execstack` (Linux only) - Makes stack executable  
- `-no-pie` (optional) - Disables position-independent executable

**Note:** You'll see warnings about `gets()` being dangerous - that's expected and part of the lesson!

---

## Experiments

### Experiment 1: Normal Operation
**Try:** Enter a short password
```bash
./vulnerable
```
Enter: `hello`

**Expected result:** "Access denied!" - program works normally

---

### Experiment 2: Overflow the Buffer
**Try:** Enter a long string (more than 8 characters)
```bash
./vulnerable
```
Enter: `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA` (32 A's)

**Expected results:**
- You may see "Access denied!" 
- The program may crash with "Segmentation fault"
- You've overwritten adjacent memory!

**What happened?**
- The buffer is only 8 bytes
- Your input was 32 bytes
- The extra data overflowed into adjacent memory
- This corrupted the stack, potentially overwriting:
  - The `authenticated` variable
  - Return addresses
  - Other stack data

---

### Experiment 3: Try Different Lengths
Test with different input lengths to see what happens:

```bash
./vulnerable    # Try 10 characters
./vulnerable    # Try 20 characters
./vulnerable    # Try 50 characters
```

**Questions to consider:**
1. At what input length does the program crash?
2. Can you corrupt the `authenticated` variable?
3. What other variables might be affected?

---

## Memory Layout Visualization

```
Stack Memory (grows downward):
┌─────────────────────────┐ ← Higher addresses
│  Return Address         │
├─────────────────────────┤
│  Saved Frame Pointer    │
├─────────────────────────┤
│  authenticated (4 bytes)│ ← Can be overwritten!
├─────────────────────────┤
│  buffer[7]              │
│  buffer[6]              │
│  buffer[5]              │
│  buffer[4]              │
│  buffer[3]              │
│  buffer[2]              │
│  buffer[1]              │
│  buffer[0]              │ ← Buffer starts here (8 bytes)
└─────────────────────────┘ ← Lower addresses
```

When you enter more than 8 characters, the overflow writes into `authenticated` and beyond!

---

## Advanced Challenge (Optional)

**Can you make the program call `secret_function()`?**

This requires overwriting the return address on the stack to point to `secret_function()`. This is more complex and requires:
1. Finding the address of `secret_function()`
2. Calculating the offset to the return address
3. Crafting an exploit payload

---

## GDB Debugging Exercise (Advanced/Extra Credit)

Want to **see** the buffer overflow happening in memory? Use the GDB debugger!

**See separate handout:** `gdb_exercise.md`

In this advanced exercise, you'll:
- Use GDB to set breakpoints and examine memory
- Watch variables get overwritten in real-time
- Calculate exact offsets for exploitation
- Visualize the stack layout
- See exactly where the crash occurs

**Quick start:**
```bash
# Compile with debug symbols
gcc -g -fno-stack-protector -o vulnerable vulnerable.c

# Start GDB
gdb ./vulnerable

# Follow the gdb_exercise.md instructions
```

This is **highly recommended** for understanding what's really happening!

---

## Discussion Questions

1. **Why is `gets()` dangerous?**
   - It doesn't check the size of input
   - No way to limit how much data is read
   - Deprecated in modern C standards

2. **What should be used instead?**
   - `fgets()` - allows you to specify maximum length
   - `scanf()` with field width specifier
   - Modern safe string functions

3. **Real-world implications:**
   - Buffer overflows have caused major security breaches
   - Examples: Morris Worm (1988), Code Red (2001), Heartbleed (2014)
   - Still a common vulnerability in legacy code

4. **Modern protections:**
   - Stack canaries (detect corruption before damage)
   - Address Space Layout Randomization (ASLR)
   - Non-executable stack (NX bit)
   - Compiler warnings and safe functions

---

## Safe Version

Here's how to fix the vulnerability:

```c
void check_password_safe() {
    char buffer[8];
    int authenticated = 0;
    
    printf("Enter password: ");
    fgets(buffer, sizeof(buffer), stdin);  // SAFE - limits input
    
    // Remove newline if present
    buffer[strcspn(buffer, "\n")] = 0;
    
    if (strcmp(buffer, "pass123") == 0) {
        authenticated = 1;
    }
    
    if (authenticated) {
        printf("✓ Access granted!\n");
    } else {
        printf("✗ Access denied!\n");
    }
}
```

---

## ⚠️ Important Safety Notes

1. **ONLY for educational purposes** - Never exploit systems you don't own
2. **WSL/VM environment** - Keep experiments in controlled environments
3. **Ethical responsibility** - Understanding vulnerabilities helps build secure systems
4. **Legal implications** - Unauthorized exploitation is illegal

---

## What to Submit

1. Screenshot showing the program crashing with a long input
2. Answers to the discussion questions
3. (Optional) Description of any interesting behaviors you observed

---

## Additional Resources

- OWASP Buffer Overflow Guide
- CWE-120: Buffer Copy without Checking Size of Input
- "Smashing The Stack For Fun And Profit" (classic paper)
