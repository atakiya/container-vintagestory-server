FROM docker.io/alpine AS base

ENV USER "vintagestory"
ENV UID "1001"
ENV GID "1001"
ENV SERVER_VERSION "1.17.11"

# Required for mono and mono-dev
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
	apk update && \
	apk add --no-cache \
		ca-certificates \
		mono@testing \
		mono-dev@testing

# Setup service user
RUN addgroup --gid ${GID} -S ${USER} && \
	adduser -G ${USER} --shell /bin/false --disabled-password -H --uid ${UID} ${USER} && \
	mkdir -p /var/log/${USER} && \
	chown ${USER}:${USER} /var/log/${USER}

COPY bootstrap.sh .

# Setup volume permissions
RUN chown ${USER}:${USER} /bootstrap.sh && \
	mkdir -p /app && \
	chown ${USER}:${USER} /app && \
	mkdir -p /data && \
	chown ${USER}:${USER} /data

EXPOSE 42420

VOLUME [ "/app", "/data" ]

USER ${USER}
ENTRYPOINT ["sh", "bootstrap.sh"]
