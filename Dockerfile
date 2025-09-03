# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS build
ARG VS_VERSION
ARG VS_VERSION_TYPE
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates jq wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN if [[ -n $VS_VERSION && -n $VS_VERSION_TYPE ]]; then \
        server_tarball_url="https://cdn.vintagestory.at/gamefiles/${VS_VERSION_TYPE}/vs_server_linux-x64_${VS_VERSION}.tar.gz"; \
    else \
        wget https://api.vintagestory.at/stable.json && \
        server_tarball_url=$(jq -r ".[] | select(.linuxserver.latest == 1) | .linuxserver.urls.cdn" stable.json); \
    fi && \
    wget -O vs_server_linux-x64.tar.gz "$server_tarball_url"

WORKDIR /opt/vintagestory/
RUN tar xzf /tmp/vs_server_linux-x64.tar.gz && \
    rm -rf VintagestoryServer* Lib

COPY ./server .

# final runtime image
FROM mcr.microsoft.com/dotnet/runtime:8.0

WORKDIR /app
COPY --from=build /opt/vintagestory .

RUN useradd -m -u 1000 -U vintagestory
ENV HOME=/home/vintagestory
ENV VSDATADIR=$HOME/.config/VintagestoryData
RUN mkdir -p $VSDATADIR && chown -R vintagestory:vintagestory /app $VSDATADIR

USER vintagestory
ENTRYPOINT ["dotnet", "/app/VintagestoryServer.dll"]
