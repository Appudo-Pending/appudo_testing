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
    return .NOTCACHED
}

func main() {
    printSub()
}

func MAIN() {
    print("state: ")
    print(Get.state)
    print("<br/>")
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // DELETE
            if var u = <!User.get("nomaster" + Get.suffix.value) {
                appudo_assert(<!u.remove(), "nomaster failed")
            }
        case 1: // NOMASTER
            if let _ = <!User.get("nomaster" + Get.suffix.value) {
            } else {
                appudo_assert(false, "nomaster failed")
            }
        default:
            break
    }
    print("<br/>")
    LINK("DELETE", "./?state=1")
    printSub()
    LINK("NOMASTER", "./?state=2")
    printSub()
}

func LINK(_ text : String, _ href : String) -> Void {
    TEXT(text)
    HREF(href)
    printSub()
}

func TEXT(_ a : String) -> Void {
    print(a)
}

func HREF(_ a : String) -> Void {
    print(a)
}
