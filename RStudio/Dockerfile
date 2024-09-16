# Use the rocker/rstudio base image
FROM rocker/rstudio:latest

# Install necessary packages if needed
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

ARG NB_USER="sagemaker-user"
ARG NB_UID=1001
ARG NB_GID=100
# Install sudo and create the user
RUN apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -u $NB_UID -g $NB_GID $NB_USER && \
    echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN chown -R sagemaker-user /home/sagemaker-user/

# Expose port 8787 for RStudio Server
EXPOSE 8787

# Set environment variable for password
ENV PASSWORD=yourpassword

# Create the _apt group with a temporary GID (e.g., 999)

# Change the GID of _apt to 101
RUN groupmod -g 101 users

# Change the GID of rstudio to 100
RUN groupmod -g 100 rstudio

# Verify the changes
RUN cut -d: -f1,3 /etc/passwd
# USER ${NB_USER}
# Start RStudio Server
CMD ["/init"]
