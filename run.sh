#! /bin/bash

docker build -t fp .
docker run -it --rm --gpus all -p 7860:7860 fp

