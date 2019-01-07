/* context_test.h - context test renderer used to test parser state functions */

#ifndef CONTEXT_TEST_H
#define CONTEXT_TEST_H

#include "document.h"
#include "buffer.h"
#include "hash.h"

#ifdef __cplusplus
extern "C" {
#endif


/*********
 * TYPES *
 *********/

struct hoedown_context_test_renderer_state {
	hoedown_document *doc;
};
typedef struct hoedown_context_test_renderer_state hoedown_context_test_renderer_state;


/*************
 * FUNCTIONS *
 *************/

/* hoedown_context_test_renderer_new: allocates a context test renderer */
hoedown_renderer *hoedown_context_test_renderer_new() __attribute__ ((malloc));

/* hoedown_context_test_renderer_free: deallocate a context test renderer */
void hoedown_context_test_renderer_free(hoedown_renderer *renderer);


#ifdef __cplusplus
}
#endif

#endif /** CONTEXT_TEST_H **/
