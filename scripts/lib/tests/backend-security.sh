#!/usr/bin/env bash

###############################################################################
#
# Monitoring-netcup Project
#
# Verify that application backends are bound only to the Incus container IP.
# Authentication itself is intentionally handled by Infrastructure-netcup
# Traefik, not by this project.
#
###############################################################################

test_backend_security()
{
    print_section "Backend exposure"

    local monitoring_host_ip
    local ports
    local port

    monitoring_host_ip="$(env_get MONITORING_HOST_IP)"

    ports=(
        "$(env_get GRAFANA_PORT)"
        "$(env_get PROMETHEUS_PORT)"
        "$(env_get ALERTMANAGER_PORT)"
        "$(env_get LOKI_PORT)"
        "$(env_get ALLOY_PORT)"
    )

    for port in "${ports[@]}"; do

        docker ps --format '{{.Ports}}' \
            | grep -Eq "(^|, )${monitoring_host_ip}:${port}->" \
            || fail "Port ${port} is not bound to ${monitoring_host_ip}."

    done

    ok "Application backends are bound to ${monitoring_host_ip}."

    log_info \
        "Final access control is provided by the Infrastructure-netcup firewall and Traefik BasicAuth."
}
