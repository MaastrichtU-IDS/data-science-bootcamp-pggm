FROM ubuntu:latest as build

ENV CONDA_DIR=/condinst

RUN apt-get update \
&& apt-get -y dist-upgrade \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y git wget keychain libsm6 libxext6 libxrender1 dvipng python-pip libblas3 liblapack3 libstdc++6 python-setuptools\
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
&& /bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR \
&& rm Miniconda3-latest-Linux-x86_64.sh \
&& $CONDA_DIR/bin/conda install -y \
matplotlib \
notebook \
jupyterlab \
numpy \
pandas \
scikit-image \
scikit-learn \
scipy \
seaborn \
plotly \
ipywidgets \
&& $CONDA_DIR/bin/conda update -y python \
&& $CONDA_DIR/bin/conda clean -a -y \
&& $CONDA_DIR/bin/pip install --no-cache-dir --process-dependency-links -U turicreate h5py sklearn-pandas isoweek pandas_summary
 
#	&& $CONDA_DIR/bin/conda update --all -y \	

ENV MATPLOTLIBRC=${HOME}/.config/matplotlib/matplotlibrc
RUN mkdir -p ${HOME}/.config/matplotlib && \
    echo "backend      : Agg" > ${HOME}/.config/matplotlib/matplotlibrc

FROM scratch
COPY --from=build / /
COPY . /work

WORKDIR /work

EXPOSE 8888

ENTRYPOINT ["/condinst/bin/jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''"]
