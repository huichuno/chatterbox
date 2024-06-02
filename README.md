<a name="readme-top"></a>

# chatterbox

Build and run local LLMs on Intel iGPU with Ollama & Open WebUI

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


## Quick Start

  ```sh
  git clone https://github.com/huichuno/chatterbox.git && cd chatterbox

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


## Configuration

* The default model is set by DEFAULT_MODEL env variable. Current default model is set to llama3 8B model.

* Downloaded LLM models are stored in $HOME/ollama-models folder on the host system

* Open-webui backend data is stored in $HOME/open-webui folder on the host system

* Refer to the *Makefile* on all the default value of environment variables

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Test Environment

  * | Hardware                       | Operating System | Kernel |
    | ---                            | ---              | ---    |
    | Intel(R) Core(TM) Ultra 7 155H | Ubuntu 22.04     | 6.5.0  |

<p align="right">(<a href="#readme-top">back to top</a>)</p>
