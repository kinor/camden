# Buffer Overflow Lab - File Guide

## 🎯 Which File Do I Need?

### Just Starting? 📖
**Start here:**
1. **README.md** - Overview of everything
2. **vulnerable.c** - The program to exploit
3. **buffer_overflow_lab.md** - Main instructions
4. **quick_reference.md** - Commands cheat sheet

### Ready to Go? 🚀
**Quick commands:**
```bash
# Compile
gcc -fno-stack-protector -o vulnerable vulnerable.c

# Run
./vulnerable

# Try this input:
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```

### Want to Use GDB? 🔍
**Additional files:**
- **gdb_exercise.md** - Complete GDB tutorial
- **gdb_quick_ref.md** - GDB commands reference
- **gdb_visual_reference.md** - What you'll see in GDB

**Quick GDB start:**
```bash
gcc -g -fno-stack-protector -o vulnerable vulnerable.c
gdb ./vulnerable
```

### Instructor? 👨‍🏫
**Your files:**
- **instructor_guide.md** - Teaching guide with solutions
- **lab_summary.md** - Overview and assessment rubrics
- **demo.sh** - Run this to demo the lab
- **exploit_demo.gdb** - GDB demo script
- **gdb_walkthrough.sh** - Interactive GDB setup

---

## 📂 All Files

| File | Purpose | Who |
|------|---------|-----|
| README.md | Complete overview | Everyone |
| vulnerable.c | The vulnerable program | Students |
| buffer_overflow_lab.md | Main lab instructions | Students |
| quick_reference.md | Command cheat sheet | Students |
| gdb_exercise.md | GDB tutorial (advanced) | Advanced students |
| gdb_quick_ref.md | GDB command reference | Advanced students |
| gdb_visual_reference.md | GDB output examples | Advanced students |
| instructor_guide.md | Teaching guide | Instructors |
| lab_summary.md | Course planning | Instructors |
| demo.sh | Automated demo | Instructors |
| exploit_demo.gdb | GDB demo script | Instructors |
| gdb_walkthrough.sh | GDB setup | Instructors |

---

## 🎓 Recommended Reading Order

### For Students (Basic)
1. README.md (skim the overview)
2. buffer_overflow_lab.md (read completely)
3. quick_reference.md (keep open while working)

### For Students (Advanced)
4. gdb_exercise.md (follow step-by-step)
5. gdb_quick_ref.md (reference while in GDB)
6. gdb_visual_reference.md (when confused about output)

### For Instructors
1. README.md (complete overview)
2. lab_summary.md (course planning)
3. instructor_guide.md (teaching guide)
4. Test demo.sh on your system

---

## 💡 Quick Tips

**If you're confused:** Start with README.md  
**If you want to code:** Use buffer_overflow_lab.md  
**If you need commands:** Check quick_reference.md  
**If using GDB:** Follow gdb_exercise.md  
**If teaching:** Read instructor_guide.md first  

---

## ⚡ One-Minute Start

```bash
# Download all files to a folder, then:
gcc -fno-stack-protector -o vulnerable vulnerable.c
./vulnerable
# Enter: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
# Watch it crash!
```

**Then read buffer_overflow_lab.md to understand what happened.**

---

## 🆘 Help!

**"I don't know where to start"**  
→ Open buffer_overflow_lab.md and follow from the beginning

**"GDB is confusing"**  
→ Check gdb_visual_reference.md to see what output means

**"Program won't crash"**  
→ Try more A's! Use: `python3 -c "print('A'*100)"`

**"I'm teaching this"**  
→ Run demo.sh first to see what happens

---

**Have fun learning about security! 🔒**
