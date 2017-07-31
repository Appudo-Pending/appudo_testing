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
    let num = Int(Get.num.value) ?? 0
    let dir = Dir.fcont
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // ADD
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                for i in 0..<num {
                    let n = "con" + String(i);
                    if var a = <!Account.add(n, n, n, true) {
                        appudo_assert(a.name == n, "wrong name")
                        appudo_assert(a.active == false, "account already active")
                        appudo_assert(<!a.setActive(true), "account update failed")
                        appudo_assert(<!a.addDomain(n + "." + Get.baseUrl.value), "account add domain failed")

                        if let info = <!a.info {
                            if var f = <!dir.open(n, [.O_RDWR, .O_CREAT]) {
                                appudo_assert(f.isOpen, "append failed")
                                if <!f.append("accountID=" + String(a.id.rawValue) + "\n") == false {
                                    appudo_assert(false, "append failed")
                                }
                                if <!f.append("userID=" + String(info.ouid.rawValue) + "\n") == false {
                                    appudo_assert(false, "append failed")
                                }
                                /*
                                if <!f.append("runnerID=" + String(info.ruid.rawValue) + "\n") == false {
                                    appudo_assert(false, "append failed")
                                }
                                */
                                if <!f.append("runnerGID=" + String(info.rgid.rawValue) + "\n") == false {
                                    appudo_assert(false, "append failed")
                                }
                                if <!f.append("userGID=" + String(info.bgid.rawValue) + "\n") == false {
                                    appudo_assert(false, "append failed")
                                }
                                appudo_assert(<!f.setMode([.S_IRWXU, .S_IRWXG, .S_IXOTH]) == true, "set mode failed")
                            } else {
                                appudo_assert(false, "append failed")
                            }
                        } else {
                            appudo_assert(false, "get info failed")
                        }
                    } else {
                        appudo_assert(false, "account add failed")
                    }
                }
                User.logout()
            } else {
                appudo_assert(false, "account add failed")
            }
        case 2: // DELETE
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                for i in 0..<num {
                    let n = "con" + String(i);
                    appudo_assert(<!Account.remove(n), "account delete failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "account current failed")
            }
        case 3: // USERS
            if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                if let g = <!Group.get("master"),let b = <!Group.get("backend") {
                    for i in 0..<num {
                        let n = "scon" + String(i);
                        _ = <!User.remove(n) != false
                        if var a = <!User.add(n, n, false) {
                            appudo_assert(<!a.setActive(true), "user update failed")
                            appudo_assert(<!a.addGroup(b.id), "add to group failed")
                            appudo_assert(<!a.addGroup(g.id), "add to group failed")
                        } else {
                            appudo_assert(false, "user add failed")
                        }
                    }
                } else {
                    appudo_assert(false, "group get failed")
                }
                User.logout()
            } else {
                appudo_assert(false, "login failed")
            }
        default:
            break
    }
    print("<br/>")
    LINK("ADD", "./?state=1")
    printSub()
    LINK("DELETE", "./?state=2")
    printSub()
    LINK("USERS", "./?state=3")
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
