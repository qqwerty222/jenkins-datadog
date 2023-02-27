FROM gcr.io/datadoghq/agent:7

RUN apt-get update && apt-get install iputils-ping && apt-get autoremove

COPY dd_custom_checks/conf.d/. /etc/datadog-agent/conf.d/
COPY dd_custom_checks/checks.d/. /etc/datadog-agent/checks.d/


