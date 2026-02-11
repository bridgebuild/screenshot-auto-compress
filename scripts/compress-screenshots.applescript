on adding folder items to this_folder after receiving added_items
    set compress_script to (POSIX path of (path to home folder)) & ".local/bin/screenshot-compress-single.sh"
    repeat with this_item in added_items
        set file_path to POSIX path of this_item
        if file_path ends with ".png" and file_path does not contain "(Comp)" then
            -- Wait for macOS to finish writing the file
            delay 1
            -- Copy to clipboard immediately in Finder context (reliable, not backgrounded)
            try
                set the clipboard to (read (POSIX file file_path) as «class PNGf»)
            end try
            -- Run compression in background
            do shell script "nohup " & quoted form of compress_script & " " & quoted form of file_path & " >/dev/null 2>&1 &"
        end if
    end repeat
end adding folder items to
