# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/runtime:7.0 as build
ARG VS_VERSION
ARG VS_VERSION_TYPE

SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y jq wget

WORKDIR /tmp
RUN <<EOF
if [[ -n $VS_VERSION && -n $VS_VERSION_TYPE ]]; then
    server_tarball_url=https://cdn.vintagestory.at/gamefiles/${VS_VERSION_TYPE}/vs_server_linux-x64_${VS_VERSION}.tar.gz
else
    wget https://api.vintagestory.at/stable.json
    server_tarball_url=$(jq -r ".[] | select(.linuxserver.latest == 1) | .linuxserver.urls.cdn" stable.json)
fi
wget -O vs_server_linux-x64.tar.gz $server_tarball_url
EOF

WORKDIR /opt/vintagestory
RUN tar xzf /tmp/vs_server_linux-x64.tar.gz
RUN rm -rf VintagestoryServer \
    VintagestoryServer.deps.json \
    VintagestoryServer.dll \
    VintagestoryServer.pdb \
    VintagestoryServer.runtimeconfig.json \
    Lib
ADD ./server .

FROM mcr.microsoft.com/dotnet/runtime:7.0
# create non-root user 'app' as defined in runtime:8.0
ENV APP_UID=1654
RUN groupadd \
        --gid=$APP_UID \
        app \
    && useradd -l \
        --uid=$APP_UID \
        --gid=$APP_UID \
        --create-home \
        app

COPY --from=build /opt/vintagestory /opt/vintagestory
ENV VSDATADIR=/home/app/.config/VintagestoryData
WORKDIR $VSDATADIR
WORKDIR /opt/vintagestory

ENTRYPOINT ["/bin/bash", "-c", " \
    chown -R app:app $VSDATADIR && \
    su - app -c 'dotnet /opt/vintagestory/VintagestoryServer.dll' \
"]
