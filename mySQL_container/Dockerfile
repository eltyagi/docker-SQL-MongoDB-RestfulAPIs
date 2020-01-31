FROM mysql:8.0 as builder

LABEL maintainer="Revanth Nemani <raynemani@gmail.com>"

RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]
ENV MYSQL_ROOT_PASSWORD=root
COPY setup.sql /docker-entrypoint-initdb.d/
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]

FROM mysql:8.0

COPY --from=builder /initialized-db /var/lib/mysql

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 33060

CMD ["mysqld"]