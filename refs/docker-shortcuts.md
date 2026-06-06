# Docker Shortcuts (Colima)

## Colima (VM lifecycle)

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| Start Colima                  | `colima start`                               |
| Start with more resources     | `colima start --cpu 4 --memory 8`            |
| Stop Colima                   | `colima stop`                                |
| Check status                  | `colima status`                              |
| SSH into Colima VM            | `colima ssh`                                 |
| Delete Colima VM              | `colima delete`                              |

---

## Docker Compose

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| Start all services            | `docker-compose up`                          |
| Start in background           | `docker-compose up -d`                       |
| Start & rebuild images        | `docker-compose up --build -d`               |
| Stop all services             | `docker-compose down`                        |
| Stop & remove volumes         | `docker-compose down -v`                     |
| Restart a service             | `docker-compose restart <service>`           |
| Rebuild one service           | `docker-compose build <service>`             |
| View logs (all)               | `docker-compose logs -f`                     |
| View logs (one service)       | `docker-compose logs -f <service>`           |
| List running services         | `docker-compose ps`                          |
| Run one-off command           | `docker-compose run --rm <service> <cmd>`    |
| Exec into running service     | `docker-compose exec <service> bash`         |

---

## Containers

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| List running containers       | `docker ps`                                  |
| List all containers           | `docker ps -a`                               |
| Shell into running container  | `docker exec -it <name/id> bash`             |
| Shell (if no bash)            | `docker exec -it <name/id> sh`               |
| Run command in container      | `docker exec -it <name/id> <cmd>`            |
| View logs                     | `docker logs -f <name/id>`                   |
| View last N lines             | `docker logs --tail 100 <name/id>`           |
| Start stopped container       | `docker start <name/id>`                     |
| Stop container                | `docker stop <name/id>`                      |
| Restart container             | `docker restart <name/id>`                   |
| Remove container              | `docker rm <name/id>`                        |
| Force remove running          | `docker rm -f <name/id>`                     |
| Inspect container             | `docker inspect <name/id>`                   |
| Copy file from container      | `docker cp <name/id>:/path/to/file ./`       |
| Copy file into container      | `docker cp ./file <name/id>:/path/to/`       |

---

## Images

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| List images                   | `docker images`                              |
| Pull image                    | `docker pull <image>:<tag>`                  |
| Build from Dockerfile         | `docker build -t <name>:<tag> .`             |
| Remove image                  | `docker rmi <image/id>`                      |
| Tag image                     | `docker tag <source> <target>`               |
| Inspect image layers          | `docker history <image>`                     |

---

## Volumes

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| List volumes                  | `docker volume ls`                           |
| Inspect volume                | `docker volume inspect <name>`               |
| Create volume                 | `docker volume create <name>`                |
| Remove volume                 | `docker volume rm <name>`                    |

---

## Networks

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| List networks                 | `docker network ls`                          |
| Inspect network               | `docker network inspect <name>`              |
| Create network                | `docker network create <name>`               |
| Connect container to network  | `docker network connect <network> <container>` |

---

## Cleanup

| Action                        | Command                                      |
|-------------------------------|----------------------------------------------|
| Remove stopped containers     | `docker container prune`                     |
| Remove unused images          | `docker image prune`                         |
| Remove unused volumes         | `docker volume prune`                        |
| Remove everything unused      | `docker system prune`                        |
| Remove all incl. volumes      | `docker system prune -a --volumes`           |
| Disk usage summary            | `docker system df`                           |
| Live resource stats           | `docker stats`                               |
