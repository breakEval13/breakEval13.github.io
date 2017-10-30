---
layout: post
title: Crate DB重启数据恢复较慢解决方案[原创]
categories: java
description: crate.io
keywords: crate.io,databases
---


Crate DB重启数据恢复较慢解决方案“采用ES restFull API”


date：2017-10-31
author：zhangjianxin

[*] 成功图，


   ![](https://zmatsh.b0.upaiyun.com/images/crate-success.png)


[*] 解决方案


# 解决Crate 重启回复分片速度慢的问题
  * 修改crate配置文件
   ```bash
   es.api.enabled: true
   ```

  * 开始处理
  ```bash
  curl -XPUT http://127.0.0.1:9200/_cluster/settings -d'
  {
  	"transient" : {
  		"cluster.routing.allocation.enable" : "none"
  	}
  }'
  ```

* 以上操作经过验证可以直接拿去。
* auther `breakEval13`
* https://github.com/breakEval13