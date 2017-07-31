
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
    print("state: ")
    print("<br/>")
    print("test1: " + Post.test1.value)
    print("<br/>")
    print("test2: " + Post.test2.value)
    printSub()
}
