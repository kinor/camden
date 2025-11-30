# GDB Quick Reference - Buffer Overflow Lab

## Getting Started
```bash
# Compile with debug symbols
gcc -g -fno-stack-protector -o vulnerable vulnerable.c

# Start GDB
gdb ./vulnerable
```

## Essential Commands for This Lab

### Setup & Execution
```gdb
break check_password    # Stop at function entry
run                     # Start program
next                    # Execute next line (step over)
continue                # Resume execution
quit                    # Exit GDB
```

### Examining Variables
```gdb
info locals             # Show all local variables
print buffer            # Show buffer contents
print authenticated     # Show authenticated value
print &buffer           # Show buffer's address
print &authenticated    # Show authenticated's address
print &secret_function  # Get function address
```

### Memory Examination
```gdb
x/s &buffer             # View buffer as string
x/8xb &buffer          # View 8 bytes in hex
x/4xw &buffer          # View 4 words (32-bit) in hex
x/20xw $rsp            # View stack (20 words from stack pointer)
x/40xb $rsp            # View 40 bytes from stack pointer
```

### Stack Information
```gdb
info frame              # Show frame information
backtrace              # Show call stack (bt for short)
info registers         # Show all registers
```

## Memory Format Cheatsheet

### Format Specifiers (after /)
- `x` = hexadecimal
- `d` = decimal  
- `s` = string
- `c` = character
- `i` = instruction

### Unit Sizes
- `b` = byte (1 byte)
- `h` = halfword (2 bytes)
- `w` = word (4 bytes)
- `g` = giant (8 bytes)

### Examples
```gdb
x/16xb 0x7fffffffe410  # 16 bytes in hex
x/4xw $rsp             # 4 words from stack pointer
x/s 0x7fffffffe410     # String at address
```

## Typical Debugging Session

```gdb
(gdb) break check_password
Breakpoint 1 at 0x555555555189

(gdb) run
Breakpoint 1, check_password ()

(gdb) print &buffer
$1 = (char (*)[8]) 0x7fffffffe410

(gdb) print &authenticated  
$2 = (int *) 0x7fffffffe418

(gdb) next
Enter password: AAAAAAAABBBB

(gdb) x/16xb &buffer
0x7fffffffe410: 0x41 0x41 0x41 0x41 0x41 0x41 0x41 0x41
0x7fffffffe418: 0x42 0x42 0x42 0x42 0x00 0x00 0x00 0x00

(gdb) print authenticated
$3 = 1111638594
```

## Pro Tips

1. **Tab completion works!** Type part of command and press TAB
2. **Up arrow** recalls previous commands
3. **Just pressing ENTER** repeats last command
4. **Ctrl+L** clears screen
5. **help <command>** shows help for any command

## Address Calculation

```
Buffer at:       0x7fffffffe410
Authenticated:   0x7fffffffe418
Difference:      0x418 - 0x410 = 0x8 = 8 bytes
```

Use Python or calculator for hex math:
```python
python3 -c "print(0x7fffffffe418 - 0x7fffffffe410)"
# Output: 8
```

## Common Issues

**"No symbol table is loaded"**
→ Recompile with `-g` flag

**"Cannot access memory at address"**  
→ Program hasn't run yet, type `run` first

**Addresses look different than examples**
→ Normal! Addresses vary by system

**Program exits before you can examine**
→ Set breakpoint earlier: `break main`
