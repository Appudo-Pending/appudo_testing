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
        case 1: // CALLLATER
            _ = <?{
                print("test")
            }
        case 2: // DOLATER
            _ = <?{
                print("test")
            }
            print("my")
            Async.later()
        case 3: // WAITALL
            _ = <?{
                print("test")
            }
            _ = Async.any()
        case 4: // WAITANY
            _ = <?{
                print("test")
            }
            _ = Async.any()
        case 5: // CANCEL
            appudo_assert(false, "todo async")
        default:
            break
    }
    print("<br/>")
    LINK("CALLLATER", "./?state=1")
    printSub()
    LINK("WAITALL", "./?state=2")
    printSub()
    LINK("WAITANY", "./?state=3")
    printSub()
    LINK("CANCEL", "./?state=4")
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
