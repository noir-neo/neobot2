#!/bin/sh

docker build -t noir-neo/neobot2 .
docker stop lita && docker rm lita
docker run -d --name lita --link redis --restart always -v /home/ec2-user/neobot2_docker_bundle_cache:/var/bundle -p 8001:8001 -e "TZ=Asia/Tokyo" noir-neo/neobot2

