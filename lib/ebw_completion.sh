_ebw_completion() {
    local cur_word prev_word type_list dir
    cur_word="${COMP_WORDS[COMP_CWORD]}"
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Check for the environment variable or fall back to a default path
    dir="${EBW_INSTALLATION_FILES_DIR:-/scicomp/admin/easybuild/ebw/installation_files}"

    if [ "$prev_word" == "-f" ]; then
        type_list=$(find "$dir" -type f -name "${cur_word}*.json" | sed "s@.*/@@" | sed "s/\.json//")
        COMPREPLY=($type_list)
    else
        COMPREPLY=()
    fi
}
complete -F _ebw_completion ebw
