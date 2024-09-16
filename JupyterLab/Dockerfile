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

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN apt update && \
    apt install r-base -y

# Install IRkernel in R
RUN Rscript -e "install.packages('IRkernel', repos='https://cloud.r-project.org/')"
RUN Rscript -e "install.packages('IRdisplay', repos='https://cloud.r-project.org/')"

# Make the kernel available to Jupyter
RUN Rscript -e "IRkernel::installspec()"



ARG NB_USER="sagemaker-user"
ARG NB_UID=1001
ARG NB_GID=100
# Install sudo and create the user
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -u $NB_UID -g $NB_GID $NB_USER && \
    echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# # Create Jupyter configuration directory
 RUN mkdir -p /home/sagemaker-user/.jupyter/

# # Configure Jupyter to disable token authentication
RUN echo "c.NotebookApp.token = ''" >> /home/sagemaker-user/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.password = ''" >> /home/sagemaker-user/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.disable_check_xsrf = True" >> /home/sagemaker-user/.jupyter/jupyter_notebook_config.py


RUN chown -R sagemaker-user /home/sagemaker-user/
RUN chown -R sagemaker-user /usr/local/lib/R/

# Copy custom logos to the kernel directory
COPY python-logo/logo-32x32.png /usr/local/share/jupyter/kernels/python3/logo-32x32.png
COPY python-logo/logo-64x64.png /usr/local/share/jupyter/kernels/python3/logo-64x64.png
# Rename Python 3 kernel
RUN sed -i 's/"display_name": "Python 3 (ipykernel)"/"display_name": "HNB Python"/' /usr/local/share/jupyter/kernels/python3/kernel.json

COPY rstudio-logo/logo-64x64.png /root/.local/share/jupyter/kernels/ir/logo-64x64.png
# Rename R kernel
RUN sed -i 's/"display_name": "R"/"display_name": "HNB R"/' /root/.local/share/jupyter/kernels/ir/kernel.json

# Remove the SVG logo file
RUN rm -f /usr/local/share/jupyter/kernels/python3/logo-svg.svg


USER $NB_UID
WORKDIR /home/sagemaker-user/

RUN  /usr/local/bin/install-glue-kernels

RUN rm -rf /home/sagemaker-user/.local/share/jupyter/kernels/glue_spark/
RUN sudo cp -r /root/.local/share/jupyter/kernels/ir /home/sagemaker-user/.local/share/jupyter/kernels/
RUN sudo rm -f /home/sagemaker-user/.local/share/jupyter/kernels/ir/logo-svg.svg

COPY pyspark-logo/logo-32x32.png /home/sagemaker-user/.local/share/jupyter/kernels/glue_pyspark/logo-32x32.png
COPY pyspark-logo/logo-64x64.png /home/sagemaker-user/.local/share/jupyter/kernels/glue_pyspark/logo-64x64.png
COPY pyspark-logo/logo-128x128.png /home/sagemaker-user/.local/share/jupyter/kernels/glue_pyspark/logo-128x128.png

# Rename Glue PySpark kernel 
RUN sed -i 's/"display_name": "Glue PySpark"/"display_name": "HNB Glue PySpark"/' /home/sagemaker-user/.local/share/jupyter/kernels/glue_pyspark/kernel.json


# Expose port 8888
EXPOSE 8888

CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
