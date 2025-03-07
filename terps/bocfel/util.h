// vim: set ft=c:

#ifndef ZTERP_UTIL_H
#define ZTERP_UTIL_H

#include <stdbool.h>
#include <stdint.h>

#ifdef ZTERP_GLK
#include <glk.h>
#endif

#if defined(__GNUC__) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7))
#define znoreturn		__attribute__((__noreturn__))
#if defined(__MINGW32__) && defined(__GNUC__) && !defined(__clang__)
// Gcc appears to default to ms_printf on MinGW, even when it is
// providing standards-conforming printf() functionality (i.e. if
// __USE_MINGW_ANSI_STDIO is defined), so force gnu_printf there.
#define zprintflike(f, a)	__attribute__((__format__(__gnu_printf__, f, a)))
#else
#define zprintflike(f, a)	__attribute__((__format__(__printf__, f, a)))
#endif
#else
#define znoreturn
#define zprintflike(f, a)
#endif

#define ASIZE(array)	(sizeof (array) / sizeof *(array))

// Values are usually stored in a uint16_t because most parts of the
// Z-machine make use of 16-bit unsigned integers. However, in a few
// places the unsigned value must be treated as signed. The “obvious”
// solution is to simply convert to an int16_t, but this is technically
// implementation-defined behavior in C and not guaranteed to provide
// the expected result. In order to be maximally portable, this
// function converts a uint16_t to its int16_t counterpart manually.
// Although it ought to be slower, both Gcc and Clang recognize this
// construct and generate the same code as a direct conversion. An
// alternative direct conversion method is included here for reference.
#if 1
static inline int16_t as_signed(uint16_t n)
{
    return (n & 0x8000) ? (long)n - 0x10000L : n;
}
#else
static inline int16_t as_signed(uint16_t n)
{
    return n;
}
#endif

#ifndef ZTERP_NO_SAFETY_CHECKS
zprintflike(1, 2)
znoreturn
void assert_fail(const char *fmt, ...);
#define ZASSERT(expr, ...)	do { if (!(expr)) assert_fail(__VA_ARGS__); } while (false)
#else
#define ZASSERT(expr, ...)	((void)0)
#endif

zprintflike(1, 2)
void warning(const char *fmt, ...);

zprintflike(1, 2)
znoreturn
void die(const char *fmt, ...);
void help(void);

char *xstrdup(const char *s);

extern enum arg_status { ARG_OK, ARG_HELP, ARG_FAIL } arg_status;
void process_arguments(int argc, char **argv);
long parseint(const char *s, int base, bool *valid);

// Somewhat ugly hack to get around the fact that some Glk functions may
// not exist. These function calls should all be guarded (e.g.
// if (have_unicode), with have_unicode being set iff GLK_MODULE_UNICODE
// is defined) so they will never be called if the Glk implementation
// being used does not support them, but they must at least exist to
// prevent link errors.
#ifdef ZTERP_GLK
#ifndef GLK_MODULE_UNICODE
#define glk_put_char_uni(...)		die("bug %s:%d: glk_put_char_uni() called with no unicode", __FILE__, __LINE__)
#define glk_put_char_stream_uni(...)	die("bug %s:%d: glk_put_char_stream_uni() called with no unicode", __FILE__, __LINE__)
#define glk_request_char_event_uni(...)	die("bug %s:%d: glk_request_char_event_uni() called with no unicode", __FILE__, __LINE__)
#define glk_request_line_event_uni(...)	die("bug %s:%d: glk_request_line_event_uni() called with no unicode", __FILE__, __LINE__)
#endif
#ifndef GLK_MODULE_LINE_ECHO
#define glk_set_echo_line_event(...)	die("bug: %s %d: glk_set_echo_line_event() called with no line echo", __FILE__, __LINE__)
#endif
#endif

#endif
