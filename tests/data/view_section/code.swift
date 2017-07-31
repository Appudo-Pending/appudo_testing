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
    switch(Int(Get.state.value) ?? 0)
    {
    case 3: // SKIN
        Page.skinId = 1000
        break
    default:
        break
    }
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
        case 1: // META
            break
        case 2: // LINK
            break
        case 3: // SKIN
            break
        default:
            break
    }
    print("<br/>")
    LINK("META", "./?state=1")
    printSub()
    LINK("LINK", "./?state=2")
    printSub()
    LINK("SKIN", "./?state=3")
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
