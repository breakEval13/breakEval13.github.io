#!/usr/bin/env bash

git add .

git commit -m 'CI/CD Push and Commit'

git push

ssh root@cgroup.ltd -p 19782 docker restart 66697251e571