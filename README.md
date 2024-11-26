# Configuration
Initialize submodules:
```
git submodule update --init --recursive
```

## Environment
Make `.env` file with the following contents:
```
ROS_MASTER_URI=http://localhost:11311
PIONEER_DEVICE=/dev/ttyUSB0
```
- Set `ROS_MASTER_URI` to whatever it should be on the robot

## X11
If you are using the image viewer for the projector, run the following on the host to ensure that the node inside the image can use the X session on the host:
```
xhost +local:root
```

If you are running this over SSH, you may have to set the `DISPLAY` environment variable as well:
```
export DISPLAY=":0"
```

## Docker Compose
Create a file named `docker_compose.yml` in the root of the repository with approximately the following contents:

```yaml
services:
  pioneer:
    build: .
    container_name: amazon_grant_projection
    restart: "unless-stopped"
    network_mode: "host"
    env_file: .env

    # enable NVIDIA runtime
    # you can remove this section if you're not using this
    # installation:
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
    runtime: nvidia
    #deploy:
    #  resources:
    #    reservations:
    #      devices:
    #        - driver: nvidia
    #          count: 1
    #          capabilities: [gpu]

    # X11 config
    # ensure your $DISPLAY environment variable is set with `export DISPLAY=:0`
    # disable access controls with `xhost +local:root`
    environment:
      - "DISPLAY"
      - "QT_X11_NO_MITSHM=1"
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
```

By default the container will launch `src/amazon_grant_projection/launch/projection.launch`. This can be changed on the last line of `Dockerfile`.

# Run
```
docker compose up --build
```
