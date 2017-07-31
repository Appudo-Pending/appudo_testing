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
                if var a = <!Account.get(aname) {
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
/*
    websocket.swift is part of Appudo

    Copyright (C) 2015-2016


    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo;
import libappudo_assert;
import libappudo_special;

extension String  {
    public func split(separatedBy:CharacterView._Element) -> [String] {
        return self.characters.split(separator: separatedBy).map(String.init)
    }

    public func extract() -> [String:String] {
        let a = self.split(separatedBy:"'")
        var res = [String:String]()
        for i in stride(from: 0, to:a.count-1, by: 4) {
            res[a[i+1]] = a[i+3];
        }
        return res;
    }

    public func extractVars() -> [[String:String]] {
        let x = self.split(separatedBy: "|")
        return x.count < 2 ? [[String:String](), [String:String]()] : [x[0].extract(), x[1].extract()]
    }

    public var value : String {
        return self
    }
}

struct Get {
    static var store : [String:String] = [String:String]();
    static var state : String {
        return store["state"] ?? "";
    }
    static var suffix : String {
        return store["suffix"] ?? "";
    }
    static var loginName : String {
        return store["loginName"] ?? "";
    }
    static var loginPassword : String {
        return store["loginPassword"] ?? "";
    }
    static var ticket : String {
        return store["ticket"] ?? "";
    }
    static var uid : String {
        return store["uid"] ?? "";
    }
    static var gid : String {
        return store["gid"] ?? "";
    }
    static var arg : String {
        return store["arg"] ?? "";
    }
    static var baseURL : String {
        return store["baseURL"] ?? "";
    }
    static var pageURL : String {
        return store["pageURL"] ?? "";
    }
}

struct Post {
    static var store : [String:String] = [String:String]();
}

struct Page {
    static func noCache() -> Void {
    }
}

func printSub() {

}

func onMessage(ev : WebSocketEvent) {
    appudo_initPrint()
    print("<html xmlns=\"http://www.w3.org/1999/xhtml\">
   <head>
      <title>test</title>
   </head>")
    let v = (ev.data as! String).extractVars()
    Get.store = v[0]
    Post.store = v[1]
    main()
    print("</html>")
    Async.later()
    let out = appudo_getPrint()
    sendText(out, ev.target)
}
