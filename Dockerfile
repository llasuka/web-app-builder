# httpd-tomcat
FROM openshift/base-centos7

#arg parameter
ARG MYSQL_HOSTNAME="mysqlServer"
ARG MYSQL_IPADDRESS

#hostname set
RUN echo $MYSQL_IPADDRESS $MYSQL_HOSTNAME >> /etc/hosts

# Here you can specify the maintainer for the image that you're building
LABEL maintainer="Asuka Arakawa  <arakawa.asuka.jri@outlook.jp>"

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Tomcat7 HTTP Serverr" \
    io.k8s.display-name="Tomcat7 HTTP Server" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,webserver,html,tomcat" \
    # this label tells s2i where to find its mandatory scripts
    # (run, assemble, save-artifacts)
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i/"

# javaのインストール
RUN set -x && \
yum install -y yum-fastestmirror && \
yum install -y which && \
yum install -y java-1.8.0-openjdk-devel && \
yum clean all

# パスを通す
RUN echo "export JAVA_HOME=$(readlink -e $(which java)|sed 's:/bin/java::')" >  /etc/profile.d/java.sh
RUN echo "PATH=\$PATH:\$JAVA_HOME/bin"                                       >> /etc/profile.d/java.sh
RUN source /etc/profile.d/java.sh

# Tomcat取得・配置
RUN useradd -s /sbin/nologin tomcat
#wget http://ftp.kddilabs.jp/infosystems/apache/tomcat/tomcat-7/v7.0.90/bin/apache-tomcat-7.0.90.tar.gz
RUN mkdir /usr/src/tomcat
COPY tools/apache-tomcat-7.0.90.tar.gz /usr/src/tomcat
RUN set -x && tar -xvf /usr/src/tomcat/apache-tomcat-7.0.90.tar.gz -C /opt/  && \
chmod -R 775 /opt/apache-tomcat-7.0.90 && \
ln -s /opt/apache-tomcat-7.0.90/ /opt/tomcat

# Tomcatのパスを通す
RUN echo 'export CATALINA_HOME=/opt/tomcat'  >  /etc/profile.d/tomcat.sh
RUN source /etc/profile.d/tomcat.sh
ENV CATALINA_HOME /opt/tomcat
ENV CATALINA_BASE /opt/tomcat

# サービス定義ファイルを移動
#COPY tools/tomcat.service /etc/systemd/system/
#RUN chmod 755 /etc/systemd/system/tomcat.service 

# warファイルを移動
#COPY deployments/*.war /opt/tomcat/webapps

# s2iスクリプトをS2iBuild用のディレクトリにコピーする
RUN mkdir /usr/libexec/s2i
COPY s2i/bin/* /usr/libexec/s2i/

# s2iスクリプトに実行権限を付与する
RUN chmod +x /usr/libexec/s2i/*

# Linuxデフォルトのユーザで実行
RUN chmod g=u /etc/passwd
USER 1001

# ホストとほかのコンテナがアクセスできるポートを8080に設定する
EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
