FROM tomcat

MAINTAINER dengshaolin drngsl@qq.com

#COPY cas.war /opt/
RUN cd /opt/ && wget https://github.com/drngsl/cas-4.0/releases/download/v0.0.1/cas.war && \
    unzip cas.war -d cas && \
    rm -f cas.war && \
    mv cas /usr/local/tomcat/webapps

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]

