# Quick Nmap Lab (5 Minutes)
## Network Scanning Basics

---

## Objective
Learn to use Nmap to discover open ports and services on a network.

**Time:** 5 minutes  
**Difficulty:** Beginner  

---

## Setup (30 seconds)

### Install Nmap (if needed)

**Ubuntu/WSL:**
```bash
sudo apt-get update
sudo apt-get install nmap -y
```

**macOS:**
```bash
brew install nmap
```

**Windows:**
Download from https://nmap.org/download.html

---

## Exercise 1: Scan Yourself (1 minute)

Scan your own machine to see what ports are open:

```bash
nmap localhost
```

**Expected output:**
```
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00012s latency).
Not shown: 997 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https

Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds
```

**What you're seeing:**
- Port numbers (22, 80, 443)
- Service names (ssh, http, https)
- Which ports are open and listening

---

## Exercise 2: Detailed Scan (1 minute)

Get more information with version detection:

```bash
nmap -sV localhost
```

**What `-sV` does:** Attempts to determine service versions

**Expected output:**
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu
80/tcp   open  http    Apache httpd 2.4.41
443/tcp  open  https   Apache httpd 2.4.41
```

**What you're seeing:**
- Specific software versions
- More detailed service information

---

## Exercise 3: Scan a Safe Target (2 minutes)

Scan a server designed for testing (scanme.nmap.org):

```bash
nmap scanme.nmap.org
```

**Expected output:**
```
Nmap scan report for scanme.nmap.org (45.33.32.156)
Host is up (0.065s latency).
Not shown: 996 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
9929/tcp  open  nping-echo
31337/tcp open  Elite

Nmap done: 1 IP address (1 host up) scanned in 2.31 seconds
```

---

## Exercise 4: Scan Multiple Ports (30 seconds)

Scan specific ports:

```bash
nmap -p 22,80,443,8080 scanme.nmap.org
```

**What `-p` does:** Specifies which ports to scan

---

## Quick Reference

### Basic Scans
```bash
nmap <target>              # Basic scan
nmap -sV <target>          # Version detection
nmap -p 1-1000 <target>    # Scan ports 1-1000
nmap -F <target>           # Fast scan (100 common ports)
```

### Common Ports to Know
| Port | Service |
|------|---------|
| 22   | SSH (remote login) |
| 80   | HTTP (web) |
| 443  | HTTPS (secure web) |
| 3306 | MySQL (database) |
| 8080 | Alternative HTTP |

---

## Discussion Questions (30 seconds)

1. **Why is port scanning useful?**
   - System administrators: Check which services are exposed
   - Security auditors: Find potential vulnerabilities
   - Attackers: Reconnaissance (first step in attack)

2. **Is port scanning legal?**
   - ✓ Scanning your own systems: Legal
   - ✓ Scanning with permission: Legal
   - ✗ Scanning others without permission: Illegal (unauthorized access)

3. **How can you protect against port scans?**
   - Close unnecessary ports
   - Use firewalls
   - Monitor for scanning attempts

---

## Key Takeaways

✓ Nmap discovers what services are running on a network  
✓ Open ports reveal potential entry points  
✓ Version detection helps identify vulnerable software  
✓ Only scan networks you own or have permission to scan  

---

## ⚠️ Legal Warning

**ONLY scan:**
- ✓ Your own machines
- ✓ localhost / 127.0.0.1
- ✓ scanme.nmap.org (explicitly allows scanning)
- ✓ Networks you have written permission to scan

**NEVER scan:**
- ✗ Your school network (without IT permission)
- ✗ Your employer's network (without authorization)
- ✗ Any external network without permission
- ✗ Government or military networks

**Unauthorized port scanning can be prosecuted under the Computer Fraud and Abuse Act (CFAA).**

---

## Submission

Take a screenshot showing:
1. Your nmap scan of localhost
2. Your nmap scan of scanme.nmap.org
3. Answers to the discussion questions

**Time to complete:** 5 minutes  
**Points:** 5 (participation credit)

---

**Done!** You now know basic network reconnaissance with Nmap.
