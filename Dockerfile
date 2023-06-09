FROM nvidia/cuda:12.1.0-base-ubuntu20.04
ENV TZ="Europe/Tallinn"
ENV DEBIAN_FRONTEND=noninteractive

# Install base utilities
RUN apt update && \
    apt install -y build-essential  && \
    apt install -y wget && \
    apt install -y git

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# Script utils
RUN apt install -y zip && \
    apt install -y curl && \
    apt install -y ffmpeg libsm6 libxext6

WORKDIR /easy-diffusion-app

ENV ED_VERSION="2.5.24"
ENV SD_UI_BIND_PORT=9000
ENV SD_UI_BIND_IP=0.0.0.0

# Load and patch installation scripts
COPY "patches-${ED_VERSION}" ./patches-${ED_VERSION}
COPY load_and_patch.sh .
RUN bash ./load_and_patch.sh

WORKDIR /easy-diffusion-app/easy-diffusion
COPY config.sh ./scripts
RUN bash ./start.sh

# Patch on_sd_start to prevent uvicorn run
RUN patch ./scripts/on_sd_start.sh < ./../patches-${ED_VERSION}/on_sd_start.patch

# Patch js paths for proxy
# If the container will be executed on a local machine, do not apply this patch
RUN cd ./sd-ui-files && git apply ./../../patches-${ED_VERSION}/js_paths_and_fonts.patch && cp -rf ./ui ../

# Continue installation
RUN bash ./scripts/on_sd_start.sh

# Init app
ENV SD_UI_PATH="/easy-diffusion-app/easy-diffusion/ui"
ENV SD_PATH="/easy-diffusion-app/easy-diffusion/stable-diffusion"
COPY preload_models.py ./ui/preload_models.py
RUN patch ./ui/main.py < ./../patches-${ED_VERSION}/main.patch

# New entripoint
COPY start_uvicorn.sh ./scripts
WORKDIR /easy-diffusion-app/easy-diffusion/scripts
RUN python ./../ui/preload_models.py
RUN chmod +x ./start_uvicorn.sh

# Clear cache
RUN pip cache purge && apt clean && rm -rf /var/cache/apt/lists

EXPOSE ${SD_UI_BIND_PORT}
# ENTRYPOINT [ "./start_uvicorn.sh" ]