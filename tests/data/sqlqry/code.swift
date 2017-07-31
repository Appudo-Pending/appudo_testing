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
        case 1: // INSERT
            var qry = SQLQry("INSERT INTO dtest(test1, test2)VALUES($1,$2)")
            qry.values = ["atest", "btest"]
            if <!qry.exec() {
                qry = SQLQry("SELECT * FROM dtest")
                if <!qry.exec() {
                    appudo_assert(qry.numRows != 0, "SQLQry failed")
                    print("<br>SQL(0,1): " + String(describing:qry.getAsText(0, 1) ?? ""))
                    print("<br>SQL(0,2): " + String(describing:qry.getAsText(0, 2) ?? ""))
                } else {
                    appudo_assert(false, "SQLQry failed")
                }

            } else {
                appudo_assert(false, "SQLQry failed")
            }
        case 2: // SELECT
            let qry = SQLQry("SELECT * FROM dtest")
            if <!qry.exec() {
                appudo_assert(qry.numRows != 0, "SQLQry failed")
                print("<br>SQL(0,1): " + String(describing:qry.getAsText(0, 1) ?? ""))
                print("<br>SQL(0,2): " + String(describing:qry.getAsText(0, 2) ?? ""))
            } else {
                appudo_assert(false, "SQLQry failed")
            }
        case 3: // DELETE
            var qry = SQLQry("DELETE FROM dtest")
            if <!qry.exec() == false {
                appudo_assert(false, "SQLQry failed")
            }
            qry = SQLQry("SELECT * FROM dtest")
            appudo_assert(<!qry.exec() && qry.numRows == 0, "SQLQry failed")
        case 4: // UPDATE
            var qry = SQLQry("INSERT INTO dtest(test1, test2)VALUES($1,$2)")
            qry.values = ["update1", "update2"]
            appudo_assert(<!qry.exec(), "SQLQry failed")

            qry = SQLQry("SELECT * FROM dtest WHERE test1 = $1")
            qry.values = ["update1"]
            appudo_assert(<!qry.exec() && qry.numRows != 0, "SQLQry failed")

            qry = SQLQry("UPDATE dtest SET test1=$1, test2=$2 WHERE test1=$3")
            qry.values = ["test1", "test2", "update1"]
            appudo_assert(<!qry.exec(), "SQLQry failed")

            qry = SQLQry("SELECT * FROM dtest WHERE test1 = $1")
            qry.values = ["update1"]
            appudo_assert(<!qry.exec() && qry.numRows == 0, "SQLQry failed")
        case 5: // ROLLBACK
            appudo_assert(<!SQLQry.begin(), "SQLQry failed")
            var qry = SQLQry("INSERT INTO dtest(test1, test2)VALUES($1,$2)")
            qry.values = ["rollback1", "rollback2"]
            if <!qry.exec() {
                qry = SQLQry("SELECT * FROM dtest")
                if <!qry.exec() {
                    appudo_assert(qry.numRows != 0, "SQLQry failed")
                    print("<br>SQL(0,1): " + String(describing:qry.getAsText(0, 1) ?? ""))
                    print("<br>SQL(0,2): " + String(describing:qry.getAsText(0, 2) ?? ""))
                } else {
                    appudo_assert(false, "SQLQry failed")
                }

            } else {
                appudo_assert(false, "SQLQry failed")
            }
            appudo_assert(SQLQry.inTransaction, "SQLQry failed")
            appudo_assert(<!SQLQry.rollback(), "SQLQry failed")
            qry = SQLQry("SELECT * FROM dtest WHERE test1 = $1")
            qry.values = ["rollback1"]
            appudo_assert(<!qry.exec() && qry.numRows == 0, "SQLQry failed")
        case 6: // END
            appudo_assert(<!SQLQry.begin(), "SQLQry failed")
            var qry = SQLQry("INSERT INTO dtest(test1, test2)VALUES($1,$2)")
            qry.values = ["end1", "end2"]
            if <!qry.exec() {
                qry = SQLQry("SELECT * FROM dtest")
                if <!qry.exec() {
                    appudo_assert(qry.numRows != 0, "SQLQry failed")
                    print("<br>SQL(0,1): " + String(describing:qry.getAsText(0, 1) ?? ""))
                    print("<br>SQL(0,2): " + String(describing:qry.getAsText(0, 2) ?? ""))
                } else {
                    appudo_assert(false, "SQLQry failed")
                }

            } else {
                appudo_assert(false, "SQLQry failed")
            }
            appudo_assert(SQLQry.inTransaction, "SQLQry failed")
            appudo_assert(<!SQLQry.end(), "SQLQry failed")
            qry = SQLQry("SELECT * FROM dtest WHERE test1 = $1")
            qry.values = ["end1"]
            appudo_assert(<!qry.exec() && qry.numRows != 0, "SQLQry failed")
        case 7: // ERRMSG
            let qry = SQLQry("INSERT INTO dtest(test1, falsetest2)VALUES($1,$2)")
            qry.values = ["test1", "test1"]
            appudo_assert(<!qry.exec() == false && qry.hasError, "SQLQry failed")
            //print(qry.errMsg)
        default:
            break
    }
    print("<br/>")
    LINK("INSERT", "./?state=1")
    printSub()
    LINK("SELECT", "./?state=2")
    printSub()
    LINK("DELETE", "./?state=3")
    printSub()
    LINK("UPDATE", "./?state=4")
    printSub()
    LINK("ROLLBACK", "./?state=5")
    printSub()
    LINK("END", "./?state=6")
    printSub()
    LINK("ERRMSG", "./?state=7")
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

