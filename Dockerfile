FROM alpine:3.12

# Variables goes here
ENV FLUTTER_CHANNEL=stable \
  FLUTTER_HOME=/opt/flutter \
  GLIBC_VERSION="2.32-r0" \
  ANDROID_HOME=/opt/android-sdk-linux \
  ANDROID_BUILD_TOOLS_1="build-tools;28.0.3" \
  ANDROID_BUILD_TOOLS_2="build-tools;29.0.3" \
  ANDROID_PLATFORM_1="platforms;android-28" \
  ANDROID_PLATFORM_2="platforms;android-29" \
  ANDROID_PLATFORM_TOOLS="platform-tools" \
  LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANGUAGE=en_US:en

# Updating path environment
ENV ANDROID_SDK_ROOT=$ANDROID_HOME \
  PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/platform-tools:${FLUTTER_HOME}/bin

# Comes from https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_VERSION 6609375

# Installing dependencies
RUN apk -U add --no-cache \
  bash \
  curl \
  git \
  libgcc \
  openjdk8-jre \
  unzip

# Installing glibc. It required for building Dart tools
RUN wget -q https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub \
  && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk \
  && apk add /tmp/glibc.apk

# Loading Android SDK
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O /tmp/android-sdk-tools.zip \
  && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
  && unzip -q /tmp/android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/

# Clearing caches
RUN rm -rf /tmp/* /var/cache/apk/* 

# Installing needed platform tools and SDKs
RUN yes | sdkmanager --licenses && sdkmanager \
  ${ANDROID_PLATFORM_1} ${ANDROID_PLATFORM_2} \
  ${ANDROID_BUILD_TOOLS_1} ${ANDROID_BUILD_TOOLS_2} \
  ${ANDROID_PLATFORM_TOOLS}

# Removed emulator folder
RUN rm -rf ${ANDROID_HOME}/emulator

# Clonning flutter from github
RUN git clone -b ${FLUTTER_CHANNEL} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

# Disable flutter analytics report
RUN flutter config --no-analytics

# Clearing flutter cache
RUN rm -rf /root/.pub-cache/hosted/pub.dartlang.org

# Running doctor is needed for fetching all additional Android dependencies
RUN flutter doctor
