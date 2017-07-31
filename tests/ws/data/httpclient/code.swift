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
    var requestType = HTTPRequestType.GET
    var ssl = false
    var post_body : String? = nil
    var use_client = true
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 3: // GET_SSL
            ssl = true
            fallthrough
        case 1: // GET
            break
        case 4: // POST_SSL
            ssl = true
            fallthrough
        case 2: // POST
            post_body = "?test1=123&test2=456"
            requestType = .POST
        case 5: // KEEP
            use_client = false
            appudo_assert(false, "todo httpclient KEEP")
        case 6: // INIT
            use_client = false
            let dir = Dir.ftest
            if let f = <!dir.open("data.txt") {
                _ = <!dir.setMode(rawValue:0o777) != false
                _ = <!f.setMode(rawValue:0o777) != false
            }
        default:
            use_client = false
    }

    if(use_client) {
        let client = HTTPClient.get(requestType, Link.toUrl("http://" + Get.baseURL.value + Get.pageURL.value, ssl))
        if <!client.send(post_body) {
            print(client.bodyText ?? "")
        } else {
            appudo_assert(false, "httpclient failed")
        }
    }

    print("<br/>")
    LINK("GET", "./?state=1")
    printSub()
    LINK("POST", "./?state=2")
    printSub()
    LINK("GET_SSL", "./?state=3")
    printSub()
    LINK("POST_SSL", "./?state=4")
    printSub()
    LINK("KEEP", "./?state=5")
    printSub()
    LINK("INIT", "./?state=6")
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
