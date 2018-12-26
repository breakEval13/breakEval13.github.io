---
layout: post
categories: python
title: python 远程启动mapreduce作业
date: 2018-12-26 18:08:19 +0800
description: python 模拟实现tail -f
keywords: python
---


本文基于Python2.7 进行测试


## 源码

```python
# -*- coding:utf-8 -*-
import BaseHTTPServer
import threading
import logging
import time
import urllib
import urlparse
import shlex
import subprocess
import io, shutil
import re
import random
import time
import os
from multiprocessing import Queue, Pool
import multiprocessing, time, random
class RequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    '''处理请求并返回页面'''

    def do_GET(s):
        try:
            if None != re.search('/api/v1/startjar*', s.path) and '?' in s.path:
                print("in controller")
                content = ""
                startjar = ""
                query = urllib.splitquery(s.path)
                action = query[0]
                if query[1]:  # 接收get参数
                    queryParams = {}
                    for qp in query[1].split('&'):
                        kv = qp.split('=')
                        queryParams[kv[0]] = urllib.unquote(kv[1]).decode("utf-8", 'ignore')
                        content += kv[0] + ':' + queryParams[kv[0]] + "\r\n"
                        if kv[0] == 'jar':
                            startjar = queryParams[kv[0]]

                shell_cmd = ' hadoop fs -copyToLocal /task/mr/'+startjar+' /opt/cm/lib/cloudera-scm-agent/jobs/myjar.jar && hadoop jar /opt/cm/lib/cloudera-scm-agent/jobs/myjar.jar && yes|rm /opt/cm/lib/cloudera-scm-agent/jobs/myjar.jar'
                print("cmd is " + shell_cmd)
                cmd = shlex.split(shell_cmd)
                p = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                while p.poll() is None:
                    line = p.stdout.readline()
                    line = line.strip()
                    if line:
                        s.wfile.write(line + "\n")
                if p.returncode == 0:
                    print('Subprogram success')
                else:
                    print('Subprogram failed')
        except Exception:
            s.wfile.close()
            print("Error ")


# ---------------------------------------------------------------------

if __name__ == '__main__':
    serverAddress = ('', 8881)
    server = BaseHTTPServer.HTTPServer(serverAddress, RequestHandler)
    server.serve_forever()

```


## python 远程执行作业，（作业通过serverless 上传到hdfs）

* 用的http服务是python2.7 自带的（简单）
* 实现比较简单就是利用了 subprocess 的PIPE 通过管道将结果输出，实现一个watch on 的效果（大佬勿喷）



转载请注明出处，本文采用 [CC4.0](http://creativecommons.org/licenses/by-nc-nd/4.0/) 协议授权
