FROM vernemq/vernemq:1.10.3-alpine


COPY ./vernemq.conf /etc/vernemq/vernemq.conf

HEALTHCHECK CMD vernemq ping | grep -q pong

USER vernemq

CMD ["start_vernemq"]
