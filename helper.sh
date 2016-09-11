checkexists() {
    while [ -n "$1" ]; do
        if [ -z "$(command -v "$1")" ]; then
            echo "$1: command not found"
            exit 1
        fi
        shift
    done
}
