FROM python:latest

ARG artifact_root="."

COPY $artifact_root/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]