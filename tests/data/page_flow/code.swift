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
        case 1: // A
            SUBA(true)
        case 2: // B
            SUBB(true)
        case 3: // C
            SUBC(true)
        default:
            break
    }
    for _ in 0...10 {
        printSub()
    }
}

func SUBA(_ enable : Bool = false) -> Void {
    if(enable) {
        printSub()
    }
}

func SUBB(_ enable : Bool = false) -> Void {
    if(enable) {
        printSub()
    }
}

func SUBC(_ enable : Bool = false) -> Void {
    if(enable) {
        printSub()
    }
}
