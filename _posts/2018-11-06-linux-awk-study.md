---
layout: post
categories: linux awk sed tail head
title: Linux里awk中split函数用法尝试[整理+转载]
date: 2018-11-06 15:16:43 +0800
description: Linux里awk,sed,less,tail,count函数的用法
keywords: awk linux sed tail less head
---



### 直接上代码


```bash
set time = 12:34:56
set hr = `echo $time | awk '{split($0,a,":" ); print a[1]}'` # = 12

set sec = `echo $time | awk '{split($0,a,":" ); print a[3]}'` # = 56

set hms = `echo $time | awk '{split($0,a,":" ); print a[1], a[2], a[3]}'`# = 12 34 56

# 获得5 - 10 line 并且用 `;` 分隔每一行  获得第个元素
sed -n '5,10p' xvideos.com-db.csv | awk '{split($0,a,";" ); print a[1]}'

sed -n '5,10p' xvideos.com-db.csv | awk '{split($0,a,";" ); print a[1] a[2]}'

#从第3000行开始，显示1000行。即显示3000~3999行
cat filename | tail -n +3000 | head -n 1000

#显示1000行到3000行

cat filename| head -n 3000 | tail -n +1000 

tail -n 1000 #：显示最后1000行

tail -n +1000 #：从1000行开始显示，显示1000行以后的

head -n 1000 #：显示前面1000行

tail -400f demo.log #监控最后400行日志文件的变化 等价与 tail -n 400 -f （-f参数是实时）

less demo.log #查看日志文件，支持上下滚屏，查找功能

uniq -c demo.log  #标记该行重复的数量，不重复值为1

grep 'INFO' demo.log     #在文件demo.log中查找所有包行INFO的行

grep -o 'order-fix.curr_id:\([0-9]\+\)' demo.log    #-o选项只提取order-fix.curr_id:xxx的内容（而不是一整行），并输出到屏幕上
grep -c 'ERROR' demo.log   #输出文件demo.log中查找所有包行ERROR的行的数量

# 输出demo.log中的某个日期中的ERROR的行
sed -n '/^2011-08-23.*ERROR/p' demolog.log

#指定执行的sed文件
sed -f demo.sed2 demo.log
```
* demo.sed2

```bash
#n   #这一行用法和命令中的-n一样意思，就是默认不输出
#demo.sed2
#下面的一行是替换指令，就是把19位长的日期和INFO/ERROR,id,和后面的一截提取出来，然后用@分割符把这4个字段重新按顺序组合
s/^\([-\: 0-9]\{19\}\).*\(INFO\|ERROR\) .*order-fix.curr_id:\([0-9]\+\),\(.*$\)/\1@\3@\2@\4/p


#排序功能 -t表示用@作为分割符，-k表示用分割出来的第几个域排序(不要漏掉后面的,2/,3/,1，详细意思看下面的参考链接，这里不做详述)
sed -f test.sed demolog.log | sort -t@ -k2,2n -k3,3r -k1,1  #n为按数字排序，r为倒序


awk 'BEGIN{FS="@"} {print $2,$3}' demo.log_after_sort   #BEGIN中预处理的是，把@号作为行的列分割符,把分割后的行的第2，3列输出

```

* 对指定时间范围内的日志进行统计，包括输出INFO，ERROR总数，记录总数，每个订单记录分类统计

```bash
sed -f demo.sed demolog.log | sort -t@ -k2,2n -k3,3r -k1,1 | awk -f demo.awk
```

* demo.awk

```bash
#下面的例子是作为命令行输入的，利用单引号作为换行标记，这样就不用另外把脚本写进文件调用了
awk '
BEGIN {
  FS="@"
}
 
{
  if ($3 == "INFO") {info_count++}
  if ($3 == "ERROR") {error_count++}
 
}
 
END {
  print "order total count:"NR           #NR是awk内置变量，是遍历的当前行号，到了END区域自然行号就等于总数了
  printf("INFO count:%d ERROR count:%d\n",info_count,error_count)
} ' demo.log_after_sort

```

原文：https://blog.csdn.net/UltraNi/article/details/6750434

转载请注明出处，本文采用 [CC4.0](http://creativecommons.org/licenses/by-nc-nd/4.0/) 协议授权
