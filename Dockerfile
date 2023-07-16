FROM emscripten/emsdk
LABEL description="Dockerfile for setting up playground SCASP for SMU CCLAW"

# Adapted by YM from https://github.com/ciao-lang/ciao/blob/be473752cac1d22a83cd3fe6299f8433a066a975/.github/workflows/build.yml#L4

RUN  apt update && apt install -y \
    tar                           \   
    emacs-nox                     \
    less                          \
    vim                           \
    && rm -rf /var/lib/apt/lists/*
    # texmf-dist         \
    # texlive            \
    # ghostscript   

WORKDIR /

# Install Ciao
RUN git clone https://github.com/ciao-lang/ciao

COPY . /playground/

WORKDIR /ciao
# ./ciao-boot.sh --help is a hack to get around 'bootstrap is missing error'
RUN chmod +x ./ciao-boot.sh && \
    ./ciao-boot.sh --help && \ 
    ./ciao-boot.sh fetch ciaowasm exfilter website && \
    ./ciao-boot.sh configure --instype=local && \
    ./ciao-boot.sh build && \
    ./ciao-boot.sh install

WORKDIR /playground
# update PATH etc and install scasp and playground
RUN eval "$(/ciao/build/bin/ciao-env --sh)" && \
    ciao get gitlab.software.imdea.org/ciao-lang/sCASP && \
    chmod +x build.sh  && ./build.sh


CMD eval "$(/ciao/build/bin/ciao-env --sh)" && ./etc/ciao-serve-mt -p ${PLAYGROUNDPORT}

# Resources
## Git repos and build context: https://ryanfb.xyz/etc/2015/07/29/git_strategies_for_docker.html

## Re emscripten:
# --- https://github.com/emscripten-core/emsdk/blob/main/docker/Dockerfile
# --- Could also look into adapting the probably slimmer alphine Dockerfile tt someone had made 5 years ago: 
# --- https://github.com/chibidev/emscripten-docker/blob/master/Dockerfile.alpine