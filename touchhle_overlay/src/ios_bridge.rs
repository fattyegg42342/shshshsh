use std::ffi::{c_char,CStr,CString};
use std::sync::Mutex;

static LOG:Mutex<Option<CString>>=Mutex::new(None);

fn setlog(s:String){
    *LOG.lock().unwrap()=CString::new(s.replace('\0'," ")).ok();
}

#[no_mangle]
pub unsafe extern "C" fn touchhle_run_ipa(path:*const c_char)->i32 {
    if path.is_null(){setlog("null ipa path".into());return -1}
    let path=CStr::from_ptr(path).to_string_lossy().into_owned();
    let args=vec!["touchHLE".to_string(),path,"--fullscreen".to_string()];
    match crate::main(args.into_iter()) {
        Ok(_)=>0,
        Err(e)=>{setlog(e);-2}
    }
}

#[no_mangle]
pub extern "C" fn touchhle_stop(){}

#[no_mangle]
pub extern "C" fn touchhle_core_available()->i32{1}

#[no_mangle]
pub extern "C" fn touchhle_get_log()->*const c_char {
    LOG.lock().unwrap().as_ref().map_or(std::ptr::null(),|s|s.as_ptr())
}
