FROM devopscenter/web_apache:devops_version
MAINTAINER josh < josh [at] devops {dot} center>


ADD requirements.txt /requirements.txt
RUN cd / && pip install -r requirements.txt


CMD /etc/init.d/pgpool start  && /usr/sbin/apache2 -D FOREGROUND
