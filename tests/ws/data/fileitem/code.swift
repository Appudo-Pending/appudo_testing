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

func printFile(_ c : FileItem) -> Void {
    if let stat = <!c.stat {
        print("----------------------------------<br>")
        print("name: " + c.name)
        print("<br>")
        print("path: " + c.path)
        print("<br>")
        print("file: " + String(stat.isFileNotDir))
        print("<br>")
        print("time_mod: " + stat.time_mod.toString())
        print("<br>")
        if(stat.isFileNotDir) {
            print("size: " + String(stat.size))
            print("<br>")
        } else {
            if let list = <!c.listDir(AlphasortDSC) {
                for f in list {
                    printFile(f)
                }
            } else {
                print("error")
            }
        }
    }
}

func main() {
    printSub()
}

func MAIN() {
    print("state: ")
    print(Get.state.value)
    print("<br/>")
    let userUID = Int32(Get.uid.value) ?? 0
    let userGID = Int32(Get.gid.value) ?? 0
    let dir = Dir.ftest
    let uname = "utest" + Get.suffix.value
    appudo_assert((Int(Get.state.value) ?? -1) != -1, "Get failed")
    switch(Int(Get.state.value) ?? 0)
    {
        case 1: // MODE
            appudo_assert(userUID != 0, "wrong uid: \(Get.uid.value)")
            appudo_assert(userGID != 0, "wrong gid: \(Get.gid.value)")
            var stat = (<!dir.stat)!
            appudo_assert(stat.uid.rawValue == userUID, "wrong user")
            appudo_assert(stat.gid.rawValue == userGID, "wrong group")
            appudo_assert(stat.mode == FileItem.Mode([.S_IRWXU]), "wrong mode")
            print("<br/>")
            print("Owner: " + String(describing: stat.uid))
            print("<br/>")
            print("Group: " + String(describing: stat.gid))
            print("<br/>")
            print("Mode: " + String(describing: stat.mode))
            print("<br/>")

            let ownerGID = Int32(Get.arg.value) ?? 0
            appudo_assert(ownerGID != 0, "wrong gid: \(ownerGID)")
            _ = <!dir.setOwner(GroupID(ownerGID)) != false

            _ = <!dir.setMode([.S_IRWXU, .S_IRWXG]) != false
            stat = (<!dir.stat)!

            appudo_assert(stat.gid.rawValue == ownerGID, "wrong owner group")
            appudo_assert(stat.mode == FileItem.Mode([.S_IRWXU, .S_IRWXG]), "wrong mode")
            print("Mode: " + String(describing: stat.mode))
            print("<br/>")

            _ = <!dir.setMode([.S_IRWXU]) != false
            stat = (<!dir.stat)!

            appudo_assert(stat.mode == FileItem.Mode([.S_IRWXU]), "wrong mode")
            print("Mode: " + String(describing: stat.mode))
            print("<br/>")

            _ = <!dir.setMode([.S_IRWXU, .S_IRWXG, .S_IXOTH]) != false


        case 2: // ACCESS
            appudo_assert(userUID != 0, "wrong uid: \(Get.uid.value)")
            appudo_assert(userGID != 0, "wrong gid: \(Get.gid.value)")
            // try to access uploaded file
            if <!dir.access("test.txt", mode:.W_OK) {

            } else {
                appudo_assert(false, "access failed")
            }
            // set file read only by owner
            if let f = <!dir.open("test.txt") {
                _ = <!f.setMode([.S_IRUSR]) != false
            } else {
                appudo_assert(false, "set mode failed")
            }
            // file is read only by owner
            if <!dir.access("test.txt", mode:.W_OK) {
                appudo_assert(false, "access failed")
            }
            // file is read only by owner
            if <!dir.access("test.txt", mode:.R_OK) == false {
                appudo_assert(false, "access failed")
            }
            // try to login as user
            if <!User.login(uname, "testpwd") {
                if let id = User.logon, let _ = <!id.value {
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user login failed")
            }
            // file is not owned by the login user
            if <!dir.access("test.txt", mode:.W_OK) {
                appudo_assert(false, "access failed")
            }
            // logout user
            User.logout()
            // file is not owned by the login user
            if <!dir.access("test.txt", mode:.R_OK) == false {
                appudo_assert(false, "access failed")
            }
            if let a = <!User.get(uname) {
                // set file owner to user
                if let f = <!dir.open("test.txt") {
                    if <!f.setOwner(a.id) == false {
                        appudo_assert(false, "set owner failed")
                    }
                } else {
                    appudo_assert(false, "file open failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
            // file is owned by the login user
            if <!dir.access("test.txt", mode:.R_OK) {
                appudo_assert(false, "access failed")
            }
            // try to login as user
            if <!User.login(uname, "testpwd") {
                if let id = User.logon, let _ = <!id.value {
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user login failed")
            }
            // file is owned by the login user
            if <!dir.access("test.txt", mode:.R_OK) == false {
                appudo_assert(false, "access failed")
            }
            User.logout()
            if let f = <!dir.open("test.txt") {
                if <!f.setOwner(UserID(userUID)) && <!f.setMode([.S_IRWXU, .S_IRWXG, .S_IXOTH]) {
                } else {
                    appudo_assert(false, "set owner failed")
                }
            } else {
                appudo_assert(false, "set owner failed")
            }
        case 3: // LISTDIR
            printFile(dir)
        case 4: // OPEN
            appudo_assert(userUID != 0, "wrong uid: \(Get.uid.value)")
            appudo_assert(userGID != 0, "wrong gid: \(Get.gid.value)")
            // open file
            if var f = <!dir.open("test.txt", [.O_RDWR]) {
                appudo_assert(f.isOpen, "open failed")
                f.close()
            } else {
                appudo_assert(false, "open failed")
            }
            // create file
            if var f = <!dir.open("test2_open.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "open failed")
                f.close()
                let stat = (<!f.stat)!
                appudo_assert(stat.uid.rawValue == userUID, "creat failed")
                appudo_assert(stat.gid.rawValue == userGID, "creat failed")
            } else {
                appudo_assert(false, "open failed")
            }
            if let _ = <!dir.open("test2_open.txt", [.O_RDWR, .O_CREAT, .O_EXCL]) {
                appudo_assert(false, "open failed")
            }
            // try to login as user
            if <!User.login(uname, "testpwd") {
                if let id = User.logon, let _ = <!id.value {
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user login failed")
            }
            if let a = <!User.get(uname) {
                if let f = <!dir.open("test3_open.txt", [.O_RDWR, .O_CREAT, .O_EXCL]) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.isFileNotDir, "creat failed")
                    appudo_assert(stat.uid.rawValue == a.id.rawValue, "creat failed")
                    appudo_assert(stat.gid.rawValue == userGID, "creat failed")
                } else {
                    appudo_assert(false, "open failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
            User.logout()
        case 5: // MKDIR
            appudo_assert(userUID != 0, "wrong uid: \(Get.uid.value)")
            appudo_assert(userGID != 0, "wrong gid: \(Get.gid.value)")
            // create directory
            var ftest1 : FileItem? = nil
            if let d = <!dir.mkpath("test1_mkdir", [.S_IRWXU, .S_IXOTH]) {
                ftest1 = d
                let stat = (<!d.stat)!
                appudo_assert(stat.isFileNotDir == false, "mkdir failed")
                appudo_assert(stat.uid.rawValue == userUID, "mkdir failed")
                appudo_assert(stat.gid.rawValue == userGID, "mkdir failed")
            } else {
                appudo_assert(false, "mkdir failed")
            }
            // try to login as user
            if <!User.login(uname, "testpwd") {
                if let id = User.logon, let _ = <!id.value {
                } else {
                    appudo_assert(false, "user login failed")
                }
            } else {
                appudo_assert(false, "user login failed")
            }
            // create directory as user
            if let a = <!User.get(uname) {
                if let d = <!dir.mkpath("test2_mkdir", [.S_IRWXU, .S_IRWXG, .S_IXOTH]) {
                    let stat = (<!d.stat)!
                    appudo_assert(stat.isFileNotDir == false, "mkdir failed")
                    appudo_assert(stat.uid.rawValue == a.id.rawValue, "mkdir failed")
                    appudo_assert(stat.gid.rawValue == userGID, "mkdir failed")
                } else {
                    appudo_assert(false, "mkdir failed")
                }
            } else {
                appudo_assert(false, "user get failed")
            }
            // try to create directory without permission
            if ftest1 != nil {
                if let _ = <!ftest1!.mkpath("test3_mkdir", [.S_IRWXU, .S_IRWXG, .S_IXOTH]) {
                    appudo_assert(false, "mkdir failed")
                }
            }
            User.logout()
        case 6: // RENAME
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_rename.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "rename failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "rename failed")
                } else {
                    appudo_assert(false, "rename failed")
                }
                // rename file
                _ = <!f.rename("test2_rename.txt") != false
            } else {
                appudo_assert(false, "rename failed")
            }
            // open old
            if let _ = <!dir.open("test1_rename.txt", [.O_RDWR]) {
                appudo_assert(false, "rename failed")
            }
            // open new
            if var f = <!dir.open("test2_rename.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "rename failed")
                } else {
                    appudo_assert(false, "rename failed")
                }
                f.close()
            } else {
                appudo_assert(false, "rename failed")
            }
            // create directory
            if var d = <!dir.mkpath("test1_rename", [.S_IRWXU, .S_IXOTH]) {
                // rename directory
                _ = <!d.rename("test2_rename") != false
            } else {
                appudo_assert(false, "mkdir failed")
            }
            // open old
            if let _ = <!dir.open("test1_rename", [.O_DIRECTORY]) {
                appudo_assert(false, "rename failed")
            }
            // open new
            if let _ = <!dir.open("test2_rename", [.O_DIRECTORY]) {
            } else {
                appudo_assert(false, "rename failed")
            }
        case 7: // LINK
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_link.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "link failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "link failed")
                } else {
                    appudo_assert(false, "link failed")
                }
                // create link to file
                _ = <!f.link("test2_link.txt") != false
            } else {
                appudo_assert(false, "link failed")
            }
            // read and compare
            if var f = <!dir.open("test2_link.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "link failed")
                } else {
                    appudo_assert(false, "link failed")
                }
                f.close()
            } else {
                appudo_assert(false, "link failed")
            }
            // create tmpfile and link
            if var f = <!dir.open(".", [.O_RDWR, .O_TMPFILE]) {
                appudo_assert(f.isOpen, "link failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat_open)!
                    appudo_assert(stat.size == _strlen(data), "link failed")
                } else {
                    appudo_assert(false, "link failed")
                }
                // create link to file
                _ = <!f.link_open("test3_link.txt", dir, hard:true) != false
            } else {
                appudo_assert(false, "link failed")
            }
            // read and compare
            if var f = <!dir.open("test3_link.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "link failed")
                } else {
                    appudo_assert(false, "link failed")
                }
                if <!f.link_open("test4_link.txt", dir, hard:false) == false {
                    appudo_assert(false, "link failed")
                }
                f.close()
            } else {
                appudo_assert(false, "link failed")
            }
        case 8: // COPY
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_copy.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "copy failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "copy failed")
                } else {
                    appudo_assert(false, "copy failed")
                }
                // copy file
                _ = <!f.copy("test2_copy.txt") != false
            } else {
                appudo_assert(false, "copy failed")
            }
            if let _ = <!dir.open("test1_copy.txt", [.O_RDWR]) {
            } else {
                appudo_assert(false, "copy failed")
            }
            // read and compare
            if var f = <!dir.open("test2_copy.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "copy failed")
                } else {
                    appudo_assert(false, "copy failed")
                }
                f.close()
            } else {
                appudo_assert(false, "copy failed")
            }
        case 9: // REMOVE
            // create file
            if var f = <!dir.open("test1_remove.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "remove failed")
                // remove file
                _ = <!f.remove() != false
            } else {
                appudo_assert(false, "remove failed")
            }
            if let _ = <!dir.open("test1_remove.txt", [.O_RDWR]) {
                appudo_assert(false, "remove failed")
            }
            // create directory
            if let d = <!dir.mkpath("test1_remove") {
                // create file
                if var f = <!d.open("test1_remove.txt", [.O_RDWR, .O_CREAT]) {
                    appudo_assert(f.isOpen, "remove failed")
                    // remove file
                    _ = <!f.remove() != false
                } else {
                    appudo_assert(false, "remove failed")
                }
                // remove inner directory
                _ = <!d.remove(outer:false) != false
                if let _ = <!d.open("test1_remove.txt", [.O_RDWR]) {
                    appudo_assert(false, "remove failed")
                }
                if let _ = <!dir.open("test1_remove", [.O_DIRECTORY]) {
                } else {
                    appudo_assert(false, "remove failed")
                }
                // remove directory
                _ = <!d.remove() != false
            } else {
                appudo_assert(false, "remove failed")
            }
            if let _ = <!dir.open("test1_remove", [.O_DIRECTORY]) {
                appudo_assert(false, "remove failed")
            }
        case 10: // WRITE
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_write.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "write failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "write failed")
                } else {
                    appudo_assert(false, "write failed")
                }
            } else {
                appudo_assert(false, "write failed")
            }
            // read and compare
            if var f = <!dir.open("test1_write.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "write failed")
                } else {
                    appudo_assert(false, "write failed")
                }
                f.close()
            } else {
                appudo_assert(false, "write failed")
            }
        case 11: // APPEND
            let data = "testdata123456789"
            let data2 = "15151515"
            // create file
            if var f = <!dir.open("test1_append.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "append failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "append failed")
                } else {
                    appudo_assert(false, "append failed")
                }
                if <!f.append(data2) == false {
                    appudo_assert(false, "append failed")
                }
            } else {
                appudo_assert(false, "append failed")
            }
            // read and compare
            if var f = <!dir.open("test1_append.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data + data2) == 0, "write failed")
                } else {
                    appudo_assert(false, "append failed")
                }
                f.close()
            } else {
                appudo_assert(false, "append failed")
            }
        case 12: // SEND
            let data = "testdata123456789"
            var file1 : FileItem? = nil
            // create file A
            if var f = <!dir.open("test1_send.txt", [.O_RDWR, .O_CREAT]) {
                file1 = f
                appudo_assert(f.isOpen, "send failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "send failed")
                } else {
                    appudo_assert(false, "append failed")
                }
            } else {
                appudo_assert(false, "send failed")
            }
            // create file B
            if let f = <!dir.open("test2_send.txt", [.O_RDWR, .O_CREAT]) {
                // send file
                _ = <!file1!.send(f)
            } else {
                appudo_assert(false, "send failed")
            }
            // read and compare
            if var f = <!dir.open("test2_send.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "send failed")
                } else {
                    appudo_assert(false, "send failed")
                }
                f.close()
            } else {
                appudo_assert(false, "send failed")
            }
        case 13: // TRUNCATE
            // create a file and truncate it
            if var f = <!dir.open("test_truncate.txt", [.O_RDWR, .O_CREAT]) {
                let size = Int(Get.arg.value) ?? 0
                if <!f.truncate_open(size) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == size, "truncate failed")
                } else {
                    appudo_assert(false, "truncate failed")
                }
            } else {
                appudo_assert(false, "truncate failed")
            }
        case 14: // READ_AS_TEXT
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_read_as_text.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "read_as_text failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "read_as_text failed")
                } else {
                    appudo_assert(false, "read_as_text failed")
                }
            } else {
                appudo_assert(false, "read_as_text failed")
            }
            // read and compare
            if var f = <!dir.open("test1_read_as_text.txt", [.O_RDWR]) {
                // read and compare
                if let txt = <!f.readAsText() {
                    appudo_assert(_strcmp(txt, data) == 0, "read_as_text failed")
                } else {
                    appudo_assert(false, "read_as_text failed")
                }
                f.close()
            } else {
                appudo_assert(false, "read_as_text failed")
            }
        case 15: // READ_AS_ARRAY
            let data = "testdata123456789"
            // create file
            if var f = <!dir.open("test1_read_as_array.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "read_as_array failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "read_as_array failed")
                } else {
                    appudo_assert(false, "read_as_array failed")
                }
            } else {
                appudo_assert(false, "read_as_array failed")
            }
            // read and compare
            if var f = <!dir.open("test1_read_as_array.txt", [.O_RDWR]) {
                // read and compare
                if let arr = <!f.readAsArray() {
                    appudo_assert(_strcmp1(arr, data) == 0, "read_as_array failed")
                } else {
                    appudo_assert(false, "read_as_array failed")
                }
                f.close()
            } else {
                appudo_assert(false, "read_as_array failed")
            }
        case 16: // SEEK
            let data  = "testdata123456789"
            let data2 = "testdata"
            let data3 = "testdatatestdata9"
            // create file
            if var f = <!dir.open("test1_seek.txt", [.O_RDWR, .O_CREAT]) {
                appudo_assert(f.isOpen, "seek failed")
                // write file
                if let _ = <!f.write(data) {
                    let stat = (<!f.stat)!
                    appudo_assert(stat.size == _strlen(data), "seek failed")
                } else {
                    appudo_assert(false, "seek failed")
                }
                // seek to position
                _ = <!f.seek(8, .SEEK_SET)
                let se = f.seek(0, .SEEK_CUR)
                _ = <!se
                // write file
                if let _ = <!f.write(data2, 0, se.value) {
                } else {
                    appudo_assert(false, "seek failed")
                }
            } else {
                appudo_assert(false, "seek failed")
            }

            // read and compare
            if var f = <!dir.open("test1_seek.txt", [.O_RDWR]) {
                // read and compare
                if let arr = <!f.readAsArray() {
                    appudo_assert(_strcmp1(arr, data3) == 0, "seek failed")
                } else {
                    appudo_assert(false, "seek failed")
                }
                f.close()
            } else {
                appudo_assert(false, "seek failed")
            }
        default:
            break
    }
    print("<br/>")
    LINK("MODE", "./?state=1")
    printSub()
    LINK("ACCESS", "./?state=2")
    printSub()
    LINK("LISTDIR", "./?state=3")
    printSub()
    LINK("OPEN", "./?state=4")
    printSub()
    LINK("MKDIR", "./?state=5")
    printSub()
    LINK("RENAME", "./?state=6")
    printSub()
    LINK("LINK", "./?state=7")
    printSub()
    LINK("COPY", "./?state=8")
    printSub()
    LINK("REMOVE", "./?state=9")
    printSub()
    LINK("WRITE", "./?state=10")
    printSub()
    LINK("APPEND", "./?state=11")
    printSub()
    LINK("SEND", "./?state=12")
    printSub()
    LINK("TRUNCATE", "./?state=13")
    printSub()
    LINK("READ_AS_TEXT", "./?state=14")
    printSub()
    LINK("READ_AS_ARRAY", "./?state=15")
    printSub()
    LINK("SEEK", "./?state=16")
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
