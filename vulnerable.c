#include <stdio.h>
#include <string.h>

void secret_function() {
    printf("\n🔓 SECRET FUNCTION EXECUTED! 🔓\n");
    printf("This function was NOT supposed to be called!\n");
    printf("The buffer overflow changed the program's execution flow.\n\n");
}

void check_password() {
    char buffer[8];  // Small buffer - only 8 bytes
    int authenticated = 0;
    
    printf("Enter password: ");
    gets(buffer);  // VULNERABLE FUNCTION - no bounds checking!
    
    if (strcmp(buffer, "pass123") == 0) {
        authenticated = 1;
    }
    
    if (authenticated) {
        printf("✓ Access granted!\n");
    } else {
        printf("✗ Access denied!\n");
    }
}

int main() {
    printf("=== Buffer Overflow Demonstration ===\n");
    printf("Buffer size: 8 bytes\n\n");
    
    check_password();
    
    printf("Program ending normally.\n");
    return 0;
}
