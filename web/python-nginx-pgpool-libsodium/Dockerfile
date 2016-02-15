FROM devopscenter/python-nginx-pgpool:devops_version

RUN mkdir /repos
WORKDIR /repos
RUN git clone https://github.com/devopsscion/libsodium-jni
RUN git clone https://github.com/data-luminosity/message

WORKDIR /repos/libsodium-jni
RUN ./dependencies-linux.sh
RUN ./build.sh

WORKDIR /repos/message
RUN pip install -r requirements.txt
