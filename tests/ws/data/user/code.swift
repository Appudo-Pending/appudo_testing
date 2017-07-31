/*
    code.swift is part of Appudo

    Copyright (C) 2015-2016


    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/

import libappudo
import libappudo_special
import libappudo_env
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
    var ticket = Get.ticket.value
    print("state: ")
    print(Get.state)
    print("<br/>")
    let uname = "x" + Get.suffix.value
    let gname = "muh" + Get.suffix.value
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // REGISTER
            if let a = <!User.register(uname, "b") {
                print("ticket:" + a)
                ticket = a
            } else {
                appudo_assert(false, "user register failed")
            }
        case 2: // VALIDATE
            if var a = <!User.validate(uname, ticket) {
                appudo_assert(a.name == uname, "wrong name")
                appudo_assert(a.active == true, "user not active")
                print(a)
            } else {
                appudo_assert(false, "user validate failed")
            }
        case 3: // ADD
            if var a = <!User.add(uname, "abc", false) {
                appudo_assert(a.name == uname, "wrong name")
                appudo_assert(a.active == false, "user not active")
                print(a)
            } else {
                appudo_assert(false, "user add failed")
            }
        case 4: // GET
            if var a = <!User.get(uname) {
                appudo_assert(a.name == uname, "wrong name")
                print(a)
            } else {
                appudo_assert(false, "user get failed")
            }
        case 5: // UPDATE
            if var a = <!User.get(uname) {
                appudo_assert(a.active == false, "user already active")
                appudo_assert(<!a.setActive(true), "user update failed")
                appudo_assert(a.active == true, "user update failed")
                if var b = <!User.get(uname) {
                    appudo_assert(b.active == true, "user update failed")
                } else {
                    appudo_assert(false, "user get failed")
                }
                appudo_assert(<!a.setActive(false), "user update failed")
                appudo_assert(a.active == false, "user update failed")
                if var b = <!User.get(uname) {
                    appudo_assert(b.active == false, "user update failed")
                } else {
                    appudo_assert(false, "user get failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
        case 6: // ADD GROUP
            if var g = <!Group.add(gname, false) {
                print(g)
                appudo_assert(g.active == false, "group active")
            } else {
                appudo_assert(false, "group add failed")
            }
            if var _ = <!Group.add(gname, true) {
                appudo_assert(false, "double add")
            }
        case 7: // UPDATE GROUP
            if var g = <!Group.get(gname) {
                appudo_assert(g.active == false, "group already active")
                appudo_assert(<!g.setActive(true), "group update failed")
                appudo_assert(g.active == true, "group update failed")
                if var b = <!Group.get(gname) {
                    appudo_assert(b.active == true, "group update failed")
                } else {
                    appudo_assert(false, "group get failed")
                }
                appudo_assert(<!g.setActive(false), "group update failed")
                appudo_assert(g.active == false, "group update failed")
                if var b = <!User.get(uname) {
                    appudo_assert(b.active == false, "group update failed")
                    appudo_assert(<!b.setActive(true), "user update failed") // needed for login
                } else {
                    appudo_assert(false, "group get failed")
                }
            } else {
                appudo_assert(false, "group get failed")
            }
        case 8: // ADD TO GROUP
            if let a = <!User.get(uname) {
                if let g = <!Group.get(gname) {
                    appudo_assert(<!a.hasGroup(g.id) == false, "already in group")
                    appudo_assert(<!a.addGroup(g.id), "add to group failed")
                    appudo_assert(<!a.hasGroup(g.id), "add to group failed")
                    print(g)
                } else {
                    appudo_assert(false, "group get failed")
                }
                appudo_assert(<!a.addGroup(Role.rtest), "add to group 'rtest' failed")
                appudo_assert(<!a.hasGroup(Role.rtest), "add to group 'rtest' failed")
            } else {
                appudo_assert(false, "user get failed")
            }
        case 9: // DELETE FROM GROUP
            if let a = <!User.get(uname) {
                if let g = <!Group.get(gname) {
                    appudo_assert(<!a.removeGroup(g.id), "remove from group failed")
                    print(g)
                } else {
                    appudo_assert(false, "group get failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
        case 10: // DELETE GROUP
            appudo_assert(<!Group.remove(gname), "group delete failed")
        case 11: // LOGIN
            if <!User.login(uname, "abc") {
                if let id = User.logon, var c = <!id.value {
                    print(String(describing:c.id) + "<br/>")
                    print(c.name + "<br/>")
                    print(String(c.active) + "<br/>")
                    appudo_assert(c.name == uname, "user mismatch")
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user login failed")
            }
        case 12: // CURRENT
            if let id = User.logon, var a = <!id.value {
                print(String(describing:a.id) + "<br/>")
                print(a.name + "<br/>")
                print(String(a.active) + "<br/>")

                User.data = 999
                if(User.data != 999) {
                    appudo_assert(false, "user data failed")
                }
                User.data = 111
                if(User.data != 111) {
                    appudo_assert(false, "user data failed")
                }
            } else {
                appudo_assert(false, "user current failed")
            }
        case 13: // LOGOUT
            User.logout()
            if let id = User.logon, var a = <!id.value {
                print(String(describing:a.id) + "<br/>")
                print(a.name + "<br/>")
                print(String(a.active) + "<br/>")
                appudo_assert(false, "user logout failed")
            }
        case 14: // SWAP
            if var u = <!User.get(uname) {
                if <!User.login(Get.loginName.value, Get.loginPassword.value) {
                        let id = User.current
                        appudo_assert(User.current == User.logon, "user swap failed")
                        appudo_assert(<!User.swap(u.id), "user swap failed")
                        appudo_assert(User.current == u.id, "user get failed")
                        appudo_assert(<!User.swap(), "user swap failed")
                        appudo_assert(User.current == id, "user get failed")
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
        case 15: // DELETE
            appudo_assert(<!User.remove(uname), "user delete failed")
        default:
            break
    }
    print("<br/>")
    LINK("REGISTER", "./?state=1")
    printSub()
    LINK("VALIDATE", "./?state=2&amp;ticket=\(ticket)")
    printSub()
    LINK("ADD", "./?state=3")
    printSub()
    LINK("GET", "./?state=4")
    printSub()
    LINK("UPDATE", "./?state=5")
    printSub()
    LINK("ADD GROUP", "./?state=6")
    printSub()
    LINK("UPDATE GROUP", "./?state=7")
    printSub()
    LINK("ADD TO GROUP", "./?state=8")
    printSub()
    LINK("DELETE FROM GROUP", "./?state=9")
    printSub()
    LINK("DELETE GROUP", "./?state=10")
    printSub()
    LINK("LOGIN", "./?state=11")
    printSub()
    LINK("CURRENT", "./?state=12")
    printSub()
    LINK("LOGOUT", "./?state=13")
    printSub()
    LINK("SWAP", "./?state=14")
    printSub()
    LINK("DELETE", "./?state=15")
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
