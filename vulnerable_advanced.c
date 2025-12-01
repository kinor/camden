#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void secret_function() {
    printf("\n");
    printf("***************************************************\n");
    printf("* 🔓 CONGRATULATIONS! You've called the secret 🔓 *\n");
    printf("*   function through a buffer overflow attack!    *\n");
    printf("***************************************************\n");
    printf("\n");
}

void vulnerable_function() {
    char buffer[16];
    printf("Enter some text: ");
    fflush(stdout);
    
    // Vulnerable: reads more than buffer size!
    read(STDIN_FILENO, buffer, 100);
    
    printf("You entered: %s\n", buffer);
}

int main() {
    printf("Buffer Overflow Demonstration\n");
    printf("==============================\n");
    vulnerable_function();
    printf("Program completed normally.\n");
    return 0;
}
