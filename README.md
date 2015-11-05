# Jenkins Docker

This is a jenkins container that is meant to be able to run Docker commands.
The challenge comes when you are using a Docker container to run commands that
build and start other Docker containers so there are a few things we need to
do to ensure the container can operate effectively.

## How to use it

This image will typically be run from a Docker Compose file within the project
structure.  We usually call this file `jenkins.yml`. The file looks similar to
this:

```
# Container for running Jenkins with a local jobs volume
# Run this image via
#   - `docker-compose -f jenkins.yml run jenkins`
jenkins:
  image: phase2/jenkins-docker
  volumes:
    # Mount the local project jobs into Jenkins
    - ./env/jobs:/var/jenkins_home/jobs
    # Install the commands to make docker work inside the container
    - /usr/bin/docker:/usr/bin/docker
    - /usr/bin/docker-compose:/usr/bin/docker-compose
    # Mount the docker socket so we can execute from within this container
    - /var/run/docker.sock:/var/run/docker.sock
  environment:
    - DEVTOOLS_PRIVATE_KEY:
    - DNSDOCK_NAME: jenkins
    - DNSDOCK_IMAGE: example
    - VIRTUAL_HOST: build-project.ci.p2devcloud.com
```

### Volume Mounts

The Jenkins container is customized mostly through volume mounts. Each project
repo should have their Jenkins CI jobs somewhere in the codebase.  Typically
those get stored in `env/jobs` and are mounted into the container into the
Jenkins Jobs directory with the following Volume specification

`- ./env/jobs:/var/jenkins_home/jobs`

We also need to mount in the Docker and Docker Compose binaries as well as the
Docker Socket.  Mounting the Docker Socket allows the container to spawn other 
peer containers outside of this container. The following configuration mounts 
those two binaries and the socket.

```
- /usr/bin/docker:/usr/bin/docker
- /usr/bin/docker-compose:/usr/bin/docker-compose
- /var/run/docker.sock:/var/run/docker.sock
```

### Environment Variables

There are a few variables that control the container.  The first of which 
controls what SSH key jenkins uses to clone private repositories.  The env
variable needs to be set in the environment that is running the Docker Compose
command to start the container.  The variable `DEVTOOLS_PRIVATE_KEY` should 
contain the contents of the private key file. It can be set with a command 
similar to this: `export DEVTOOLS_PRIVATE_KEY="$(~/.ssh/id_rsa)"`. Then in the
Compose file you will tell it to use the env var from your current environment
by specifying it without a value as such:

```
environment:
  - DEVTOOLS_PRIVATE_KEY
```

Other environment variables are used to control the container name resolution
and what virtual host the container uses.  The variables `DNSDOCK_IMAGE`,
`DNSDOCK_NAME`, and `VIRTUAL_HOST` are documented in the main Dev Tools 
docs and should be referenced there.

### Customizing Plugins

If you want to add custom plugins to your Jenkins container you will need to 
"roll your own" image.  It is pretty as easy and the following example `Dockerfile`
should help get you up and running.  You likely want to start with the `plugins.txt`
file that is included in this repo and add your own customizations to the end.

```
FROM phase2/jenkins-docker

COPY env/plugins.txt  /usr/share/jenkins/plugins.txt

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
```

The above can be a `Dockerfile` in your repo and you then update your 
`jenkins.yml` file and remove the `image:` specification and replace it 
with the following.

`build: env/jenkins`

If `env/jenkins` is the directory where your custom `Dockerfile` is located.


