FROM devopscenter/python-apache-pgpool-redis:devops_version
MAINTAINER josh < josh [at] devops {dot} center>


ADD requirements.txt /requirements.txt
RUN cd / && pip install -r requirements.txt


CMD /etc/init.d/pgpool start  && /etc/init.d/apache2 start
