source nvhls_exec.tcl

proc nvhls::usercmd_post_assembly {} {
    upvar TOP_NAME TOP_NAME
    directive set /$TOP_NAME/run/while -PIPELINE_INIT_INTERVAL 1
    directive set /$TOP_NAME/run/while -PIPELINE_STALL_MODE flush
    directive set /$TOP_NAME/run/buf:rsc -MAP_TO_MODULE ccs_sample_mem.ccs_ram_sync_singleport
    directive set /$TOP_NAME/run/buf2:rsc -MAP_TO_MODULE ccs_sample_mem.ccs_ram_sync_singleport
}

nvhls::run
