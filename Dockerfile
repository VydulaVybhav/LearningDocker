FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and Python 3.11.6
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    libncurses5-dev \
    libgdbm-dev \
    liblzma-dev \
    zlib1g-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11.6
RUN curl -O https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz && \
    tar -xvf Python-3.11.6.tgz && \
    cd Python-3.11.6 && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.11.6 Python-3.11.6.tgz

# Install pip for the installed Python version
RUN /usr/local/bin/python3.11 -m ensurepip && \
    /usr/local/bin/python3.11 -m pip install --upgrade pip

# Install Miniconda
RUN curl -o Miniconda3.sh -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3.sh -b -p /opt/conda && \
    rm Miniconda3.sh

# Update PATH environment variable
ENV PATH=/opt/conda/bin:$PATH

# Initialize Conda
RUN conda init bash

# Create Conda environment and install SageMaker Code Editor
RUN conda config --add channels conda-forge && \
    conda install sagemaker-code-editor -y

# Set Python 3.11.6 as the default `python` command
RUN update-alternatives --install /opt/conda/bin/python python /usr/local/bin/python3.11 1

COPY requirements.txt .
RUN pip install -r requirements.txt

ARG NB_USER="sagemaker-user"
ARG NB_UID=1001
ARG NB_GID=100
# Install sudo and create the user
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -u $NB_UID -g $NB_GID $NB_USER && \
    echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# Create the parent directory if it does not exist
RUN mkdir -p /home/sagemaker-user/.vscode-server-oss/extensions

# Copy the extensions directory
COPY extensions/ /home/sagemaker-user/.vscode-server-oss/extensions/

RUN chown -R sagemaker-user /home/sagemaker-user/

USER $NB_UID
WORKDIR /home/sagemaker-user/

RUN  /usr/local/bin/install-glue-kernels

# Expose port 8888
EXPOSE 8888

# Command to run SageMaker Code Editor
CMD ["sagemaker-code-editor", "--host", "0.0.0.0", "--port", "8888", "--without-connection-token"]
