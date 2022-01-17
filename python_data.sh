#!/usr/bin/bash
docker run -v `pwd`:/working_dir -w /working_dir --rm -ti data-dev-env-gen:latest python "$@"