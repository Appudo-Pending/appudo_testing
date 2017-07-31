#define _GNU_SOURCE

#include <cap-ng.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <sys/prctl.h>
#include <linux/capability.h>
#include <unistd.h>
#include <sys/syscall.h>

static void set_ambient_cap(int cap)
{
	int rc;

	capng_get_caps_process();
	rc = capng_update(CAPNG_ADD, CAPNG_INHERITABLE, cap);
    if(rc)
    {
        fprintf(stderr, "capng_update failed\n");
        exit(EXIT_FAILURE);
	}
	capng_apply(CAPNG_SELECT_CAPS);

    if(prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE, cap, 0, 0))
    {
        fprintf(stderr, "prctl failed\n");
        exit(EXIT_FAILURE);
	}
}

int main(int argc, char** argv) 
{
	char tmp[4096<<1];
	char* pos = tmp;
	int i = 1;
	int status;
	for(; i < argc; i++)
	{
		int len = strlen(argv[i]);
		memcpy(pos, argv[i], len);
		pos += len;
		*pos = ' ';
		pos++;
	}

	set_ambient_cap(CAP_DAC_READ_SEARCH);

	status = system(tmp);
	return  WEXITSTATUS(status);
}
