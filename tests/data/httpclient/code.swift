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
