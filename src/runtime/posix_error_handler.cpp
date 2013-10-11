#include "mini_stdint.h"

#define WEAK __attribute__((weak))

extern "C" {

extern int halide_printf(const char *, ...);
extern void exit(int);

WEAK void (*halide_error_handler)(const char *) = NULL;

WEAK void halide_error(const char *msg) {
    if (halide_error_handler) (*halide_error_handler)(msg);
    else {
        halide_printf("Error: %s\n", msg);
        exit(1);
    }
}

WEAK void halide_set_error_handler(void (*handler)(const char *)) {
    halide_error_handler = handler;
}

}
