FROM mcr.microsoft.com/dotnet/runtime:7.0 as build
ARG VS_VERSION=1.19.0-rc.6
ARG VS_VERSION_TYPE=unstable

WORKDIR /tmp
ADD https://cdn.vintagestory.at/gamefiles/${VS_VERSION_TYPE}/vs_server_linux-x64_${VS_VERSION}.tar.gz \
    ./vs_server_linux-x64_${VS_VERSION}.tar.gz
ADD https://github.com/anegostudios/VintagestoryServerArm64/raw/main/vs_server_linux-arm64_${VS_VERSION}.tar.gz \
    ./vs_server_linux-arm64_${VS_VERSION}.tar.gz

WORKDIR /opt/vintagestory
RUN tar xzf /tmp/vs_server_linux-x64_${VS_VERSION}.tar.gz
RUN rm -rf VintagestoryServer \
    VintagestoryServer.deps.json \
    VintagestoryServer.dll \
    VintagestoryServer.pdb \
    VintagestoryServer.runtimeconfig.json \
    Lib
RUN tar xzf /tmp/vs_server_linux-arm64_${VS_VERSION}.tar.gz

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
