# Connecting to Your PYNQ Board

This guide explains how to connect to your assigned PYNQ board, copy files to and from the board, and compile C/C++ programs directly on the board.

Each student or team has a designated board named:

```text
pynqXX
```

Replace `XX` with your assigned board number.

For example:

```text
pynq01
pynq02
pynq15
```

The default login credentials are:

```text
Username: xilinx
Password: xilinx
```

---

## 1. Connect to the PYNQ Board Using SSH

Open a terminal on your computer.

Use the following command:

```bash
ssh xilinx@pynqXX
```

Replace `pynqXX` with your assigned board name.

Example:

```bash
ssh xilinx@pynq05
```

When asked for the password, type:

```text
xilinx
```

The password will not be displayed while typing. This is normal.

After a successful login, you should see a terminal prompt similar to:

```bash
xilinx@pynqXX:~$
```

You are now connected to the PYNQ board.

---

## 2. First SSH Connection Warning

The first time you connect, you may see a message like this:

```text
The authenticity of host 'pynqXX' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Type:

```text
yes
```

Then press `Enter`.

After that, enter the password:

```text
xilinx
```

---

## 3. Disconnect from the PYNQ Board

To close the SSH session, run:

```bash
exit
```

or press:

```text
Ctrl + D
```

---

## 4. Copy Files from Your Computer to the PYNQ Board

Use `scp` from your computer terminal, not from inside the SSH session.

The general command is:

```bash
scp local_file xilinx@pynqXX:/home/xilinx/
```

Example:

```bash
scp main.cpp xilinx@pynq05:/home/xilinx/
```

This copies `main.cpp` from your computer to the home directory of the `xilinx` user on `pynq05`.

To copy a file into a specific folder:

```bash
scp main.cpp xilinx@pynq05:/home/xilinx/my_project/
```

---

## 5. Copy a Directory to the PYNQ Board

To copy an entire directory, use `scp -r`.

Example:

```bash
scp -r my_project xilinx@pynq05:/home/xilinx/
```

The `-r` option means recursive copy.

---

## 6. Copy Files from the PYNQ Board to Your Computer

Use this command from your computer terminal:

```bash
scp xilinx@pynqXX:/home/xilinx/file_name .
```

Example:

```bash
scp xilinx@pynq05:/home/xilinx/result.txt .
```

The final `.` means the current directory on your computer.

To copy an entire directory from the board:

```bash
scp -r xilinx@pynq05:/home/xilinx/my_project .
```

---

## 7. Recommended Workflow

A simple workflow is:

1. Write your code on your computer.
2. Copy the code to the PYNQ board using `scp`.
3. Connect to the board using `ssh`.
4. Compile and run the code on the board.

Example:

```bash
scp main.cpp xilinx@pynq05:/home/xilinx/
ssh xilinx@pynq05
g++ main.cpp -o main
./main
```

---

## 8. Compile C Code

For C programs, use `gcc`.

Example source file:

```c
#include <stdio.h>

int main() {
    printf("Hello from PYNQ!\n");
    return 0;
}
```

Save it as:

```text
main.c
```

Compile it with:

```bash
gcc main.c -o main
```

Run it with:

```bash
./main
```

Expected output:

```text
Hello from PYNQ!
```

---

## 9. Compile C++ Code

For C++ programs, use `g++`.

Example source file:

```cpp
#include <iostream>

int main() {
    std::cout << "Hello from PYNQ!" << std::endl;
    return 0;
}
```

Save it as:

```text
main.cpp
```

Compile it with:

```bash
g++ main.cpp -o main
```

Run it with:

```bash
./main
```

Expected output:

```text
Hello from PYNQ!
```

---

## 10. Compile with Warnings Enabled

It is recommended to compile with warnings enabled.

For C:

```bash
gcc -Wall -Wextra main.c -o main
```

For C++:

```bash
g++ -Wall -Wextra main.cpp -o main
```

Warnings help you detect possible mistakes in your code.

---

## 11. Compile Multiple C Files

Suppose you have:

```text
main.c
utils.c
utils.h
```

Compile with:

```bash
gcc main.c utils.c -o main
```

Run with:

```bash
./main
```

---

## 12. Compile Multiple C++ Files

Suppose you have:

```text
main.cpp
utils.cpp
utils.hpp
```

Compile with:

```bash
g++ main.cpp utils.cpp -o main
```

Run with:

```bash
./main
```

---

## 13. Using a Makefile

For larger projects, it is better to use a `Makefile`.

Example `Makefile` for a C++ program:

```makefile
CXX = g++
CXXFLAGS = -Wall -Wextra -O2

TARGET = main
SOURCES = main.cpp

all:
	$(CXX) $(CXXFLAGS) $(SOURCES) -o $(TARGET)

clean:
	rm -f $(TARGET)
```

Compile by running:

```bash
make
```

Run the program:

```bash
./main
```

Clean the compiled executable:

```bash
make clean
```

Important: the indented lines inside the `Makefile` must start with a tab, not spaces.

---

## 14. Check Whether GCC and G++ Are Installed

To check the C compiler:

```bash
gcc --version
```

To check the C++ compiler:

```bash
g++ --version
```

If the commands are not found, ask the laboratory assistant or instructor.

---

## 15. Common Problems

### Problem: `ssh: Could not resolve hostname pynqXX`

Check that you replaced `pynqXX` with your actual board name.

Example:

```bash
ssh xilinx@pynq05
```

Also check that you are connected to the correct laboratory network.

### Problem: `Permission denied`

Make sure you are using:

```text
Username: xilinx
Password: xilinx
```

The SSH command should look like:

```bash
ssh xilinx@pynqXX
```

### Problem: `No such file or directory`

Check that the file exists in the current directory.

Use:

```bash
ls
```

### Problem: `command not found`

Check that you typed the command correctly.

For example, use:

```bash
g++ main.cpp -o main
```

not:

```bash
gcc++ main.cpp -o main
```

### Problem: `Permission denied` when running a program

Make sure you are running the executable with:

```bash
./main
```

If needed, add execute permission:

```bash
chmod +x main
```

---

## 17. Quick Command Summary

Connect to board:

```bash
ssh xilinx@pynqXX
```

Copy file to board:

```bash
scp main.cpp xilinx@pynqXX:/home/xilinx/
```

Copy directory to board:

```bash
scp -r my_project xilinx@pynqXX:/home/xilinx/
```

Copy file from board:

```bash
scp xilinx@pynqXX:/home/xilinx/result.txt .
```

Compile C:

```bash
gcc main.c -o main
```

Compile C++:

```bash
g++ main.cpp -o main
```

Run program:

```bash
./main
```

Disconnect:

```bash
exit
```
