RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6

create_dirs()
{
    mkdir alice
    mkdir bob
    mkdir shared
}

echo_bob()
{
    MESSAGE=$1
    tput setaf $YELLOW
    echo $MESSAGE
    tput sgr0
    read -n1 -s
}

echo_alice()
{
    MESSAGE=$1
    tput setaf $CYAN
    echo $MESSAGE
    tput sgr0
    read -n1 -s
}

echo_both()
{
    MESSAGE=$1
    tput setaf $MAGENTA
    echo $MESSAGE
    tput sgr0
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
