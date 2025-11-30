# Buffer Overflow Lab - Quick Reference

## Compilation Command

**Simple (works everywhere):**
```bash
gcc -fno-stack-protector -o vulnerable vulnerable.c
```

**With extra flags (Linux/WSL):**
```bash
gcc -fno-stack-protector -z execstack -no-pie -o vulnerable vulnerable.c
```

💡 Warnings about gets() are expected!

## Running the Program
```bash
./vulnerable
```

## Test Inputs to Try

| Test | Input | Expected Result |
|------|-------|-----------------|
| Normal | `hello` | Access denied (normal) |
| Small overflow | `AAAAAAAAAA` (10 A's) | May work or crash |
| Medium overflow | `AAAAAAAAAAAAAAAA` (16 A's) | Likely crashes |
| Large overflow | `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA` (32 A's) | Definitely crashes |

## Python Helper (For Long Strings)
```bash
# Generate long strings easily
python3 -c "print('A'*32)" | ./vulnerable
```

## What's Happening?

```
Memory Layout:
┌─────────────────┐
│ Return Address  │ ← Overflow can reach here
├─────────────────┤
│ authenticated   │ ← Overflow corrupts this
├─────────────────┤
│ buffer[0-7]     │ ← Input starts here (8 bytes only!)
└─────────────────┘
```

## Key Concepts

**Buffer:** Fixed-size memory area for data storage (8 bytes in this program)

**gets():** Dangerous function - reads unlimited input without bounds checking

**Stack Smashing:** Overwriting data on the call stack, corrupting program state

**Segmentation Fault:** Crash caused by accessing invalid memory

## Fix: Use fgets() Instead
```c
fgets(buffer, sizeof(buffer), stdin);  // Safe!
```

## Discussion Questions
1. Why is gets() dangerous?
2. What modern protections exist?
3. How can developers prevent this?
4. What are real-world examples?

## Safety Reminder
⚠️ Educational purposes only! Never exploit systems without permission.
