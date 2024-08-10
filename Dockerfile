FROM mcr.microsoft.com/dotnet/runtime:7.0 AS base

LABEL org.opencontainers.image.authors="Avunia Takiya <avunia.takiya.eu>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/atakiya/container-vintagestory-server/"

ENV USER="vintagestory"
ENV UID="1001"
ENV GID="1001"
ENV SERVER_VERSION="latest"
ENV UPDATE_CHANNEL="stable"

ARG DEBIAN_FRONTNED=noninteractive

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get dist-upgrade -y \
	&& apt-get install -y --no-install-recommends \
	wget jq

FROM base AS app

# Setup service user
RUN addgroup --gid ${GID} --system ${USER} && \
	adduser --ingroup ${USER} --shell /bin/false --disabled-password --no-create-home --uid ${UID} ${USER} && \
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
