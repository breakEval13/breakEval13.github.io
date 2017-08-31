---
layout: post
title: docker clear up for mac 
categories: docker
description: bash shell docker clear up for mac 
keywords: docker
---


# 1、Main

> 清理mac上Docker占用的磁盘空间

## 1.1、内容：

```text
Docker依赖Linux系统的cgroup实现，在mac系统中运行的时候，Docker会启动一个虚拟机中的Linux内核，并在硬盘上放一个 qcow2 格式的磁盘镜像文件。这个文件会随着Docker的使用不断膨胀，即使删除不用的Docker Image和Container也不会缩小。我在测试完一个自动化工具的Dockerfile改写之后，Docker.qcow2文件就达到42GB了。

Google搜了一圏发现一个叫Théo Chamley的法国人写了一个脚本释放Docker.qcow2文件占用的空间。基本原理是用 docker save 命令保存要保留的image，然后关闭Docker，删除Docker.qcow2，再启动Docker，它会自动重建，最后用 docker load 命令恢复保留的image。
```


## 命令行

```bash
 sudo sh docker-clean.sh $(docker images | awk 'NR>1 {print $1":"$2}')
```


## 脚本

```bash
#!/bin/bash
# sudo sh docker-clean.sh $(docker images | awk 'NR>1 {print $1":"$2}')

IMAGES=$@

echo "This will remove all your current containers and images except for:"
echo ${IMAGES}
read -p "Are you sure? [yes/NO] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi


TMP_DIR=$(mktemp -d)

pushd $TMP_DIR >/dev/null

open -a Docker
echo "=> Saving the specified images"
for image in ${IMAGES}; do
	echo "==> Saving ${image}"
	tar=$(echo -n ${image} | base64)
	docker save -o ${tar}.tar ${image}
	echo "==> Done."
done

echo "=> Cleaning up"
echo -n "==> Quiting Docker"
osascript -e 'quit app "Docker"'
while docker info >/dev/null 2>&1; do
	echo -n "."
	sleep 1
done;
echo ""

echo "==> Removing Docker.qcow2 file"
rm ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2

echo "==> Launching Docker"
open -a Docker
echo -n "==> Waiting for Docker to start"
until docker info >/dev/null 2>&1; do
	echo -n "."
	sleep 1
done;
echo ""

echo "=> Done."

echo "=> Loading saved images"
for image in ${IMAGES}; do
	echo "==> Loading ${image}"
	tar=$(echo -n ${image} | base64)
	docker load -q -i ${tar}.tar || exit 1
	echo "==> Done."
done

popd >/dev/null
rm -r ${TMP_DIR}
```

