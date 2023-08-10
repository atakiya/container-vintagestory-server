FROM mcr.microsoft.com/dotnet/runtime:7.0-alpine AS base

ENV USER "vintagestory"
ENV UID "1001"
ENV GID "1001"
ENV SERVER_VERSION "1.18.8"

RUN apk update \
	&& apk add --no-cache \
	ca-certificates \
	gcompat

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
