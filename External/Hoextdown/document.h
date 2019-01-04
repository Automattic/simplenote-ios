/* document.h - generic markdown parser */

#ifndef HOEDOWN_DOCUMENT_H
#define HOEDOWN_DOCUMENT_H

#include "buffer.h"
#include "autolink.h"

#ifdef __cplusplus
extern "C" {
#endif


/*************
 * CONSTANTS *
 *************/

/* Next offset: 22 */
typedef enum hoedown_extensions {
	/* block-level extensions */
	HOEDOWN_EXT_TABLES = (1 << 0),
	HOEDOWN_EXT_MULTILINE_TABLES = (1 << 18),
	HOEDOWN_EXT_FENCED_CODE = (1 << 1),
	HOEDOWN_EXT_FOOTNOTES = (1 << 2),
	HOEDOWN_EXT_DEFINITION_LISTS = (1 << 19),
	HOEDOWN_EXT_BLOCKQUOTE_EMPTY_LINE = (1 << 21),

	/* span-level extensions */
	HOEDOWN_EXT_AUTOLINK = (1 << 3),
	HOEDOWN_EXT_STRIKETHROUGH = (1 << 4),
	HOEDOWN_EXT_UNDERLINE = (1 << 5),
	HOEDOWN_EXT_HIGHLIGHT = (1 << 6),
	HOEDOWN_EXT_QUOTE = (1 << 7),
	HOEDOWN_EXT_SUPERSCRIPT = (1 << 8),
	HOEDOWN_EXT_MATH = (1 << 9),

	/* other flags */
	HOEDOWN_EXT_NO_INTRA_EMPHASIS = (1 << 11),
	HOEDOWN_EXT_SPACE_HEADERS = (1 << 12),
	HOEDOWN_EXT_MATH_EXPLICIT = (1 << 13),
	HOEDOWN_EXT_HTML5_BLOCKS = (1 << 20),
	HOEDOWN_EXT_NO_INTRA_UNDERLINE_EMPHASIS = (1 << 21),

	/* negative flags */
	HOEDOWN_EXT_DISABLE_INDENTED_CODE = (1 << 14),

	/* special attribute */
	HOEDOWN_EXT_SPECIAL_ATTRIBUTE = (1 << 15),

	/* script tags */
	HOEDOWN_EXT_SCRIPT_TAGS = (1 << 16),

	/* meta block */
	HOEDOWN_EXT_META_BLOCK = (1 << 17)
} hoedown_extensions;

#define HOEDOWN_EXT_BLOCK (\
	HOEDOWN_EXT_TABLES |\
	HOEDOWN_EXT_MULTILINE_TABLES |\
	HOEDOWN_EXT_FENCED_CODE |\
	HOEDOWN_EXT_FOOTNOTES |\
	HOEDOWN_EXT_DEFINITION_LISTS |\
	HOEDOWN_EXT_BLOCKQUOTE_EMPTY_LINE )

#define HOEDOWN_EXT_SPAN (\
	HOEDOWN_EXT_AUTOLINK |\
	HOEDOWN_EXT_STRIKETHROUGH |\
	HOEDOWN_EXT_UNDERLINE |\
	HOEDOWN_EXT_HIGHLIGHT |\
	HOEDOWN_EXT_QUOTE |\
	HOEDOWN_EXT_SUPERSCRIPT |\
	HOEDOWN_EXT_MATH )

#define HOEDOWN_EXT_FLAGS (\
	HOEDOWN_EXT_NO_INTRA_EMPHASIS |\
	HOEDOWN_EXT_SPACE_HEADERS |\
	HOEDOWN_EXT_MATH_EXPLICIT |\
	HOEDOWN_EXT_SPECIAL_ATTRIBUTE |\
	HOEDOWN_EXT_SCRIPT_TAGS |\
	HOEDOWN_EXT_META_BLOCK |\
	HOEDOWN_EXT_HTML5_BLOCKS)

#define HOEDOWN_EXT_NEGATIVE (\
	HOEDOWN_EXT_DISABLE_INDENTED_CODE )

typedef enum hoedown_list_flags {
	HOEDOWN_LIST_ORDERED = (1 << 0),
	HOEDOWN_LI_BLOCK = (1 << 1),	/* <li> containing block data */
	HOEDOWN_LI_TASK = (1 << 2),
	HOEDOWN_LI_END = (1 << 3),	/* internal list flag */
	HOEDOWN_LIST_DEFINITION = (1 << 4),
	HOEDOWN_LI_DT = (1 << 5),
	HOEDOWN_LI_DD = (1 << 6)
} hoedown_list_flags;

typedef enum hoedown_table_flags {
	HOEDOWN_TABLE_ALIGN_LEFT = 1,
	HOEDOWN_TABLE_ALIGN_RIGHT = 2,
	HOEDOWN_TABLE_ALIGN_CENTER = 3,
	HOEDOWN_TABLE_ALIGNMASK = 3,
	HOEDOWN_TABLE_HEADER = 4
} hoedown_table_flags;

typedef enum hoedown_autolink_type {
	HOEDOWN_AUTOLINK_NONE,		/* used internally when it is not an autolink*/
	HOEDOWN_AUTOLINK_NORMAL,	/* normal http/http/ftp/mailto/etc link */
	HOEDOWN_AUTOLINK_EMAIL		/* e-mail link without explit mailto: */
} hoedown_autolink_type;

typedef enum hoedown_header_type {
	HOEDOWN_HEADER_NONE,   /* not a header */
	HOEDOWN_HEADER_ATX,    /* e.g. "# Foo" */
	HOEDOWN_HEADER_SETEXT  /* e.g. "Foo\n---" or "Foo\n===" */
} hoedown_header_type;

typedef enum hoedown_link_type {
	HOEDOWN_LINK_NONE,            /* not in a link */
	HOEDOWN_LINK_INLINE,          /* e.g. [foo](/bar/) */
	HOEDOWN_LINK_REFERENCE,       /* e.g. [foo][bar] */
	HOEDOWN_LINK_EMPTY_REFERENCE, /* e.g. [foo][] */
	HOEDOWN_LINK_SHORTCUT         /* e.g. [foo] */
} hoedown_link_type;

/*********
 * TYPES *
 *********/

struct hoedown_document;
typedef struct hoedown_document hoedown_document;

struct hoedown_renderer_data {
	void *opaque;
};
typedef struct hoedown_renderer_data hoedown_renderer_data;

/* hoedown_renderer - functions for rendering parsed data */
struct hoedown_renderer {
	/* state object */
	void *opaque;

	/* block level callbacks - NULL skips the block */
	void (*blockcode)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *lang, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	void (*blockquote)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	void (*header)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *attr, int level, const hoedown_renderer_data *data);
	void (*hrule)(hoedown_buffer *ob, const hoedown_renderer_data *data);
	void (*list)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, hoedown_list_flags flags, const hoedown_renderer_data *data);
	void (*listitem)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, hoedown_list_flags *flags, const hoedown_renderer_data *data);
	void (*paragraph)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	void (*table)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	void (*table_header)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	void (*table_body)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	void (*table_row)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	void (*table_cell)(hoedown_buffer *ob, const hoedown_buffer *content, hoedown_table_flags flags, const hoedown_renderer_data *data);
	void (*footnotes)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	void (*footnote_def)(hoedown_buffer *ob, const hoedown_buffer *content, unsigned int num, const hoedown_renderer_data *data);
	void (*blockhtml)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data);

	/* span level callbacks - NULL or return 0 prints the span verbatim */
	int (*autolink)(hoedown_buffer *ob, const hoedown_buffer *link, hoedown_autolink_type type, const hoedown_renderer_data *data);
	int (*codespan)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	int (*double_emphasis)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*emphasis)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*underline)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*highlight)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*quote)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*image)(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *alt, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	int (*linebreak)(hoedown_buffer *ob, const hoedown_renderer_data *data);
	int (*link)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *attr, const hoedown_renderer_data *data);
	int (*triple_emphasis)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*strikethrough)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*superscript)(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data);
	int (*footnote_ref)(hoedown_buffer *ob, unsigned int num, const hoedown_renderer_data *data);
	int (*math)(hoedown_buffer *ob, const hoedown_buffer *text, int displaymode, const hoedown_renderer_data *data);
	int (*raw_html)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data);

	/* low level callbacks - NULL copies input directly into the output */
	void (*entity)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data);
	void (*normal_text)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data);

	/* miscellaneous callbacks */
	void (*doc_header)(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data);
	void (*doc_footer)(hoedown_buffer *ob, int inline_render, const hoedown_renderer_data *data);

	/* user block */
	void (*user_block)(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_renderer_data *data);

	/* reference callbacks */
	/* called when a link reference definition is parsed */
	void (*ref)(hoedown_buffer *orig, const hoedown_renderer_data *data);
	/* called when a footnote reference definition is parsed */
	void (*footnote_ref_def)(hoedown_buffer *orig, const hoedown_renderer_data *data);
};
typedef struct hoedown_renderer hoedown_renderer;


/*************
 * FUNCTIONS *
 *************/

typedef size_t (*hoedown_user_block)(uint8_t *context, size_t size, const hoedown_renderer_data *data);

/* hoedown_document_new: allocate a new document processor instance */
hoedown_document *hoedown_document_new(
	const hoedown_renderer *renderer,
	hoedown_extensions extensions,
	size_t max_nesting,
	uint8_t attr_activation,
	hoedown_user_block user_block,
	hoedown_buffer *meta
) __attribute__ ((malloc));

/* hoedown_document_render: render regular Markdown using the document processor */
void hoedown_document_render(hoedown_document *doc, hoedown_buffer *ob, const uint8_t *data, size_t size);

/* hoedown_document_render_inline: render inline Markdown using the document processor */
void hoedown_document_render_inline(hoedown_document *doc, hoedown_buffer *ob, const uint8_t *data, size_t size);

/* hoedown_document_free: deallocate a document processor instance */
void hoedown_document_free(hoedown_document *doc);

/* returns a hoedown buffer containing the id of link or footnote reference being processed, or NULL if no link or footnote is being processed */
const hoedown_buffer *hoedown_document_link_id(hoedown_document* document);

/* returns a hoedown buffer containing the reference attr of link being
 * processed, or NULL or empty if none exists */
const hoedown_buffer *hoedown_document_link_ref_attr(
    hoedown_document *document);

/* returns a hoedown buffer containing the inline attr of link being processed,
 * or NULL or empty if none exists */
const hoedown_buffer *hoedown_document_link_inline_attr(
    hoedown_document *document);

/* returns the id of the footnote definition currently processed, or NULL if not processing a footnote */
const hoedown_buffer *hoedown_document_footnote_id(hoedown_document *document);

/* returns 1 if the currently processed buffer in normal text was escaped in the original document */
int hoedown_document_is_escaped(hoedown_document* document);

/* returns the header type of the currently processed header, or HOEDOWN_HEADER_NONE if not processing a header */
hoedown_header_type hoedown_document_header_type(hoedown_document* document);

/* returns the link type of the currently processed link, or HOEDOWN_LINK_NONE if not processing a link */
hoedown_link_type hoedown_document_link_type(hoedown_document *document);

/* returns the list depth of the currently processed element, 1 per level */
int hoedown_document_list_depth(hoedown_document* document);

/* returns the blockquote depth of the currently processed element, 1 per level */
int hoedown_document_blockquote_depth(hoedown_document* document);

/* returns the character used for the currently processing unordered list (+, *, or -), or 0 if not processing an unordered list */
uint8_t hoedown_document_ul_item_char(hoedown_document* document);

/* returns the character used for the currently processing hrule (-, *, or _), or 0 if not processing an hrule */
uint8_t hoedown_document_hrule_char(hoedown_document* document);

/* returns the character used for the currently processing fenced code block (` or ~), or 0 if not processing a fenced code block */
uint8_t hoedown_document_fencedcode_char(hoedown_document* document);

/* returns the text of the numeral that begins an ordered list item, or NULL if not processing an ordered list item */
const hoedown_buffer* hoedown_document_ol_numeral(hoedown_document* document);

#ifdef __cplusplus
}
#endif

#endif /** HOEDOWN_DOCUMENT_H **/
