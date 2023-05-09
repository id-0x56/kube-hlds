FROM debian:bullseye

ARG USERNAME=hlds
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

ENV TZ=Europe/London
RUN apt update \
    && apt install --no-install-recommends -y tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt update \
    && apt install --no-install-recommends -y sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt update \
    && apt install --no-install-recommends -y locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN apt update \
    && apt install -y ca-certificates lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

COPY bin/hlds_l /hlds_l

RUN chown -R $USERNAME:$USERNAME /hlds_l \
    && chmod +x /hlds_l/hlds_* \
    && mkdir -p /home/hlds/.steam/sdk32 \
    && ln -snf /hlds_l/steamclient.so /home/hlds/.steam/sdk32/steamclient.so

USER $USERNAME

WORKDIR /hlds_l



# docker builder prune -af \
#     && docker system prune -af \
#     && docker volume prune -f \
#     && docker image prune -af

# docker login
# docker build --no-cache -t 00x56/kubernetes-hlds:latest .
# docker push 00x56/kubernetes-hlds:latest

# docker run --rm --interactive --tty --workdir /hlds_l -p 27015:27015/tcp -p 27015:27015/udp 00x56/kubernetes-hlds /bin/bash
# docker exec --interactive --tty 7809913082a3 /bin/bash
