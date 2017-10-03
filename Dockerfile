FROM ubuntu

#Arguments for User ID & Group
ARG USER
ARG USER_ID
ARG GROUP_ID

# add user with specified (or default) user/group ids
ENV USER ${USER:-guest}
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

#Add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} ${USER} && \
   useradd -u ${USER_ID} -g ${USER} -s /bin/bash -m -d /${USER} ${USER}

#Config Locale
RUN apt-get update && apt-get install -y locales && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install ruby dependencies
RUN apt-get install -y wget curl \
    build-essential git git-core \
    zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
    libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
    openssh-server openssh-client && \

# Cleanup
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# Install Ruby 2.4.1
ENV RUBY_PATH 2.4
ENV RUBY_VERSION 2.4.1
RUN cd /tmp &&\
  wget -O ruby-$RUBY_VERSION.tar.gz https://cache.ruby-lang.org/pub/ruby/$RUBY_PATH/ruby-$RUBY_VERSION.tar.gz &&\
  tar -xzvf ruby-$RUBY_VERSION.tar.gz &&\
  cd ruby-$RUBY_VERSION/ &&\
  ./configure &&\
  make &&\
  make install &&\
  cd /tmp &&\
  rm -rf ruby-$RUBY_VERSION &&\
  rm -rf ruby-$RUBY_VERSION.tar.gz

# Add Ruby binaries to $PATH
ENV PATH /opt/rubies/ruby-$RUBY_VERSION/bin:$PATH

# Add options to gemrc
RUN echo "gem: --no-document" > ~/.gemrc

# Install bundler
RUN gem install bundler

#Install Fastlane
RUN gem install fastlane -NV

#Install Java & Set environment
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:webupd8team/java && \
    apt-get update -y && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-unlimited-jce-policy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Android SDK
ENV ANDROID_SDK_VERSION r24.4.1
ENV ANDROID_BUILD_TOOLS_VERSION 25.3.3

# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

#Fake Android SDK Path
ENV LIBRARY_HOME_BETA [YOUR HOME ANDROID PATH]
RUN mkdir -p ${LIBRARY_HOME_BETA}

# Installs Android SDK
ENV ANDROID_SDK_FILENAME android-sdk_${ANDROID_SDK_VERSION}-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-25
ENV ANDROID_HOME ${LIBRARY_HOME_BETA}android-sdk-linux
ENV ANDROID_SDK ${LIBRARY_HOME_BETA}android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

ENV SDK_PATH_NAME sdk.tgz
RUN cd ${LIBRARY_HOME_BETA} && \
    curl -o ${SDK_PATH_NAME} ${ANDROID_SDK_URL} && \
    tar -xzf ${SDK_PATH_NAME} && \
    rm ${SDK_PATH_NAME} && \
    echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION},extra-android-m2repository,extra-android-support

# Set Licenses Android Tools
RUN cd ${LIBRARY_HOME_BETA}android-sdk-linux  \
 && mkdir licenses \
 && echo -n 8933bad161af4178b1185d1a37fbf41ea5269c55 \
        > licenses/android-sdk-license

#Change de Name Path for Linux
RUN mv ${LIBRARY_HOME_BETA}android-sdk-linux/ ${LIBRARY_HOME_BETA}sdk

# Switch to $USER
USER $USER

#Set work Folder
ENV MAIN_FOLDER=/usr/local/share
VOLUME $MAIN_FOLDER
WORKDIR $MAIN_FOLDER
