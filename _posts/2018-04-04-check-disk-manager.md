---
layout: post
categories: awk
title: linu硬盘检查大小awk脚本全自动执行
date: 2018-04-04 17:08:52 +0800
description: 硬盘监测
keywords: awk linux 硬盘检查
---


## DISK 监测剩余量


```bash
#!/bin/bash
temp=0.0
DISK_SIZE=0.0
for i in {0..26}
do
    echo -e "dscn0$i Disk"
    echo "剩余可用大小GB"
    temp=`ssh dscn0$i df -m|grep hadoop | awk '$4~/^[0-9]/ {split($4,array,"[A-Z]");b+=array[1]} END {print b/1024}'`
    DISK_SIZE=$(echo "$DISK_SIZE + $temp" | bc)

    echo -e "总数 剩余 占比 目录"
    ssh dscn0$i df -h | grep hadoop  | awk '{print$2, $4, $5, $6}'
done
echo -e "\033[32m 剩余总大小: $DISK_SIZE GB \033[0m"

```

转载请注明出处，本文采用 [CC4.0](http://creativecommons.org/licenses/by-nc-nd/4.0/) 协议授权
