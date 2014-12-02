#
# Docker Stack - Docker stack to manage infrastructures
#
# Copyright 2014 devops.center
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# inherit from this image
#FROM slafs/sentry:latest
FROM devopscenter/sentry-docker:dev

MAINTAINER josh@devops.center

ENV SECRET_KEY randomvalue
#ENV SENTRY_URL_PREFIX http://sentry:9000

ENV SENTRY_INITIAL_TEAM devops.center
ENV SENTRY_INITIAL_PROJECT DockerApp
ENV SENTRY_INITIAL_KEY public:secret
ENV SENTRY_INITIAL_DOMAINS 127.0.0.1 localhost

ENV SENTRY_SECURE_PROXY_SSL_HEADER HTTP_X_FORWARDED_PROTO,https
ENV SENTRY_USE_X_FORWARDED_HOST True
ENV SENTRY_ALLOW_ORIGIN "*"

ENV SENTRY_ADMIN_USERNAME admin
ENV SENTRY_ADMIN_PASSWORD admin

RUN /usr/local/bin/sentry_run prepare
