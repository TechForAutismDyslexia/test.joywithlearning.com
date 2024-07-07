#!/usr/bin/env fish
set filename build.config.json

function buildRepo

    set name (basename $argv[1])
    set subdomain (jq -r ".[\"$name\"].subdomain" $filename)
    set repolink (jq -r ".[\"$name\"].repolink" $filename)
    set repodir ./buildfiles/$name

    if test ! -e site
        mkdir site
    else
        rm -rf ./site/$subdomain
    end
    if test ! -e buildfiles
        mkdir buildfiles
    else
        rm -rf ./buildfiles/*
    end

    
    # if "$subdomain" = "/" 
    #     set repodir "./buildfiles/root"
    # end
    echo $name
    echo $repolink
    echo $repodir
    echo "$subdomain $repolink"
    git clone "$repolink" "$repodir"
    cd $repodir
    bun i
    bun run build
    cd -
    mkdir -p "./site/$subdomain"
    if test -e $repodir/build
        cp -r $repodir/build/* ./site/$subdomain
    else if test -e $repodir/dist
        cp -r $repodir/dist/* ./site/$subdomain
    end
end

if test "$argv[1]" = "all"

    set filename build.config.json
    set keys (jq 'keys[]' $filename)
    if test ! -e site
        mkdir site
    else
        rm -rf ./site/*
    end
    if test ! -e buildfiles
        mkdir buildfiles
    else
        rm -rf ./buildfiles/*
    end
    for i in $keys
        set subdomain (jq -r ".[$i].subdomain" $filename)
        set name (basename $subdomain)
        set repolink (jq -r ".[$i].repolink" $filename)
        set repodir ./buildfiles/$name
        # if "$subdomain" = "/" 
        #     set repodir "./buildfiles/root"
        # end
        echo $name
        echo $repolink
        echo $repodir
        echo "$subdomain $repolink"
        git clone "$repolink" "$repodir"
        cd $repodir
        bun i
        bun run build
        cd -
        mkdir -p "./site/$subdomain"
        if test -e $repodir/build
            cp -r $repodir/build/* ./site/$subdomain
        else if test -e $repodir/dist
            cp -r $repodir/dist/* ./site/$subdomain
        end
    end
else
    buildRepo "$argv[1]"
end
