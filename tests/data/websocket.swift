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
    print("<html xmlns=\"http://www.w3.org/1999/xhtml\">\n   <head>\n      <title>test</title>\n   </head>")
    let v = (ev.data as! String).extractVars()
    Get.store = v[0]
    Post.store = v[1]
    main()
    print("</html>")
    Async.later()
    let out = appudo_getPrint()
    sendText(out, ev.target)
}
