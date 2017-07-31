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
    print("<br/>")
    print("ptest: " + Post.ptest.value)
    printSub()
}
