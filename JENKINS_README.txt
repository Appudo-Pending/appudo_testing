jenkins config:
0.  If necessary setup dnsmasq to resolve the host used for the tests.
0.1 Create the master account to start with.
1.0 Possibly set the path for SoapUI in "testrunner.sh".
1.  Export the user directory in "testrunner.sh".
2.  Create a free style project in jenkins.
2.  Set the working dir of the project to the directory of this file.
3.  Add a build step for shell execution with "./test.sh".
4.  Add a post build action for JUnit test results with "results/*.xml".
