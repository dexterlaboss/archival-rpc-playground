FROM ubuntu:22.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    cmake \
    supervisor \
    python3-pip \
    openjdk-11-jdk-headless \
    && pip3 install supervisor-stdout

# Set up environment variables for Java
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /usr/local/bin
RUN curl -L -o ingestor-rpc https://github.com/dexterlaboss/ingestor-rpc/releases/download/v1.2.8/ingestor_rpc_v1.2.8_linux_amd64 \
    && chmod +x ingestor-rpc

RUN curl -L -o archival-rpc https://github.com/dexterlaboss/archival-rpc/releases/download/v1.4.4/archival_rpc_v1.4.4_linux_amd64 \
    && chmod +x archival-rpc

# Install HBase
ENV HBASE_VERSION 2.4.11
WORKDIR /opt
RUN curl -O https://archive.apache.org/dist/hbase/2.4.11/hbase-2.4.11-bin.tar.gz \
    && tar xzf hbase-2.4.11-bin.tar.gz \
    && mv hbase-2.4.11 hbase \
    && rm hbase-2.4.11-bin.tar.gz

# Set up Supervisor
RUN mkdir -p /var/run/supervisor && chmod 755 /var/run/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set up HBase configuration
COPY hbase-site.xml /opt/hbase-${HBASE_VERSION}/conf/hbase-site.xml
RUN mkdir -p /data/hbase /data/zookeeper

# Update PATH for HBase
ENV PATH $PATH:/opt/hbase-${HBASE_VERSION}/bin

# Copy the create-hbase-tables script
COPY create-hbase-tables.sh /usr/local/bin/create-hbase-tables.sh
RUN chmod +x /usr/local/bin/create-hbase-tables.sh

# Expose ports
EXPOSE 2181 8080 8899 9090 16000 16010 16020 16030

# Create data directories
VOLUME /data/hbase
VOLUME /data/zookeeper

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
