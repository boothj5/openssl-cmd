GREEN=2

echo_wait()
{
    COLOUR=$1    
    MESSAGE=$2

    tput setaf $COLOUR
    echo $MESSAGE
    read -n1 -s
    tput sgr0
}

function exit_handler {
    tput sgr0
}

error_handler()
{
    ERR_CODE=$?

    tput setaf 1
    echo "Error $ERR_CODE with command '$BASH_COMMAND' on line ${BASH_LINENO[0]}. Exiting."
    tput sgr0
    exit $ERR_CODE
}
