###
 # @Author: qwertyyb <qwertyyb@foxmail.com>
 # @LastEditors: qwertyyb <qwertyyb@foxmail.com>
 # @FilePath: /undefined/Users/marchyang/bash/sshx.sh
 # @Date: 2020-03-15 08:19:07
 # @LastEditTime: 2020-03-15 18:18:33
 ###
#!/usr/bin/expect

proc get_password {args} {
  if { ![file exists "~/.ssh/sshxrc"] } {
    return false
  }
  set fp [open "~/.ssh/sshxrc" r]
  while { [gets $fp data] >= 0 } {
    regexp {(.+),\s*(.+)} $data a b c
    if {$b == $args} {
      close $fp
      return $c
    }
  }
  close $fp
  return false
}

proc set_password {args password} {
  set fp [open "~/.ssh/sshxrc" r]

  set new_content ""
  set inserted false
  while { [gets $fp data] >= 0 } {
    # puts $data
    regexp {(.+),\s*(.+)} $data a b c
    if { $b == $args && !$inserted } {
      append new_content "$args,$password\n"
      set inserted true
    } elseif { $b != $args } {
      append new_content "$args,$password\n"
    }
  }
  close $fp
  if { !$inserted } {
    append new_content "$args,$password\n"
  }

  set fp [open "~/.ssh/sshxrc" w]
  # puts "new: $new_content"
  puts $fp $new_content
  close $fp
}

proc prompt_password {} {
  stty -echo
  # send_user -- "Password:"
  expect_user -re "(.*)\n"
  send_user "\n"
  stty echo
  set pass $expect_out(1,string)
  return $pass
}

# puts [set_password "$argv" "123"]
# puts [set_password "root@116.62.58.193" "124456"]

set timeout 60

spawn ssh $argv

set try_times 0

expect {
  "*(yes/no)?" { send "yes\r"; exp_continue }
  "password:" {
    if { $try_times <= 0 } {
      # 初次，尝试从配置中获取密码
      set saved_password [get_password $argv]
      set new_password $saved_password
      set password $saved_password
    }
    if {$password == false || $try_times > 0} {
      # 从配置中获取密码失败或者第一次登录失败时，要重新输入密码
      # 把密码存储到$new_password
      set new_password [prompt_password]
      set password $new_password
    }
    if {$saved_password != false && $try_times <= 0} {
      send_user "find password in config file, try auto login"
    }
    send "$password\r"

    set try_times [expr $try_times + 1]
    exp_continue
  }
  "Last*:" {
    if { $new_password != $saved_password } {
      # 使用新密码登录成功，询问是否记住密码，更新配置文件
      stty echo
      send_user "Remember Password (yes/no)?"
      expect_user {
        "yes" { puts [set_password $argv $new_password] }
        "YES" { puts [set_password $argv $new_password] }
        "y" { puts [set_password $argv $new_password] }
        "Y" { puts [set_password $argv $new_password] }
      }
    }
  }
}

interact
