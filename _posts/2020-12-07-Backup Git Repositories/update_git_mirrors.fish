function update_git_mirrors -d \
    "For each directory given, non-recursively update each Git mirror repository directory suffixed with .git"
    for dir in $argv
        if not test -d $dir
            continue
            echo "Argument '$dir' is not a directory" 1>&2
        end

        for mirror in $dir/*.git
            if test -d $mirror
                git -C $mirror remote update --prune >/dev/null
                echo "Updated $mirror"
            end
        end
    end
end
