#!/bin/bash
# Buffer Overflow Demonstration Script
# Run this to see all three scenarios

echo "================================"
echo "COMPILING THE VULNERABLE PROGRAM"
echo "================================"
gcc -fno-stack-protector -o vulnerable vulnerable.c
echo "✓ Compiled successfully"
echo ""

echo "================================"
echo "TEST 1: NORMAL OPERATION"
echo "================================"
echo "Input: 'hello'"
echo "hello" | ./vulnerable
echo ""

echo "================================"
echo "TEST 2: CORRECT PASSWORD"
echo "================================"
echo "Input: 'pass123'"
echo "pass123" | ./vulnerable
echo ""

echo "================================"
echo "TEST 3: BUFFER OVERFLOW"
echo "================================"
echo "Input: 32 A's (way over 8-byte buffer)"
python3 -c "print('A'*32)" | ./vulnerable
if [ $? -eq 139 ]; then
    echo "✓ Segmentation fault detected! Buffer overflow successful."
else
    echo "Program exited with code: $?"
fi
echo ""

echo "================================"
echo "TEST 4: MEDIUM OVERFLOW"
echo "================================"
echo "Input: 16 A's"
python3 -c "print('A'*16)" | ./vulnerable
echo "Exit code: $?"
echo ""

echo "================================"
echo "DEMO COMPLETE"
echo "================================"
echo "Students can now experiment with different input lengths!"
