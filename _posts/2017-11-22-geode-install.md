---
layout: post
title: 为流处理加上一层高新能缓存。
categories: Apache
description: 搭建分布式缓存集群。
keywords: Apache geode, geode
---

# Apache geode install 

 * 下载二进制文件

```bash
wget http://apache.osuosl.org/geode/1.3.0/apache-geode-1.3.0.zip

```

* 复制到其他多个节点进行解压


```bash

unzip apache-geode-1.3.0.zip

```

* 修改为集群模式（注意⚠️：支持的模式有分组模式，集群模式，集群+分组模式）

* 二进制文件所在 `/home/hadmin/geode/`

* 创建相应的配置文件路径

```bash
mkdir -p cluster_config/cluster
```

* 将`/home/hadmin/geode/config`内的文件复制到刚才创建的目录内，并且进行相应的修改文件名。

```bash

gemfire.properties	mv -> cluster.properties

cache.xml	mv -> cluster.xml

```


* 结果

```bash

[root@dscn022 geode]# ls cluster_config/cluster/
cluster.properties  cluster.xml

```
