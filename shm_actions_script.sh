#!/bin/bash

set -e

EVENT="{{ event_name }}"
AWG_MANAGER="/etc/amnezia/amneziawg/awg-manager.sh"
CONF_DIR="/etc/amnezia/amneziawg"
SESSION_ID="{{ user.gen_session.id }}"
API_URL="{{ config.api.url }}"

echo "EVENT=$EVENT"

case $EVENT in
    INIT)
        SERVER_HOST="{{ server.settings.host_name }}"
        SERVER_INTERFACE="{{ server.settings.interface }}"
        if [[ -z "$SERVER_INTERFACE" ]]; then
            SERVER_INTERFACE=$(ip route | awk '/default/ {print $5; exit}')
        fi
        if [ -z $SERVER_HOST ]; then
            SERVER_HOST="{{ server.settings.host }}"
        fi
        echo "Check domain: $API_URL"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL/shm/v1/test)
        if [ $HTTP_CODE -ne '200' ]; then
            echo "ERROR: incorrect API URL: $API_URL"
            echo "Got status: $HTTP_CODE"
            exit 1
        fi
        echo
        echo "Download awg-manager.sh & encode.py"
        mkdir -p $CONF_DIR
        curl -s https://raw.githubusercontent.com/bkeenke/awg-manager/master/awg-manager.sh > $AWG_MANAGER
        curl -s https://raw.githubusercontent.com/bkeenke/awg-manager/master/encode.py > $CONF_DIR/encode.py

        echo "Init server"
        chmod 700 $AWG_MANAGER
        if [ $SERVER_INTERFACE ]; then
            $AWG_MANAGER -i -s $SERVER_HOST -I $SERVER_INTERFACE
        else
            $AWG_MANAGER -i -s $SERVER_HOST
        fi
        ;;
    CREATE)
        echo "Create new user"
        $AWG_MANAGER -u "{{ us.id }}" -c
        echo "Upload user key to SHM"
        curl -s -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: text/plain" \
            $API_URL/shm/v1/storage/manage/conf_{{ us.id }} \
            --data-binary "@$CONF_DIR/keys/{{ us.id }}/{{ us.id }}.conf"
        sleep 1
        ENCODE=$(python3 $CONF_DIR/encode.py {{ us.id }})
        curl -sk -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: text/plain" \
            $API_URL/shm/v1/storage/manage/url_{{ us.id }} \
            --data-binary "vpn://$ENCODE"
        curl -sk -XPUT \
            -H "session-id: $SESSION_ID" \
            -H "Content-Type: text/plain" \
            $API_URL/shm/v1/storage/manage/encode_{{ us.id }} \
            --data-binary "$ENCODE"
        echo "done"
        ;;
    ACTIVATE)
        echo "Activate user"
        $AWG_MANAGER -u "{{ us.id }}" -U
        echo "done"
        ;;
    BLOCK)
        echo "Block user"
        $AWG_MANAGER -u "{{ us.id }}" -L
        echo "done"
        ;;
    REMOVE)
        echo "Remove user"
        $AWG_MANAGER -u "{{ us.id }}" -d
        echo "Remove user key from SHM"
        curl -s -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/encode_{{ us.id }}
        curl -s -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/url_{{ us.id }}
        curl -s -XDELETE \
            -H "session-id: $SESSION_ID" \
            $API_URL/shm/v1/storage/manage/conf_{{ us.id }}
        echo "done"
        ;;
    *)
        echo "Unknown event: $EVENT. Exit."
        exit 0
        ;;
esac
