#!/usr/bin/env bash

 exec \
     /app/lidarr/bin/Lidarr \
         --nobrowser \
         --data=/config \
         "$@"
