---
layout: post
title: Mongodb Aggregate Sum。
categories: mongo
description: Mongodb sum 查询聚合
keywords: mongo, sum
---

# Mongodb search aggregate SUM

 * find aggregate

```bash

db.cabinet.aggregate(
   [
     {
       $group:
         {
           _id: { },
           totalAmount: { $sum: "$cabinetBoxTotal" },
           count: { $sum: 1 }
         }
     }
   ]
)

```
