/*
String Utilities

Copyright (c) 2014 Rob "N3X15" Nelson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
#include "config.h"
#include "string_utils.h"
#include <string>
#include <memory>
#include <cstdarg>
#include <cstring>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdlib.h>

/**
http://stackoverflow.com/a/8098080
**/
std::string string_format(const std::string fmt_str, ...) {
    int final_n, n = fmt_str.size() * 2; /* reserve 2 times as much as the length of the fmt_str */
    std::string str;
    std::unique_ptr<char[]> formatted;
    va_list ap;
    while(1) {
        formatted.reset(new char[n]); /* wrap the plain char array into the unique_ptr */
        strcpy(&formatted[0], fmt_str.c_str());
        va_start(ap, fmt_str);
        final_n = vsnprintf(&formatted[0], n, fmt_str.c_str(), ap);
        va_end(ap);
        if (final_n < 0 || final_n >= n)
            n += abs(final_n - n + 1);
        else
            break;
    }
    return std::string(formatted.get());
}

/*
 * Copyright (c) 2004 Darren Tucker.
 *
 * Based originally on asprintf.c from OpenBSD:
 * Copyright (c) 1997 Todd C. Miller <Todd.Miller AT courtesan.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

extern int vsnprintf();

/* Include vasprintf() if not on your OS. */
#ifndef HAVE_VASPRINTF

#ifndef VA_COPY
# ifdef HAVE_VA_COPY
#  define VA_COPY(dest, src) va_copy(dest, src)
# else
#  ifdef HAVE___VA_COPY
#   define VA_COPY(dest, src) __va_copy(dest, src)
#  else
#   define VA_COPY(dest, src) (dest) = (src)
#  endif
# endif
#endif

#define INIT_SZ 128

int vasprintf(char **str, const char *fmt, va_list ap)
{
        int ret = -1;
        va_list ap2;
        char *string, *newstr;
        size_t len;

        VA_COPY(ap2, ap);
        if ((string = (char *)malloc(INIT_SZ)) == NULL)
                goto fail;

        ret = vsnprintf(string, INIT_SZ, fmt, ap2);
        if (ret >= 0 && ret < INIT_SZ) { /* succeeded with initial alloc */
                *str = string;
        } else if (ret == INT_MAX || ret < 0) { /* Bad length */
                goto fail;
        } else {        /* bigger than initial, realloc allowing for nul */
                len = (size_t)ret + 1;
                if ((newstr = (char *)realloc(string, len)) == NULL) {
                        free(string);
                        goto fail;
                } else {
                        va_end(ap2);
                        VA_COPY(ap2, ap);
                        ret = vsnprintf(newstr, len, fmt, ap2);
                        if (ret >= 0 && (size_t)ret < len) {
                                *str = newstr;
                        } else { /* failed with realloc'ed string, give up */
                                free(newstr);
                                goto fail;
                        }
                }
        }
        va_end(ap2);
        return (ret);

fail:
        *str = NULL;
        errno = ENOMEM;
        va_end(ap2);
        return (-1);
}
#endif

/* Include asprintf() if not on your OS. */
#ifndef HAVE_ASPRINTF
int asprintf(char **str, const char *fmt, ...)
{
        va_list ap;
        int ret;
        
        *str = NULL;
        va_start(ap, fmt);
        ret = vasprintf(str, fmt, ap);
        va_end(ap);

        return ret;
}
#endif