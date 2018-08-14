# httpd-tomcat
FROM centos:7

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
chown -R tomcat. /opt/apache-tomcat-7.0.90 && \
ln -s /opt/apache-tomcat-7.0.90/ /opt/tomcat

# Tomcatのパスを通す
RUN echo 'export CATALINA_HOME=/opt/tomcat'  >  /etc/profile.d/tomcat.sh
RUN source /etc/profile.d/tomcat.sh

# サービス定義ファイルを移動
COPY tools/tomcat.service /etc/systemd/system/
RUN chmod 755 /etc/systemd/system/tomcat.service 

#warファイルを移動
COPY deployments/*.war /opt/tomcat/webapps

# サービスの起動
#systemctl start tomcat
# runスクリプトで実行するためコメントアウト

# firewallの設定 多分不要
# firewall-cmd --add-service=http --permanent
# firewall-cmd --add-service=https --permanent
# firewall-cmd --add-service=ssh --permanent
# firewall-cmd --reload


