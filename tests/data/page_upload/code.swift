/*
    code.swift is part of Appudo

    Copyright (C) 2015-2016


    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_env
import libappudo_special
import libappudo_assert

func preHeader() {

}

func onGetCache(ev : PageEvent) -> PageCache {
    MAIN(nil)
    return .NOTCACHED
}

func main() {
    printSub()
}

func onUpload(ev : PageEvent) -> FileItem? {

    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // UPLOAD
            if let f = <!Dir.ftest.open("data.txt", [.O_CREAT, .O_RDWR]) {
                MAIN(f)
                return f
            } else {
                appudo_assert(false, "upload failed")
            }
        default:
           break
    }
    return nil
}

func MAIN(_ file: FileItem?) {
    print("state: ")
    print(Get.state)
    print("<br/>")
    let data = "upload data test"
    print("ptest: " + Post.ptest.value)
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // UPLOAD
            appudo_assert(file != nil, "page_upload error")
            // read and compare
            var f = file!
            if let txt = <!f.readAsText() {
                appudo_assert(_strcmp(txt, data) == 0, "page_upload failed")
            } else {
                appudo_assert(false, "link failed")
            }
         default:
            break
    }
    printSub()
}

