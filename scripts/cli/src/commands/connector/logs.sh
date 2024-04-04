open="${args[--open]}"
log="${args[--wait-for-log]}"
max_wait="${args[--max-wait]}"
lcc_id="${args[--lcc-id]}"

connector_type=$(playground state get run.connector_type)

if [ "$connector_type" == "$CONNECTOR_TYPE_CUSTOM" ]
then
    logerror "🚨 This command is not supported for custom connectors"
    exit 1
fi

opensearch_script="$root_folder/reproduction-models/_miscellaneous/opensearch/alfred-workflow/alfred-opensearch-connect-workflow/open-lcc-logs.ksh"
datadog_script="$root_folder/reproduction-models/_miscellaneous/opensearch/alfred-workflow/alfred-opensearch-connect-workflow/open-lcc-datadog.ksh"

if [[ -n "$lcc_id" ]]
then
    if [ -f "$opensearch_script" ]
    then
        # confluent employee
        export number_of_days=4
        export open_audit_logs=1
        log "🐛 Opening dashboards for $CONNECTOR_TYPE_CUSTOM connector ($lcc_id)"
        bash "$opensearch_script" "$lcc_id"
        bash "$datadog_script" "$lcc_id"
        exit 0
    else
        logerror "🚨 This command with --lcc-id is not supported for non Confluent employees ($$root_folder/reproduction-models does not contain required scripts)"
        exit 1
    fi
fi

if [ "$connector_type" == "$CONNECTOR_TYPE_FULLY_MANAGED" ]
then
    if [ -f "$opensearch_script" ]
    then
        # confluent employee
        if [[ ! -n "$lcc_id" ]]
        then
            connector=$(playground get-connector-list)
            if [ "$connector" == "" ]
            then
                log "💤 No $connector_type connector is running !"
                exit 1
            fi
        fi

        items=($connector)
        length=${#items[@]}
        if ((length > 1))
        then
            log "✨ --lcc-id flag was not provided, applying command to all $CONNECTOR_TYPE_FULLY_MANAGED connectors"
        fi
        export number_of_days=4
        export open_audit_logs=1
        for connector in ${items[@]}
        do
            log "🐛 Opening dashboards for $connector_type connector $connector ($connectorId)"
            connectorId=$(get_ccloud_connector_lcc $connector)
            bash "$opensearch_script" "$connectorId"
            bash "$datadog_script" "$connectorId"
        done

    else
        logerror "🚨 This command is not supported for fully managed connectors or non Confluent employees ($$root_folder/reproduction-models does not contain required scripts)"
        exit 1
    fi
else
    if [[ -n "$open" ]]
    then
        playground container logs --open --container connect
    elif [[ -n "$log" ]]
    then
        playground container logs --container connect --wait-for-log "$log" --max-wait "$max_wait"
    else 
        playground container logs --container connect
    fi
fi