<a name="readme-top"></a>

# chatterbox

Build and run local LLMs on Intel iGPU with Ollama

## Prerequisite

  * Install docker

    ```sh
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io

    # Add $USER to docker group
    sudo usermod -aG docker $USER
    newgrp $USER

    # Verify docker is installed successfully
    docker run hello-world
    ```

  * Install make

    ```sh
    sudo apt install make
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Quick start

  ```sh
  git clone https://github.com/huichuno/chatterbox.git

  # list make options
  make help

  # run chatterbox and open-webui containers 
  make runall

  # make sure both containers are running
  docker ps

  # launch web browser and navigate to <host ip>:8080
  # signup and login

  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


