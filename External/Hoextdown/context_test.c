#include "context_test.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

/********************
 * GENERIC RENDERER *
 ********************/

static void
rndr_blockcode(hoedown_buffer *ob, const hoedown_buffer *text, const hoedown_buffer *lang, const hoedown_buffer *attr, const hoedown_renderer_data *data)
{
	uint8_t c = hoedown_document_fencedcode_char(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (c) hoedown_buffer_putc(ob, c);
	else hoedown_buffer_puts(ob, "unfenced blockcode");
	hoedown_buffer_putc(ob, ' ');
}

static void
rndr_blockquote(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static void
rndr_header(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, int level, const hoedown_renderer_data *data)
{
	hoedown_header_type header_type = hoedown_document_header_type(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	switch (header_type) {
		case HOEDOWN_HEADER_ATX:
			hoedown_buffer_puts(ob, "HOEDOWN_HEADER_ATX");
			break;
		case HOEDOWN_HEADER_SETEXT:
			hoedown_buffer_puts(ob, "HOEDOWN_HEADER_SETEXT");
			break;
		default:
			break;
	}
	hoedown_buffer_putc(ob, ' ');
}

static int
rndr_link(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *attr, const hoedown_renderer_data *data)
{
	const hoedown_buffer *id, *ref_attr, *inline_attr;
	hoedown_link_type link_type;

	id = hoedown_document_link_id(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	hoedown_buffer_puts(ob, "id: ");
	if (id) hoedown_buffer_put(ob, id->data, id->size);
	else hoedown_buffer_puts(ob, "no id");

	hoedown_buffer_putc(ob, ' ');

	link_type = hoedown_document_link_type(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	switch (link_type) {
		case HOEDOWN_LINK_INLINE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_INLINE");
			break;
		case HOEDOWN_LINK_REFERENCE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_REFERENCE");
			break;
		case HOEDOWN_LINK_EMPTY_REFERENCE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_EMPTY_REFERENCE");
			break;
		case HOEDOWN_LINK_SHORTCUT:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_SHORTCUT");
			break;
		default:
			break;
	}

	ref_attr = hoedown_document_link_ref_attr(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (ref_attr && ref_attr->size > 0) {
		hoedown_buffer_puts(ob, " ref_attr: ");
		hoedown_buffer_put(ob, ref_attr->data, ref_attr->size);
	}

	inline_attr = hoedown_document_link_inline_attr(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (inline_attr && inline_attr->size > 0) {
		hoedown_buffer_puts(ob, " inline_attr: ");
		hoedown_buffer_put(ob, inline_attr->data, inline_attr->size);
	}

	return 1;
}

static void
rndr_list(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, unsigned int flags, const hoedown_renderer_data *data)
{
	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static void
rndr_listitem(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, hoedown_list_flags *flags, const hoedown_renderer_data *data)
{
	uint8_t c;
	const hoedown_buffer* ol_numeral;

	ol_numeral = hoedown_document_ol_numeral(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (ol_numeral) {
		hoedown_buffer_put(ob, ol_numeral->data, ol_numeral->size);
		hoedown_buffer_puts(ob, ". ");
	} else {
		c = hoedown_document_ul_item_char(((hoedown_context_test_renderer_state*) data->opaque)->doc);
		if (c) {
			hoedown_buffer_putc(ob, c);
			hoedown_buffer_putc(ob, ' ');
		}
	}

	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static void
rndr_paragraph(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_buffer *attr, const hoedown_renderer_data *data)
{
	int list_depth, blockquote_depth;

	list_depth = hoedown_document_list_depth(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	blockquote_depth = hoedown_document_blockquote_depth(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	hoedown_buffer_printf(ob, "list depth: %d blockquote depth: %d ", list_depth, blockquote_depth);
	if (content) {
		hoedown_buffer_puts(ob, "paragraph: ");
		hoedown_buffer_put(ob, content->data, content->size);
	}
	hoedown_buffer_putc(ob, '\n');
}

static void
rndr_hrule(hoedown_buffer *ob, const hoedown_renderer_data *data)
{
	uint8_t c = hoedown_document_hrule_char(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	hoedown_buffer_putc(ob, c);
	hoedown_buffer_putc(ob, ' ');
}

static int
rndr_image(hoedown_buffer *ob, const hoedown_buffer *link, const hoedown_buffer *title, const hoedown_buffer *alt, const hoedown_buffer *attr, const hoedown_renderer_data *data)
{
	const hoedown_buffer *id, *ref_attr, *inline_attr;
	hoedown_link_type link_type;

	id = hoedown_document_link_id(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	hoedown_buffer_puts(ob, "id: ");
	if (id) hoedown_buffer_put(ob, id->data, id->size);
	else hoedown_buffer_puts(ob, "no id");
	hoedown_buffer_putc(ob, ' ');

	link_type = hoedown_document_link_type(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	switch (link_type) {
		case HOEDOWN_LINK_INLINE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_INLINE");
			break;
		case HOEDOWN_LINK_REFERENCE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_REFERENCE");
			break;
		case HOEDOWN_LINK_EMPTY_REFERENCE:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_EMPTY_REFERENCE");
			break;
		case HOEDOWN_LINK_SHORTCUT:
			hoedown_buffer_puts(ob, "HOEDOWN_LINK_SHORTCUT");
			break;
		default:
			break;
	}

	ref_attr = hoedown_document_link_ref_attr(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (ref_attr && ref_attr->size > 0) {
		hoedown_buffer_puts(ob, " ref_attr: ");
		hoedown_buffer_put(ob, ref_attr->data, ref_attr->size);
	}

	inline_attr = hoedown_document_link_inline_attr(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (inline_attr && inline_attr->size > 0) {
		hoedown_buffer_puts(ob, " inline_attr: ");
		hoedown_buffer_put(ob, inline_attr->data, inline_attr->size);
	}

	return 1;
}

static void
rndr_normal_text(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
	int escaped = hoedown_document_is_escaped(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (escaped) {
		hoedown_buffer_putc(ob, '\\');
	}
	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static void
rndr_footnotes(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static void
rndr_footnote_def(hoedown_buffer *ob, const hoedown_buffer *content, unsigned int num, const hoedown_renderer_data *data)
{
	const hoedown_buffer *id;

	id = hoedown_document_footnote_id(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (id) {
		hoedown_buffer_puts(ob, "id: ");
		hoedown_buffer_put(ob, id->data, id->size);
	}
	hoedown_buffer_putc(ob, ' ');
	if (content) hoedown_buffer_put(ob, content->data, content->size);
}

static int
rndr_footnote_ref(hoedown_buffer *ob, unsigned int num, const hoedown_renderer_data *data)
{
	const hoedown_buffer *id;

	id = hoedown_document_link_id(((hoedown_context_test_renderer_state*) data->opaque)->doc);
	if (id) {
		hoedown_buffer_puts(ob, "id: ");
		hoedown_buffer_put(ob, id->data, id->size);
	}
	hoedown_buffer_putc(ob, ' ');
	return 1;
}

static void
rndr_ref(hoedown_buffer *orig, const hoedown_renderer_data *data)
{
	/* this is a little dirty, but it is simpler than maintaining this state in the renderer */
	hoedown_buffer *copy;
	copy = hoedown_buffer_new(64);
	hoedown_buffer_grow(copy, orig->size);
	memcpy(copy->data, orig->data, orig->size);
	copy->size = orig->size;

	printf("Reference Definition: %s\n", hoedown_buffer_cstr(copy));

	hoedown_buffer_free(copy);
}

static void
rndr_footnote_ref_def(hoedown_buffer *orig, const hoedown_renderer_data *data)
{
	/* this is a little dirty, but it is simpler than maintaining this state in the renderer */
	hoedown_buffer *copy;
	copy = hoedown_buffer_new(64);
	hoedown_buffer_grow(copy, orig->size);
	memcpy(copy->data, orig->data, orig->size);
	copy->size = orig->size;

	printf("Footnote Reference Definition: %s\n", hoedown_buffer_cstr(copy));

	hoedown_buffer_free(copy);
}

static int
rndr_dummy_span(hoedown_buffer *ob, const hoedown_buffer *content, const hoedown_renderer_data *data)
{
	return 1;
}

hoedown_renderer *
hoedown_context_test_renderer_new(hoedown_document *doc)
{
	static const hoedown_renderer cb_default = {
		NULL,

		rndr_blockcode,
		rndr_blockquote,
		rndr_header,
		rndr_hrule,
		rndr_list,
		rndr_listitem,
		rndr_paragraph,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		rndr_footnotes,
		rndr_footnote_def,
		NULL,

		NULL,
		NULL,
		rndr_dummy_span,
		rndr_dummy_span,
		rndr_dummy_span,
		rndr_dummy_span,
		rndr_dummy_span,
		rndr_image,
		NULL,
		rndr_link,
		rndr_dummy_span,
		rndr_dummy_span,
		NULL,
		rndr_footnote_ref,
		NULL,
		NULL,

		NULL,
		rndr_normal_text,

		NULL,
		NULL,

		NULL,

		rndr_ref,
		rndr_footnote_ref_def,
	};

	hoedown_context_test_renderer_state *state;
	hoedown_renderer *renderer;

	/* Prepare the state pointer */
	state = hoedown_malloc(sizeof(hoedown_context_test_renderer_state));
	memset(state, 0x0, sizeof(hoedown_context_test_renderer_state));

	state->doc = doc;

	/* Prepare the renderer */
	renderer = hoedown_malloc(sizeof(hoedown_renderer));
	memcpy(renderer, &cb_default, sizeof(hoedown_renderer));

	renderer->opaque = state;

	return renderer;
}

void
hoedown_context_test_renderer_free(hoedown_renderer *renderer)
{
	free(renderer->opaque);
	free(renderer);
}
