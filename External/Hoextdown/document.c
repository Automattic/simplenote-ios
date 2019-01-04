#include "document.h"

#include <assert.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "stack.h"

#ifndef _MSC_VER
#include <strings.h>
#else
#define strncasecmp	_strnicmp
#endif

#define REF_TABLE_SIZE 8

#define BUFFER_BLOCK 0
#define BUFFER_SPAN 1
#define BUFFER_ATTRIBUTE 2

const char *hoedown_find_block_tag(const char *str, unsigned int len);
const char *hoedown_find_html5_block_tag(const char *str, unsigned int len);

/***************
 * LOCAL TYPES *
 ***************/

/* link_ref: reference to a link */
struct link_ref {
	unsigned int id;

	hoedown_buffer *link;
	hoedown_buffer *title;
	hoedown_buffer *attr;

	struct link_ref *next;
};

/* footnote_ref: reference to a footnote */
struct footnote_ref {
	unsigned int id;

	int is_used;
	unsigned int num;

	hoedown_buffer *contents;

	/* the original string id of the footnote, before conversion to an int */
	hoedown_buffer *name;
};

/* footnote_item: an item in a footnote_list */
struct footnote_item {
	struct footnote_ref *ref;
	struct footnote_item *next;
};

/* footnote_list: linked list of footnote_item */
struct footnote_list {
	unsigned int count;
	struct footnote_item *head;
	struct footnote_item *tail;
};

/* char_trigger: function pointer to render active chars */
/*   returns the number of chars taken care of */
/*   data is the pointer of the beginning of the span */
/*   offset is the number of valid chars before data */
typedef size_t
(*char_trigger)(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);

static size_t char_emphasis(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_quote(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_linebreak(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_codespan(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_escape(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_entity(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_langle_tag(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_autolink_url(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_autolink_email(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_autolink_www(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_link(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_image(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_superscript(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);
static size_t char_math(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size);

enum markdown_char_t {
	MD_CHAR_NONE = 0,
	MD_CHAR_EMPHASIS,
	MD_CHAR_CODESPAN,
	MD_CHAR_LINEBREAK,
	MD_CHAR_LINK,
	MD_CHAR_IMAGE,
	MD_CHAR_LANGLE,
	MD_CHAR_ESCAPE,
	MD_CHAR_ENTITY,
	MD_CHAR_AUTOLINK_URL,
	MD_CHAR_AUTOLINK_EMAIL,
	MD_CHAR_AUTOLINK_WWW,
	MD_CHAR_SUPERSCRIPT,
	MD_CHAR_QUOTE,
	MD_CHAR_MATH
};

static char_trigger markdown_char_ptrs[] = {
	NULL,
	&char_emphasis,
	&char_codespan,
	&char_linebreak,
	&char_link,
	&char_image,
	&char_langle_tag,
	&char_escape,
	&char_entity,
	&char_autolink_url,
	&char_autolink_email,
	&char_autolink_www,
	&char_superscript,
	&char_quote,
	&char_math
};

struct hoedown_document {
	hoedown_renderer md;
	hoedown_renderer_data data;

	uint8_t attr_activation;

	struct link_ref *refs[REF_TABLE_SIZE];
	struct footnote_list footnotes_found;
	struct footnote_list footnotes_used;
	uint8_t active_char[256];
	hoedown_stack work_bufs[3];
	hoedown_extensions ext_flags;
	size_t max_nesting;
	int in_link_body;

	/* extra information provided to callbacks */
	const hoedown_buffer *link_id;
	const hoedown_buffer *link_inline_attr;
	const hoedown_buffer *link_ref_attr;
	int is_escape_char;
	hoedown_header_type header_type;
	hoedown_link_type link_type;
	const hoedown_buffer *footnote_id;
	int list_depth;
	int blockquote_depth;
	uint8_t ul_item_char;
	uint8_t hrule_char;
	uint8_t fencedcode_char;
	const hoedown_buffer *ol_numeral;

	hoedown_user_block user_block;
	hoedown_buffer *meta;
};

/***************************
 * HELPER FUNCTIONS *
 ***************************/

static hoedown_buffer *
newbuf(hoedown_document *doc, int type)
{
	static const size_t buf_size[3] = {256, 64, 64};
	hoedown_buffer *work = NULL;
	hoedown_stack *pool = &doc->work_bufs[type];

	if (pool->size < pool->asize &&
		pool->item[pool->size] != NULL) {
		work = pool->item[pool->size++];
		work->size = 0;
	} else {
		work = hoedown_buffer_new(buf_size[type]);
		hoedown_stack_push(pool, work);
	}

	return work;
}

static void
popbuf(hoedown_document *doc, int type)
{
	doc->work_bufs[type].size--;
}

static void
unscape_text(hoedown_buffer *ob, hoedown_buffer *src)
{
	size_t i = 0, org;
	while (i < src->size) {
		org = i;
		while (i < src->size && src->data[i] != '\\')
			i++;

		if (i > org)
			hoedown_buffer_put(ob, src->data + org, i - org);

		if (i + 1 >= src->size)
			break;

		hoedown_buffer_putc(ob, src->data[i + 1]);
		i += 2;
	}
}

static unsigned int
hash_link_ref(const uint8_t *link_ref, size_t length)
{
	size_t i;
	unsigned int hash = 0;

	for (i = 0; i < length; ++i)
		hash = tolower(link_ref[i]) + (hash << 6) + (hash << 16) - hash;

	return hash;
}

static struct link_ref *
add_link_ref(
	struct link_ref **references,
	const uint8_t *name, size_t name_size)
{
	struct link_ref *ref = hoedown_calloc(1, sizeof(struct link_ref));

	ref->id = hash_link_ref(name, name_size);
	ref->next = references[ref->id % REF_TABLE_SIZE];

	references[ref->id % REF_TABLE_SIZE] = ref;
	return ref;
}

static struct link_ref *
find_link_ref(struct link_ref **references, uint8_t *name, size_t length)
{
	unsigned int hash = hash_link_ref(name, length);
	struct link_ref *ref = NULL;

	ref = references[hash % REF_TABLE_SIZE];

	while (ref != NULL) {
		if (ref->id == hash)
			return ref;

		ref = ref->next;
	}

	return NULL;
}

static void
free_link_refs(struct link_ref **references)
{
	size_t i;

	for (i = 0; i < REF_TABLE_SIZE; ++i) {
		struct link_ref *r = references[i];
		struct link_ref *next;

		while (r) {
			next = r->next;
			hoedown_buffer_free(r->link);
			hoedown_buffer_free(r->title);
			hoedown_buffer_free(r->attr);
			free(r);
			r = next;
		}
	}
}

static struct footnote_ref *
create_footnote_ref(struct footnote_list *list, const uint8_t *name, size_t name_size)
{
	struct footnote_ref *ref = hoedown_calloc(1, sizeof(struct footnote_ref));

	ref->id = hash_link_ref(name, name_size);

	return ref;
}

static int
add_footnote_ref(struct footnote_list *list, struct footnote_ref *ref)
{
	struct footnote_item *item = hoedown_calloc(1, sizeof(struct footnote_item));
	if (!item)
		return 0;
	item->ref = ref;

	if (list->head == NULL) {
		list->head = list->tail = item;
	} else {
		list->tail->next = item;
		list->tail = item;
	}
	list->count++;

	return 1;
}

static struct footnote_ref *
find_footnote_ref(struct footnote_list *list, uint8_t *name, size_t length)
{
	unsigned int hash = hash_link_ref(name, length);
	struct footnote_item *item = NULL;

	item = list->head;

	while (item != NULL) {
		if (item->ref->id == hash)
			return item->ref;
		item = item->next;
	}

	return NULL;
}

static void
free_footnote_ref(struct footnote_ref *ref)
{
	hoedown_buffer_free(ref->contents);
	hoedown_buffer_free(ref->name);
	free(ref);
}

static void
free_footnote_list(struct footnote_list *list, int free_refs)
{
	struct footnote_item *item = list->head;
	struct footnote_item *next;

	while (item) {
		next = item->next;
		if (free_refs)
			free_footnote_ref(item->ref);
		free(item);
		item = next;
	}
}


/*
 * Check whether a char is a Markdown spacing char.

 * Right now we only consider spaces the actual
 * space and a newline: tabs and carriage returns
 * are filtered out during the preprocessing phase.
 *
 * If we wanted to actually be UTF-8 compliant, we
 * should instead extract an Unicode codepoint from
 * this character and check for space properties.
 */
static int
_isspace(int c)
{
	return c == ' ' || c == '\n';
}

/* is_empty_all: verify that all the data is spacing */
static int
is_empty_all(const uint8_t *data, size_t size)
{
	size_t i = 0;
	while (i < size && _isspace(data[i])) i++;
	return i == size;
}

/*
 * Replace all spacing characters in data with spaces. As a special
 * case, this collapses a newline with the previous space, if possible.
 */
static void
replace_spacing(hoedown_buffer *ob, const uint8_t *data, size_t size)
{
	size_t i = 0, mark;
	hoedown_buffer_grow(ob, size);
	while (1) {
		mark = i;
		while (i < size && data[i] != '\n') i++;
		hoedown_buffer_put(ob, data + mark, i - mark);

		if (i >= size) break;

		if (!(i > 0 && data[i-1] == ' '))
			hoedown_buffer_putc(ob, ' ');
		i++;
	}
}

/****************************
 * INLINE PARSING FUNCTIONS *
 ****************************/

/* is_mail_autolink • looks for the address part of a mail autolink and '>' */
/* this is less strict than the original markdown e-mail address matching */
static size_t
is_mail_autolink(uint8_t *data, size_t size)
{
	size_t i = 0, nb = 0;

	/* address is assumed to be: [-@._a-zA-Z0-9]+ with exactly one '@' */
	for (i = 0; i < size; ++i) {
		if (isalnum(data[i]))
			continue;

		switch (data[i]) {
			case '@':
				nb++;

			case '-':
			case '.':
			case '_':
				break;

			case '>':
				return (nb == 1) ? i + 1 : 0;

			default:
				return 0;
		}
	}

	return 0;
}

static size_t
script_tag_length(uint8_t *data, size_t size)
{
	size_t i = 2;
	char comment = 0;

	if (size < 3 || data[0] != '<' || data[1] != '?') {
		return 0;
	}

	i = 2;

	while (i < size) {
		if (data[i - 1] == '?' && data[i] == '>' && comment == 0) {
			break;
		}

		if (data[i] == '\'' || data[i] == '"') {
			if (comment != 0) {
				if (data[i] == comment && data[i - 1] != '\\') {
					comment = 0;
				}
			} else {
				comment = data[i];
			}
		}

		++i;
	}

	if (i >= size) return i;

	return i + 1;
}

/* tag_length • returns the length of the given tag, or 0 is it's not valid */
static size_t
tag_length(uint8_t *data, size_t size, hoedown_autolink_type *autolink, int script_tag)
{
	size_t i, j;

	/* a valid tag can't be shorter than 3 chars */
	if (size < 3) return 0;

	if (data[0] != '<') return 0;

	/* HTML comment, laxist form */
	if (size > 5 && data[1] == '!' && data[2] == '-' && data[3] == '-') {
		i = 5;

		while (i < size && !(data[i - 2] == '-' && data[i - 1] == '-' && data[i] == '>'))
			i++;

		i++;

		if (i <= size)
			return i;
	}

	/* begins with a '<' optionally followed by '/', followed by letter or number */
	i = (data[1] == '/') ? 2 : 1;

	if (!isalnum(data[i])) {
		if (script_tag) {
			return script_tag_length(data, size);
		}
		return 0;
	}

	/* scheme test */
	*autolink = HOEDOWN_AUTOLINK_NONE;

	/* try to find the beginning of an URI */
	while (i < size && (isalnum(data[i]) || data[i] == '.' || data[i] == '+' || data[i] == '-'))
		i++;

	if (i > 1 && i < size && data[i] == '@') {
		if ((j = is_mail_autolink(data + i, size - i)) != 0) {
			*autolink = HOEDOWN_AUTOLINK_EMAIL;
			return i + j;
		}
	}

	if (i > 2 && i < size && data[i] == ':') {
		*autolink = HOEDOWN_AUTOLINK_NORMAL;
		i++;
	}

	/* completing autolink test: no spacing or ' or " */
	if (i >= size)
		*autolink = HOEDOWN_AUTOLINK_NONE;

	else if (*autolink) {
		j = i;

		while (i < size) {
			if (data[i] == '\\') i += 2;
			else if (data[i] == '>' || data[i] == '\'' ||
					data[i] == '"' || data[i] == ' ' || data[i] == '\n')
					break;
			else i++;
		}

		if (i >= size) return 0;
		if (i > j && data[i] == '>') return i + 1;
		/* one of the forbidden chars has been found */
		*autolink = HOEDOWN_AUTOLINK_NONE;
	}

	/* looking for something looking like a tag end */
	while (i < size && data[i] != '>') i++;
	if (i >= size) return 0;
	return i + 1;
}

/* parse_inline • parses inline markdown elements */
static void
parse_inline(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t i = 0, end = 0, consumed = 0;
	hoedown_buffer work = { 0, 0, 0, 0, NULL, NULL, NULL };
	uint8_t *active_char = doc->active_char;

	if (doc->work_bufs[BUFFER_SPAN].size +
		doc->work_bufs[BUFFER_BLOCK].size > doc->max_nesting)
		return;

	while (i < size) {
		size_t user_block = 0;
		while (end < size) {
			if (doc->user_block) {
				user_block = doc->user_block(data+end, size - end, &doc->data);
				if (user_block) {
					break;
				}
			}
			/* copying inactive chars into the output */
			if (active_char[data[end]] != 0) {
				break;
			}
			end++;
		}

		if (doc->md.normal_text) {
			work.data = data + i;
			work.size = end - i;
			doc->md.normal_text(ob, &work, &doc->data);
		}
		else
			hoedown_buffer_put(ob, data + i, end - i);

		if (end >= size) {
			break;
		}
		i = end;

		if (user_block) {
			work.data = data + i;
			work.size = user_block;
			end = user_block;
			if (doc->md.user_block) {
				doc->md.user_block(ob, &work, &doc->data);
			} else {
				hoedown_buffer_put(ob, data + i, size - i);
			}
			if (!end) {
				end = i + 1;
			} else {
				i += end;
				end = i;
				consumed = i;
			}
		} else {
			end = markdown_char_ptrs[ (int)active_char[data[end]] ](ob, doc, data + i, i - consumed, size - i);
			if (!end) /* no action from the callback */
				end = i + 1;
			else {
				i += end;
				end = i;
				consumed = i;
			}
		}
	}
}

/* parse_inline_attributes • parses inline attributes, returning the end position of the
 * attributes. attributes must be in the start. differs from parse_attributes in
 * that parses_attributes assumes attributes are at the end of data.*/
static size_t parse_inline_attributes(uint8_t *data, size_t size, struct hoedown_buffer *attr, uint8_t attr_activation)
{
	size_t attr_start, i = 0;

	if (size < 1)
		return 0;

	if (data[i] == '{' && (!attr_activation || (i + 1 < size && data[i + 1] == attr_activation))) {
		attr_start = i + 1;
		/* skip an extra character to skip over the activation character if any */
		if (attr_activation) attr_start++;
	} else {
		return 0;
	}

	while (i < size) {
		/* ignore escaped characters */
		if (data[i] == '\\') {
			i += 2;
		} else if (data[i] == '}') {
			if (attr != NULL) {
				hoedown_buffer_put(attr, data + attr_start, i - attr_start);
			}
			return i + 1;
		} else {
			i++;
		}
	}
	return 0;
}


/* parse_attributes • parses special attributes at the end of the data */
static size_t parse_attributes(uint8_t *data, size_t size, struct hoedown_buffer *attr, struct hoedown_buffer *block_attr, const uint8_t *block_id, size_t block_id_size, int is_header, uint8_t attr_activation)
{
	size_t i, len, begin = 0, end = 0;

	if (size < 1)
		return 0;

	i = size;
	while (i && data[i-1] == '\n') {
		i--;
	}
	len = i;

	if (i && data[i-1] == '}') {
		do {
			i--;
		} while (i && data[i] != '{');

		begin = i + 1;
		end = len - 1;
		while (i && data[i-1] == ' ') {
			i--;
		}
	}

	if (is_header && i && data[i-1] == '#') {
		while (i && data[i-1] == '#') {
			i--;
		}
		while (i && data[i-1] == ' ') {
			i--;
		}
	}

	if (begin && end && data[begin-1] == '{' && data[end] == '}') {
		if (begin >=2 && data[begin-2] == '\\' && data[end-1] == '\\') {
			return len;
		}

		if (block_attr && data[begin] == '@') {
			/* skip the @ by incrementing past it */
			begin++;
			size_t j = 0;
			while (begin < end && data[begin] != ' ') {
				/* if a block_id was fed in, check to make sure the string until the
				 * space is identical */
				if (block_id_size != 0 &&
				   (j >= block_id_size || block_id[j] != data[begin])) {
					return len;
				}
				begin++;
				j++;
			}
			/* it might have matched only the first portion of block_id; make sure
			 * there's no more to it here */
			if (j != block_id_size) {
				return len;
			}
			if (block_attr) {
				if (block_attr->size) {
					hoedown_buffer_reset(block_attr);
				}
				hoedown_buffer_put(block_attr, data + begin, end - begin);
			}
			len = i;
			if (attr) {
				len = parse_attributes(data, len, attr, NULL, "", 0, is_header, attr_activation);
			}
		} else if (attr && (!attr_activation || attr_activation == data[begin])) {
			if (attr->size) {
				hoedown_buffer_reset(attr);
			}
			if (attr_activation) {
				begin++;
			}
			hoedown_buffer_put(attr, data + begin, end - begin);
			len = i;
		}
	}

	return len;
}

/* is_escaped • returns whether special char at data[loc] is escaped by '\\' */
static int
is_escaped(uint8_t *data, size_t loc)
{
	size_t i = loc;
	while (i >= 1 && data[i - 1] == '\\')
		i--;

	/* odd numbers of backslashes escapes data[loc] */
	return (loc - i) % 2;
}

/* is_backslashed • returns whether special char at data[loc] is preceded by '\\', a stricter interpretation of escaping than is_escaped. */
static int
is_backslashed(uint8_t *data, size_t loc)
{
	return loc >= 1 && data[loc - 1] == '\\';
}

/* find_emph_char • looks for the next emph uint8_t, skipping other constructs */
static size_t
find_emph_char(uint8_t *data, size_t size, uint8_t c)
{
	size_t i = 0;

	while (i < size) {
		while (i < size && data[i] != c && data[i] != '[' && data[i] != '`')
			i++;

		if (i == size)
			return 0;

		/* not counting escaped chars */
		if (is_escaped(data, i)) {
			i++; continue;
		}

		if (data[i] == c)
			return i;

		/* skipping a codespan */
		if (data[i] == '`') {
			size_t span_nb = 0, bt;
			size_t tmp_i = 0;

			/* counting the number of opening backticks */
			while (i < size && data[i] == '`') {
				i++; span_nb++;
			}

			if (i >= size) return 0;

			/* finding the matching closing sequence */
			bt = 0;
			while (i < size && bt < span_nb) {
				if (!tmp_i && data[i] == c) tmp_i = i;
				if (data[i] == '`') bt++;
				else bt = 0;
				i++;
			}

			/* not a well-formed codespan; use found matching emph char */
			if (bt < span_nb && i >= size) return tmp_i;
		}
		/* skipping a link */
		else if (data[i] == '[') {
			size_t tmp_i = 0;
			uint8_t cc;

			i++;
			while (i < size && data[i] != ']') {
				if (!tmp_i && data[i] == c) tmp_i = i;
				i++;
			}

			i++;
			while (i < size && _isspace(data[i]))
				i++;

			if (i >= size)
				return tmp_i;

			switch (data[i]) {
			case '[':
				cc = ']'; break;

			case '(':
				cc = ')'; break;

			default:
				if (tmp_i)
					return tmp_i;
				else
					continue;
			}

			i++;
			while (i < size && data[i] != cc) {
				if (!tmp_i && data[i] == c) tmp_i = i;
				i++;
			}

			if (i >= size)
				return tmp_i;

			i++;
		}
	}

	return 0;
}

/* find_separator_char • looks for the next unbackslashed separator character c */
static size_t
find_separator_char(uint8_t *data, size_t size, uint8_t c)
{
	size_t i = 0;

	while (i < size) {
		while (i < size && data[i] != c)
			i++;

		if (i == size)
			return 0;

		/* not counting backslashed separators */
		if (is_backslashed(data, i)) {
			i++; continue;
		}

		if (data[i] == c)
			return i;
	}

	return 0;
}

/* parse_emph1 • parsing single emphase */
/* closed by a symbol not preceded by spacing and not followed by symbol */
static size_t
parse_emph1(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, uint8_t c)
{
	size_t i = 0, len;
	hoedown_buffer *work = 0;
	int r;

	/* skipping one symbol if coming from emph3 */
	if (size > 1 && data[0] == c && data[1] == c) i = 1;

	while (i < size) {
		len = find_emph_char(data + i, size - i, c);
		if (!len) return 0;
		i += len;
		if (i >= size) return 0;

		if (data[i] == c && !_isspace(data[i - 1])) {

			if (doc->ext_flags & HOEDOWN_EXT_NO_INTRA_EMPHASIS ||
				(doc->ext_flags & HOEDOWN_EXT_NO_INTRA_UNDERLINE_EMPHASIS && c == '_')) {
				if (i + 1 < size && isalnum(data[i + 1]))
					continue;
			}

			work = newbuf(doc, BUFFER_SPAN);
			parse_inline(work, doc, data, i);

			if (doc->ext_flags & HOEDOWN_EXT_UNDERLINE && c == '_')
				r = doc->md.underline(ob, work, &doc->data);
			else
				r = doc->md.emphasis(ob, work, &doc->data);

			popbuf(doc, BUFFER_SPAN);
			return r ? i + 1 : 0;
		}
	}

	return 0;
}

/* parse_emph2 • parsing single emphase */
static size_t
parse_emph2(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, uint8_t c)
{
	size_t i = 0, len;
	hoedown_buffer *work = 0;
	int r;

	while (i < size) {
		len = find_emph_char(data + i, size - i, c);
		if (!len) return 0;
		i += len;

		if (i + 1 < size && data[i] == c && data[i + 1] == c && i && !_isspace(data[i - 1])) {
			work = newbuf(doc, BUFFER_SPAN);
			parse_inline(work, doc, data, i);

			if (c == '~')
				r = doc->md.strikethrough(ob, work, &doc->data);
			else if (c == '=')
				r = doc->md.highlight(ob, work, &doc->data);
			else
				r = doc->md.double_emphasis(ob, work, &doc->data);

			popbuf(doc, BUFFER_SPAN);
			return r ? i + 2 : 0;
		}
		i++;
	}
	return 0;
}

/* parse_emph3 • parsing single emphase */
/* finds the first closing tag, and delegates to the other emph */
static size_t
parse_emph3(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, uint8_t c)
{
	size_t i = 0, len;
	int r;

	while (i < size) {
		len = find_emph_char(data + i, size - i, c);
		if (!len) return 0;
		i += len;

		/* skip spacing preceded symbols */
		if (data[i] != c || _isspace(data[i - 1]))
			continue;

		if (i + 2 < size && data[i + 1] == c && data[i + 2] == c && doc->md.triple_emphasis) {
			/* triple symbol found */
			hoedown_buffer *work = newbuf(doc, BUFFER_SPAN);

			parse_inline(work, doc, data, i);
			r = doc->md.triple_emphasis(ob, work, &doc->data);
			popbuf(doc, BUFFER_SPAN);
			return r ? i + 3 : 0;

		} else if (i + 1 < size && data[i + 1] == c) {
			/* double symbol found, handing over to emph1 */
			len = parse_emph1(ob, doc, data - 2, size + 2, c);
			if (!len) return 0;
			else return len - 2;

		} else {
			/* single symbol found, handing over to emph2 */
			len = parse_emph2(ob, doc, data - 1, size + 1, c);
			if (!len) return 0;
			else return len - 1;
		}
	}
	return 0;
}

/* parse_math • parses a math span until the given ending delimiter */
static size_t
parse_math(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size, const char *end, size_t delimsz, int displaymode)
{
	hoedown_buffer text = { NULL, 0, 0, 0, NULL, NULL, NULL };
	size_t i = delimsz;

	if (!doc->md.math)
		return 0;

	/* find ending delimiter */
	while (1) {
		while (i < size && data[i] != (uint8_t)end[0])
			i++;

		if (i >= size)
			return 0;

		if (!is_escaped(data, i) && !(i + delimsz > size)
			&& memcmp(data + i, end, delimsz) == 0)
			break;

		i++;
	}

	/* prepare buffers */
	text.data = data + delimsz;
	text.size = i - delimsz;

	/* if this is a $$ and MATH_EXPLICIT is not active,
	 * guess whether displaymode should be enabled from the context */
	i += delimsz;
	if (delimsz == 2 && !(doc->ext_flags & HOEDOWN_EXT_MATH_EXPLICIT))
		displaymode = is_empty_all(data - offset, offset) && is_empty_all(data + i, size - i);

	/* call callback */
	if (doc->md.math(ob, &text, displaymode, &doc->data))
		return i;

	return 0;
}

/* char_emphasis • single and double emphasis parsing */
static size_t
char_emphasis(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	uint8_t c = data[0];
	size_t ret;

	if (doc->ext_flags & HOEDOWN_EXT_NO_INTRA_EMPHASIS) {
		if (offset > 0 && !_isspace(data[-1]) && data[-1] != '>' && data[-1] != '(')
			return 0;
	}

	if (size > 2 && data[1] != c) {
		/* spacing cannot follow an opening emphasis;
		 * strikethrough and highlight only takes two characters '~~' */
		if (c == '~' || c == '=' || _isspace(data[1]) || (ret = parse_emph1(ob, doc, data + 1, size - 1, c)) == 0)
			return 0;

		return ret + 1;
	}

	if (size > 3 && data[1] == c && data[2] != c) {
		if (_isspace(data[2]) || (ret = parse_emph2(ob, doc, data + 2, size - 2, c)) == 0)
			return 0;

		return ret + 2;
	}

	if (size > 4 && data[1] == c && data[2] == c && data[3] != c) {
		if (c == '~' || c == '=' || _isspace(data[3]) || (ret = parse_emph3(ob, doc, data + 3, size - 3, c)) == 0)
			return 0;

		return ret + 3;
	}

	return 0;
}


/* char_linebreak • '\n' preceded by two spaces (assuming linebreak != 0) */
static size_t
char_linebreak(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	if (offset < 2 || data[-1] != ' ' || data[-2] != ' ')
		return 0;

	/* removing the last space from ob and rendering */
	while (ob->size && ob->data[ob->size - 1] == ' ')
		ob->size--;

	return doc->md.linebreak(ob, &doc->data) ? 1 : 0;
}


/* char_codespan • '`' parsing a code span (assuming codespan != 0) */
static size_t
char_codespan(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	hoedown_buffer work = { NULL, 0, 0, 0, NULL, NULL, NULL };
	size_t end, nb = 0, i, f_begin, f_end;

	/* counting the number of backticks in the delimiter */
	while (nb < size && data[nb] == '`')
		nb++;

	/* finding the next delimiter */
	i = 0;
	for (end = nb; end < size && i < nb; end++) {
		if (data[end] == '`') {
			if (end + 1 == size || !is_escaped(data, end)) {
				i++;
			} else {
				i = 0;
			}
		}
		else i = 0;
	}

	if (i < nb && end >= size)
		return 0; /* no matching delimiter */

	/* trimming outside whitespace */
	f_begin = nb;
	while (f_begin < end && (data[f_begin] == ' ' || data[f_begin] == '\n'))
		f_begin++;

	f_end = end - nb;
	while (f_end > nb && (data[f_end-1] == ' ' || data[f_end-1] == '\n'))
		f_end--;

	/* real code span */
	if (f_begin < f_end) {
		/* needed for parse_attribute functions as buffer functions do not work with
		 * buffers made on the stack */
		hoedown_buffer *attr = newbuf(doc, BUFFER_ATTRIBUTE);

		work.data = data + f_begin;
		work.size = f_end - f_begin;

		if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
			end += parse_inline_attributes(data + end, size - end, attr, doc->attr_activation);
		}

		if (!doc->md.codespan(ob, &work, attr, &doc->data))
			end = 0;
		popbuf(doc, BUFFER_ATTRIBUTE);
	} else {
		if (!doc->md.codespan(ob, 0, 0, &doc->data))
			end = 0;
	}

	return end;
}

/* char_quote • '"' parsing a quote */
static size_t
char_quote(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	size_t end, nq = 0, i, f_begin, f_end;

	/* counting the number of quotes in the delimiter */
	while (nq < size && data[nq] == '"')
		nq++;

	/* finding the next delimiter */
	end = nq;
	while (1) {
		i = end;
		end += find_emph_char(data + end, size - end, '"');
		if (end == i) return 0;		/* no matching delimiter */
		i = end;
		while (end < size && data[end] == '"' && end - i < nq) end++;
		if (end - i >= nq) break;
	}

	/* trimming outside spaces */
	f_begin = nq;
	while (f_begin < end && data[f_begin] == ' ')
		f_begin++;

	f_end = end - nq;
	while (f_end > nq && data[f_end-1] == ' ')
		f_end--;

	/* real quote */
	if (f_begin < f_end) {
		hoedown_buffer *work = newbuf(doc, BUFFER_SPAN);
		parse_inline(work, doc, data + f_begin, f_end - f_begin);

		if (!doc->md.quote(ob, work, &doc->data))
			end = 0;
		popbuf(doc, BUFFER_SPAN);
	} else {
		if (!doc->md.quote(ob, 0, &doc->data))
			end = 0;
	}

	return end;
}


/* char_escape • '\\' backslash escape */
static size_t
char_escape(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	static const char *escape_chars = "\\`*_{}[]()#+-.!:|&<>^~=\"$";
	hoedown_buffer work = { 0, 0, 0, 0, NULL, NULL, NULL };
	size_t w;

	if (size > 1) {
		if (data[1] == '\\' && (doc->ext_flags & HOEDOWN_EXT_MATH) &&
			size > 2 && (data[2] == '(' || data[2] == '[')) {
			const char *end = (data[2] == '[') ? "\\\\]" : "\\\\)";
			w = parse_math(ob, doc, data, offset, size, end, 3, data[2] == '[');
			if (w) return w;
		}

		if (strchr(escape_chars, data[1]) == NULL)
			return 0;

		if (doc->md.normal_text) {
			work.data = data + 1;
			work.size = 1;
			doc->is_escape_char = 1;
			doc->md.normal_text(ob, &work, &doc->data);
			doc->is_escape_char = 0;
		}
		else hoedown_buffer_putc(ob, data[1]);
	} else if (size == 1) {
		if (doc->md.normal_text) {
			work.data = data;
			work.size = 1;
			doc->md.normal_text(ob, &work, &doc->data);
		}
		else hoedown_buffer_putc(ob, data[0]);
	}

	return 2;
}

/* char_entity • '&' escaped when it doesn't belong to an entity */
/* valid entities are assumed to be anything matching &#?[A-Za-z0-9]+; */
static size_t
char_entity(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	size_t end = 1;
	hoedown_buffer work = { 0, 0, 0, 0, NULL, NULL, NULL };

	if (end < size && data[end] == '#')
		end++;

	while (end < size && isalnum(data[end]))
		end++;

	if (end < size && data[end] == ';')
		end++; /* real entity */
	else
		return 0; /* lone '&' */

	if (doc->md.entity) {
		work.data = data;
		work.size = end;
		doc->md.entity(ob, &work, &doc->data);
	}
	else hoedown_buffer_put(ob, data, end);

	return end;
}

/* char_langle_tag • '<' when tags or autolinks are allowed */
static size_t
char_langle_tag(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	hoedown_buffer work = { NULL, 0, 0, 0, NULL, NULL, NULL };
	hoedown_autolink_type altype = HOEDOWN_AUTOLINK_NONE;
	size_t end = tag_length(data, size, &altype, doc->ext_flags & HOEDOWN_EXT_SCRIPT_TAGS);
	int ret = 0;

	work.data = data;
	work.size = end;

	if (end > 2) {
		if (doc->md.autolink && altype != HOEDOWN_AUTOLINK_NONE) {
			hoedown_buffer *u_link = newbuf(doc, BUFFER_SPAN);
			work.data = data + 1;
			work.size = end - 2;
			unscape_text(u_link, &work);
			ret = doc->md.autolink(ob, u_link, altype, &doc->data);
			popbuf(doc, BUFFER_SPAN);
		}
		else if (doc->md.raw_html)
			ret = doc->md.raw_html(ob, &work, &doc->data);
	}

	if (!ret) return 0;
	else return end;
}

static size_t
char_autolink_www(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	hoedown_buffer *link, *link_url, *link_text;
	size_t link_len, rewind;

	if (!doc->md.link || doc->in_link_body)
		return 0;

	link = newbuf(doc, BUFFER_SPAN);

	if ((link_len = hoedown_autolink__www(&rewind, link, data, offset, size, HOEDOWN_AUTOLINK_SHORT_DOMAINS)) > 0) {
		link_url = newbuf(doc, BUFFER_SPAN);
		HOEDOWN_BUFPUTSL(link_url, "http://");
		hoedown_buffer_put(link_url, link->data, link->size);

		if (ob->size > rewind)
			ob->size -= rewind;
		else
			ob->size = 0;

		if (doc->md.normal_text) {
			link_text = newbuf(doc, BUFFER_SPAN);
			doc->md.normal_text(link_text, link, &doc->data);
			doc->md.link(ob, link_text, link_url, NULL, NULL, &doc->data);
			popbuf(doc, BUFFER_SPAN);
		} else {
			doc->md.link(ob, link, link_url, NULL, NULL, &doc->data);
		}
		popbuf(doc, BUFFER_SPAN);
	}

	popbuf(doc, BUFFER_SPAN);
	return link_len;
}

static size_t
char_autolink_email(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	hoedown_buffer *link;
	size_t link_len, rewind;

	if (!doc->md.autolink || doc->in_link_body)
		return 0;

	link = newbuf(doc, BUFFER_SPAN);

	if ((link_len = hoedown_autolink__email(&rewind, link, data, offset, size, 0)) > 0) {
		if (ob->size > rewind)
			ob->size -= rewind;
		else
			ob->size = 0;

		doc->md.autolink(ob, link, HOEDOWN_AUTOLINK_EMAIL, &doc->data);
	}

	popbuf(doc, BUFFER_SPAN);
	return link_len;
}

static size_t
char_autolink_url(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	hoedown_buffer *link;
	size_t link_len, rewind;

	if (!doc->md.autolink || doc->in_link_body)
		return 0;

	link = newbuf(doc, BUFFER_SPAN);

	if ((link_len = hoedown_autolink__url(&rewind, link, data, offset, size, 0)) > 0) {
		if (ob->size > rewind)
			ob->size -= rewind;
		else
			ob->size = 0;

		doc->md.autolink(ob, link, HOEDOWN_AUTOLINK_NORMAL, &doc->data);
	}

	popbuf(doc, BUFFER_SPAN);
	return link_len;
}

static size_t
char_image(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size) {
	size_t ret;

	if (size < 2 || data[1] != '[') return 0;

	ret = char_link(ob, doc, data + 1, offset + 1, size - 1);
	if (!ret) return 0;
	return ret + 1;
}

/* char_link • '[': parsing a link, a footnote or an image */
static size_t
char_link(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	int is_img = (offset && data[-1] == '!' && !is_escaped(data - offset, offset - 1));
	int is_footnote = (doc->ext_flags & HOEDOWN_EXT_FOOTNOTES && size > 1 && data[1] == '^');
	size_t i = 1, txt_e, link_b = 0, link_e = 0, title_b = 0, title_e = 0;
	hoedown_buffer *content = NULL;
	hoedown_buffer *link = NULL;
	hoedown_buffer *title = NULL;
	hoedown_buffer *u_link = NULL;
	hoedown_buffer *inline_attr = NULL;
	hoedown_buffer *ref_attr = NULL;
	hoedown_buffer *attr = NULL;
	hoedown_buffer *id = NULL;
	size_t org_work_size = doc->work_bufs[BUFFER_SPAN].size;
	int ret = 0, in_title = 0, qtype = 0;
	hoedown_link_type link_type = HOEDOWN_LINK_NONE;
	int ref_attr_exists = 0, inline_attr_exists = 0;

	/* checking whether the correct renderer exists */
	if ((is_footnote && !doc->md.footnote_ref) || (is_img && !doc->md.image)
		|| (!is_img && !is_footnote && !doc->md.link))
		goto cleanup;

	/* looking for the matching closing bracket */
	i += find_emph_char(data + i, size - i, ']');
	txt_e = i;

	if (i < size && data[i] == ']') i++;
	else goto cleanup;

	/* footnote link */
	if (is_footnote) {
		hoedown_buffer id = { NULL, 0, 0, 0, NULL, NULL, NULL };
		struct footnote_ref *fr;

		if (txt_e < 3)
			goto cleanup;

		id.data = data + 2;
		id.size = txt_e - 2;

		fr = find_footnote_ref(&doc->footnotes_found, id.data, id.size);

		/* mark footnote used */
		if (fr && !fr->is_used) {
			if(!add_footnote_ref(&doc->footnotes_used, fr))
				goto cleanup;
			fr->is_used = 1;
			fr->num = doc->footnotes_used.count;

			/* render */
			if (doc->md.footnote_ref) {
				doc->link_id = &id;
				ret = doc->md.footnote_ref(ob, fr->num, &doc->data);
				doc->link_id = NULL;
			}
		}

		goto cleanup;
	}

	/* skip any amount of spacing */
	/* (this is much more laxist than original markdown syntax) */
	while (i < size && _isspace(data[i]))
		i++;

	/* inline style link */
	if (i < size && data[i] == '(') {
		size_t nb_p;

		link_type = HOEDOWN_LINK_INLINE;

		/* skipping initial spacing */
		i++;

		while (i < size && _isspace(data[i]))
			i++;

		link_b = i;

		/* looking for link end: ' " ) */
		/* Count the number of open parenthesis */
		nb_p = 0;

		while (i < size) {
			if (data[i] == '\\') i += 2;
			else if (data[i] == '(' && i != 0) {
				nb_p++; i++;
			}
			else if (data[i] == ')') {
				if (nb_p == 0) break;
				else nb_p--; i++;
			} else if (i >= 1 && _isspace(data[i-1]) && (data[i] == '\'' || data[i] == '"')) break;
			else i++;
		}

		if (i >= size) goto cleanup;
		link_e = i;

		/* looking for title end if present */
		if (data[i] == '\'' || data[i] == '"') {
			qtype = data[i];
			in_title = 1;
			i++;
			title_b = i;

			while (i < size) {
				if (data[i] == '\\') i += 2;
				else if (data[i] == qtype) {in_title = 0; i++;}
				else if ((data[i] == ')') && !in_title) break;
				else i++;
			}

			if (i >= size) goto cleanup;

			/* skipping spacing after title */
			title_e = i - 1;
			while (title_e > title_b && _isspace(data[title_e]))
				title_e--;

			/* checking for closing quote presence */
			if (data[title_e] != '\'' &&  data[title_e] != '"') {
				title_b = title_e = 0;
				link_e = i;
			}
		}

		/* remove spacing at the end of the link */
		while (link_e > link_b && _isspace(data[link_e - 1]))
			link_e--;

		/* remove optional angle brackets around the link */
		if (data[link_b] == '<' && data[link_e - 1] == '>') {
			link_b++;
			link_e--;
		}

		/* building escaped link and title */
		if (link_e > link_b) {
			link = newbuf(doc, BUFFER_SPAN);
			hoedown_buffer_put(link, data + link_b, link_e - link_b);
		}

		if (title_e > title_b) {
			title = newbuf(doc, BUFFER_SPAN);
			hoedown_buffer_put(title, data + title_b, title_e - title_b);
		}

		i++;
	}

	/* reference style link */
	else if (i < size && data[i] == '[') {
		struct link_ref *lr;

		id = newbuf(doc, BUFFER_SPAN);

		/* looking for the id */
		i++;
		link_b = i;
		while (i < size && data[i] != ']') i++;
		if (i >= size) goto cleanup;
		link_e = i;

		/* finding the link_ref */
		if (link_b == link_e) {
			link_type = HOEDOWN_LINK_EMPTY_REFERENCE;
			replace_spacing(id, data + 1, txt_e - 1);
		} else {
			link_type = HOEDOWN_LINK_REFERENCE;
			hoedown_buffer_put(id, data + link_b, link_e - link_b);
		}

		lr = find_link_ref(doc->refs, id->data, id->size);
		if (!lr)
			goto cleanup;

		/* keeping link and title from link_ref */
		link = lr->link;
		title = lr->title;
		ref_attr = lr->attr;
		i++;
	}

	/* shortcut reference style link */
	else {
		struct link_ref *lr;

		id = newbuf(doc, BUFFER_SPAN);

		link_type = HOEDOWN_LINK_SHORTCUT;

		/* crafting the id */
		replace_spacing(id, data + 1, txt_e - 1);

		/* finding the link_ref */
		lr = find_link_ref(doc->refs, id->data, id->size);
		if (!lr)
			goto cleanup;

		/* keeping link and title from link_ref */
		link = lr->link;
		title = lr->title;
		ref_attr = lr->attr;

		/* rewinding the spacing */
		i = txt_e + 1;
	}

	/* building content: img alt is kept, only link content is parsed */
	if (txt_e > 1) {
		content = newbuf(doc, BUFFER_SPAN);
		if (is_img) {
			hoedown_buffer_put(content, data + 1, txt_e - 1);
		} else {
			/* disable autolinking when parsing inline the
			 * content of a link */
			doc->in_link_body = 1;
			parse_inline(content, doc, data + 1, txt_e - 1);
			doc->in_link_body = 0;
		}
	}

	if (link) {
		u_link = newbuf(doc, BUFFER_SPAN);
		unscape_text(u_link, link);
	}

	/* if special attributes are enabled, attempt to parse an inline one from
	 * the link */
	if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
		/* attr is a span because cleanup code depends on it being span */
		inline_attr = newbuf(doc, BUFFER_SPAN);
		i += parse_inline_attributes(data + i, size - i, inline_attr, doc->attr_activation);
	}

	/* remove optional < and > around inline and ref special attributes */
	if (ref_attr && ref_attr->size > 0) {
		if (ref_attr->size > 1) {
			if (ref_attr->data[0] == '<') {
				hoedown_buffer_slurp(ref_attr, 1);
			}
			if (ref_attr->data[ref_attr->size - 1] == '>') {
				ref_attr->size--;
			}
		}
	}
	if (inline_attr && inline_attr->size > 0) {
		if (inline_attr->size > 1) {
			if (inline_attr->data[0] == '<') {
				hoedown_buffer_slurp(inline_attr, 1);
			}
			if (inline_attr->data[inline_attr->size - 1] == '>') {
				inline_attr->size--;
			}
		}
	}

	/* construct the final attr that is actually applied to the link */
	ref_attr_exists = ref_attr && ref_attr->size > 0;
	inline_attr_exists = inline_attr && inline_attr->size > 0;
	if (ref_attr_exists || inline_attr_exists) {
		attr = newbuf(doc, BUFFER_SPAN);
		if (ref_attr_exists) {
			hoedown_buffer_put(attr, ref_attr->data, ref_attr->size);
		}
		/* if both inline and ref attrs exist, join them with a space to prevent
		 * conflicts */
		if (ref_attr_exists && inline_attr_exists) {
			hoedown_buffer_putc(attr, ' ');
		}
		if (inline_attr_exists) {
			hoedown_buffer_put(attr, inline_attr->data, inline_attr->size);
		}
	}

	/* calling the relevant rendering function */
	doc->link_id = id;
	doc->link_type = link_type;
	doc->link_ref_attr = ref_attr;
	doc->link_inline_attr = inline_attr;
	if (is_img) {
		ret = doc->md.image(ob, u_link, title, content, attr, &doc->data);
	} else {
		ret = doc->md.link(ob, content, u_link, title, attr, &doc->data);
	}
	doc->link_inline_attr = NULL;
	doc->link_ref_attr = NULL;
	doc->link_type = HOEDOWN_LINK_NONE;
	doc->link_id = NULL;

	/* cleanup */
cleanup:
	doc->work_bufs[BUFFER_SPAN].size = (int)org_work_size;
	return ret ? i : 0;
}

static size_t
char_superscript(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	size_t sup_start, sup_len;
	hoedown_buffer *sup;

	if (!doc->md.superscript)
		return 0;

	if (size < 2)
		return 0;

	if (data[1] == '(') {
		sup_start = 2;
		sup_len = find_emph_char(data + 2, size - 2, ')') + 2;

		if (sup_len == size)
			return 0;
	} else {
		sup_start = sup_len = 1;

		while (sup_len < size && !_isspace(data[sup_len]))
			sup_len++;
	}

	if (sup_len - sup_start == 0)
		return (sup_start == 2) ? 3 : 0;

	sup = newbuf(doc, BUFFER_SPAN);
	parse_inline(sup, doc, data + sup_start, sup_len - sup_start);
	doc->md.superscript(ob, sup, &doc->data);
	popbuf(doc, BUFFER_SPAN);

	return (sup_start == 2) ? sup_len + 1 : sup_len;
}

static size_t
char_math(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t offset, size_t size)
{
	/* double dollar */
	if (size > 1 && data[1] == '$')
		return parse_math(ob, doc, data, offset, size, "$$", 2, 1);

	/* single dollar allowed only with MATH_EXPLICIT flag */
	if (doc->ext_flags & HOEDOWN_EXT_MATH_EXPLICIT)
		return parse_math(ob, doc, data, offset, size, "$", 1, 0);

	return 0;
}

/*********************************
 * BLOCK-LEVEL PARSING FUNCTIONS *
 *********************************/

/* is_empty • returns the line length when it is empty, 0 otherwise */
static size_t
is_empty(const uint8_t *data, size_t size)
{
	size_t i;

	for (i = 0; i < size && data[i] != '\n'; i++)
		if (data[i] != ' ')
			return 0;

	return i + 1;
}

/* is_hrule • returns whether a line is a horizontal rule */
static int
is_hrule(uint8_t *data, size_t size)
{
	size_t i = 0, n = 0;
	uint8_t c;

	/* skipping initial spaces */
	if (size < 3) return 0;
	if (data[0] == ' ') { i++;
	if (data[1] == ' ') { i++;
	if (data[2] == ' ') { i++; } } }

	/* looking at the hrule uint8_t */
	if (i + 2 >= size
	|| (data[i] != '*' && data[i] != '-' && data[i] != '_'))
		return 0;
	c = data[i];

	/* the whole line must be the char or space */
	while (i < size && data[i] != '\n') {
		if (data[i] == c) n++;
		else if (data[i] != ' ')
			return 0;

		i++;
	}

	return n >= 3;
}

/* check if a line is a code fence; return the
 * end of the code fence. if passed, width of
 * the fence rule and character will be returned */
static size_t
is_codefence(uint8_t *data, size_t size, size_t *width, uint8_t *chr)
{
	size_t i = 0, n = 1;
	uint8_t c;

	/* skipping initial spaces */
	if (size < 3)
		return 0;

	if (data[0] == ' ') { i++;
	if (data[1] == ' ') { i++;
	if (data[2] == ' ') { i++; } } }

	/* looking at the hrule uint8_t */
	c = data[i];
	if (i + 2 >= size || !(c=='~' || c=='`'))
		return 0;

	/* the fence must be that same character */
	while (++i < size && data[i] == c)
		++n;

	if (n < 3)
		return 0;

	if (width) *width = n;
	if (chr) *chr = c;
	return i;
}

/* expects single line, checks if it's a codefence and extracts language */
static int
parse_codefence(hoedown_document *doc, uint8_t *data, size_t size, hoedown_buffer *lang, size_t *width, uint8_t *chr, unsigned int flags, hoedown_buffer *attr)
{
	size_t i, w, lang_start, attr_start = 0;

	i = w = is_codefence(data, size, width, chr);
	if (i == 0)
		return 0;

	while (i < size && _isspace(data[i]))
		i++;

	lang_start = i;

	if (flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
		attr_start = i + parse_attributes(data + i, size - i, attr, NULL, "", 0, 0, doc->attr_activation);
		while (i < attr_start) {
			if (_isspace(data[i])) {
				break;
			}
			i++;
		}
	} else {
		while (i < size && !_isspace(data[i]))
			i++;
	}

	lang->data = data + lang_start;
	lang->size = i - lang_start;

	/* Avoid parsing a codespan as a fence */
	i = lang_start + 2;
	while (i < size && !(data[i] == *chr && data[i-1] == *chr && data[i-2] == *chr)) i++;
	if (i < size) return 0;

	return w;
}

/* is_atxheader • returns whether the line is a hash-prefixed header */
static int
is_atxheader(hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t level = 0, begin = 0, len;
	uint8_t *p;

	if (data[0] != '#')
		return 0;

	while (level < size && level < 6 && data[level] == '#')
		level++;

	if (level >= size || data[level] == '\n') {
			return 0;
	}

	len = size - level;
	p = memchr(data + level, '\n', len);
	if (p) {
		len = p - (data + level) + 1;
	}

	/* if the header is only whitespace, it is not a header */
	if (len && is_empty_all(data + level, len)) {
		return 0;
	}

	if ((doc->ext_flags & HOEDOWN_EXT_SPACE_HEADERS) && level < size && data[level] != ' ') {
		return 0;
	}

	/* if the header is only special attribute, it is not a header */
	if (len && (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE)) {
		p = memchr(data + level, '{', len);
		if (p) {
			/* get number of characters from # to { */
			begin = p - (data + level);
			if (begin > 0 && !is_empty_all(data + level, begin)) {
				return 1;
			}
			/* check for special attributes after the # */
			return !parse_inline_attributes(data + level + begin, len - begin, NULL, doc->attr_activation);
		}
	}

	return 1;
}

/* is_headerline • returns whether the line is a setext-style hdr underline */
static int
is_headerline(uint8_t *data, size_t size)
{
	size_t i = 0;

	/* test of level 1 header */
	if (data[i] == '=') {
		for (i = 1; i < size && data[i] == '='; i++);
		while (i < size && data[i] == ' ') i++;
		return (i >= size || data[i] == '\n') ? 1 : 0; }

	/* test of level 2 header */
	if (data[i] == '-') {
		for (i = 1; i < size && data[i] == '-'; i++);
		while (i < size && data[i] == ' ') i++;
		return (i >= size || data[i] == '\n') ? 2 : 0; }

	return 0;
}

static int
is_next_headerline(uint8_t *data, size_t size)
{
	size_t i = 0;

	while (i < size && data[i] != '\n')
		i++;

	if (++i >= size)
		return 0;

	return is_headerline(data + i, size - i);
}

/* prefix_quote • returns blockquote prefix length */
static size_t
prefix_quote(uint8_t *data, size_t size)
{
	size_t i = 0;
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;

	if (i < size && data[i] == '>') {
		if (i + 1 < size && data[i + 1] == ' ')
			return i + 2;

		return i + 1;
	}

	return 0;
}

/* prefix_code • returns prefix length for block code*/
static size_t
prefix_code(uint8_t *data, size_t size)
{
	if (size > 3 && data[0] == ' ' && data[1] == ' '
		&& data[2] == ' ' && data[3] == ' ') return 4;

	return 0;
}

/* prefix_oli • returns ordered list item prefix */
static size_t
prefix_oli(uint8_t *data, size_t size)
{
	size_t i = 0;

	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;

	if (i >= size || data[i] < '0' || data[i] > '9')
		return 0;

	while (i < size && data[i] >= '0' && data[i] <= '9')
		i++;

	if (i + 1 >= size || data[i] != '.' || data[i + 1] != ' ')
		return 0;

	if (is_next_headerline(data + i, size - i))
		return 0;

	return i + 2;
}

/* prefix_uli • returns unordered list item prefix */
static size_t
prefix_uli(uint8_t *data, size_t size)
{
	size_t i = 0;

	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;

	if (i + 1 >= size ||
		(data[i] != '*' && data[i] != '+' && data[i] != '-') ||
		data[i + 1] != ' ')
		return 0;

	if (is_next_headerline(data + i, size - i))
		return 0;

	return i + 2;
}

/* prefix_dt • returns dictionary definition prefix
 * this is in the form of /\s{0,3}:/ (e.g. "  :", where spacing is optional) */
static size_t
prefix_dt(uint8_t *data, size_t size)
{
	size_t i = 0;

	/* skip up to 3 whitespaces (since it's an indented codeblock at 4) */
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;
	if (i < size && data[i] == ' ') i++;

	/* if the first character after whitespaces isn't :, it isn't a dt */
	if (i + 1 >= size ||
		data[i] != ':' ||
		data[i + 1] != ' ')
		return 0;

	if (is_next_headerline(data + i, size - i))
		return 0;

	return i + 2;
}

/* is_paragraph • returns if the next block is a paragraph (doesn't follow any
 * other special rules for other types of blocks) */
static int
is_paragraph(hoedown_document *doc, uint8_t *txt_data, size_t end);

/* prefix_dli • returns dictionary definition prefix
 * a dli looks like a block of text, followed by optional whitespace, followed
 * by another block with : as the first non-whitespace character */
static size_t
prefix_dli(hoedown_document *doc, uint8_t *data, size_t size)
{
	/* end is to keep track of the final return value */
	size_t i = 0, j = 0, end = 0;
	int empty = 0;

	/* if the first line has a : in front of it, it can't be a definition list
	 * that starts at this point */
	if (prefix_dt(data, size)) {
		return 0;
	}

	/* temporarily toggle definition lists off to prevent infinite loops */
	doc->ext_flags &= ~HOEDOWN_EXT_DEFINITION_LISTS;

	/* check if it is a block of text with no double newlines inside, followed by
	 *  another block of text starting with : */
	while (i < size) {
		/* if the line we are on is empty, flip the empty flag to indicate that
		 * the next block of text we see has to start with : to be considered
		 * a definition list; then skip to the next line */
		j = is_empty(data + i, size - i);
		if(j != 0) {
			empty = 1;
			i += j;
			continue;
		}

		/* if anything special is found while parsing the definition term part,
		 * then return so that the main loop can deal with it */
		if (!is_paragraph(doc, data + i, size - i)) {
			break;
		}

		/* check if the current line starts with :, returning the position of the
		 * beginning of the line if it does */
		j = prefix_dt(data + i, size - i);
		if (j > 0) {
			end = i;
			break;
		} else if(empty) {
			/* if an empty newline has been found, then since : was not the first
			 * character after whitespaces, it can't be a definition list */
			break;
		}
		/* scan characters until the next newline */
		for (i = i + 1; i < size && data[i - 1] != '\n'; i++);
	}

	doc->ext_flags |= HOEDOWN_EXT_DEFINITION_LISTS;
	return end;
}

/* parse_block • parsing of one block, returning next uint8_t to parse */
static void parse_block(hoedown_buffer *ob, hoedown_document *doc,
			uint8_t *data, size_t size);


/* parse_blockquote • handles parsing of a blockquote fragment */
static size_t
parse_blockquote(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t beg, end = 0, pre, work_size = 0;
	uint8_t *work_data = 0;
	hoedown_buffer *out = 0;

	doc->blockquote_depth++;

	out = newbuf(doc, BUFFER_BLOCK);
	beg = 0;
	while (beg < size) {
		for (end = beg + 1; end < size && data[end - 1] != '\n'; end++);

		pre = prefix_quote(data + beg, end - beg);

		if (pre)
			beg += pre; /* skipping prefix */

		/* empty line finished */
		else if ((doc->ext_flags & HOEDOWN_EXT_BLOCKQUOTE_EMPTY_LINE) &&
				(is_empty(data + beg, end - beg)))
			break;

		/* empty line followed by non-quote line */
		else if (is_empty(data + beg, end - beg) &&
				(end >= size || (prefix_quote(data + end, size - end) == 0 &&
				!is_empty(data + end, size - end))))
			break;

		if (beg < end) { /* copy into the in-place working buffer */
			/* hoedown_buffer_put(work, data + beg, end - beg); */
			if (!work_data)
				work_data = data + beg;
			else if (data + beg != work_data + work_size)
				memmove(work_data + work_size, data + beg, end - beg);
			work_size += end - beg;
		}
		beg = end;
	}

	parse_block(out, doc, work_data, work_size);
	if (doc->md.blockquote)
		doc->md.blockquote(ob, out, &doc->data);
	popbuf(doc, BUFFER_BLOCK);

	doc->blockquote_depth--;

	return end;
}

static size_t
parse_htmlblock(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, int do_render);

/* parse_paragraph • handles parsing of a regular paragraph */
static size_t
parse_paragraph(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	hoedown_buffer work = { NULL, 0, 0, 0, NULL, NULL, NULL };
	size_t i = 0, end = 0;
	int level = 0;

	work.data = data;

	while (i < size) {
		for (end = i + 1; end < size && data[end - 1] != '\n'; end++) /* empty */;

		if (is_empty(data + i, size - i))
			break;

		if ((level = is_headerline(data + i, size - i)) != 0) {
			if (i == 0) {
				level = 0;
				i = end;
			}
			break;
		}

		if (is_atxheader(doc, data + i, size - i) ||
			is_hrule(data + i, size - i) ||
			prefix_quote(data + i, size - i)) {
			end = i;
			break;
		}

		i = end;
	}

	work.size = i;
	while (work.size && data[work.size - 1] == '\n')
		work.size--;

	if (!level) {
		hoedown_buffer *attr = newbuf(doc, BUFFER_ATTRIBUTE);
		if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
			parse_attributes(work.data, work.size, NULL, attr, "paragraph", 9, 1, doc->attr_activation);
			if (attr->size > 0) {
				/* remove the length of the attribute from the work size - the 12 comes
				* from the leading space (1), the paragraph (9), the @ symbol (1), and
				* the {} (2) (any extra spaces in the attribute are included inside
				* the attribute) */
				work.size -= attr->size + 12;
			}
		}

		hoedown_buffer *tmp = newbuf(doc, BUFFER_BLOCK);
		parse_inline(tmp, doc, work.data, work.size);
		if (doc->md.paragraph)
			doc->md.paragraph(ob, tmp, attr, &doc->data);
		popbuf(doc, BUFFER_BLOCK);
		popbuf(doc, BUFFER_ATTRIBUTE);
	} else {
		hoedown_buffer *header_work;
		hoedown_buffer *attr_work;
		size_t len;

		if (work.size) {
			size_t beg;
			i = work.size;
			work.size -= 1;

			while (work.size && data[work.size] != '\n')
				work.size -= 1;

			beg = work.size + 1;
			while (work.size && data[work.size - 1] == '\n')
				work.size -= 1;

			if (work.size > 0) {
				hoedown_buffer *tmp = newbuf(doc, BUFFER_BLOCK);
				parse_inline(tmp, doc, work.data, work.size);

				if (doc->md.paragraph)
					doc->md.paragraph(ob, tmp, NULL, &doc->data);

				popbuf(doc, BUFFER_BLOCK);
				work.data += beg;
				work.size = i - beg;
			}
			else work.size = i;
		}

		header_work = newbuf(doc, BUFFER_SPAN);
		attr_work = newbuf(doc, BUFFER_ATTRIBUTE);

		len = work.size;
		if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
			len = parse_attributes(work.data, work.size, attr_work, NULL, "", 0, 1, doc->attr_activation);
		}

		parse_inline(header_work, doc, work.data, len);

		if (doc->md.header) {
			doc->header_type = HOEDOWN_HEADER_SETEXT;
			doc->md.header(ob, header_work, attr_work, (int)level, &doc->data);
			doc->header_type = HOEDOWN_HEADER_NONE;
		}

		popbuf(doc, BUFFER_SPAN);
		popbuf(doc, BUFFER_ATTRIBUTE);
	}

	return end;
}

/* parse_fencedcode • handles parsing of a block-level code fragment */
static size_t
parse_fencedcode(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, unsigned int flags)
{
	hoedown_buffer text = { 0, 0, 0, 0, NULL, NULL, NULL };
	hoedown_buffer lang = { 0, 0, 0, 0, NULL, NULL, NULL };
	size_t i = 0, text_start, line_start;
	size_t w, w2;
	size_t width, width2;
	uint8_t chr, chr2;
	/* needed for parse_attribute functions as buffer functions do not work with
	 * buffers on the stack */
	hoedown_buffer *attr = newbuf(doc, BUFFER_ATTRIBUTE);


	/* parse codefence line */
	while (i < size && data[i] != '\n')
		i++;

	w = parse_codefence(doc, data, i, &lang, &width, &chr, flags, attr);
	if (!w) {
		popbuf(doc, BUFFER_ATTRIBUTE);
		return 0;
	}

	/* search for end */
	i++;
	text_start = i;
	while ((line_start = i) < size) {
		while (i < size && data[i] != '\n')
			i++;

		w2 = is_codefence(data + line_start, i - line_start, &width2, &chr2);
		if (w == w2 && width == width2 && chr == chr2 &&
			is_empty(data + (line_start+w), i - (line_start+w)))
			break;

		if (i < size) i++;
	}

	text.data = data + text_start;
	text.size = line_start - text_start;

	if (doc->md.blockcode) {
		doc->fencedcode_char = chr;
		doc->md.blockcode(ob, text.size ? &text : NULL, lang.size ? &lang : NULL, attr->size ? attr : NULL, &doc->data);
		doc->fencedcode_char = 0;
	}

	popbuf(doc, BUFFER_ATTRIBUTE);

	return i;
}

static size_t
parse_blockcode(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t beg, end, pre;
	hoedown_buffer *work = 0;
	hoedown_buffer *attr = 0;

	work = newbuf(doc, BUFFER_BLOCK);
	attr = newbuf(doc, BUFFER_ATTRIBUTE);

	beg = 0;
	while (beg < size) {
		for (end = beg + 1; end < size && data[end - 1] != '\n'; end++) {};
		pre = prefix_code(data + beg, end - beg);

		if (pre)
			beg += pre; /* skipping prefix */
		else if (!is_empty(data + beg, end - beg))
			/* non-empty non-prefixed line breaks the pre */
			break;

		if (beg < end) {
			/* verbatim copy to the working buffer,
				escaping entities */
			if (is_empty(data + beg, end - beg))
				hoedown_buffer_putc(work, '\n');
			else hoedown_buffer_put(work, data + beg, end - beg);
		}
		beg = end;
	}

	while (work->size && work->data[work->size - 1] == '\n')
		work->size -= 1;

	if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
		work->size = parse_attributes(work->data, work->size, NULL, attr, "", 0, 0, doc->attr_activation);
	}

	hoedown_buffer_putc(work, '\n');

	if (doc->md.blockcode)
		doc->md.blockcode(ob, work, NULL, attr, &doc->data);

	popbuf(doc, BUFFER_BLOCK);
	popbuf(doc, BUFFER_ATTRIBUTE);
	return beg;
}

/* parse_listitem • parsing of a single list item */
/*	assuming initial prefix is already removed */
static size_t
parse_listitem(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, hoedown_list_flags *flags, hoedown_buffer *attribute)
{
	hoedown_buffer *work = 0, *inter = 0;
	hoedown_buffer *attr = 0;
	size_t beg = 0, end, pre, sublist = 0, orgpre = 0, i, len, fence_pre = 0;
	int in_empty = 0, has_inside_empty = 0, in_fence = 0;
	uint8_t ul_item_char = '*';
	hoedown_buffer *ol_numeral = NULL;

	/* keeping track of the first indentation prefix */
	while (orgpre < 3 && orgpre < size && data[orgpre] == ' ')
		orgpre++;

	beg = prefix_uli(data, size);
	if (beg) ul_item_char = data[beg - 2];
	if (!beg) {
		beg = prefix_oli(data, size);
		if (beg) {
			ol_numeral = hoedown_buffer_new(1024);
			/* -2 to eliminate the trailing ". " */
			hoedown_buffer_put(ol_numeral, data, beg - 2);
		}
		if (*flags & HOEDOWN_LIST_DEFINITION) {
			beg = prefix_dt(data, size);
			if (beg) ul_item_char = data[beg - 2];
		}
	}

	if (!beg) {
		if (ol_numeral) hoedown_buffer_free(ol_numeral);
		return 0;
	}

	/* skipping to the beginning of the following line */
	end = beg;
	while (end < size && data[end - 1] != '\n')
		end++;

	/* getting working buffers */
	work = newbuf(doc, BUFFER_SPAN);
	inter = newbuf(doc, BUFFER_SPAN);

	/* calculating the indentation */
	i = 0;
	while (i < 4 && beg + i < end && data[beg + i] == ' ')
		i++;

	beg += i;

	/* putting the first line into the working buffer */
	hoedown_buffer_put(work, data + beg, end - beg);
	beg = end;

	attr = newbuf(doc, BUFFER_ATTRIBUTE);

	/* process the following lines */
	while (beg < size) {
		size_t has_next_uli = 0, has_next_oli = 0, has_next_dli = 0;

		end++;

		while (end < size && data[end - 1] != '\n')
			end++;

		/* process an empty line */
		if (is_empty(data + beg, end - beg)) {
			in_empty = 1;
			beg = end;
			continue;
		}

		/* calculating the indentation */
		i = 0;
		while (i < 4 && beg + i < end && data[beg + i] == ' ')
			i++;

		if (in_fence && i > fence_pre) {
			i = fence_pre;
		}

		pre = i;

		if (doc->ext_flags & HOEDOWN_EXT_FENCED_CODE) {
			if (is_codefence(data + beg + i, end - beg - i, NULL, NULL))
				in_fence = !in_fence;
			if (in_fence && fence_pre == 0) {
				fence_pre = pre;
			}
		}

		/* Only check for new list items if we are **not** inside
		 * a fenced code block */
		if (!in_fence) {
			has_next_uli = prefix_uli(data + beg + i, end - beg - i);
			has_next_oli = prefix_oli(data + beg + i, end - beg - i);

			/* only check for the next definition if it is same indentation or less
			 * since embedded definition lists need terms, so finding just a
			 * colon by itself does not mean anything */
			if (pre <= orgpre)
				has_next_dli = prefix_dt(data + beg + i, end - beg - i);
		}

		/* checking for a new item */
		if ((has_next_uli && !is_hrule(data + beg + i, end - beg - i)) || 
			has_next_oli || (*flags & HOEDOWN_LI_DD && has_next_dli)) {
			if (in_empty)
				has_inside_empty = 1;

			/* the following item must have the same (or less) indentation */
			if (pre <= orgpre) {
				/* if the following item has different list type, we end this list */
				if (in_empty && (
					((*flags & HOEDOWN_LIST_ORDERED) && has_next_uli) ||
					(!(*flags & HOEDOWN_LIST_ORDERED) && has_next_oli))) {
					*flags |= HOEDOWN_LI_END;
					has_inside_empty = 0;
				}
				break;
			}

			if (!sublist)
				sublist = work->size;
		}
		/* joining only indented stuff after empty lines;
		 * note that now we only require 1 space of indentation
		 * to continue a list */
		else if (in_empty && pre == 0) {
			*flags |= HOEDOWN_LI_END;
			break;
		}

		if (in_empty) {
			hoedown_buffer_putc(work, '\n');
			has_inside_empty = 1;
			in_empty = 0;
		}

		/* adding the line without prefix into the working buffer */
		hoedown_buffer_put(work, data + beg + i, end - beg - i);
		beg = end;
	}

	/* render of li contents */
	if (has_inside_empty)
		*flags |= HOEDOWN_LI_BLOCK;

	if (*flags & HOEDOWN_LI_BLOCK) {
		/* intermediate render of block li */
		pre = 0;
		if (sublist && sublist < work->size) {
			end = sublist;
		} else {
			end = work->size;
		}

		do {
			if (!(doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE)) {
				break;
			}

			i = 0;
			while (i < end && work->data[i] != '\n') {
				i++;
			}

			len = parse_attributes(work->data, i, attr, attribute, "list", 4, 0, doc->attr_activation);
			if (i == len) {
				break;
			}

			pre = i;
			parse_block(inter, doc, work->data, len);
		} while (0);

		parse_block(inter, doc, work->data + pre, end - pre);
		if (end == sublist) {
			parse_block(inter, doc, work->data + sublist, work->size - sublist);
		}
	} else {
		/* intermediate render of inline li */
		if (sublist && sublist < work->size) {
			if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
				len = parse_attributes(work->data, sublist, attr, attribute, "list", 4, 0, doc->attr_activation);
			} else {
				len = sublist;
			}
			parse_inline(inter, doc, work->data, len);
			parse_block(inter, doc, work->data + sublist, work->size - sublist);
		} else {
			if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
				len = parse_attributes(work->data, work->size, attr, attribute, "list", 4, 0, doc->attr_activation);
			} else {
				len = work->size;
			}
			parse_inline(inter, doc, work->data, len);
		}
	}

	/* render of li itself */
	if (doc->md.listitem) {
		doc->ul_item_char = ul_item_char;
		doc->ol_numeral = ol_numeral;
		doc->md.listitem(ob, inter, attr, flags, &doc->data);
		doc->ol_numeral = NULL;
		doc->ul_item_char = 0;
	}

	if (ol_numeral) hoedown_buffer_free(ol_numeral);

	popbuf(doc, BUFFER_SPAN);
	popbuf(doc, BUFFER_SPAN);
	popbuf(doc, BUFFER_ATTRIBUTE);
	return beg;
}

/* parse_definition • parsing of a term/definition pair, assuming starting
 * at start of line */
static size_t
parse_definition(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, hoedown_list_flags *flags, hoedown_buffer *attribute)
{
	/* end represents the position of the first line where definitions start */
	size_t j = 0, k = 0, len = 0, end = prefix_dli(doc, data, size);
	if (end <= 0) {
		return 0;
	}
	hoedown_buffer *work = 0, *attr_work;


	/* scan all the definition terms, rendering them to the output buffer
	 * the +1 is to account for the trailing newline on each term
	 * j is a counter keeping track of the beginning of each new term */
	*flags |= HOEDOWN_LI_DT;
	while (j + 1 < end) {
		/* find the end of the term (where the newline is) */
		for(k = j + 1; k - 1 < end && data[k - 1] != '\n'; k++);

		len = k - j;

		if (is_empty(data + j, len)) {
			j = k;
			continue;
		}

		work = newbuf(doc, BUFFER_BLOCK);
		attr_work = newbuf(doc, BUFFER_ATTRIBUTE);

		if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
			len = parse_attributes(data + j, len, attr_work, NULL, "", 0, 1, doc->attr_activation);
		}

		parse_inline(work, doc, data + j, len);

		if (doc->md.listitem) {
			doc->md.listitem(ob, work, attr_work, flags, &doc->data);
		}

		j = k;

		popbuf(doc, BUFFER_BLOCK);
		popbuf(doc, BUFFER_ATTRIBUTE);
	}
	*flags &= ~HOEDOWN_LI_DT;

	/* scan all the definitions, rendering it to the output buffer */
	*flags |= HOEDOWN_LI_DD;
	while (end < size) {
		j = parse_listitem(ob, doc, data + end, size - end, flags, attribute);
		if (j <= 0) {
			break;
		}
		end += j;
	}

	*flags &= ~HOEDOWN_LI_DD;
	*flags &= ~HOEDOWN_LI_END;

	return end;
}

/* parse_list • parsing ordered or unordered list block */
static size_t
parse_list(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, hoedown_list_flags flags)
{
	hoedown_buffer *work = 0;
	hoedown_buffer *attr = 0;
	size_t i = 0, j;

	doc->list_depth++;

	work = newbuf(doc, BUFFER_BLOCK);
	attr = newbuf(doc, BUFFER_ATTRIBUTE);

	while (i < size) {
		if (flags & HOEDOWN_LIST_DEFINITION) {
			j = parse_definition(work, doc, data + i, size - i, &flags, attr);
		} else {
			j = parse_listitem(work, doc, data + i, size - i, &flags, attr);
		}
		i += j;

		if (!j || (flags & HOEDOWN_LI_END))
			break;
	}

	if (doc->md.list)
		doc->md.list(ob, work, attr, flags, &doc->data);
	popbuf(doc, BUFFER_BLOCK);
	popbuf(doc, BUFFER_ATTRIBUTE);

	doc->list_depth--;

	return i;
}

/* parse_atxheader • parsing of atx-style headers */
static size_t
parse_atxheader(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t level = 0;
	size_t i, end, skip;

	while (level < size && level < 6 && data[level] == '#')
		level++;

	for (i = level; i < size && data[i] == ' '; i++);

	for (end = i; end < size && data[end] != '\n'; end++);
	skip = end;

	while (end && data[end - 1] == '#')
		end--;

	while (end && data[end - 1] == ' ')
		end--;

	if (end > i) {
		hoedown_buffer *work = newbuf(doc, BUFFER_SPAN);
		hoedown_buffer *attr = newbuf(doc, BUFFER_ATTRIBUTE);
		size_t len;

		len = end - i;
		if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
			len = parse_attributes(data + i, end - i, attr, NULL, "", 0, 1, doc->attr_activation);
		}

		parse_inline(work, doc, data + i, len);

		if (doc->md.header) {
			doc->header_type = HOEDOWN_HEADER_ATX;
			doc->md.header(ob, work, attr, (int)level, &doc->data);
			doc->header_type = HOEDOWN_HEADER_NONE;
		}

		popbuf(doc, BUFFER_SPAN);
		popbuf(doc, BUFFER_ATTRIBUTE);
	} else {
		doc->md.header(ob, NULL, NULL, (int)level, &doc->data);
	}

	return skip;
}

/* parse_footnote_def • parse a single footnote definition */
static void
parse_footnote_def(hoedown_buffer *ob, hoedown_document *doc, unsigned int num, const hoedown_buffer *name, uint8_t *data, size_t size)
{
	hoedown_buffer *work = 0;
	work = newbuf(doc, BUFFER_SPAN);
	doc->footnote_id = name;

	parse_block(work, doc, data, size);

	if (doc->md.footnote_def)
	doc->md.footnote_def(ob, work, num, &doc->data);

	doc->footnote_id = NULL;
	popbuf(doc, BUFFER_SPAN);
}

/* parse_footnote_list • render the contents of the footnotes */
static void
parse_footnote_list(hoedown_buffer *ob, hoedown_document *doc, struct footnote_list *footnotes)
{
	hoedown_buffer *work = 0;
	struct footnote_item *item;
	struct footnote_ref *ref;

	if (footnotes->count == 0)
		return;

	work = newbuf(doc, BUFFER_BLOCK);

	item = footnotes->head;
	while (item) {
		ref = item->ref;
		parse_footnote_def(work, doc, ref->num, ref->name, ref->contents->data, ref->contents->size);
		item = item->next;
	}

	if (doc->md.footnotes)
		doc->md.footnotes(ob, work, &doc->data);
	popbuf(doc, BUFFER_BLOCK);
}

/* htmlblock_is_end • check for end of HTML block : </tag>( *)\n */
/*	returns tag length on match, 0 otherwise */
/*	assumes data starts with "<" */
static size_t
htmlblock_is_end(
	const char *tag,
	size_t tag_len,
	hoedown_document *doc,
	uint8_t *data,
	size_t size)
{
	size_t i = tag_len + 3, w;

	/* try to match the end tag */
	/* note: we're not considering tags like "</tag >" which are still valid */
	if (i > size ||
		data[1] != '/' ||
		strncasecmp((char *)data + 2, tag, tag_len) != 0 ||
		data[tag_len + 2] != '>')
		return 0;

	/* rest of the line must be empty */
	if ((w = is_empty(data + i, size - i)) == 0 && i < size)
		return 0;

	return i + w;
}

/* htmlblock_find_end • try to find HTML block ending tag */
/*	returns the length on match, 0 otherwise */
static size_t
htmlblock_find_end(
	const char *tag,
	size_t tag_len,
	hoedown_document *doc,
	uint8_t *data,
	size_t size)
{
	size_t i = 0, w;

	while (1) {
		while (i < size && data[i] != '<') i++;
		if (i >= size) return 0;

		w = htmlblock_is_end(tag, tag_len, doc, data + i, size - i);
		if (w) return i + w;
		i++;
	}
}

/* htmlblock_find_end_strict • try to find end of HTML block in strict mode */
/*	(it must have a blank line or a new HTML tag afterwards) */
/*	returns the length on match, 0 otherwise */
static size_t
htmlblock_find_end_strict(
	const char *tag,
	size_t tag_len,
	hoedown_document *doc,
	uint8_t *data,
	size_t size)
{
	size_t i = 0, mark;

	while (1) {
		mark = i;
		while (i < size && data[i] != '\n') i++;
		if (i < size) i++;
		if (i == mark) return 0;

		mark += htmlblock_find_end(tag, tag_len, doc, data + mark, i - mark);
		if (mark == i && (is_empty(data + i, size - i) || (i + 1 < size && data[i] == '<' && data[i + 1] != '/') || i >= size)) break;
	}

	return i;
}

/* parse_htmlblock • parsing of inline HTML block */
static size_t
parse_htmlblock(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size, int do_render)
{
	hoedown_buffer work = { NULL, 0, 0, 0, NULL, NULL, NULL };
	size_t i, j = 0, tag_len, tag_end;
	const char *curtag = NULL;
	int meta = 0;

	work.data = data;

	/* identification of the opening tag */
	if (size < 2 || data[0] != '<')
		return 0;

	i = 1;
	while (i < size && data[i] != '>' && data[i] != ' ')
		i++;

	if (i < size) {
		if (doc->ext_flags & HOEDOWN_EXT_HTML5_BLOCKS)
			curtag = hoedown_find_html5_block_tag((char *)data + 1, (int)i - 1);
		else
			curtag = hoedown_find_block_tag((char *)data + 1, (int)i - 1);
	}	

	/* handling of special cases */
	if (!curtag) {

		/* HTML comment, laxist form */
		if (size > 5 && data[1] == '!' && data[2] == '-' && data[3] == '-') {
			i = 5;

			if (data[4] == '*') {
				meta++;
			}

			while (i < size && !(data[i - 2] == '-' && data[i - 1] == '-' && data[i] == '>'))
				i++;

			if (data[i - 3] == '*') {
				meta++;
			}

			i++;

			if (i < size)
				j = is_empty(data + i, size - i);

			if (j) {
				work.size = i + j;

				if (do_render && doc->ext_flags & HOEDOWN_EXT_META_BLOCK &&
					meta == 2 && doc->meta) {
					size_t org, sz;

					sz = work.size - 5;
					while (sz > 0 && work.data[sz - 1] == '\n') {
						sz--;
					}

					org = 5;
					while (org < sz && work.data[org] == '\n') {
						org++;
					}

					if (org < sz) {
						hoedown_buffer_put(doc->meta, work.data + org, sz - org);
						hoedown_buffer_putc(doc->meta, '\n');
					}
				} else if (do_render && doc->md.blockhtml) {
					doc->md.blockhtml(ob, &work, &doc->data);
				}
				return work.size;
			}
		}

		/* HR, which is the only self-closing block tag considered */
		if (size > 4 && (data[1] == 'h' || data[1] == 'H') && (data[2] == 'r' || data[2] == 'R')) {
			i = 3;
			while (i < size && data[i] != '>')
				i++;

			if (i + 1 < size) {
				i++;
				j = is_empty(data + i, size - i);
				if (j) {
					work.size = i + j;
					if (do_render && doc->md.blockhtml)
						doc->md.blockhtml(ob, &work, &doc->data);
					return work.size;
				}
			}
		}

		/* Extension script tags */
		if (doc->ext_flags & HOEDOWN_EXT_SCRIPT_TAGS) {
			i = script_tag_length(data, size);
			if (i) {
				if (i < size) {
					j = is_empty(data + i, size - i);
				}

				if (j) {
					work.size = i + j;
					if (do_render && doc->md.blockhtml) {
						doc->md.blockhtml(ob, &work, &doc->data);
					}
					return work.size;
				}
			}

		}

		/* no special case recognised */
		return 0;
	}

	/* looking for a matching closing tag in strict mode */
	tag_len = strlen(curtag);
	tag_end = htmlblock_find_end_strict(curtag, tag_len, doc, data, size);

	/* if not found, trying a second pass looking for indented match */
	/* but not if tag is "ins" or "del" (following original Markdown.pl) */
	if (!tag_end && strcmp(curtag, "ins") != 0 && strcmp(curtag, "del") != 0)
		tag_end = htmlblock_find_end(curtag, tag_len, doc, data, size);

	if (!tag_end)
		return 0;

	/* the end of the block has been found */
	work.size = tag_end;
	if (do_render && doc->md.blockhtml)
		doc->md.blockhtml(ob, &work, &doc->data);

	return tag_end;
}

/* Common function to parse table main rows and continued rows. */
static size_t
parse_table_cell_line(
		hoedown_buffer *ob,
		uint8_t *data,
		size_t size,
		size_t offset,
		char separator,
		int is_continuation) {
	size_t pos, line_end, cell_start, cell_end, len, copy_start, copy_end;

	pos = offset;

	while (pos < size && _isspace(data[pos])) pos++;

	cell_start = pos;

	line_end = pos;
	while (line_end < size && data[line_end] != '\n') line_end++;
	len = find_separator_char(data + pos, line_end - pos, separator);

	/* Two possibilities for len == 0:
	   1) No more separator char found in the current line.
	   2) The next separator is right after the current one, i.e. empty cell.
	   For case 1, we skip to the end of line; for case 2 we just continue.
	*/
	if (len == 0 && pos < size && data[pos] != separator) {
		while (pos + len < size && data[pos + len] != '\n') len++;
	}
	pos += len;

	cell_end = pos - 1;

	while (cell_end > cell_start && _isspace(data[cell_end]))
		cell_end--;

	/* If this isn't the first line of the cell, add a new line before the
	   extra cell contents, to separate them (and make backslash linebreaks
	   work).
	*/
	if (is_continuation) hoedown_buffer_putc(ob, '\n');

	/* Remove escaping from pipes */
	copy_start = copy_end = cell_start;
	while (copy_end < cell_end + 1) {
		if (data[copy_end] == separator && copy_end > copy_start && data[copy_end - 1] == '\\') {
			hoedown_buffer_put(ob, data + copy_start, copy_end - copy_start - 1);
			copy_start = copy_end;
		}
		copy_end++;
	}
	hoedown_buffer_put(ob, data + copy_start, copy_end - copy_start);

	return pos - offset;
}

static void
parse_table_row(
	hoedown_buffer *ob,
	hoedown_document *doc,
	uint8_t *data,
	size_t size,
	size_t columns,
	size_t rows,
	hoedown_table_flags *col_data,
	hoedown_table_flags header_flag)
{
	size_t i = 0, col;
	hoedown_buffer *row_work = 0;

	if (!doc->md.table_cell || !doc->md.table_row)
		return;

	row_work = newbuf(doc, BUFFER_SPAN);

	/* skip optional first pipe */
	if (i < size && data[i] == '|')
		i++;

	for (col = 0; col < columns && i < size; ++col) {
		size_t pos, extra_rows_in_cell;
		hoedown_buffer *cell_content;
		hoedown_buffer *cell_work;

		/* cell_content is the text that is inline parsed into cell_work. It
		   consists of the values of this cell from each row, concatenated and
		   separated by new lines.
		*/
		cell_content = newbuf(doc, BUFFER_SPAN);
		cell_work = newbuf(doc, BUFFER_SPAN);

		i += parse_table_cell_line(cell_content, data, size, i, '|', 0 /* is_contination */);

		/* Add extra rows of the cell. This only occurs if rows is greater than 0,
		   which only happens when multiline tables are enabled.

		   Each extra row is a colon, followed by cell contents for the continued
		   row, separated by colons.
		*/
		extra_rows_in_cell = rows - 1;
		pos = i;
		while (extra_rows_in_cell > 0 && pos < size) {
			size_t c;

			/* seek to the end of the current row */
			while (pos < size && data[pos] != '\n') {
				pos++;
			}

			/* skip new line and leading colon */
			if (pos < size) pos++;
			if (pos < size) pos++;

			/* Seek to the beginning of the correct column on the continuation line.
			 * The continuation line should have the expected number of columns, and
			 * so we never expect pos >= size or data[pos] == '\n'. These checks serve
			 * as defense in depth against wrong preconditions. */
			for (c = 0; c < col; c++) {
				while (pos < size && data[pos] != '\n' && (is_backslashed(data, pos) || data[pos] != ':'))
					pos++;
				if (pos < size && data[pos] == ':') pos++;  /* skip colon */
			}

			parse_table_cell_line(cell_content, data, size, pos, ':', 1 /* is_contination */);

			extra_rows_in_cell--;
		}

		parse_inline(cell_work, doc, cell_content->data, cell_content->size);

		doc->md.table_cell(row_work, cell_work, col_data[col] | header_flag, &doc->data);

		popbuf(doc, BUFFER_SPAN);
		popbuf(doc, BUFFER_SPAN);
		i++;
	}

	for (; col < columns; ++col) {
		hoedown_buffer empty_cell = { 0, 0, 0, 0, NULL, NULL, NULL };
		doc->md.table_cell(row_work, &empty_cell, col_data[col] | header_flag, &doc->data);
	}

	doc->md.table_row(ob, row_work, &doc->data);

	popbuf(doc, BUFFER_SPAN);
}

static size_t
parse_table_header(
	hoedown_buffer *ob,
	hoedown_buffer *attr,
	hoedown_document *doc,
	uint8_t *data,
	size_t size,
	size_t *columns,
	hoedown_table_flags **column_data)
{
	int pipes, rows;
	size_t i = 0, col, header_end, under_end;
	hoedown_buffer *header_contents = 0;

	pipes = 0;
	while (i < size && data[i] != '\n') {
		if (!is_backslashed(data, i) && data[i] == '|') {
			pipes++;
		}
		i++;
	}

	if (i == size || pipes == 0)
		return 0;

	header_end = i;

	while (header_end > 0 && _isspace(data[header_end - 1]))
		header_end--;

	if (data[0] == '|')
		pipes--;

	if (header_end && data[header_end - 1] == '|' && !is_backslashed(data, header_end - 1))
		pipes--;

	if (doc->ext_flags & HOEDOWN_EXT_SPECIAL_ATTRIBUTE) {
		size_t n = parse_attributes(data, header_end, attr, NULL, "", 0, 1, doc->attr_activation);
		/* n == header_end when no attribute is found */
		if (n != header_end) {
			while (n > 0 && _isspace(data[n - 1]))
				n--;
			if (attr->size && n && data[n - 1] == '|' && !is_backslashed(data, n - 1))
				pipes--;

			header_end = n + 1;
		}
	}

	if (pipes < 0)
		return 0;

	/* header_contents will have the lines of the header copied into it, and then
	   is passed to parse_table_row. We need a separate buffer to avoid passing
	   the attribute to parse_table_row.
	*/
	header_contents = newbuf(doc, BUFFER_SPAN);
	hoedown_buffer_put(header_contents, data, header_end);

	*columns = pipes + 1;
	*column_data = hoedown_calloc(*columns, sizeof(hoedown_table_flags));

	/* If the multiline table extension is enabled, check the next lines for
	   continuation markers, to find the number of text rows that make up this
	   logical row, and copy the contents of each row to header_contents,
	   separated by new lines.
	*/
	rows = 1;
	if ((doc->ext_flags & HOEDOWN_EXT_MULTILINE_TABLES) != 0) {
		while (i < size) {
			size_t j = i + 1;
			int colons = 0;

			/* Require that the continuation line starts with a colon */
			if (j >= size || data[j] != ':') break;
			/* Skip the leading colon to match the pipe counting behavior above */
			j++;

			/* Require that the continuation line start with ": ", to
			   distinguish from ":-" which could start a left-aligned header
			   bar.
			*/
			if (j >= size || data[j] != ' ') break;

			while (j < size && data[j] != '\n') {
				j++;
				if (j < size && !is_backslashed(data, j) && data[j] == ':')
					colons++;
			}

			/* Allow a trailing colon to match the pipe counting behavior above */
			if (!is_backslashed(data, j - 1) && data[j - 1] == ':')
				colons--;

			if (colons != pipes) break;

			hoedown_buffer_putc(header_contents, '\n');
			/* data[i] is the previous new line, and data[j] is the next new
			   line. This copies all the text between the new lines.
			 */
			hoedown_buffer_put(header_contents, data + i + 1, j - i - 1);

			rows++;
			i = j;
			header_end = j;
		}
	}

	/* Parse the header underline */
	i++;
	if (i < size && data[i] == '|')
		i++;

	under_end = i;
	while (under_end < size && data[under_end] != '\n')
		under_end++;

	for (col = 0; col < *columns && i < under_end; ++col) {
		size_t dashes = 0;

		while (i < under_end && data[i] == ' ')
			i++;

		if (i < under_end && data[i] == ':') {
			i++; (*column_data)[col] |= HOEDOWN_TABLE_ALIGN_LEFT;
			dashes++;
		}

		while (i < under_end && data[i] == '-') {
			i++; dashes++;
		}

		if (i < under_end && data[i] == ':') {
			i++; (*column_data)[col] |= HOEDOWN_TABLE_ALIGN_RIGHT;
			dashes++;
		}

		while (i < under_end && data[i] == ' ')
			i++;

		if (i < under_end && data[i] != '|' && data[i] != '+')
			break;

		if (dashes < 3)
			break;

		i++;
	}

	if (col < *columns) {
		/* clean up header_contents */
		popbuf(doc, BUFFER_SPAN);
		return 0;
	}

	parse_table_row(
		ob, doc, header_contents->data,
		header_contents->size,
		*columns,
		rows,
		*column_data,
		HOEDOWN_TABLE_HEADER
	);

	/* clean up header_contents */
	popbuf(doc, BUFFER_SPAN);

	return under_end + 1;
}

static size_t
parse_table(
	hoedown_buffer *ob,
	hoedown_document *doc,
	uint8_t *data,
	size_t size)
{
	size_t i;

	hoedown_buffer *work = 0;
	hoedown_buffer *header_work = 0;
	hoedown_buffer *body_work = 0;
	hoedown_buffer *attr_work = 0;

	size_t columns;
	hoedown_table_flags *col_data = NULL;

	work = newbuf(doc, BUFFER_BLOCK);
	header_work = newbuf(doc, BUFFER_SPAN);
	body_work = newbuf(doc, BUFFER_BLOCK);
	attr_work = newbuf(doc, BUFFER_ATTRIBUTE);
	i = parse_table_header(header_work, attr_work, doc, data, size, &columns, &col_data);
	if (i > 0) {

		while (i < size) {
			size_t row_start;
			int pipes = 0;
			size_t rows = 1;

			row_start = i;

			while (i < size && data[i] != '\n') {
				if (data[i] == '|' && !is_backslashed(data, i)) pipes++;
				i++;
			}

			if (pipes == 0 || i == size) {
				i = row_start;
				break;
			}

			/* Don't count a leading pipe. */
			if (data[row_start] == '|')
				pipes--;

			/* Don't count a trailing pipe. */
			if (data[i - 1] == '|' && !is_backslashed(data, i - 1))
				pipes--;

			/* If the multiline table extension is enabled, check the next
			   lines for continuation markers, to find the number of text rows
			   that make up this logical row.
			*/
			if ((doc->ext_flags & HOEDOWN_EXT_MULTILINE_TABLES) != 0) {
				while (i < size) {
					size_t j = i + 1;
					int colons = 0;

					/* Require that a continued row starts with a colon. */
					if (j >= size || data[j] != ':') break;

					/* Don't count leading colon for comparison to pipes. */
					j++;

					while (j < size && data[j] != '\n') {
						if (!is_backslashed(data, j) && data[j] == ':')
							colons++;
						j++;
					}

					/* Don't count a trailing colon for comparison to pipes. */
					if (!is_backslashed(data, j - 1) && data[j - 1] == ':')
						colons--;

					/* Hoedown allows table rows where the number of cells is different
					 * from `columns`. In this case, `parse_table_row` will add empty
					 * cells. However, the code does not work in the multi-line case, so
					 * we require the right number of columns. */
					if (colons != pipes || colons != columns - 1) break;

					rows++;
					i = j;
				}
			}

			parse_table_row(
				body_work,
				doc,
				data + row_start,
				i - row_start,
				columns,
				rows,
				col_data, 0
			);

			i++;

			/* Skip an optional row separator, if it's there. */
			if ((doc->ext_flags & HOEDOWN_EXT_MULTILINE_TABLES) != 0) {
				/* Use j instead of i, and set i to j only if this is actually a row separator. */
				size_t j = i, next_line_end = i, col;

				/* Seek next_line_end to the position of the terminating new line. */
				while (next_line_end < size && data[next_line_end] != '\n')
					next_line_end++;

				/* Skip leading pipe, if any. */
				if (j < next_line_end && data[j] == '|')
					j++;

				/* Ensure that there are at least columns pipe/plus separated
				   runs of dashes, each at least 3 long. The pipes may be
				   padded with spaces, and the line may end in a pipe.
				*/
				for (col = 0; col < columns && j < next_line_end; col++) {
					size_t dashes = 0;

					while (j < next_line_end && data[j] == ' ')
						j++;

					while (j < next_line_end && data[j] == '-') {
						j++;
						dashes++;
					}

					while (j < next_line_end && data[j] == ' ')
						j++;

					if (j < next_line_end && data[j] != '|' && data[j] != '+')
						break;

					if (dashes < 3)
						break;

					j++;
				}

				/* Skip i past the row separator, if it was valid. */
				if (col == columns)
					i = next_line_end + 1;
			}
		}

		if (doc->md.table_header)
			doc->md.table_header(work, header_work, &doc->data);

		if (doc->md.table_body)
			doc->md.table_body(work, body_work, &doc->data);

		if (doc->md.table)
			doc->md.table(ob, work, attr_work, &doc->data);
	}

	free(col_data);
	popbuf(doc, BUFFER_SPAN);
	popbuf(doc, BUFFER_BLOCK);
	popbuf(doc, BUFFER_BLOCK);
	popbuf(doc, BUFFER_ATTRIBUTE);
	return i;
}

/* parse_userblock • parsing of user block */
static size_t
parse_userblock(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	hoedown_buffer work = { 0, 0, 0, 0, NULL, NULL, NULL };
	size_t len = doc->user_block(data, size, &doc->data);

	if (!len) {
		return 0;
	}

	work.data = data;
	work.size = len;

	if (doc->md.user_block) {
		doc->md.user_block(ob, &work, &doc->data);
	} else {
		hoedown_buffer_put(ob, work.data, work.size);
	}
	return len;
}

/* is_paragraph • returns if the next block is a paragraph (doesn't follow any
 * other special rules for other types of blocks) */
static int
is_paragraph(hoedown_document *doc, uint8_t *txt_data, size_t end)
{
	/* temporary buffer for results of checking special blocks */
	hoedown_buffer *tmp = newbuf(doc, BUFFER_BLOCK);
	/* temporary renderer that has no rendering function */
	hoedown_renderer temp_renderer;
	/* ensure all callbacks are NULL */
	memset(&temp_renderer, 0, sizeof(hoedown_renderer));
	/* store the old renderer */
	hoedown_renderer old_renderer;
	memcpy(&old_renderer, &doc->md, sizeof(hoedown_renderer));
	/* copy the new renderer over to the document */
	memcpy(&doc->md, &temp_renderer, sizeof(hoedown_renderer));
	/* these are all the if branches inside parse_block, wrapped into one bool,
	 * with minimal parsing, and completely idempotent */
	int result = !(is_atxheader(doc, txt_data, end) ||
					(doc->user_block && parse_userblock(tmp, doc, txt_data, end)) ||
					(txt_data[0] == '<' &&
						parse_htmlblock(tmp, doc, txt_data, end, 0)) ||
					is_hrule(txt_data, end) ||
					((doc->ext_flags & HOEDOWN_EXT_FENCED_CODE) &&
						parse_fencedcode(tmp, doc, txt_data, end, doc->ext_flags)) ||
					((doc->ext_flags & HOEDOWN_EXT_TABLES) &&
						parse_table(tmp, doc, txt_data, end)) ||
					prefix_quote(txt_data, end) ||
					(!(doc->ext_flags & HOEDOWN_EXT_DISABLE_INDENTED_CODE) &&
						prefix_code(txt_data, end)) ||
					prefix_uli(txt_data, end) ||
					prefix_oli(txt_data, end) ||
					((doc->ext_flags & HOEDOWN_EXT_DEFINITION_LISTS) &&
						prefix_dli(doc, txt_data, end)));
	popbuf(doc, BUFFER_BLOCK);
	memcpy(&doc->md, &old_renderer, sizeof(hoedown_renderer));
	return result;
}

/* parse_block • parsing of one block, returning next uint8_t to parse */
static void
parse_block(hoedown_buffer *ob, hoedown_document *doc, uint8_t *data, size_t size)
{
	size_t beg, end, i;
	uint8_t *txt_data;
	beg = 0;

	if (doc->work_bufs[BUFFER_SPAN].size +
		doc->work_bufs[BUFFER_BLOCK].size > doc->max_nesting)
		return;

	while (beg < size) {
		txt_data = data + beg;
		end = size - beg;

		if (is_atxheader(doc, txt_data, end))
			beg += parse_atxheader(ob, doc, txt_data, end);

		else if (doc->user_block &&
				(i = parse_userblock(ob, doc, txt_data, end)) != 0)
			beg += i;

		else if (data[beg] == '<' && doc->md.blockhtml &&
				(i = parse_htmlblock(ob, doc, txt_data, end, 1)) != 0)
			beg += i;

		else if ((i = is_empty(txt_data, end)) != 0)
			beg += i;

		else if (is_hrule(txt_data, end)) {
			while (beg < size && data[beg] != '\n')
				beg++;

			if (doc->md.hrule) {
				doc->hrule_char = data[beg - 1];
				doc->md.hrule(ob, &doc->data);
				doc->hrule_char = 0;
			}

			beg++;
		}

		else if ((doc->ext_flags & HOEDOWN_EXT_FENCED_CODE) != 0 &&
			(i = parse_fencedcode(ob, doc, txt_data, end, doc->ext_flags)) != 0)
			beg += i;

		else if ((doc->ext_flags & HOEDOWN_EXT_TABLES) != 0 &&
			(i = parse_table(ob, doc, txt_data, end)) != 0)
			beg += i;

		else if (prefix_quote(txt_data, end))
			beg += parse_blockquote(ob, doc, txt_data, end);

		else if (!(doc->ext_flags & HOEDOWN_EXT_DISABLE_INDENTED_CODE) && prefix_code(txt_data, end))
			beg += parse_blockcode(ob, doc, txt_data, end);

		else if (prefix_uli(txt_data, end))
			beg += parse_list(ob, doc, txt_data, end, 0);

		else if (prefix_oli(txt_data, end))
			beg += parse_list(ob, doc, txt_data, end, HOEDOWN_LIST_ORDERED);

		else if ((doc->ext_flags & HOEDOWN_EXT_DEFINITION_LISTS) && prefix_dli(doc, txt_data, end))
			beg += parse_list(ob, doc, txt_data, end, HOEDOWN_LIST_DEFINITION);

		else
			beg += parse_paragraph(ob, doc, txt_data, end);
	}
}



/*********************
 * REFERENCE PARSING *
 *********************/

/* is_footnote • returns whether a line is a footnote definition or not */
static int
is_footnote(const uint8_t *data, size_t beg, size_t end, size_t *last, struct footnote_list *list)
{
	size_t i = 0;
	hoedown_buffer *contents = NULL;
	hoedown_buffer *name = NULL;
	size_t ind = 0;
	int in_empty = 0;
	size_t start = 0;

	size_t id_offset, id_end;
	size_t id_indent = 0, content_line = 0, content_indent = 0;

	/* up to 3 optional leading spaces */
	if (beg + 3 >= end) return 0;
	if (data[beg] == ' ') { i = 1;
	if (data[beg + 1] == ' ') { i = 2;
	if (data[beg + 2] == ' ') { i = 3;
	if (data[beg + 3] == ' ') return 0; } } }
	i += beg;

	/* id part: caret followed by anything between brackets */
	if (data[i] != '[') return 0;
	i++;
	if (i >= end || data[i] != '^') return 0;
	i++;
	id_offset = i;
	while (i < end && data[i] != '\n' && data[i] != '\r' && data[i] != ']')
		i++;
	if (i >= end || data[i] != ']') return 0;
	id_end = i;

	/* spacer: colon (space | tab)* newline? (space | tab)* */
	i++;
	if (i >= end || data[i] != ':') return 0;
	i++;
	if (i >= end) return 0;

	/* getting content and name buffers */
	contents = hoedown_buffer_new(64);
	name = hoedown_buffer_new(64);

	start = i;

	/* getting item indent size */
	while (id_indent != start && data[start - id_indent] != '\n' && data[start - id_indent] != '\r') {
		id_indent++;
	}

	/* process lines similar to a list item */
	while (i < end) {
		while (i < end && data[i] != '\n' && data[i] != '\r') i++;

		/* process an empty line */
		if (is_empty(data + start, i - start)) {
			in_empty = 1;
			if (i < end && (data[i] == '\n' || data[i] == '\r')) {
				i++;
				if (i < end && data[i] == '\n' && data[i - 1] == '\r') i++;
			}
			start = i;
			continue;
		}

		/* calculating the indentation */
		ind = 0;
		while (ind < 4 && start + ind < end && data[start + ind] == ' ')
			ind++;

		content_line++;

		/* joining only indented stuff after empty lines;
		 * note that now we only require 1 space of indentation
		 * to continue, just like lists */
		if (ind == 0) {
			if (start == id_end + 2 && data[start] == '\t') {}
			else break;
		}
		else if (in_empty) {
			hoedown_buffer_putc(contents, '\n');
		}

		in_empty = 0;

		/* re-calculating the indentation */
		if (content_line == 2 && data[start + ind] == ' ') {
			while (ind < id_indent && data[start + ind] == ' ') {
				ind++;
			}
			content_indent = ind;
		}
		if (content_indent > ind) {
			while (ind < content_indent && data[start + ind] == ' ') {
				ind++;
			}
		}

		/* adding the line into the content buffer */
		hoedown_buffer_put(contents, data + start + ind, i - start - ind);
		/* add carriage return */
		if (i < end) {
			hoedown_buffer_putc(contents, '\n');
			if (i < end && (data[i] == '\n' || data[i] == '\r')) {
				i++;
				if (i < end && data[i] == '\n' && data[i - 1] == '\r') i++;
			}
		}
		start = i;
	}

	if (last)
		*last = start;

	if (list) {
		struct footnote_ref *ref;
		ref = create_footnote_ref(list, data + id_offset, id_end - id_offset);
		if (!ref)
			return 0;
		if (!add_footnote_ref(list, ref)) {
			free_footnote_ref(ref);
			return 0;
		}
		ref->contents = contents;
		hoedown_buffer_put(name, data + id_offset, id_end - id_offset);
		ref->name = name;
	}

	return 1;
}

/* is_html_comment • returns whether a html comment or not */
static int
is_html_comment(const uint8_t *data, size_t beg, size_t end, size_t *last)
{
	size_t i = 0;

	if (beg + 5 >= end) return 0;
	if (!(data[beg] == '<'  && data[beg + 1] == '!' && data[beg + 2] == '-' && data[beg + 3] == '-')) return 0;

	i = 5;
	while (beg + i < end && !(data[beg + i - 2] == '-' && data[beg + i - 1] == '-' && data[beg + i] == '>')) i++;
	/* i can only ever be beyond the end if the ending --> is not found */
	if (beg + i >= end) return 0;
	i++;

	if (beg + i < end && (data[beg + i] == '\n' || data[beg + i] == '\r')) {
		i++;
		if (beg + i < end && data[beg + i] == '\r' && data[beg + i - 1] == '\n') i++;
	}

	if (last)
		*last = beg + i;

	return 1;
}

/* is_ref • returns whether a line is a reference or not */
static int
is_ref(const uint8_t *data, size_t beg, size_t end, size_t *last, struct link_ref **refs)
{
/*	int n; */
	size_t i = 0;
	size_t id_offset, id_end;
	size_t link_offset, link_end;
	size_t title_offset, title_end;
	size_t line_end;
	size_t attr_offset = 0, attr_end = 0;

	/* up to 3 optional leading spaces */
	if (beg + 3 >= end) return 0;
	if (data[beg] == ' ') { i = 1;
	if (data[beg + 1] == ' ') { i = 2;
	if (data[beg + 2] == ' ') { i = 3;
	if (data[beg + 3] == ' ') return 0; } } }
	i += beg;

	/* id part: anything but a newline between brackets */
	if (data[i] != '[') return 0;
	i++;
	id_offset = i;
	while (i < end && data[i] != '\n' && data[i] != '\r' && data[i] != ']')
		i++;
	if (i >= end || data[i] != ']') return 0;
	id_end = i;

	/* spacer: colon (space | tab)* newline? (space | tab)* */
	i++;
	if (i >= end || data[i] != ':') return 0;
	i++;
	while (i < end && data[i] == ' ') i++;
	if (i < end && (data[i] == '\n' || data[i] == '\r')) {
		i++;
		if (i < end && data[i] == '\r' && data[i - 1] == '\n') i++; }
	while (i < end && data[i] == ' ') i++;
	if (i >= end) return 0;

	/* link: spacing-free sequence, optionally between angle brackets */
	if (data[i] == '<')
		i++;

	link_offset = i;

	while (i < end && data[i] != ' ' && data[i] != '\n' && data[i] != '\r')
		i++;

	if (data[i - 1] == '>') link_end = i - 1;
	else link_end = i;

	/* optional spacer: (space | tab)* (newline | '\'' | '"' | '(' ) */
	while (i < end && data[i] == ' ') i++;
	if (i < end && data[i] != '\n' && data[i] != '\r'
			&& data[i] != '\'' && data[i] != '"' && data[i] != '(')
		return 0;
	line_end = 0;
	/* computing end-of-line */
	if (i >= end || data[i] == '\r' || data[i] == '\n') line_end = i;
	if (i + 1 < end && data[i] == '\n' && data[i + 1] == '\r')
		line_end = i + 1;

	/* optional (space|tab)* spacer after a newline */
	if (line_end) {
		i = line_end + 1;
		while (i < end && data[i] == ' ') i++; }

	/* optional title: any non-newline sequence enclosed in '"()
					alone on its line */
	title_offset = title_end = 0;
	if (i + 1 < end
	&& (data[i] == '\'' || data[i] == '"' || data[i] == '(')) {
		char d = data[i++];
		title_offset = i;

		/* looking for end of tile */
		while (i < end && data[i] != d && data[i] != '\n' && data[i] != '\r') {
			++i;
		}

		if (i + 1 < end && data[i] == d) {
			title_end = i++;
			attr_offset = i;

			/* looking for EOL */
			while (i < end && data[i] != '\n' && data[i] != '\r') {
				i++;
			}

			/* looking for attribute */
			if (data[i-1] == '}' &&
				memchr(&data[attr_offset], '{', i - attr_offset)) {
				while (attr_offset < i && data[attr_offset] != '{') {
					++attr_offset;
				}
				++attr_offset;
				attr_end = i - 1;
			} else {
				if (data[i-1] == d) {
					title_end = i - 1;
				} else {
					title_end = i;
				}
				attr_offset = 0;
				attr_end = 0;
			}
			if (i + 1 < end && data[i] == '\r' && data[i + 1] == '\n') {
				++i;
			}

			line_end = i;
		} else {
			/* looking for EOL */
			while (i < end && data[i] != '\n' && data[i] != '\r') {
				i++;
			}
			if (i + 1 < end && data[i] == '\n' && data[i + 1] == '\r') {
				title_end = i + 1;
			} else {
				title_end = i;
			}
			/* stepping back */
			i -= 1;
			while (i > title_offset && data[i] == ' ') {
				i -= 1;
			}
			if (i > title_offset &&
				(data[i] == '\'' || data[i] == '"' || data[i] == ')')) {
				line_end = title_end;
				title_end = i;
			}
		}
	}

	if (!line_end || link_end == link_offset)
		return 0; /* garbage after the link empty link */

	/* a valid ref has been found, filling-in return structures */
	if (last)
		*last = line_end;

	if (refs) {
		struct link_ref *ref;

		ref = add_link_ref(refs, data + id_offset, id_end - id_offset);
		if (!ref)
			return 0;

		ref->link = hoedown_buffer_new(link_end - link_offset);
		hoedown_buffer_put(ref->link, data + link_offset, link_end - link_offset);

		if (title_end > title_offset) {
			ref->title = hoedown_buffer_new(title_end - title_offset);
			hoedown_buffer_put(ref->title, data + title_offset, title_end - title_offset);
		}
		if (attr_end > attr_offset) {
			ref->attr = hoedown_buffer_new(attr_end - attr_offset);
			hoedown_buffer_put(ref->attr, data + attr_offset, attr_end - attr_offset);
		}
	}

	return 1;
}

static void expand_tabs(hoedown_buffer *ob, const uint8_t *line, size_t size)
{
	/* This code makes two assumptions:
	 * - Input is valid UTF-8.  (Any byte with top two bits 10 is skipped,
	 *   whether or not it is a valid UTF-8 continuation byte.)
	 * - Input contains no combining characters.  (Combining characters
	 *   should be skipped but are not.)
	 */
	size_t  i = 0, tab = 0;

	while (i < size) {
		size_t org = i;

		while (i < size && line[i] != '\t') {
			/* ignore UTF-8 continuation bytes */
			if ((line[i] & 0xc0) != 0x80)
				tab++;
			i++;
		}

		if (i > org)
			hoedown_buffer_put(ob, line + org, i - org);

		if (i >= size)
			break;

		do {
			hoedown_buffer_putc(ob, ' '); tab++;
		} while (tab % 4);

		i++;
	}
}

/**********************
 * EXPORTED FUNCTIONS *
 **********************/

hoedown_document *
hoedown_document_new(
	const hoedown_renderer *renderer,
	hoedown_extensions extensions,
	size_t max_nesting,
	uint8_t attr_activation,
	hoedown_user_block user_block,
	hoedown_buffer *meta)
{
	hoedown_document *doc = NULL;

	assert(max_nesting > 0 && renderer);

	doc = hoedown_malloc(sizeof(hoedown_document));
	memcpy(&doc->md, renderer, sizeof(hoedown_renderer));

	doc->data.opaque = renderer->opaque;

	hoedown_stack_init(&doc->work_bufs[BUFFER_BLOCK], 4);
	hoedown_stack_init(&doc->work_bufs[BUFFER_SPAN], 8);
	hoedown_stack_init(&doc->work_bufs[BUFFER_ATTRIBUTE], 8);

	memset(doc->active_char, 0x0, 256);

	if (extensions & HOEDOWN_EXT_UNDERLINE && doc->md.underline) {
		doc->active_char['_'] = MD_CHAR_EMPHASIS;
	}

	if (doc->md.emphasis || doc->md.double_emphasis || doc->md.triple_emphasis) {
		doc->active_char['*'] = MD_CHAR_EMPHASIS;
		doc->active_char['_'] = MD_CHAR_EMPHASIS;
		if (extensions & HOEDOWN_EXT_STRIKETHROUGH)
			doc->active_char['~'] = MD_CHAR_EMPHASIS;
		if (extensions & HOEDOWN_EXT_HIGHLIGHT)
			doc->active_char['='] = MD_CHAR_EMPHASIS;
	}

	if (doc->md.codespan)
		doc->active_char['`'] = MD_CHAR_CODESPAN;

	if (doc->md.linebreak)
		doc->active_char['\n'] = MD_CHAR_LINEBREAK;

	if (doc->md.image || doc->md.link || doc->md.footnotes || doc->md.footnote_ref) {
		doc->active_char['['] = MD_CHAR_LINK;
		doc->active_char['!'] = MD_CHAR_IMAGE;
	}

	doc->active_char['<'] = MD_CHAR_LANGLE;
	doc->active_char['\\'] = MD_CHAR_ESCAPE;
	doc->active_char['&'] = MD_CHAR_ENTITY;

	if (extensions & HOEDOWN_EXT_AUTOLINK) {
		doc->active_char[':'] = MD_CHAR_AUTOLINK_URL;
		doc->active_char['@'] = MD_CHAR_AUTOLINK_EMAIL;
		doc->active_char['w'] = MD_CHAR_AUTOLINK_WWW;
	}

	if (extensions & HOEDOWN_EXT_SUPERSCRIPT)
		doc->active_char['^'] = MD_CHAR_SUPERSCRIPT;

	if (extensions & HOEDOWN_EXT_QUOTE)
		doc->active_char['"'] = MD_CHAR_QUOTE;

	if (extensions & HOEDOWN_EXT_MATH)
		doc->active_char['$'] = MD_CHAR_MATH;

	/* Extension data */
	doc->ext_flags = extensions;
	doc->max_nesting = max_nesting;
	doc->attr_activation = attr_activation;
	doc->in_link_body = 0;
	doc->link_id = NULL;
	doc->link_ref_attr = NULL;
	doc->link_inline_attr = NULL;
	doc->is_escape_char = 0;
	doc->header_type = HOEDOWN_HEADER_NONE;
	doc->link_type = HOEDOWN_LINK_NONE;
	doc->footnote_id = NULL;
	doc->list_depth = 0;
	doc->blockquote_depth = 0;
	doc->ul_item_char = 0;
	doc->hrule_char = 0;
	doc->fencedcode_char = 0;
	doc->ol_numeral = NULL;
	doc->user_block = user_block;
	doc->meta = meta;

	return doc;
}

void
hoedown_document_render(hoedown_document *doc, hoedown_buffer *ob, const uint8_t *data, size_t size)
{
	static const uint8_t UTF8_BOM[] = {0xEF, 0xBB, 0xBF};

	hoedown_buffer *text;
	size_t beg, end;

	int footnotes_enabled;

	text = hoedown_buffer_new(64);

	/* Preallocate enough space for our buffer to avoid expanding while copying */
	hoedown_buffer_grow(text, size);

	/* reset the references table */
	memset(&doc->refs, 0x0, REF_TABLE_SIZE * sizeof(void *));

	footnotes_enabled = doc->ext_flags & HOEDOWN_EXT_FOOTNOTES;

	/* reset the footnotes lists */
	if (footnotes_enabled) {
		memset(&doc->footnotes_found, 0x0, sizeof(doc->footnotes_found));
		memset(&doc->footnotes_used, 0x0, sizeof(doc->footnotes_used));
	}

	/* first pass: looking for references, copying everything else */
	beg = 0;

	/* Skip a possible UTF-8 BOM, even though the Unicode standard
	 * discourages having these in UTF-8 documents */
	if (size >= 3 && memcmp(data, UTF8_BOM, 3) == 0)
		beg += 3;

	while (beg < size) /* iterating over lines */
		if (footnotes_enabled && is_footnote(data, beg, size, &end, &doc->footnotes_found)) {
			if (doc->md.footnote_ref_def) {
				hoedown_buffer original = { NULL, 0, 0, 0, NULL, NULL, NULL };
				original.data = (uint8_t*) (data + beg);
				original.size = end - beg;
				doc->md.footnote_ref_def(&original, &doc->data);
			}
			beg = end;
		} else if (is_html_comment(data, beg, size, &end)) {
			size_t  i = 0;
			while (i < (end - beg) && beg + i < size) {
				if (data[beg + i] == '\t' && (data[beg + i] & 0xc0) != 0x80) {
					hoedown_buffer_put(text, (uint8_t*)"    ", 4);
				} else {
					hoedown_buffer_putc(text, data[beg + i]);
				}
				i++;
			}
			beg = end;
		} else if (is_ref(data, beg, size, &end, doc->refs)) {
			if (doc->md.ref) {
				hoedown_buffer original = { NULL, 0, 0, 0, NULL, NULL, NULL };
				original.data = (uint8_t*) (data + beg);
				original.size = end - beg;
				doc->md.ref(&original, &doc->data);
			}
			beg = end;
		} else { /* skipping to the next line */
			end = beg;
			while (end < size && data[end] != '\n' && data[end] != '\r')
				end++;

			/* adding the line body if present */
			if (end > beg)
				expand_tabs(text, data + beg, end - beg);

			while (end < size && (data[end] == '\n' || data[end] == '\r')) {
				/* add one \n per newline */
				if (data[end] == '\n' || (end + 1 < size && data[end + 1] != '\n'))
					hoedown_buffer_putc(text, '\n');
				end++;
			}

			beg = end;
		}

	/* pre-grow the output buffer to minimize allocations */
	hoedown_buffer_grow(ob, text->size + (text->size >> 1));

	/* second pass: actual rendering */
	if (doc->md.doc_header)
		doc->md.doc_header(ob, 0, &doc->data);

	if (text->size) {
		/* adding a final newline if not already present */
		if (text->data[text->size - 1] != '\n')
			hoedown_buffer_putc(text, '\n');

		parse_block(ob, doc, text->data, text->size);
	}

	/* footnotes */
	if (footnotes_enabled)
		parse_footnote_list(ob, doc, &doc->footnotes_used);

	if (doc->md.doc_footer)
		doc->md.doc_footer(ob, 0, &doc->data);

	/* clean-up */
	hoedown_buffer_free(text);
	free_link_refs(doc->refs);
	if (footnotes_enabled) {
		free_footnote_list(&doc->footnotes_found, 1);
		free_footnote_list(&doc->footnotes_used, 0);
	}

	assert(doc->work_bufs[BUFFER_SPAN].size == 0);
	assert(doc->work_bufs[BUFFER_BLOCK].size == 0);
	assert(doc->work_bufs[BUFFER_ATTRIBUTE].size == 0);
}

void
hoedown_document_render_inline(hoedown_document *doc, hoedown_buffer *ob, const uint8_t *data, size_t size)
{
	size_t i = 0, mark;
	hoedown_buffer *text = hoedown_buffer_new(64);

	/* reset the references table */
	memset(&doc->refs, 0x0, REF_TABLE_SIZE * sizeof(void *));

	/* first pass: expand tabs and process newlines */
	hoedown_buffer_grow(text, size);
	while (1) {
		mark = i;
		while (i < size && data[i] != '\n' && data[i] != '\r')
			i++;

		expand_tabs(text, data + mark, i - mark);

		if (i >= size)
			break;

		while (i < size && (data[i] == '\n' || data[i] == '\r')) {
			/* add one \n per newline */
			if (data[i] == '\n' || (i + 1 < size && data[i + 1] != '\n'))
				hoedown_buffer_putc(text, '\n');
			i++;
		}
	}

	/* second pass: actual rendering */
	hoedown_buffer_grow(ob, text->size + (text->size >> 1));

	if (doc->md.doc_header)
		doc->md.doc_header(ob, 1, &doc->data);

	parse_inline(ob, doc, text->data, text->size);

	if (doc->md.doc_footer)
		doc->md.doc_footer(ob, 1, &doc->data);

	/* clean-up */
	hoedown_buffer_free(text);

	assert(doc->work_bufs[BUFFER_SPAN].size == 0);
	assert(doc->work_bufs[BUFFER_BLOCK].size == 0);
}

void
hoedown_document_free(hoedown_document *doc)
{
	size_t i;

	for (i = 0; i < (size_t)doc->work_bufs[BUFFER_SPAN].asize; ++i)
		hoedown_buffer_free(doc->work_bufs[BUFFER_SPAN].item[i]);

	for (i = 0; i < (size_t)doc->work_bufs[BUFFER_BLOCK].asize; ++i)
		hoedown_buffer_free(doc->work_bufs[BUFFER_BLOCK].item[i]);

	for (i = 0; i < (size_t)doc->work_bufs[BUFFER_ATTRIBUTE].asize; ++i)
		hoedown_buffer_free(doc->work_bufs[BUFFER_ATTRIBUTE].item[i]);

	hoedown_stack_uninit(&doc->work_bufs[BUFFER_SPAN]);
	hoedown_stack_uninit(&doc->work_bufs[BUFFER_BLOCK]);
	hoedown_stack_uninit(&doc->work_bufs[BUFFER_ATTRIBUTE]);

	free(doc);
}

const hoedown_buffer*
hoedown_document_link_id(hoedown_document* document)
{
	return document->link_id;
}

const hoedown_buffer*
hoedown_document_link_ref_attr(hoedown_document* document)
{
	return document->link_ref_attr;
}

const hoedown_buffer*
hoedown_document_link_inline_attr(hoedown_document* document)
{
	return document->link_inline_attr;
}

int
hoedown_document_is_escaped(hoedown_document* document)
{
	return document->is_escape_char;
}

hoedown_header_type
hoedown_document_header_type(hoedown_document* document)
{
	return document->header_type;
}

hoedown_link_type
hoedown_document_link_type(hoedown_document* document)
{
	return document->link_type;
}

const hoedown_buffer*
hoedown_document_footnote_id(hoedown_document* document)
{
	return document->footnote_id;
}

int
hoedown_document_list_depth(hoedown_document* document)
{
	return document->list_depth;
}

int
hoedown_document_blockquote_depth(hoedown_document* document)
{
	return document->blockquote_depth;
}

uint8_t
hoedown_document_ul_item_char(hoedown_document* document)
{
	return document->ul_item_char;
}

uint8_t
hoedown_document_hrule_char(hoedown_document* document)
{
	return document->hrule_char;
}

uint8_t
hoedown_document_fencedcode_char(hoedown_document* document)
{
	return document->fencedcode_char;
}

const hoedown_buffer*
hoedown_document_ol_numeral(hoedown_document* document)
{
		return document->ol_numeral;
}
