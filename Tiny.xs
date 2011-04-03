#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <string.h>

struct smaps_sizes {
    int KernelPageSize;
    int MMUPageSize;
    int Private_Clean;
    int Private_Dirty;
    int Pss;
    int Referenced;
    int Rss;
    int Shared_Clean;
    int Shared_Dirty;
    int Size;
    int Swap;
};

MODULE = Linux::Smaps::Tiny PACKAGE = Linux::Smaps::Tiny
PROTOTYPES: DISABLE

SV*
__get_smaps_summary_xs(char* filename)
PPCODE:
    FILE *file = fopen(filename, "r");
    struct smaps_sizes sizes;
    memset(&sizes, 0, sizeof sizes);
    HV* hash = newHV();

    if (!file) {
        croak("In get_smaps_summary, failed to read '%s': [%d] %s", filename, errno, strerror(errno));
    }

    char line [BUFSIZ];
    while (fgets(line, sizeof line, file))
    {
        char substr[32];
        int n;
        if (sscanf(line, "%31[^:]%n", substr, &n) == 1)
        {
            if      (strcmp(substr, "KernelPageSize") == 0) { sizes.KernelPageSize += n; }
            else if (strcmp(substr, "MMUPageSize") == 0)    { sizes.MMUPageSize += n; }
            else if (strcmp(substr, "Private_Clean") == 0)  { sizes.Private_Clean += n; }
            else if (strcmp(substr, "Private_Dirty") == 0)  { sizes.Private_Dirty += n; }
            else if (strcmp(substr, "Pss") == 0)            { sizes.Pss += n; }
            else if (strcmp(substr, "Referenced") == 0)     { sizes.Referenced += n; }
            else if (strcmp(substr, "Rss") == 0)            { sizes.Rss += n; }
            else if (strcmp(substr, "Shared_Clean") == 0)   { sizes.Shared_Clean += n; }
            else if (strcmp(substr, "Shared_Dirty") == 0)   { sizes.Shared_Dirty += n; }
            else if (strcmp(substr, "Size") == 0)           { sizes.Size += n; }
            else if (strcmp(substr, "Swap") == 0)           { sizes.Swap += n; }
        }
    }
    fclose(file);

    hv_store(hash, "KernelPageSize", strlen("KernelPageSize"), newSViv(sizes.KernelPageSize), 0);
    hv_store(hash, "MMUPageSize", strlen("MMUPageSize"), newSViv(sizes.MMUPageSize), 0);
    hv_store(hash, "Private_Clean", strlen("Private_Clean"), newSViv(sizes.Private_Clean), 0);
    hv_store(hash, "Private_Dirty", strlen("Private_Dirty"), newSViv(sizes.Private_Dirty), 0);
    hv_store(hash, "Pss", strlen("Pss"), newSViv(sizes.Pss), 0);
    hv_store(hash, "Referenced", strlen("Referenced"), newSViv(sizes.Referenced), 0);
    hv_store(hash, "Rss", strlen("Rss"), newSViv(sizes.Rss), 0);
    hv_store(hash, "Shared_Clean", strlen("Shared_Clean"), newSViv(sizes.Shared_Clean), 0);
    hv_store(hash, "Shared_Dirty", strlen("Shared_Dirty"), newSViv(sizes.Shared_Dirty), 0);
    hv_store(hash, "Size", strlen("Size"), newSViv(sizes.Size), 0);
    hv_store(hash, "Swap", strlen("Swap"), newSViv(sizes.Swap), 0);

    XPUSHs(newRV_noinc((SV*) hash));

