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

    local ports=(
        "${GRAFANA_PORT}"
        "${PROMETHEUS_PORT}"
        "${ALERTMANAGER_PORT}"
        "${LOKI_PORT}"
        "${ALLOY_PORT}"
    )

    local port

    for port in "${ports[@]}"; do
        docker ps --format '{{.Ports}}'             | grep -Eq "(^|, )${MONITORING_HOST_IP}:${port}->"             || fail "Port ${port} is not bound to ${MONITORING_HOST_IP}."
    done

    ok "Application backends are bound to ${MONITORING_HOST_IP}."
    log_info "Final access control is provided by the Infrastructure-netcup firewall and Traefik BasicAuth."
}
