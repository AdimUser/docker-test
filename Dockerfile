FROM vfiump/java8

MAINTAINER Mahesh Perara <utpmahesh@gmail.com>

RUN apt-get update \
	&& apt-get install -y curl

RUN echo "deb http://debian.datastax.com/community stable main" |  tee -a /etc/apt/sources.list.d/cassandra.sources.list
RUN curl -L https://debian.datastax.com/debian/repo_key |  apt-key add -

ENV CASSANDRA_VERSION 2.1.11

RUN apt-get update \
	&& apt-get install -y dsc21=$CASSANDRA_VERSION-1 cassandra=$CASSANDRA_VERSION cassandra-tools=$CASSANDRA_VERSION \
	&& apt-get install -y datastax-agent

ENV CASSANDRA_CONFIG /etc/cassandra

COPY conf/cassandra.yaml $CASSANDRA_CONFIG/cassandra.yaml

# listen to all rpc
RUN sed -ri ' \
		s/^(rpc_address:).*/\1 0.0.0.0/; \
	' "$CASSANDRA_CONFIG/cassandra.yaml"

COPY bin/docker-entrypoint.sh /docker-entrypoint.sh
COPY conf/cassandra-env.sh $CASSANDRA_CONFIG/cassandra-env.sh

RUN echo "stomp_interface: 192.168.1.2" |  tee -a /var/lib/datastax-agent/conf/address.yaml


ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160 61620 61621 9169  22
CMD ["cassandra", "-f"]
