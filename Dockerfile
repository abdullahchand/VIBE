FROM ubuntu:18.04

# Build Python 3.7 from source.  The deadsnakes ppa is flakey
RUN apt-get update
RUN apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl 
RUN cd /tmp && curl https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz | tar xz
RUN cd /tmp/Python-3.7.4 && ./configure --enable-optimizations 
RUN cd /tmp/Python-3.7.4 && make -j 8 && make altinstall
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.7

# Build Mesa software render from source
RUN apt-get install -y git wget zip libglfw3-dev libgles2-mesa-dev ffmpeg llvm-6.0 llvm-6.0-tools freeglut3 freeglut3-dev pkg-config zlib1g-dev libexpat1-dev
RUN cd /tmp && curl ftp://ftp.freedesktop.org/pub/mesa/mesa-18.3.3.tar.gz | tar xz && \
  cd /tmp/mesa-18.3.3/ && \
  ./configure --prefix=/usr/local \
  --enable-opengl --disable-gles1 --disable-gles2   \
  --disable-va --disable-xvmc --disable-vdpau       \
  --enable-shared-glapi                             \
  --disable-texture-float                           \
  --enable-gallium-llvm --enable-llvm-shared-libs   \
  --with-gallium-drivers=swrast,swr                 \
  --disable-dri --with-dri-drivers=                 \
  --disable-egl --with-egl-platforms= --disable-gbm \
  --disable-glx                                     \
  --disable-osmesa --enable-gallium-osmesa          \
  ac_cv_path_LLVM_CONFIG=llvm-config-6.0
RUN cd /tmp/mesa-18.3.3/ && make -j8 && make install

# Mesa envvars
ENV MESA_HOME /usr/local
ENV LIBRARY_PATH $LIBRARY_PATH:$MESA_HOME/lib
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$MESA_HOME/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$MESA_HOME/include/
ENV CPLUS_INCLUDE_PATH $CPLUS_INCLUDE_PATH:$MESA_HOME/include/

# Mesa enabled pyopengl
RUN pip3 uninstall -y pyopengl
RUN pip3 install git+https://github.com/mmatl/pyopengl.git

# Install VIBE dependencies
RUN  mkdir /opt/vibe
WORKDIR /opt/vibe
COPY requirements.txt /opt/vibe/
RUN pip3 install -r requirements.txt
COPY prepare_data.sh /opt/vibe/
RUN sh prepare_data.sh

# copy VIBE source
COPY lib /opt/vibe/lib
COPY demo.py /opt/vibe/

ENTRYPOINT ["python3.7", "demo.py"]
CMD ["--vid_file", "/opt/vibe/sample_video.mp4", "--output_folder", "output/"]