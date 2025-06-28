#ifndef X_H
#define X_H

// This is the function declaration that the Swift code will see.
// The implementation is in our Zig code.
void hello_from_zig(void);
const char* get_message_from_zig(void);

#endif // X_H