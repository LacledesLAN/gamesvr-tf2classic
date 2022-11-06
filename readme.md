# Team Fortress 2 Classic Server in Docker

Team Fortress 2 Classic is a re-imagining of the 2008 era of the original [Team Fortress 2](https://github.com/LacledesLAN/gamesvr-tf2), adding in old features that were scrapped and working upon them or adding new content such as weapons and game modes.

![Team Fortress 2 Classic](https://raw.githubusercontent.com/LacledesLAN/gamesvr-tf2classic/master/.misc/banner.png "Team Fortress 2 Classic")

This repository is maintained by [Laclede's LAN](https://lacledeslan.com). Its contents are intended to be bare-bones and used as a stock server. For an example of building a customized server from this Docker image browse the related child-project [gamesvr-tf2classic-freeplay](https://github.com/LacledesLAN/gamesvr-tf2classic-freeplay). If any documentation is unclear or it has any issues please see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Linux

```shell
docker pull lacledeslan/gamesvr-tf2classic;
```

### Run Self Tests

The image includes a test script that can be used to verify its contents. No changes or pull-requests will be accepted to this repository if any tests fail.

```shell
docker run -it --rm lacledeslan/gamesvr-tf2classic ./ll-tests/gamesvr-tf2classic.sh;
```

### Run Simple, Interactive Server

```shell
docker run -it --rm --net=host lacledeslan/gamesvr-tf2classic ./srcds_run -game tf2classic +map vip_harbor +maxplayers 32
```

## Getting Started with Game Servers in Docker

[Docker](https://docs.docker.com/) is an open-source project that bundles applications into lightweight, portable, self-sufficient containers. For a crash course on running Dockerized game servers check out [Using Docker for Game Servers](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/DockerAndGameServers.md). For tips, tricks, and recommended tools for working with Laclede's LAN Dockerized game server repos see the guide for [Working with our Game Server Repos](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/WorkingWithOurRepos.md). You can also browse all of our other Dockerized game servers: [Laclede's LAN Game Servers Directory](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers)
