/*
    code.swift is part of Appudo

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
import java.nio.file.*;

class Helper {
public static void sendDir(Path dir, InputStream ins, OutputStream out) throws IOException {
        try {
		DirectoryStream<Path> stream = Files.newDirectoryStream(dir);
		for (Path entry: stream) {
			File file = new File(entry.toString());
			if(file.isDirectory()) {
				String command = "D0755 0 ";
				String filename = entry.toString();
				if(filename.lastIndexOf('/') > 0) {
                                        command += filename.substring(filename.lastIndexOf('/') + 1);
                                } else {  
                                        command += filename;
                                }
                                command += "\n";
				out.write(command.getBytes());
                                out.flush();
                                Helper.checkAck(ins);
				sendDir(entry, ins, out);
				command = "E\n";
				out.write(command.getBytes());
                                out.flush();
                                Helper.checkAck(ins);
			} else {
                                long fsize = file.length();
                                String command = "C0644 " + fsize + " ";
				String filename = entry.toString();

                                if(filename.lastIndexOf('/') > 0) {
                                        command += filename.substring(filename.lastIndexOf('/') + 1);
                                } else {
                                        command += filename;
                                }

				command += "\n";
				out.write(command.getBytes()); 
				out.flush();
				Helper.checkAck(ins);
	
				// send a content of file
				InputStream fis = new FileInputStream(new File(entry.toString()));
				byte[] buf = new byte[1024];
				while(true) {
					int len = fis.read(buf, 0, buf.length);
					if(len <= 0) 
						break;
					out.write(buf, 0, len);
				}
				fis.close();
				fis = null;
				// send '\0'
				buf[0] = 0;
				out.write(buf, 0, 1); 
				out.flush();
				Helper.checkAck(ins);
			}		
		}
	} catch (DirectoryIteratorException ex) {
		throw ex.getCause();
	}
}

public static void recvDir(Path dir, InputStream ins, OutputStream out) throws IOException {
        try {
                long idx = 0;
                byte[] buf = new byte[1024];
                FileOutputStream fos = null;

                // send '\0'
                buf[0] = 0;
                out.write(buf, 0, 1);
                out.flush();

                while(true)
                {
                    String fname = null;
                    int c = Helper.checkAck(ins);
                    if(c == 'C') {
                        int bsize;
                        long fsize = 0L;
                        ins.read(buf, 0, 5);
                        while(true) {
                            if(ins.read(buf, 0, 1) < 0 || buf[0] == ' ') {
                               break;
                            }
                            fsize = fsize * 10L + (long)(buf[0] - (byte)'0');
                        }

                        for(int i = 0; i < 1024; i++) {
                            ins.read(buf, i, 1);
                            if(buf[i] == (byte)0x0a) {
                                fname = new String(buf, 0, i);
                                break;
                            }
                        }
                        // send '\0'
                        buf[0] = 0;
                        out.write(buf, 0, 1);
                        out.flush();
                        if(fname == null)
                            break;

                        fos = new FileOutputStream(dir.resolve(fname).toString());
                        while(true) {
                            if(buf.length < fsize) {
                                bsize = buf.length;
                            } else {
                                bsize = (int)fsize;
                            }
                            bsize = ins.read(buf, 0, bsize);
                            if(bsize < 0) {
                                break;
                            }
                            fos.write(buf, 0, bsize);
                            fsize -= bsize;
                            if(fsize == 0L) {
                                break;
                            }
                        }
                        fos.close();
                        fos = null;

                        if(Helper.checkAck(ins) != 0) {
                            break;
                        }

                        // send '\0'
                        buf[0] = 0;
                        out.write(buf, 0, 1);
                        out.flush();

                    }
                    else
                    if(c == 'D')
                    {
                        ins.read(buf, 0, 7);

                        for(int i = 0; i < 1024; i++) {
                            ins.read(buf, i, 1);
                            if(buf[i] == (byte)0x0a) {
                                fname = new String(buf, 0, i);
                                break;
                            }
                        }

                        if(fname == null)
                            break;

                        if(idx != 0) {
                            dir = dir.resolve(fname);
                            new File(dir.toString()).mkdir();
                        }
                        idx++;

                        // send '\0'
                        buf[0] = 0;
                        out.write(buf, 0, 1);
                        out.flush();
                    }
                    else
                    if(c == 'E')
                    {
                        ins.read(buf, 0, 1);
                        idx--;
                        if(idx != 0) {
                            dir = dir.getParent();
                        }

                        // send '\0'
                        buf[0] = 0;
                        out.write(buf, 0, 1);
                        out.flush();
                    }
                    else
                    {
                        break;
                    }
                }
        } catch (DirectoryIteratorException ex) {
                throw ex.getCause();
        }
}

public static int checkAck(InputStream ins) throws IOException {
    int b = ins.read();
    if(b == 0)  // success
        return b;
    if(b == -1) 
        return b;

    if(b == 1 || b == 2) {
        StringBuffer sb = new StringBuffer();
        int c;
        while(true) {
            c = ins.read();
            sb.append((char)c);
	    if(c == '\n')
		break;
        }
        if(b == 1) { // error
            throw new IOException(sb.toString());
        }
        if(b == 2) { // fatal error
            throw new IOException(sb.toString());
        }
    }
    return b;
}
}

class SSHUserInfo implements UserInfo {
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
	((ChannelExec)channel).setCommand((recv == 1 ? "scp -rf " : "scp -rt ") + target);
	channel.setInputStream(null);
	((ChannelExec)channel).setErrStream(System.err);
	channel.connect();
    } catch(Throwable t) { 
        continue;
    }
    break;
}

InputStream instream = channel.getInputStream();
OutputStream outstream = channel.getOutputStream();


try {
        if(recv == 1) {
            Helper.recvDir(Paths.get(source), instream, outstream);
        } else {
            Helper.checkAck(instream);
            Helper.sendDir(Paths.get(source), instream, outstream);
        }
} catch(Exception ee) {
	testRunner.fail("SSH command failed: $ee.")
}

context.setProperty("exitStatus", "0");
channel.disconnect();
session.disconnect();
