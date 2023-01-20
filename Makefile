NAME := op-tee
DOCKER_USER_NAME := $(shell cat Dockerfile | grep "ARG DOCKER_USER_" | cut -d "=" -f 2)
DOCKER_HOME_DIR := /home/${DOCKER_USER_NAME}

SHELL := /bin/bash




# コンテナ実行
run:
	make _preExec -s
	-docker container exec -it ${NAME} bash
	make _postExec -s

# dockerのリソースを開放
clean:
	docker system prune

# キャッシュ有りでビルド
build:
	DOCKER_BUILDKIT=1 docker image build -t ${NAME}
	make _postBuild -s

# キャッシュを使わずにビルド
rebuild:
	DOCKER_BUILDKIT=1 docker image build -t ${NAME} \
	--pull \
	--no-cache=true .
	make _postBuild -s

# コンテナ実行する際の前処理
_preExec:
ifneq ($(shell docker ps -a | grep -c ${NAME}),0)
	docker container kill ${NAME}
endif
	-docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	${NAME}:latest

# コンテナ終了時の後処理
# コンテナ内のファイルをローカルへコピー，コンテナの削除を行う
_postExec:
	docker container stop ${NAME}
