#!/bin/bash
# GDB Step-by-Step Demonstration
# This script guides you through using GDB to examine the buffer overflow

echo "=========================================="
echo "GDB BUFFER OVERFLOW WALKTHROUGH"
echo "=========================================="
echo ""

# Check if vulnerable program exists and is compiled with debug symbols
if [ ! -f "vulnerable" ]; then
    echo "Compiling vulnerable.c with debug symbols..."
    gcc -g -fno-stack-protector -o vulnerable vulnerable.c
    echo "✓ Compiled successfully"
    echo ""
fi

# Create input files for testing
echo "hello" > input1.txt
echo "AAAAAAAABBBB" > input2.txt
python3 -c "print('A'*32)" > input3.txt
echo "✓ Created test input files"
echo ""

echo "=========================================="
echo "DEMONSTRATION OVERVIEW"
echo "=========================================="
echo "We'll run 3 tests:"
echo "  1. Normal input (5 chars) - No overflow"
echo "  2. Medium overflow (12 chars) - Corrupts variable"
echo "  3. Large overflow (32 chars) - Crashes program"
echo ""
echo "For each test, you'll:"
echo "  - Set a breakpoint"
echo "  - Run with input"
echo "  - Examine memory"
echo "  - See the overflow"
echo ""

read -p "Press Enter to start GDB with guided commands..."
echo ""

# Create a GDB command file for guided session
cat > guided_session.gdb << 'EOF'
# Guided GDB Session

echo \n===========================================\n
echo TEST 1: NORMAL INPUT - NO OVERFLOW\n
echo ===========================================\n

echo Setting breakpoint...\n
break check_password

echo Starting program with input 'hello'...\n
run < input1.txt

echo \n>> Type these commands to examine memory:\n
echo >> info locals\n
echo >> print &buffer\n
echo >> print &authenticated\n
echo >> x/16xb &buffer\n
echo \n>> Press 'c' (continue) when ready for next test\n\n
EOF

cat > test1.gdb << 'EOF'
break check_password
run < input1.txt
info locals
print &buffer
print &authenticated
x/16xb &buffer
echo \n[Normal input - buffer contains "hello", authenticated = 0]\n\n
continue
EOF

cat > test2.gdb << 'EOF'
break check_password
run < input2.txt
next
info locals
print buffer
print authenticated
x/16xb &buffer
echo \n[OVERFLOW! buffer has 8 A's, authenticated overwritten with B's (0x42424242)]\n\n
continue
EOF

cat > test3.gdb << 'EOF'
break check_password
run < input3.txt
next
x/40xb &buffer
echo \n[MASSIVE OVERFLOW! Entire stack corrupted with A's (0x41)]\n
echo [Continuing will cause segmentation fault...]\n\n
continue
backtrace
echo \n[Return address was overwritten - program tried to jump to 0x4141414141414141]\n\n
quit
EOF

echo "=========================================="
echo "MANUAL GDB SESSION"
echo "=========================================="
echo "Starting GDB. Follow these steps:"
echo ""
echo "STEP 1: Set breakpoint and run"
echo "  (gdb) break check_password"
echo "  (gdb) run < input1.txt"
echo ""
echo "STEP 2: Examine variables"
echo "  (gdb) info locals"
echo "  (gdb) print &buffer"
echo "  (gdb) print &authenticated"
echo ""
echo "STEP 3: Look at memory"
echo "  (gdb) x/16xb &buffer"
echo ""
echo "STEP 4: Continue and try again"
echo "  (gdb) continue"
echo "  (gdb) run < input2.txt"
echo ""
read -p "Press Enter to launch GDB..."
echo ""

gdb ./vulnerable

echo ""
echo "=========================================="
echo "AUTOMATED DEMOS AVAILABLE"
echo "=========================================="
echo "Run these for automated demonstrations:"
echo ""
echo "Test 1 (Normal):"
echo "  gdb -batch -x test1.gdb ./vulnerable"
echo ""
echo "Test 2 (Overflow authenticated):"
echo "  gdb -batch -x test2.gdb ./vulnerable"
echo ""
echo "Test 3 (Crash):"
echo "  gdb -batch -x test3.gdb ./vulnerable"
echo ""
echo "All tests at once:"
echo "  gdb -batch -x test1.gdb ./vulnerable && gdb -batch -x test2.gdb ./vulnerable && gdb -batch -x test3.gdb ./vulnerable"
echo ""
