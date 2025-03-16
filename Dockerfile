FROM ghcr.io/linuxserver/webtop:fedora-kde

# Set Environment Variables
ENV USER=webtop
ENV DEBIAN_FRONTEND=noninteractive

# Update Fedora and Install Dependencies
RUN dnf update -y && \
    dnf install -y \
    wget \
    libreoffice \
    python3-pip \
    fish \
    eza \
    git \
    qt5-qtbase \
    qt5-qtdeclarative \
    qt5-qtsvg \
    unzip \
    tmux 

# Install VS Code
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' && \
    dnf check-update && \
    dnf install -y code && \
    dnf clean all

# Install Nerd Fonts (FiraCode)
RUN LATEST_FONT_URL=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | \
    jq -r '.assets[] | select(.name | startswith("FiraCode") and endswith(".zip")) | .browser_download_url') && \
    wget -O FiraCode.zip "$LATEST_FONT_URL" && \
    mkdir -p /usr/share/fonts/FiraCode && \
    unzip FiraCode.zip -d /usr/share/fonts/FiraCode && \
    fc-cache -vf && \
    rm FiraCode.zip

# Install Wave Terminal
RUN LATEST_URL=$(curl -s https://api.github.com/repos/wavetermdev/waveterm/releases/latest | \
    jq -r '.assets[] | select(.name | startswith("waveterm-linux-x86_64-") and endswith(".rpm")) | .browser_download_url') && \
    wget -O waveterm.rpm "$LATEST_URL" && \
    dnf install -y ./waveterm.rpm && \
    rm waveterm.rpm

# Install positron
RUN LATEST_URL=$(curl -sL "https://api.github.com/repos/posit-dev/positron/releases" | \
    jq -r '.[0].assets[] | select(.name | test(".*x64\\.rpm$")) | .browser_download_url' | head -n 1) && \
    wget -O positron.rpm "$LATEST_URL" && \
    dnf install -y ./positron.rpm && \
    rm positron.rpm

# Jupyter
RUN dnf install python3-notebook mathjax sscg -y
RUN jupyter notebook --generate-config

# Enable COPR repository for RStudio (Now Positron IDE)
RUN dnf copr enable iucar/rstudio -y && \
    touch /usr/share/doc/R && \
    dnf install -y rstudio-desktop

# Install Zellij from COPR
RUN dnf copr enable varlad/zellij -y && \
    dnf install -y zellij

RUN wget https://release.gitkraken.com/linux/gitkraken-amd64.rpm
RUN dnf install -y ./gitkraken-amd64.rpm

###########################
# R packages Dependencies
###########################
RUN dnf update -y && \
    dnf install -y \
    R \
    R-devel \
    libcurl-devel \
    openssl-devel \
    libxml2-devel \
    fribidi-devel \
    freetype-devel \
    libpng-devel \
    libtiff-devel \
    libjpeg-devel \
    make \
    gcc \
    gcc-c++
# Install R `devtools` tidyverse and data.table Package
#RUN R -e 'install.packages("devtools", repos="http://cran.rstudio.com/")'
#RUN R -e 'install.packages("tidyverse", repos="http://cran.rstudio.com/")'
#RUN R -e 'install.packages("data.table", repos="http://cran.rstudio.com/")'
# Add R to jupyter (ju - Julia / py - Python / r - R)
#RUN R -e 'devtools::install_github("IRkernel/IRkernel")'
#RUN R -e 'IRkernel::installspec()'

# Configure tmux to enable mouse support
RUN echo 'set -g mouse on' >> /.tmux.conf

# Refresh KDE application menu
RUN kbuildsycoca5
RUN wget -O warp.rpm https://releases.warp.dev/stable/v0.2025.02.12.16.51.stable_03/warp-terminal-v0.2025.02.12.16.51.stable_03-1.x86_64.rpm 
RUN dnf install -y warp.rpm

# Expose port for NoVNC
EXPOSE 3000

