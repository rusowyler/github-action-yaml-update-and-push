FROM alpine:3.15

RUN apk --no-cache add curl gettext git bash
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
