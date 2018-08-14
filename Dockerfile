# httpd-tomcat
FROM openshift/base-centos7

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
chmod 775 /opt/apache-tomcat-7.0.90/webapps && \
ln -s /opt/apache-tomcat-7.0.90/ /opt/tomcat

# Tomcatのパスを通す
RUN echo 'export CATALINA_HOME=/opt/tomcat'  >  /etc/profile.d/tomcat.sh
RUN source /etc/profile.d/tomcat.sh

# サービス定義ファイルを移動
#COPY tools/tomcat.service /etc/systemd/system/
#RUN chmod 755 /etc/systemd/system/tomcat.service 

#warファイルを移動
#COPY deployments/*.war /opt/tomcat/webapps

# s2iスクリプトをS2iBuild用のディレクトリにコピーする
COPY s2i/bin/ /usr/libexec/s2i

# s2iスクリプトに実行権限を付与する
RUN chmod +x /usr/libexec/s2i/*

# ホストとほかのコンテナがアクセスできるポートを8080に設定する
EXPOSE 8080
