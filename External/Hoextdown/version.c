#include "version.h"

void
hoedown_version(int *major, int *minor, int *revision, int *extras)
{
	*major = HOEDOWN_VERSION_MAJOR;
	*minor = HOEDOWN_VERSION_MINOR;
	*revision = HOEDOWN_VERSION_REVISION;
	*extras = HOEDOWN_VERSION_EXTRAS;
}
