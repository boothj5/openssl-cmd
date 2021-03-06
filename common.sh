RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6

create_dirs()
{
    mkdir -p alice
    mkdir -p bob
    mkdir -p trent
    mkdir -p shared
}

echo_error()
{
    MESSAGE=$1
    tput setaf $RED
    tput bold
    echo $MESSAGE
    tput sgr0
}

echo_bob()
{
    MESSAGE=$1
    tput setaf $YELLOW
    tput bold
    echo ""
    echo $MESSAGE
    tput sgr0
}

echo_alice()
{
    MESSAGE=$1
    tput setaf $CYAN
    tput bold
    echo ""
    echo $MESSAGE
    tput sgr0
}

echo_both()
{
    MESSAGE=$1
    tput setaf $MAGENTA
    tput bold
    echo ""
    echo $MESSAGE
    tput sgr0
}

echo_trent()
{
    MESSAGE=$1
    tput setaf $BLUE
    tput bold
    echo ""
    echo $MESSAGE
    tput sgr0
}

wait_key()
{
    read -n1 -s
}

cat_safe()
{
    FILE=$1
    tput setaf $GREEN
    cat $FILE
    tput sgr0
}

cat_unsafe()
{
    FILE=$1
    tput setaf $RED
    cat $FILE
    tput sgr0
}

payload_create()
{
    TARGET_FILE=$1
    MESSAGE=$2

    if [ ! -z "$3" ]; then
        SESSION_KEY=$3
    else
        SESSION_KEY=""
    fi
    if [ ! -z "$4" ]; then
        SIGNATURE=$4
    else
        SIGNATURE=""
    fi

    echo "MESSAGE:" > $TARGET_FILE
    cat $MESSAGE >> $TARGET_FILE

    if [ ! -z "$SESSION_KEY" ]; then
        echo "" >> $TARGET_FILE
        echo "SESSION_KEY:" >> $TARGET_FILE
        cat $SESSION_KEY >> $TARGET_FILE
    fi
    if [ ! -z "$SIGNATURE" ]; then
        echo "" >> $TARGET_FILE
        echo "SIGNATURE:" >> $TARGET_FILE
        cat $SIGNATURE >> $TARGET_FILE
    fi
}

payload_get_message()
{
    INPUT_FILE=$1
    OUTPUT_FILE=$2

    sed '2!d' $INPUT_FILE > $OUTPUT_FILE
}

payload_get_session_key()
{
    INPUT_FILE=$1
    OUTPUT_FILE=$2

    sed '4!d' $INPUT_FILE > $OUTPUT_FILE
}

payload_get_signature()
{
    INPUT_FILE=$1
    OUTPUT_FILE=$2

    sed '6!d' $INPUT_FILE > $OUTPUT_FILE
}

exit_handler()
{
    tput sgr0
}

error_handler()
{
    ERR_CODE=$?

    echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
    exit $ERR_CODE
}
