---
layout: post
title:  Flink 消费RocketMQ 如何定义Source[原创精品]
categories: RocketMQ,Flink,MapReduce
description: 笔记
keywords: RocketMQ
---


RocketMQ消息队列整合Flink的解决方案。


## 摘要: RocketMQ-->Flink-->CrateDB
* 本文不涉及Sink的定义
* 详情关注 `Github` https://github.com/zmatsh
* 稍后会整理成插件放到GitHub ：https://github.com/zmatsh/rocketmq-flink-source-plugin

# Flink Source定义

```java
package com.flink.source;

import com.alibaba.rocketmq.client.consumer.DefaultMQPushConsumer;
import com.alibaba.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import com.alibaba.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import com.alibaba.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import com.alibaba.rocketmq.common.consumer.ConsumeFromWhere;
import com.alibaba.rocketmq.common.message.Message;
import com.alibaba.rocketmq.common.message.MessageExt;
import com.alibaba.rocketmq.common.protocol.heartbeat.MessageModel;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;

import java.nio.charset.Charset;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.*;

/**
 * Created by zhangjianxin on 2017/7/21.
 */
public class RocketMQSource extends RichSourceFunction<String> implements MessageListenerConcurrently  {
    public static DefaultMQPushConsumer consumer;
    public static LinkedBlockingQueue<String> queue;
    public static ConcurrentLinkedQueue<String> cqueue;
    public RocketMQSource(String ConsumerGroupName,String NamesrvAddr,int QueueSize,int ConsumeMessageMAXSize) throws Exception {
        queue = new LinkedBlockingQueue<>(QueueSize);
        consumer = new DefaultMQPushConsumer(ConsumerGroupName);
        consumer.setNamesrvAddr(NamesrvAddr);
        consumer.setInstanceName(UUID.randomUUID().toString());
        consumer.setConsumeMessageBatchMaxSize(ConsumeMessageMAXSize);//消息数量每次读取的消息数量
        consumer.setMessageModel(MessageModel.CLUSTERING);
        consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);
        consumer.registerMessageListener(this);
        consumer.subscribe("user", "*");
        consumer.subscribe("org", "*");
        consumer.start();
        System.out.println("RocketMQ Started.");
    }
    @Override
    public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
        System.out.println("list Size:" + list.size());
        System.out.println(Thread.currentThread().getName() + " Receive New Messages: " + list);
        long offset = list.get(0).getQueueOffset();
        String maxOffset = list.get(0).getProperty("MAX_OFFSET");
        long diff = Long.parseLong(maxOffset) - offset;
        if (diff > 100000) {
            System.out.println("消息堆积");
            return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
        }
        byte[] body;
        String message;
        for (Message msg : list) {
            if(msg.getTopic().equals("user")){
                body = msg.getBody();
                message = new String(body, Charset.forName("GBK"));
                try {
                    queue.put(message);
                    System.out.println("------------------user:"+message+"------------------");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }else if(msg.getTopic().equals("org")){
                body = msg.getBody();
                message = new String(body, Charset.forName("GBK"));
                try {
                    queue.put(message);
                    System.out.println("------------------org:"+message+"------------------");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
    }

    @Override
    public void run(SourceContext sourceContext) throws Exception {
        String obj = null;
        while (!((obj = queue.take()).equals("quit"))) {
                Thread.sleep(10L);
                sourceContext.collect(obj);
            }

        }
    @Override
    public void cancel() {

    }
}


```


## Main方法调用Flink启动JobManager

```java
  final ParameterTool parameterTool = ParameterTool.fromArgs(args);

        if (parameterTool.getNumberOfParameters() < 5) {
            System.out.println("Missing parameters!");
            System.out.println("\nUsage: Flink->MQ->CrateDB \n" +
                    "--consumerGroupName <消费组名称> \n" +
                    "--parallelism <并发数量> \n"+
                    "--qsize <转发队列的大小>\n" +
                    "--mqaddr <MQ地址>\n" +
                    "--consumer <consumer read Message size>\n");
            return;
        }

   RocketMQSource rocketMQSource2 = new RocketMQSource(
                   parameterTool.get("consumerGroupName","DEMO")
                  ,parameterTool.get("mqaddr","127.0.0.1:9876")
                  ,parameterTool.getInt("qsize",1000)
                  ,parameterTool.getInt("consumer",1)
          );
```

## 禁止转载，盗版必究。`倒贴必须DDOS你！`


