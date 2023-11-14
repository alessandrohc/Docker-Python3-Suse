FROM registry.suse.com/bci/bci-base:15.5

USER root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

ARG PYTHON_VERSION_TAG=3.10.13
ARG LINK_PYTHON_TO_PYTHON3=0

# Update and install packages
RUN zypper --non-interactive update && \
    zypper --non-interactive install \
        gcc \
        gdb \
        pkg-config \
        libbz2-devel \
        libffi-devel \
        gdbm-devel \
        ncurses-devel \
        readline-devel \
        sqlite3-devel \
        libopenssl-devel \
        xz \
        xz-devel \
        libuuid-devel \
        zlib-devel \
        unzip \
        cairo-devel \
        wget \
        curl \
        git \
        sudo \
        bash-completion \
        tree \
        vim \
        libmysqlclient-devel \
        mysql-client \
        file \
        patterns-devel-base-devel_basis \
        awk \
        openssh \
        && zypper clean --all


COPY install_python.sh install_python.sh
RUN bash install_python.sh ${PYTHON_VERSION_TAG} ${LINK_PYTHON_TO_PYTHON3} && \
    rm -r install_python.sh Python-${PYTHON_VERSION_TAG}

# Habilitando a conclusão de tabulação (tab completion) no bash
RUN sed -i '/enable bash completion in interactive shells/,+7 s/^#//' /etc/bash.bashrc

# Criando usuário "docker" com poderes sudo
RUN useradd -m docker && \
    usermod -aG users docker && \
    echo '%users ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /home/docker/data && \
    chown -R --from=root docker /home/docker

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8


WORKDIR /home/docker/data
ENV HOME /home/docker
ENV USER docker
USER docker
ENV PATH /home/docker/.local/bin:$PATH
ENV LD_LIBRARY_PATH /usr/lib:$LD_LIBRARY_PATH

# Avoid first use of sudo warning. c.f. https://askubuntu.com/a/22614/781671
RUN touch $HOME/.sudo_as_admin_successful

CMD [ "/bin/bash" ]
