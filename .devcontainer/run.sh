#!/bin/bash

docker compose run --rm yocto-builder bash

# docker compose run --rm --service-ports yocto-builder bash

# docker compose run --rm yocto-builder bash -c "source bitbake-builds/poky-wrynose/build/init-build-env && bash"

# source bitbake-builds/poky-wrynose/build/init-build-env 

# source toaster start webport=0.0.0.0:8000 --> http://localhost:8000
