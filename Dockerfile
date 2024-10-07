FROM ubuntu:22.04

# Dependency versions
ENV HBASE_VERSION=2.4.11 \
    INGESTOR_VERSION=1.2.9 \
    RPC_VERSION=1.4.4 \
    JAVA_VERSION=openjdk-11

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    cmake \
    supervisor \
    python3-pip \
    ${JAVA_VERSION}-jdk-headless \
    && pip3 install supervisor-stdout \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables for Java
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64" \
    PATH="$JAVA_HOME/bin:/opt/hbase/bin:$PATH"

# Install HBase
WORKDIR /opt
RUN curl -O https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar xzf hbase-${HBASE_VERSION}-bin.tar.gz \
    && mv hbase-${HBASE_VERSION} hbase \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

# Set up Supervisor
RUN mkdir -p /var/run/supervisor /data/hbase /data/zookeeper
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy HBase configuration and necessary scripts
COPY hbase-site.xml /opt/hbase/conf/hbase-site.xml
COPY hbase/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Install ingestor and RPC services
WORKDIR /usr/local/bin
RUN curl -L -o ingestor-rpc https://github.com/dexterlaboss/ingestor-rpc/releases/download/v${INGESTOR_VERSION}/ingestor_rpc_v${INGESTOR_VERSION}_linux_amd64 \
    && chmod +x ingestor-rpc

RUN curl -L -o archival-rpc https://github.com/dexterlaboss/archival-rpc/releases/download/v${RPC_VERSION}/archival_rpc_v${RPC_VERSION}_linux_amd64 \
    && chmod +x archival-rpc

# Copy setup and service start scripts
COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Expose necessary ports
EXPOSE 2181 8080 8899 9090 16000 16010 16020 16030

# Create data volumes
VOLUME /data/hbase /data/zookeeper

# Environment variables
ENV RPC_ARGS=""
ENV INGESTOR_ARGS=""

# Start the main script
CMD ["/usr/local/bin/start.sh"]
