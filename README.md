# sshx
enhance ssh command's ability to remember password

you can use sshx command just like ssh, when you use sshx to login another machine successfully, you can choose to remember password or not, but there is no options for ssh.

## install
*** you should know before you try to run it: sshx.expect is based on [expect](https://zh.wikipedia.org/wiki/Expect), so make sure expect has been already installed in your machine that you will run sshx.expect but remote machine. As i know, users that use macos needn't install manually because it has been built in while most linux system not ***

1. download `sshx.expect` to your machine (e.g. `/path/to/sshx.expect`)
2. run command `echo "alias sshx='expect /path/to/sshx.expect'" >> ~/.bash_profile`
3. then restart you terminal or run `source ~/.bash_profile`

## usage
enjoy sshx command just like ssh!

```
$ sshx user@example.com
user@example.com's password:

// input password 12345

$ Remember Password (yes/no)?
// type yes, then exit remote shell
$ exit

// verify 
$ sshx user@example.com
user@example.com's password: find password in config file, try auto login
// then it will auto login remote shell without inputting password again
```
