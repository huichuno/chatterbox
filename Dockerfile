# Reference:
# - https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Overview/install_gpu.html
# - https://github.com/intel-analytics/ipex-llm/blob/main/docker/llm/inference-cpp/Dockerfile
FROM intel/oneapi-basekit:2024.0.1-devel-ubuntu22.04

ARG TZ=Asia/Kuala_Lumpur
ENV PYTHONUNBUFFERED=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -nv -O - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
  gpg --dearmor | tee /usr/share/keyrings/intel-oneapi-archive-keyring.gpg > \
  /dev/null && \
  chmod 644 /usr/share/keyrings/intel-oneapi-archive-keyring.gpg && \
  rm /etc/apt/sources.list.d/intel-graphics.list && \
  wget -nv -O - https://repositories.intel.com/graphics/intel-graphics.key | \
  gpg --dearmor | tee /usr/share/keyrings/intel-graphics.gpg > /dev/null && \
  echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy arc" >> \
  /etc/apt/sources.list.d/intel.gpu.jammy.list && \
  chmod 644 /usr/share/keyrings/intel-graphics.gpg && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo "$TZ" > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install --no-install-recommends -y gawk \
  linux-headers-$(uname -r) libc6-dev udev \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
  libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev \
  libgl1-mesa-dri libglapi-mesa libgles2-mesa-dev libglx-mesa0 \
  libigdgmm12 libxatracker2 mesa-va-drivers \
  mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo hwinfo \
  curl nano jq libcairo2-dev \
  intel-oneapi-common-vars=2024.0.0-49406 \
  intel-oneapi-common-oneapi-vars=2024.0.0-49406 \
  intel-oneapi-diagnostics-utility=2024.0.0-49093 \
  intel-oneapi-compiler-dpcpp-cpp=2024.0.2-49895 \
  intel-oneapi-dpcpp-ct=2024.0.0-49381 \
  intel-oneapi-mkl=2024.0.0-49656 \
  intel-oneapi-mkl-devel=2024.0.0-49656 \
  intel-oneapi-mpi=2021.11.0-49493 \
  intel-oneapi-mpi-devel=2021.11.0-49493 \
  intel-oneapi-dal=2024.0.1-25 \
  intel-oneapi-dal-devel=2024.0.1-25 \
  intel-oneapi-ippcp=2021.9.1-5 \
  intel-oneapi-ippcp-devel=2021.9.1-5 \
  intel-oneapi-ipp=2021.10.1-13 \
  intel-oneapi-ipp-devel=2021.10.1-13 \
  intel-oneapi-tlt=2024.0.0-352 \
  intel-oneapi-ccl=2021.11.2-5 \
  intel-oneapi-ccl-devel=2021.11.2-5 \
  intel-oneapi-dnnl-devel=2024.0.0-49521 \
  intel-oneapi-dnnl=2024.0.0-49521 \
  intel-oneapi-tcm-1.0=1.0.0-435 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN DEBIAN_FRONTEND=noninteractive \
  add-apt-repository ppa:deadsnakes/ppa -y && \
  apt-get install --no-install-recommends -y \
  python3.11 python3.11-dev python3.11-distutils python3-wheel && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm /usr/bin/python3 && \
  ln -s /usr/bin/python3.11 /usr/bin/python3 && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  wget -nv https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  rm get-pip.py
  # pip install --no-cache-dir --upgrade requests argparse urllib3 
  # pip install --no-cache-dir --pre --upgrade ipex-llm[cpp]

WORKDIR /app
COPY requirements.txt .
COPY run-llm.sh .

RUN pip install -r requirements.txt && \
  chmod +x run-llm.sh && \
  init-ollama

ENV PATH=/app:$PATH
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_MODELS=/ollama-models
ENV OLLAMA_NUM_GPU=999
ENV no_proxy=localhost,127.0.0.1
ENV ZES_ENABLE_SYSMAN=1
ENV SYCL_CACHE_PERSISTENT=1
ENV DEFAULT_MODEL=llama3

CMD ["bash", "-c", "run-llm.sh $DEFAULT_MODEL"]
