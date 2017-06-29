---
layout: post
title: Kubernetes命名空间资源限制[学习]
categories: Java, Scala,Hadoop,Flink
description: Java, Scala,Hadoop,Flink
keywords: Java, Scala,Hadoop,Flink
---

Kubernetes命名空间资源限制主要是为了多个团队一起开发来区分资源使用情况。




## 1. ResourceQuota
```yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: test
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 12Gi

```

## 2. LimitRange

```yaml

apiVersion: v1
kind: LimitRange
metadata:
  name: limits
spec:
  limits:
  - max:
      cpu: "4"
      memory: 2Gi
    min:
      cpu: 200m
      memory: 6Mi
    maxLimitRequestRatio:
      cpu: 3
      memory: 2
    type: Pod
  - default:
      cpu: 300m
      memory: 200Mi
    defaultRequest:
      cpu: 200m
      memory: 100Mi
    max:
      cpu: "2"
      memory: 1Gi
    min:
      cpu: 100m
      memory: 3Mi
    maxLimitRequestRatio:
      cpu: 5
      memory: 4
    type: Container


```

> 感谢企业服务部牛总提供的解决方案
