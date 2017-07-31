/*
    setup_props.groovy is part of Appudo

    Copyright (C) 2015-2016


    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/
def propfile = context.expand('${#propfile}')
def udir = context.expand('${#projectDir}')
def props = new Properties();
if(!propfile) {
        propfile = "settings.properties";
}
udir += "/" + propfile;
props.load(new FileInputStream(udir));

def ln = props.getProperty('loginName');
props.setProperty('masterName', "");
def uid = props.getProperty('userID');
props.setProperty('masterID', "");

testSuite.testCaseList.each {
        def e = props.propertyNames();
        log.info "Test Case : ${it.name}"
        while (e.hasMoreElements()) {
                String key = (String) e.nextElement();
                //it.removeProperty(key)
                it.setPropertyValue(key, "")
        }
}
