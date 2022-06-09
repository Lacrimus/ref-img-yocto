FROM debian:10

#Install dependencies for setting up the build environment
RUN apt-get update -y && apt-get install apt-utils -y
RUN apt-get install curl git python3 python3-distutils gpg locales -y

#Install build dependencies
RUN apt-get install chrpath cpio cpp diffstat g++ gawk gcc make wget -y && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

#Symlink python to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python

#Install the git repo utility
RUN curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

#Configure git
RUN git config --global user.name "${GIT_USERNAME}" && \
    git config --global user.email "${GIT_EMAIL}"

#Configure locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN dpkg-reconfigure --frontend noninteractive locales

RUN useradd builder

ENV BUILD_DIR=/home/builder/oe-core

RUN mkdir -p ${BUILD_DIR}

WORKDIR ${BUILD_DIR}

RUN repo init -u https://git.toradex.com/toradex-manifest.git -b dunfell-5.x.y -m tdxref/default.xml && \
    repo sync -c --no-clone-bundle -j$(nproc --all)

#Apply custom configurations
COPY ./conf ./build/conf

RUN chown -R builder ${BUILD_DIR}   

USER builder

#Keep the container runnning even if run non-interactively
CMD ["sleep", "infinity"]
