FROM ubuntu:18.04

# Install python 3.7
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update
RUN apt-get install -y python3.7 python3.7-distutils git curl wget zip libglfw3-dev libgles2-mesa-dev ffmpeg
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.7
RUN apt-get install -y libsm6 libxext6



# Install VIBE dependencies
RUN  mkdir /opt/vibe
WORKDIR /opt/vibe
COPY requirements.txt /opt/vibe/
RUN pip3 install -r requirements.txt
COPY prepare_data.sh /opt/vibe/
RUN sh prepare_data.sh
RUN apt-get install -y freeglut3-dev
# copy VIBE source
COPY lib /opt/vibe/lib
COPY demo.py /opt/vibe/

ENTRYPOINT ["python3.7", "demo.py"]
CMD ["--vid_file", "/opt/vibe/sample_video.mp4", "--output_folder", "output/"]
