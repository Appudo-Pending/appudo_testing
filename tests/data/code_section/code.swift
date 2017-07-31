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
        case 1: // SETTING
            print("Setting: " + String(describing:Setting.stest))
        case 2: //
            print("Role: " + String(describing:Role.rtest))
        case 3: // COOKIE
            Cookie.ctest.set("cvalue")
            break
        case 4: // VARIABLES
            print("Cookie: " + String(describing:Cookie.ctest))
            print("PostVar: " + String(describing:Post.ptest))
            print("GetVar: " + String(describing:Get.state))
            break
        case 5: // FOLDER
            print("Folder: " + String(describing:Dir.ftest))
            break
        default:
            break
    }
    print("<br/>")
    LINK("SETTING", "./?state=1")
    printSub()
    LINK("ROLE", "./?state=2")
    printSub()
    LINK("COOKIE", "./?state=3")
    printSub()
    LINK("VARIABLES", "./?state=4")
    printSub()
    LINK("FOLDER", "./?state=5")
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
