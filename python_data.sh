#!/usr/bin/bash
container_python_path=/usr/local/bin/python
		"source=${localEnv:HOME}/data-models,target=/home/vscode/data-models,type=bind",
		"source=${localEnv:HOME}/nltk_data,target=/home/vscode/nltk_data,type=bind",

# If models are already present
docker run \
  -v `pwd`:/working_dir \
  -v $HOME/data-models:/root/data-models
  -v $HOME/nltk_data:/root/nltk_data
  -w /working_dir --rm -ti data-dev-env-gen:latest python "$@"
