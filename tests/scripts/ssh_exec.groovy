/*
    ssh_scp.groovy is part of Appudo

    Copyright (C) 2015-2016


    Licensed under the Apache License, Version 2.0

    See http://www.apache.org/licenses/LICENSE-2.0 for more information
*/
package com.content.jsc;
import com.jcraft.jsch.*;
import java.awt.*;
import javax.swing.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import java.io.*;

public class SSHUserInfo implements UserInfo {
    String password = "";
    public SSHUserInfo(String password) { this.password = password; }
    public String getPassword(){ return password; }
    public boolean promptYesNo(String str){return true;}
    public String getPassphrase(){ return null; }
    public boolean promptPassphrase(String message){ return true; }
    public boolean promptPassword(String message){ return true; }
    public void showMessage(String message){}
}

def username = context.expand('${#TestCase#sshName}')
def pwd = context.expand('${#TestCase#sshPassword}')
def host = context.expand('${#TestCase#baseURL}')

//log.info("name: $username");
//log.info("host: $host");
//log.info("pass: $pwd")

JSch jsch = new JSch();
Channel channel;
while(true) {
    session = jsch.getSession(username, host, 22);
    UserInfo ui = new SSHUserInfo(pwd);
    try {
        session.setUserInfo(ui);
	session.setServerAliveInterval(1000);
	session.setServerAliveCountMax(99);
        session.connect();
	channel = session.openChannel("exec");
	((ChannelExec)channel).setCommand(command);
	channel.setInputStream(null);
	((ChannelExec)channel).setErrStream(System.err);
	instream=channel.getInputStream();
	channel.connect();
    } catch(Throwable t) {
        continue;
    }
    break;
}

byte[] tmp=new byte[1024];

while(true) {
    while(instream.available() > 0) {
        int i = instream.read(tmp, 0, 100);
        if(i < 0)
            break;
	result.append((new String(tmp, 0, i)).toCharArray());
    }
    if(channel.isEOF() && instream.available() == 0) {
	context.setProperty("exitStatus", channel.getExitStatus().toString());
        break;
    }

    try {
        Thread.sleep(1000);
    } catch(Exception ee) { 
        log.info(ee);
	testRunner.fail("SSH command failed: $ee.") 
    }
}
channel.disconnect();
session.disconnect();
