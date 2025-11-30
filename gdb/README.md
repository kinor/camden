# Buffer Overflow Lab - Complete Materials Package

**Course:** Operating Systems Concepts  
**Institution:** Rutgers-Camden  
**Topic:** Program Threats - Buffer Overflow Vulnerabilities  

---

## 📦 Package Contents

This complete package includes everything needed to teach buffer overflow vulnerabilities with hands-on exercises and GDB debugging.

### 🎓 For Students

#### Core Lab (Required)
1. **vulnerable.c** - The vulnerable C program to exploit
2. **buffer_overflow_lab.md** - Main lab instructions and exercises
3. **quick_reference.md** - One-page command reference

#### GDB Exercise (Advanced/Optional)
4. **gdb_exercise.md** - Complete 7-part GDB tutorial
5. **gdb_quick_ref.md** - GDB commands quick reference
6. **gdb_visual_reference.md** - Visual guide showing actual GDB output

### 👨‍🏫 For Instructors

7. **instructor_guide.md** - Complete teaching guide with solutions
8. **lab_summary.md** - Overview, learning objectives, assessment rubrics
9. **demo.sh** - Automated demonstration script (bash)
10. **exploit_demo.gdb** - GDB script with prompts
11. **gdb_walkthrough.sh** - Interactive GDB setup guide

---

## 🚀 Quick Start

### For Instructors - 5 Minute Demo
```bash
# Download all files, then:
chmod +x demo.sh
./demo.sh
```

Shows three scenarios: normal input, variable corruption, program crash.

### For Students - Basic Lab
```bash
# Compile the program
gcc -fno-stack-protector -o vulnerable vulnerable.c

# Run it
./vulnerable

# Try normal input
# Then try: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```

### For Advanced Students - GDB Exercise
```bash
# Compile with debug symbols
gcc -g -fno-stack-protector -o vulnerable vulnerable.c

# Start GDB
gdb ./vulnerable

# Follow gdb_exercise.md instructions
```

---

## 📋 Lab Overview

### What Students Will Learn

**Basic Level (30-45 min):**
- How buffer overflows corrupt memory
- Why gets() is dangerous
- Stack memory layout
- Segmentation faults

**Advanced Level (45-60 min):**
- Using GDB to examine memory
- Variable addresses and offsets
- Stack frame structure
- Precise exploitation techniques

### Three Key Experiments

1. **Normal Input (5 chars)** → No overflow, program works
2. **Medium Overflow (12 chars)** → Corrupts `authenticated` variable
3. **Large Overflow (32 chars)** → Crashes with segfault

---

## 📚 File Descriptions

### Student Materials

#### vulnerable.c
The vulnerable C program containing:
- `check_password()` function with 8-byte buffer
- `gets()` call (no bounds checking)
- `authenticated` variable adjacent to buffer
- `secret_function()` for advanced challenges

#### buffer_overflow_lab.md
Complete student handout including:
- Setup instructions
- Background on buffer overflows
- Three experiments to run
- Memory layout visualization
- Discussion questions
- Safe coding examples

#### quick_reference.md
One-page cheat sheet with:
- Compilation commands
- Test inputs table
- Memory diagram
- Key concepts
- Common commands

#### gdb_exercise.md (Advanced)
7-part comprehensive tutorial:
1. Understanding stack layout
2. Examining memory addresses
3. Normal input (no overflow)
4. Overwriting authenticated variable
5. Massive overflow (corrupting return address)
6. Advanced offset calculations
7. Challenge: calling secret_function()

#### gdb_quick_ref.md
Quick reference card with:
- Essential GDB commands
- Memory format specifiers
- Typical debugging session
- Pro tips and tricks

#### gdb_visual_reference.md
Shows actual GDB output for:
- Setting breakpoints
- Viewing variables
- Memory examination
- All three overflow scenarios
- Memory layout diagrams

### Instructor Materials

#### instructor_guide.md
Complete teaching guide with:
- Quick setup instructions
- What students should observe
- Common questions and answers
- Advanced extensions
- Assessment rubric (70% to 110%)
- Troubleshooting tips
- Real-world examples

#### lab_summary.md
Comprehensive overview including:
- Package contents
- Lab structure (basic vs advanced)
- Quick start options
- How to assign the lab
- Learning objectives mapping
- Teaching tips
- Session plans (50 min classes)
- Quiz/exam questions
- Next steps and follow-up topics

#### demo.sh
Automated bash script demonstrating:
- Compilation
- Normal operation
- Correct password test
- Buffer overflow crash
- Medium overflow effect

#### exploit_demo.gdb
GDB script that:
- Sets up breakpoints
- Provides helpful prompts
- Guides through three test scenarios
- Shows key commands to try

#### gdb_walkthrough.sh
Interactive bash script that:
- Compiles with debug symbols
- Creates test input files
- Launches GDB with guidance
- Provides automated test scripts

---

## 🎯 Learning Objectives

By completing this lab, students will be able to:

### Knowledge
- Explain how buffer overflows work
- Identify vulnerable code patterns
- Describe stack memory layout
- Understand modern security protections

### Skills
- Compile programs with security features disabled
- Use GDB to examine memory
- Calculate memory offsets
- Recognize buffer overflow vulnerabilities

### Application
- Write secure code using safe functions
- Audit code for buffer overflow bugs
- Understand real-world exploit techniques
- Appreciate modern OS protections

---

## 🏆 Assignment Options

### Basic Assignment (70% difficulty, 30-45 minutes)
**Files needed:** vulnerable.c, buffer_overflow_lab.md, quick_reference.md

**Deliverables:**
- Screenshot of segmentation fault
- Answers to discussion questions
- Explanation of why gets() is dangerous

### Advanced Assignment (100% difficulty, 75-90 minutes)
**Add:** gdb_exercise.md, gdb_quick_ref.md

**Deliverables:**
- Complete basic assignment
- GDB session showing memory corruption
- Calculate exact offsets
- Submit GDB command log

### Expert Assignment (110% difficulty, 2-3 hours)
**Deliverables:**
- Complete advanced assignment
- Successfully call secret_function()
- Explain ASLR and stack canaries
- Research and present a real-world buffer overflow CVE

---

## 🔧 Technical Requirements

### Software
- GCC compiler
- GDB debugger
- Python 3 (for generating test strings)
- Bash shell

### Operating Systems
- **Primary:** WSL (Windows Subsystem for Linux) - Ubuntu recommended
- **Alternative:** Native Linux, macOS (with slight modifications)

### Compilation Flags
```bash
# Basic (works everywhere)
gcc -fno-stack-protector -o vulnerable vulnerable.c

# With additional protections disabled (Linux/WSL)
gcc -fno-stack-protector -z execstack -no-pie -o vulnerable vulnerable.c

# With debug symbols (for GDB)
gcc -g -fno-stack-protector -o vulnerable vulnerable.c
```

---

## 📊 Assessment Rubric Summary

| Component | Points | Description |
|-----------|--------|-------------|
| Compilation | 10 | Successfully compiles program |
| Basic Exploitation | 30 | Demonstrates overflow, screenshots |
| Analysis | 30 | Discussion questions, understanding |
| GDB Exercise | 20 | Memory examination (advanced) |
| Expert Challenge | 10 | Call secret_function() (extra credit) |
| **Total** | **100** | (110 with extra credit) |

---

## ⚠️ Safety and Ethics

This lab teaches offensive security techniques for **defensive purposes only**.

**Emphasized to students:**
- ✅ Understanding vulnerabilities helps build secure systems
- ✅ Knowledge used for defense and responsible disclosure
- ✅ Legal and ethical considerations discussed
- ❌ Never exploit systems without permission
- ❌ Unauthorized access is illegal (CFAA)
- ❌ Academic integrity violations will be enforced

---

## 🎓 Pedagogical Approach

### Constructivist Learning
Students learn by **doing** - they actively exploit the vulnerability rather than just reading about it.

### Scaffolded Difficulty
- Start with simple observation (program runs)
- Progress to causing crashes
- Advance to precise memory manipulation
- Expert level: controlled execution hijacking

### Visual Learning
- Memory diagrams throughout
- Actual GDB output examples
- Stack layout visualizations
- ASCII/Hex conversion tables

### Connection to Real World
- Morris Worm (1988)
- Code Red (2001)
- Heartbleed (2014)
- Modern CVEs and bug bounties

---

## 🔗 Additional Resources

### Recommended Reading
- "Smashing The Stack For Fun And Profit" - Aleph One (1996)
- OWASP Buffer Overflow Guide
- CWE-120: Buffer Copy without Checking Size

### Video Resources
- LiveOverflow YouTube channel
- Computerphile buffer overflow videos

### Practice Platforms
- exploit.education
- picoCTF
- Hack The Box

---

## 🎬 Suggested Timeline

### Week 1: Preparation
- Review all materials
- Test on your system
- Prepare demos
- Set up lab environment

### Week 2: Lecture
- Chapter 16 coverage
- Buffer overflow theory
- Live demonstration
- Ethics discussion

### Week 3: Lab Session
- Students work through basic lab
- Help with compilation/debugging
- Monitor progress
- Answer questions

### Week 4: Advanced (Optional)
- GDB exercise introduced
- Advanced students work independently
- Regular students complete reports

---

## 📝 Modification Ideas

### Make it Easier
- Pre-compile the binary
- Provide more hints
- Create video walkthroughs
- Allow pair programming

### Make it Harder
- Remove some hints
- Require calling secret_function()
- Add ASLR bypass requirement
- Ask for written exploit code

### Adapt for Different Courses
- **Intro to Programming:** Just demonstrate, don't require exploitation
- **Operating Systems:** Full lab as presented
- **Security Course:** Add ROP chains, shellcode injection
- **Systems Programming:** Focus on safe alternatives (fgets, etc.)

---

## 🆘 Support

### Common Issues

**"Program won't crash"**
- Try longer input
- Verify compilation flags
- Check system protections

**"Can't install GDB"**
- WSL: `sudo apt-get install gdb`
- Mac: `brew install gdb`

**"Addresses different than examples"**
- Normal! ASLR changes addresses
- Use your actual addresses

### Getting Help
1. Check instructor_guide.md troubleshooting
2. Review gdb_quick_ref.md
3. Test on instructor machine first
4. Have backup demonstrations ready

---

## ✅ Pre-Class Checklist

Before distributing to students:

- [ ] Tested all files on your system
- [ ] Verified GDB is available
- [ ] Reviewed ethical considerations
- [ ] Prepared demonstration
- [ ] Printed quick reference cards
- [ ] Set up projector for live demo
- [ ] Ready to answer security ethics questions
- [ ] Know where to direct advanced students
- [ ] Have backup plans if technology fails

---

## 📧 File Distribution

### Email to Students (Basic Lab)
Attach:
- vulnerable.c
- buffer_overflow_lab.md
- quick_reference.md

### Email to Advanced Students
Add:
- gdb_exercise.md
- gdb_quick_ref.md
- gdb_visual_reference.md

### Keep for Yourself
- instructor_guide.md
- lab_summary.md
- All demo scripts

---

## 🎉 Success Indicators

Students have succeeded when they can:
- ✓ Explain buffer overflow in their own words
- ✓ Demonstrate the vulnerability
- ✓ Recognize dangerous code patterns
- ✓ Use GDB for memory analysis (advanced)
- ✓ Discuss modern protections
- ✓ Connect to real-world security

---

## 📈 Future Enhancements

Ideas for next iteration:
- Video demonstrations
- Online auto-grader
- CTF-style challenges
- Automated testing framework
- Docker container for consistent environment

---

## 📄 License and Attribution

These materials are designed for educational use in Operating Systems courses.

**Usage:**
- ✅ Use in your classes
- ✅ Modify for your needs
- ✅ Share with colleagues
- ✅ Adapt to your curriculum

**Credit:**
If sharing externally, please attribute to:
- Course: Operating Systems Concepts
- Institution: Rutgers-Camden

---

## 🎓 About This Lab

This lab provides a safe, controlled environment for students to:
1. Experience buffer overflow vulnerabilities firsthand
2. Understand low-level memory corruption
3. Appreciate modern security protections
4. Develop secure coding practices

By understanding how attacks work, students become better defenders and write more secure code.

**"Know thy enemy."** - Sun Tzu

---

**Version:** 1.0  
**Last Updated:** 2024  
**Tested On:** Ubuntu 22.04, WSL2, macOS  

---

For questions or improvements, update the materials and redistribute to colleagues.

**Good luck teaching this eye-opening lab!** 🎓🔒
