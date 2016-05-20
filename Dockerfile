FROM baseimageversion

ADD buildtools/utils/base-utils.sh /installs/base-utils.sh
ADD logging/papertrail.sh /installs/papertrail.sh
ADD logging/90-papertrailqueue.conf /installs/90-papertrailqueue.conf
ADD logging/50-default.conf /installs/50-default.conf

# Add the files needed to pip-install supervisor, later.
ADD buildtools/utils/install-supervisor.sh /installs/utils/install-supervisor.sh
ADD buildtools/utils/supervisord.conf /installs/utils/supervisord.conf
ADD buildtools/utils/initd-supervisor-custom /installs/utils/initd-supervisor-custom
ADD buildtools/utils/initd-supervisor /installs/utils/initd-supervisor


WORKDIR /installs
RUN ./base-utils.sh
RUN ./papertrail.sh
