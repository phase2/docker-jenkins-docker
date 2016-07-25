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
    # Volume mount the private key
    - ~/.ssh/id_rsa:/root/.ssh/devtools.key
```

### Private Key Import

When CI jobs have to deal with private repositories, Jenkins will need an
SSH key to connect to GitHub and BitBucket. Since our images are meant to be
public, we cannot build a private key into the image and we must import a key
into the running container.

### Other Volume Mounts

The Jenkins container is customized mostly through volume mounts. Each project
repo should have their Jenkins CI jobs somewhere in the codebase.  Typically
those get stored in `env/jobs` and are mounted into the container into the
Jenkins Jobs directory with the following Volume specification

`- ./env/jobs:/var/jenkins_home/jobs`

We also need to mount in the Docker Socket.  Mounting the Docker Socket allows 
the container to spawn other peer containers outside of this container. 
The following configuration mounts the socket.

`- /var/run/docker.sock:/var/run/docker.sock`

### Environment Variables

Other environment variables are used to control the container name resolution
and what virtual host the container uses.  The variables `DNSDOCK_IMAGE`,
`DNSDOCK_NAME`, and `VIRTUAL_HOST` are documented in the main Dev Tools
docs and should be referenced there.

### Customizing Plugins

If you want to add custom plugins to your Jenkins container you will need to
"roll your own" image.  It is pretty as easy and the following example `Dockerfile`
should help get you up and running.

```
FROM phase2/jenkins-docker

RUN install-versioned-plugins.sh \
        fun-plugin-one \
        funner-plugin-two:1.22 \
        the-funnest-plugin-of-all
```

The above can be a `Dockerfile` in your repo and you then update your
`jenkins.yml` file and remove the `image:` specification and replace it
with the following.

`build: env/jenkins`

If `env/jenkins` is the directory where your custom `Dockerfile` is located.
