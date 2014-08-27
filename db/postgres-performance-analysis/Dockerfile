FROM devopscenter/db_postgres:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

RUN echo "log_destination = 'csvlog'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "logging_collector = on" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "log_directory = 'pg_log'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "shared_preload_libraries = 'auto_explain'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "custom_variable_classes = 'auto_explain'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "auto_explain.log_min_duration = '10ms'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "auto_explain.log_verbose = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "auto_explain.log_analyze = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf

# pg_stats
#RUN echo "track_activities = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "track_activity_query_size = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "track_counts = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "track_io_timing = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf

#Statistics Monitoring
#RUN echo "log_statement_stats = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "log_parser_stats = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "log_planner_stats = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "log_executor_stats = 'true'" >> /etc/postgresql/9.3/main/postgresql.conf

# ssl not needed for now. also gives error on boot2docker
RUN echo "ssl = false                              # (change requires restart)" >> /etc/postgresql/9.3/main/postgresql.conf


# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
