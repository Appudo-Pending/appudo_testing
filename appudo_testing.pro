###########################################################################################
#    appudo_testing.pro is part of Appudo
#
#    Copyright (C) 2015
#        bc00940f92e19b5d84931da5bbb6bce10b8e341bdd9d98d016513a164e790c05 source@appudo.com
#
#    Licensed under the Apache License, Version 2.0
#
#    See http://www.apache.org/licenses/LICENSE-2.0 for more information
###########################################################################################

TEMPLATE = aux

MACHINE = $$system(uname -m)
CONFIG(release, debug|release) : DESTDIR = $$_PRO_FILE_PWD_/Release.$$MACHINE
CONFIG(debug, debug|release)   : DESTDIR = $$_PRO_FILE_PWD_/Debug.$$MACHINE
CONFIG(force_debug_info)       : DESTDIR = $$_PRO_FILE_PWD_/Profile.$$MACHINE

QMAKE_MAKEFILE = $$DESTDIR/Makefile
OBJECTS_DIR = $$DESTDIR/.obj
MOC_DIR = $$DESTDIR/.moc
RCC_DIR = $$DESTDIR/.qrc
UI_DIR = $$DESTDIR/.ui

CONFIG(release, debug|release) : first.commands = cd $$_PRO_FILE_PWD_ # && ./test.sh 0
CONFIG(debug, debug|release)   : first.commands = cd $$_PRO_FILE_PWD_ # && ./test.sh 1
CONFIG(force_debug_info)       : first.commands = cd $$_PRO_FILE_PWD_ # && ./test.sh 1

QMAKE_EXTRA_TARGETS += first


DISTFILES += \
    tests/test1.xml \
    testrunner.sh \
    todo.txt \
    test.sh \
    xdelta.sh \
    JENKINS_README.txt \
    tests/appudo.xml \
    tests/data/sqlqry/view.html \
    tests/data/sqlqry/code.swift \
    tests/data/account/view.html \
    tests/data/account/code.swift \
    tests/settings.properties \
    tests/data/user/view.html \
    tests/data/user/code.swift \
    tests/data/fileitem/code.swift \
    tests/data/fileitem/view.html \
    tests/data/account/code.bin \
    tests/data/account/view.bin \
    tests/data/blob/code.bin \
    tests/data/blob/view.bin \
    tests/data/cookies/code.bin \
    tests/data/cookies/view.bin \
    tests/data/date/code.bin \
    tests/data/date/view.bin \
    tests/data/fileitem/code.bin \
    tests/data/fileitem/view.bin \
    tests/data/httpclient/code.bin \
    tests/data/httpclient/view.bin \
    tests/data/link/code.bin \
    tests/data/link/view.bin \
    tests/data/log/code.bin \
    tests/data/log/view.bin \
    tests/data/mail/code.bin \
    tests/data/mail/view.bin \
    tests/data/memory/code.bin \
    tests/data/memory/view.bin \
    tests/data/menuitem/code.bin \
    tests/data/menuitem/view.bin \
    tests/data/page/code.bin \
    tests/data/page/view.bin \
    tests/data/redirect/code.bin \
    tests/data/redirect/view.bin \
    tests/data/session/code.bin \
    tests/data/session/view.bin \
    tests/data/settings/code.bin \
    tests/data/settings/view.bin \
    tests/data/sqlqry/code.bin \
    tests/data/sqlqry/view.bin \
    tests/data/upload/code.bin \
    tests/data/upload/view.bin \
    tests/data/user/code.bin \
    tests/data/user/view.bin \
    tests/data/variables/code.bin \
    tests/data/variables/view.bin \
    tests/data/websocket/code.bin \
    tests/data/websocket/view.bin \
    tests/data/blob/view.html \
    tests/data/cookies/view.html \
    tests/data/date/view.html \
    tests/data/httpclient/view.html \
    tests/data/link/view.html \
    tests/data/log/view.html \
    tests/data/mail/view.html \
    tests/data/memory/view.html \
    tests/data/menuitem/view.html \
    tests/data/page/view.html \
    tests/data/redirect/view.html \
    tests/data/session/view.html \
    tests/data/settings/view.html \
    tests/data/upload/view.html \
    tests/data/variables/view.html \
    tests/data/websocket/view.html \
    tests/data/blob/code.swift \
    tests/data/cookies/code.swift \
    tests/data/date/code.swift \
    tests/data/filetree/testa/blubb.txt \
    tests/data/filetree/testa/muh.txt \
    tests/data/filetree/testc/wuff.txt \
    tests/data/httpclient/code.swift \
    tests/data/link/code.swift \
    tests/data/log/code.swift \
    tests/data/mail/code.swift \
    tests/data/memory/code.swift \
    tests/data/menuitem/code.swift \
    tests/data/page/code.swift \
    tests/data/redirect/code.swift \
    tests/data/session/code.swift \
    tests/data/settings/code.swift \
    tests/data/upload/code.swift \
    tests/data/variables/code.swift \
    tests/data/websocket/code.swift \
    tests/data/view_section/view.html \
    tests/data/view_section/code.swift \
    tests/data/view_section/tskin.txt \
    tests/data/code_section/view.html \
    tests/data/code_section/code.swift \
    tests/data/code_section/code.bin \
    tests/data/code_section/view.bin \
    tests/data/data_section/code.bin \
    tests/data/data_section/view.bin \
    tests/data/view_section/code.bin \
    tests/data/view_section/view.bin \
    tests/data/data_section/view.html \
    tests/data/data_section/code.swift \
    tests/scripts/setup_props.groovy \
    tests/scripts/ssh_exec.groovy \
    tests/scripts/ssh_scp.groovy \
    tests/data/datatree/view.html \
    tests/data/datatree/code.swift \
    tests/data/fileitem/test/test.txt \
    tests/data/httpclient/test/data.txt \
    tests/data/httpclient/post_code.swift \
    tests/data/async/view.html \
    tests/data/async/code.swift \
    tests/data/page_flow/view.html \
    tests/data/page_flow/code.swift \
    tests/data/skins/view.html \
    tests/data/skins/code.swift \
    tests/data/skins/data/skin1.txt \
    tests/data/skins/data/skin2.txt \
    tests/data/async/code.bin \
    tests/data/async/view.bin \
    tests/data/httpclient/post_code.bin \
    tests/data/httpclient/post_view.bin \
    tests/data/page_flow/code.bin \
    tests/data/page_flow/view.bin \
    tests/data/skins/code.bin \
    tests/data/skins/view.bin \
    tests/data/account/view.html.test \
    tests/data/blob/view.html.test \
    tests/data/code_section/view.html.test \
    tests/data/cookies/view.html.test \
    tests/data/data_section/view.html.test \
    tests/data/date/view.html.test \
    tests/data/fileitem/view.html.test \
    tests/data/httpclient/view.html.test \
    tests/data/link/view.html.test \
    tests/data/log/view.html.test \
    tests/data/mail/view.html.test \
    tests/data/memory/view.html.test \
    tests/data/menuitem/view.html.test \
    tests/data/page/view.html.test \
    tests/data/page_cache/view.html \
    tests/data/page_form/view.html \
    tests/data/page_inherit/view.html \
    tests/data/page_log/view.html \
    tests/data/page_redirect/view.html \
    tests/data/page_upload/view.html \
    tests/data/redirect/view.html.test \
    tests/data/session/view.html.test \
    tests/data/settings/view.html.test \
    tests/data/sqlqry/view.html.test \
    tests/data/upload/view.html.test \
    tests/data/user/view.html.test \
    tests/data/variables/view.html.test \
    tests/data/view_section/view.html.test \
    tests/data/websocket/view.html.test \
    tests/data/account/code.swift.test \
    tests/data/blob/code.swift.test \
    tests/data/code_section/code.swift.test \
    tests/data/cookies/code.swift.test \
    tests/data/data_section/code.swift.test \
    tests/data/date/code.swift.test \
    tests/data/fileitem/code.swift.test \
    tests/data/httpclient/code.swift.test \
    tests/data/link/code.swift.test \
    tests/data/log/code.swift.test \
    tests/data/mail/code.swift.test \
    tests/data/memory/code.swift.test \
    tests/data/menuitem/code.swift.test \
    tests/data/page/code.swift.test \
    tests/data/page_cache/code.swift \
    tests/data/page_form/code.swift \
    tests/data/page_inherit/code.swift \
    tests/data/page_log/code.swift \
    tests/data/page_redirect/code.swift \
    tests/data/page_upload/code.swift \
    tests/data/redirect/code.swift.test \
    tests/data/session/code.swift.test \
    tests/data/settings/code.swift.test \
    tests/data/sqlqry/code.swift.test \
    tests/data/upload/code.swift.test \
    tests/data/user/code.swift.test \
    tests/data/variables/code.swift.test \
    tests/data/view_section/code.swift.test \
    tests/data/websocket/code.swift.test \
    tests/data/page_inherit/code_inherit.swift \
    tests/data/page_redirect/redirect_code.swift \
    tests/data/nomaster/view.html \
    tests/data/nomaster/code.swift \
    tests/data/concurrent/code.swift \
    tests/data/concurrent/view.bin \
    tests/data/concurrent/code.bin \
    tests/data/concurrent/view.html.test \
    tests/data/concurrent/view.html \
    tests/data/concurrent/code.swift.test \
    tests/data/nomaster/code.bin \
    tests/data/nomaster/view.bin \
    tests/data/page_cache/code.bin \
    tests/data/page_cache/view.bin \
    tests/data/page_cookies/code.bin \
    tests/data/page_cookies/view.bin \
    tests/data/page_form/code.bin \
    tests/data/page_form/view.bin \
    tests/data/page_inherit/code.bin \
    tests/data/page_inherit/code_inherit.bin \
    tests/data/page_inherit/view.bin \
    tests/data/page_log/code.bin \
    tests/data/page_log/view.bin \
    tests/data/page_redirect/code.bin \
    tests/data/page_redirect/redirect_code.bin \
    tests/data/page_redirect/view.bin \
    tests/data/page_session/code.bin \
    tests/data/page_session/view.bin \
    tests/data/page_skins/code.bin \
    tests/data/page_skins/view.bin \
    tests/data/page_upload/code.bin \
    tests/data/page_upload/view.bin \
    tests/data/async/view.html.test \
    tests/data/page_cache/view.html.test \
    tests/data/page_cookies/view.html \
    tests/data/page_cookies/view.html.test \
    tests/data/page_flow/view.html.test \
    tests/data/page_form/view.html.test \
    tests/data/page_inherit/view.html.test \
    tests/data/page_log/view.html.test \
    tests/data/page_redirect/view.html.test \
    tests/data/page_session/view.html \
    tests/data/page_session/view.html.test \
    tests/data/page_skins/view.html \
    tests/data/page_skins/view.html.test \
    tests/data/page_upload/view.html.test \
    tests/data/async/code.swift.test \
    tests/data/httpclient/post_code.swift.test \
    tests/data/page_cache/code.swift.test \
    tests/data/page_cookies/code.swift \
    tests/data/page_cookies/code.swift.test \
    tests/data/page_flow/code.swift.test \
    tests/data/page_form/code.swift.test \
    tests/data/page_inherit/code.swift.test \
    tests/data/page_log/code.swift.test \
    tests/data/page_redirect/code.swift.test \
    tests/data/page_session/code.swift \
    tests/data/page_session/code.swift.test \
    tests/data/page_skins/data/skin1.txt \
    tests/data/page_skins/data/skin2.txt \
    tests/data/page_skins/code.swift \
    tests/data/page_skins/code.swift.test \
    tests/data/page_upload/code.swift.test \
    concurrent.sh \
    concurrent_single.sh \
    jenkins_1.651.3_all.deb \
    evilexec/evilexec \
    jsch-0.1.54.jar \
    soapui/SoapUI-x64-5.2.1.sh \
    build_test.sh \
    build_test_concurrent.sh \
    clean.sh \
    test_loop.sh \
    xdelta_test.sh \
    tests/global.settings.xml \
    websocket_bridge.py \
    websocket_setup.sh \
    tests/data/websocket.swift \
    tests/data/websocket.bin \
    tests/ws/data/account/code.bin \
    tests/ws/data/account/view.bin \
    tests/ws/data/async/code.bin \
    tests/ws/data/async/view.bin \
    tests/ws/data/fileitem/code.bin \
    tests/ws/data/fileitem/view.bin \
    tests/ws/data/httpclient/code.bin \
    tests/ws/data/httpclient/post_code.bin \
    tests/ws/data/httpclient/view.bin \
    tests/ws/data/settings/code.bin \
    tests/ws/data/settings/view.bin \
    tests/ws/data/sqlqry/code.bin \
    tests/ws/data/sqlqry/view.bin \
    tests/ws/data/user/code.bin \
    tests/ws/data/user/view.bin \
    websocket_test.sh \
    tests/ws/data/account/view.html \
    tests/ws/data/account/view.html.test \
    tests/ws/data/async/view.html \
    tests/ws/data/async/view.html.test \
    tests/ws/data/fileitem/view.html \
    tests/ws/data/fileitem/view.html.test \
    tests/ws/data/httpclient/view.html \
    tests/ws/data/httpclient/view.html.test \
    tests/ws/data/settings/view.html \
    tests/ws/data/settings/view.html.test \
    tests/ws/data/sqlqry/view.html \
    tests/ws/data/sqlqry/view.html.test \
    tests/ws/data/user/view.html \
    tests/ws/data/user/view.html.test \
    tests/ws/data/account/code.swift \
    tests/ws/data/account/code.swift.test \
    tests/ws/data/async/code.swift \
    tests/ws/data/async/code.swift.test \
    tests/ws/data/fileitem/test/test.txt \
    tests/ws/data/fileitem/code.swift \
    tests/ws/data/fileitem/code.swift.test \
    tests/ws/data/httpclient/test/data.txt \
    tests/ws/data/httpclient/code.swift \
    tests/ws/data/httpclient/code.swift.test \
    tests/ws/data/httpclient/post_code.swift \
    tests/ws/data/httpclient/post_code.swift.test \
    tests/ws/data/settings/code.swift \
    tests/ws/data/settings/code.swift.test \
    tests/ws/data/sqlqry/code.swift \
    tests/ws/data/sqlqry/code.swift.test \
    tests/ws/data/user/code.swift \
    tests/ws/data/user/code.swift.test \
    clean_bin.sh \
    tests/scripts/clean_props.groovy

SOURCES += \
    evilexec/evilexec.c
