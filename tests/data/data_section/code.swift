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
        case 1: // TABLE
            var qry : SQLQry = SQLQry("INSERT INTO table1(tcol1, tcol2)VALUES($1,$2)")
            qry.values = ["atest", "btest"]
            if <!qry.exec() {
                qry = SQLQry("SELECT * FROM table1")
                if <!qry.exec() != nil {
                    print("<br>SQL(0,1): " + String(describing:qry.getAsText(0, 1) ?? ""))
                    print("<br>SQL(0,2): " + String(describing:qry.getAsText(0, 2) ?? ""))
                } else {
                    appudo_assert(false, "SQLQry select failed")
                }

            } else {
                appudo_assert(false, "SQLQry insert failed")
            }
        default:
            break
    }
    print("<br/>")
    LINK("TABLE", "./?state=1")
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
