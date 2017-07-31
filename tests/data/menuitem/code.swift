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

func checkMenu(_ a : [String], _ aidx : Int = -1)
{
    let m : MenuItem? = MenuItem.get(Page.root, 1).value
    var it : MenuItem? = nil
    if(m != nil && m!.numChildren == a.count) {
        for i in 0..<m!.numChildren {
            it = m!.getChildAt(i)
            if(aidx != -1 && i == aidx) {
                appudo_assert(it!.active, "checkMenu failed")
            }
            if(_strcmp(it!.name, a[i]) != 0) {
                appudo_assert(false, "checkMenu failed")
            }
        }
    } else {
        appudo_assert(false, "checkMenu failed")
    }
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
        case 1: // ABC   print("state: ")
        print(Get.state)
        print("<br/>")
            checkMenu(["testA", "testB", "testC"])
        case 2: // ABC, active B
            checkMenu(["testA", "testB", "testC"], 1)
        case 3: // CAB
            checkMenu(["testC", "testA", "testB"])
        case 4: // CAB, active A
            checkMenu(["testC", "testA", "testB"], 1)
        case 5: // ACB
            checkMenu(["testA", "testC", "testB"])
        default:
            break
    }
    print("<br/>")
    LINK("ABC", "./?state=1")
    printSub()
    LINK("ABC, active B", "./?state=2")
    printSub()
    LINK("CAB", "./?state=3")
    printSub()
    LINK("CAB, active A", "./?state=4")
    printSub()
    LINK("ACB", "./?state=5")
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
