---
layout: page
title: FAQ
group: FAQ
---

## Setup Vagrant and Create VM Instance

**Note that all example commands are executed on the host machine (your laptop), e.g., in `Terminal.app` (or `iTerm2.app`) on macOS, `cmd` in Windows, and `console` or `xterm` on Linux.  After the last step (`vagrant ssh`) you will get inside the virtual machine and can compile your code there.**

- Download and install your favourite virtualization engine, e.g., [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

  You may need to enable VT-x/AMD-V in BIOS if VirtualBox is not working properly. See more [here](https://www.youtube.com/watch?v=XgF7RiXs43k)

- Download and install [Vagrant tools](https://www.vagrantup.com/downloads.html) for your platform

- Find base virtual machine you want to use

  * Go to [Vagrant Cloud](https://app.vagrantup.com/boxes/search)

- Create local folder to store meta information.  Note that actual virtual machine will be handled by VirtualBox (or another virtualization engine) and the base images will be stored under `$HOME/.vagrant` folder

        mkdir my-vm
        cd my-vm

  * Initialize and start the VM.  For `boxcutter/ubuntu1604` you can use the following example.  Note before you run `up` command, you can adjust parameters in the generated `Vagrantfile`

        vagrant init boxcutter/ubuntu1604
        vagrant up

    I would not recommend starting VM instance manually from VirtualBox GUI, otherwise you may have various problems (connection error, connection timeout, missing packages, etc.).  However, if you are experiencing "timeout" problems, try in GUI that can give you better error diagnostics.
    {: class="alert alert-warning"}

  * To establish an SSH session to the created VM, run

        vagrant ssh

  If you are using Putty on Windows platform, `vagrant ssh` will return information regarding the IP address and the port to connect to your virtual machine.

### Notes

* If you want to open another SSH session, just open another terminal and run `vagrant ssh` (or create a new Putty session).

* If you are using Windows, read [this article](http://www.sitepoint.com/getting-started-vagrant-windows/) to help yourself set up the environment.

## Setup Docker

Docker is a software to manage "containers" (feature of Linux kernel), which one can view as a light-weight virtualization.  On MacOS and Windows, Docker uses virtualization to create a small Linux VM and then uses it to create containers.  But everything is happening transparently to you and you may not see much difference with just using Linux.

- Download and install Docker for your platform: [https://www.docker.com/](https://www.docker.com/) -> Get Docker

- Find base container you want to use, e.g., on [Docker Hub](https://hub.docker.com)

At this point, you have several options what you can do.

### The simplest approach would be to just download the container image

    docker pull ubuntu:xenial

And then start `bash` in that container.  Note that Docker containers behave a bit differently than VirtualBox VM. They are designed to run a specific application inside the containerized environment and don't start (unless you explicitly request) anything else.  The example:

    docker run -ti ubuntu:xenial bash

### A more advanced approach is to create a derivative image

Create some folder

    mkdir my-docker
    cd my-docker

Create `Dockerfile`

    FROM ubuntu:xenial
    RUN apt -y update && apt -y install command-not-found dnsutils

Build your container

    docker build -t my .

Run bash in your container

    docker run -ti my bash

Several notes:

1. Each `docker run` will create a new container with a new clean environment

2. After you exited bash that started with `docker run` examples above, the container will not be destroyed and can be restarted with the old "dirty" environment using

        docker start -i <hash-of-the-container>

   To get container ID, you can run `docker ps -a`

3. If you want to automatically destroy the container after it exits, add `--rm` option to `docker run`

        docker run -ti --rm my bash

4. You can run another command in the existing running container using `docker exec`

        docker exec -ti <hash-of-the-container> <command-to-run>
