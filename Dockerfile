FROM node:8-alpine AS builder

ARG GIT_REPOSITORY=https://github.com/adsr/irslackd.git
ARG GIT_BRANCH=master

RUN apk add --no-cache git && \
    git clone --single-branch --depth=1 -b ${GIT_BRANCH} ${GIT_REPOSITORY} /tmp/irslackd.git && \
    mkdir -pv /opt/irslackd && \
    cd /tmp/irslackd.git && \
    git archive ${GIT_BRANCH} | tar -xC /opt/irslackd && \
    cd /opt/irslackd && \
    rm -rf /tmp/irslackd.git && \
    npm install

FROM node:8-alpine

ENV LISTEN_PORT=6667
ENV LISTEN_ADDR=0.0.0.0
ENV SSL_KEY=/ssl/key.pem
ENV SSL_CERT=/ssl/cert.pem
ENV EXTRA_FLAGS=

RUN apk update && \
    apk upgrade && \
    apk add ca-certificates dumb-init

COPY --from=builder /opt/irslackd /opt/irslackd
EXPOSE 6667

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD /opt/irslackd/irslackd -a ${LISTEN_ADDR} -p ${LISTEN_PORT} -k ${SSL_KEY} -c ${SSL_CERT} ${EXTRA_FLAGS:-}
