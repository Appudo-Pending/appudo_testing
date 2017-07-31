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
    let aname = "x" + Get.suffix.value
    let dname = "x" + Get.suffix.value + ".domain.net"
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // ADD
            if var _ = <!Account.add(aname, "b", "c", true) {
                appudo_assert(false, "account add failed")
            }
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if var a = <!Account.add(aname, "b", "c", true) {
                    appudo_assert(a.name == aname, "wrong name")
                    appudo_assert(a.active == false, "account already active")
                } else {
                    appudo_assert(false, "account add failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account add failed")
            }
        case 2: // GET
            if var _ = <!Account.get(aname) {
                appudo_assert(false, "account get failed")
            }
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if let a = <!Account.get(aname) {
                    appudo_assert(a.name == aname, "wrong name")
                } else {
                    appudo_assert(false, "account get failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account get failed")
            }
        case 3: // UPDATE
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if var a = <!Account.get(aname) {
                    appudo_assert(a.active == false, "account already active")
                    appudo_assert(<!a.setActive(true), "account update failed")
                    appudo_assert(a.active == true, "account update failed")
                    if var b = <!Account.get(aname) {
                        appudo_assert(b.active == true, "account update failed")
                    } else {
                        appudo_assert(false, "account get failed")
                    }
                    appudo_assert(<!a.setActive(false), "account update failed")
                    appudo_assert(a.active == false, "account update failed")
                    if var b = <!Account.get(aname) {
                        appudo_assert(b.active == false, "account update failed")
                    } else {
                        appudo_assert(false, "account update failed")
                    }
                } else {
                    appudo_assert(false, "account get failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account update failed")
            }
        case 4: // ADD DOMAIN
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if var a = <!Account.get(aname) {
                    appudo_assert(<!a.addDomain(dname), "account add domain failed")
                } else {
                    appudo_assert(false, "account get failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account add domain failed")
            }
        case 5: // DELETE DOMAIN
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if var a = <!Account.get(aname) {
                    appudo_assert(<!a.removeDomain(dname), "account delete domain failed")
                } else {
                    appudo_assert(false, "account get failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account delete domain failed")
            }
        case 6: // CURRENT
            if var _ = <!Account.current.value  {
                appudo_assert(false, "account current failed")
            }
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if var a = <!Account.current.value {
                    print(String(a.id.rawValue) + "<br/>")
                    print(a.name + "<br/>")
                    print(String(a.active) + "<br/>")
                } else {
                    appudo_assert(false, "account current failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account current failed")
            }
        case 7: // DELETE
            appudo_assert(<!Account.remove(aname) == false, "account delete failed")
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                appudo_assert(<!Account.remove(aname), "account delete failed")
                User.logout()
            } else {
                appudo_assert(false, "account current failed")
            }
        default:
            break
    }
    print("<br/>")
    LINK("ADD", "./?state=1")
    printSub()
    LINK("GET", "./?state=2")
    printSub()
    LINK("UPDATE", "./?state=3")
    printSub()
    LINK("ADD DOMAIN", "./?state=4")
    printSub()
    LINK("DELETE DOMAIN", "./?state=5")
    printSub()
    LINK("CURRENT", "./?state=6")
    printSub()
    LINK("DELETE", "./?state=7")
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
