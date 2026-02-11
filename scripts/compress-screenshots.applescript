on adding folder items to this_folder after receiving added_items
    set compress_script to (POSIX path of (path to home folder)) & ".local/bin/screenshot-compress-single.sh"
    repeat with this_item in added_items
        set file_path to POSIX path of this_item
        do shell script "nohup " & quoted form of compress_script & " " & quoted form of file_path & " >/dev/null 2>&1 &"
    end repeat
end adding folder items to
