#ifndef touchhle_bridge_h
#define touchhle_bridge_h
int touchhle_core_available(void);
int touchhle_run_ipa(const char *path);
void touchhle_stop(void);
const char *touchhle_get_log(void);
#endif
