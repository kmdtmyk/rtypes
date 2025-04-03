FROM ruby:3.0.3-alpine3.13

ARG UID=1000
ARG GID=1000

# add user
RUN addgroup -g $GID docker && \
    adduser -S -u $UID -G docker docker && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'docker:docker' | chpasswd

USER docker
