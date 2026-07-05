#include "touchhle_bridge.h"
int touchhle_core_available(void){return 0;}
int touchhle_run_ipa(const char *path){return -1;}
void touchhle_stop(void){}
const char *touchhle_get_log(void){return "touchHLE iOS core is not linked";}
