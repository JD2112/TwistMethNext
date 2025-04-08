FROM continuumio/miniconda3:4.10.3
LABEL authors="Jyotirmoy Das" \
      description="Docker image containing all requirements for TwistMethNext pipeline"
# Set working directory
WORKDIR /app

# Set environment variables for locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Copy the environment file
COPY environment.yml .

# Create conda environment
RUN conda env create -f environment.yml && conda clean -a

# Add conda environment to PATH
ENV PATH /opt/conda/envs/twistnext/bin:$PATH

# Install additional system dependencies
RUN apt-get update && apt-get install -y \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GOplot using R
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('GOplot')"

# Set the default command to activate the conda environment
CMD ["/bin/bash", "-c", "source activate twistnext && /bin/bash"]