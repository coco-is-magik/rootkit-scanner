# Rootkit Scanner

This project is a **Rootkit Scanner** written in 64-bit Netwide Assembler (NASM). It is a work in progress (WIP) aimed at detecting rootkits on systems by scanning for known signatures and anomalies at a low level.

## Table of Contents
- [About](#about)
- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [License](#license)

## About
The Rootkit Scanner is a low-level security tool written in assembly language, designed to detect malicious rootkits on a system. By leveraging NASM, the scanner operates with high performance and minimal overhead, making it suitable for systems where resource efficiency is critical.

## Features
- Written in 64-bit Netwide Assembler (NASM)
- Efficient rootkit detection
- Minimalistic and lightweight

## Getting Started
### Prerequisites
- A Linux system with a 64-bit processor
- NASM assembler installed

### Installation
```bash
git clone https://github.com/coco-is-magik/rootkit-scanner.git
cd rootkit-scanner
nasm -f elf64 -o scanner.o scanner.asm
ld -o scanner scanner.o
```

### Usage
```bash
./scanner
```
### Commands
#### Exit
```
>> exit
```
Terminates the program

## License
This project is licensed under the MIT License. See the LICENSE file for more details.
