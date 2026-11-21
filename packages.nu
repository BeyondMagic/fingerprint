#!/usr/bin/env nu
# Subtree management helper for fingerprint packages (AURIS & Artix Linux).

const PACKAGES = [
    {
        name: "open-fprintd-dinit"
        target: "auris"
        remote: "auris-open-fprintd-dinit"
        url: "ssh://git@auris.artixlinux.org:23/auris/open-fprintd-dinit.git"
        branch: "master"
    }
    {
        name: "python-validity-dinit"
        target: "auris"
        remote: "auris-python-validity-dinit"
        url: "ssh://git@auris.artixlinux.org:23/auris/python-validity-dinit.git"
        branch: "master"
    }
    {
        name: "open-fprintd-elogind-dinit"
        target: "artix"
        remote: null
        url: null
        branch: "master"
    }
    {
        name: "python-validity-elogind-dinit"
        target: "artix"
        remote: null
        url: null
        branch: "master"
    }
    {
        name: "fprintd-clients-git-elogind"
        target: "artix"
        remote: null
        url: null
        branch: "master"
    }
]

def find-package [name: string] {
    let matches = ($PACKAGES | where name == $name)
    if ($matches | is-empty) {
        let valid = ($PACKAGES | get name | str join ", ")
        error make { msg: $"Unknown package '($name)'. Expected one of: ($valid)" }
    }
    $matches | first
}

def require-clean-tree [] {
    let dirty = (^git status --porcelain | str trim)
    if not ($dirty | is-empty) {
        error make { msg: "Working tree is not clean. Commit or stash changes before running subtree operations." }
    }
}

def ensure-remote [pkg: record] {
    if ($pkg.remote == null) or ($pkg.url == null) {
        error make { msg: $"Package '($pkg.name)' has no configured upstream remote yet." }
    }
    let existing = (^git remote | lines)
    if ($pkg.remote in $existing) {
        let current_url = (^git remote get-url $pkg.remote | str trim)
        if $current_url != $pkg.url {
            ^git remote set-url $pkg.remote $pkg.url
            print $"Updated remote ($pkg.remote) -> ($pkg.url)"
        }
    } else {
        ^git remote add $pkg.remote $pkg.url
        print $"Added remote ($pkg.remote) -> ($pkg.url)"
    }
}

def resolve-auris-targets [package?: string] {
    if ($package | is-empty) {
        $PACKAGES | where target == "auris"
    } else {
        let pkg = (find-package $package)
        if ($pkg.remote == null) {
            error make { msg: $"Package '($pkg.name)' has no remote configured yet." }
        }
        [$pkg]
    }
}

# Display available subcommands.
def main [] {
    help main
}

# Show status, target, configured remote, and latest commit for each package subtree.
def "main status" [] {
    let existing_remotes = (^git remote | lines)
    $PACKAGES | each {|pkg|
        let latest = (^git log -n 1 --format="%h %s" -- $pkg.name | str trim)
        let remote_state = if ($pkg.remote == null) {
            "pending (Artix)"
        } else if ($pkg.remote in $existing_remotes) {
            $"configured: ($pkg.remote)"
        } else {
            $"missing: ($pkg.remote)"
        }
        {
            package: $pkg.name
            target: $pkg.target
            remote: $remote_state
            latest_commit: $latest
        }
    }
}

# Ensure local git remotes for AURIS subtrees are configured in .git/config.
def "main remotes" [] {
    for pkg in ($PACKAGES | where remote != null) {
        ensure-remote $pkg
    }
    print "AURIS remotes are configured."
}

# Pull upstream changes from AURIS into a package subtree (or all AURIS subtrees).
def "main pull" [
    package?: string # Optional package name; defaults to all AURIS packages
] {
    require-clean-tree
    let targets = (resolve-auris-targets $package)
    for pkg in $targets {
        ensure-remote $pkg
        print $"Pulling ($pkg.name) from ($pkg.remote)/($pkg.branch)..."
        ^git subtree pull $"--prefix=($pkg.name)" $pkg.remote $pkg.branch -m $"chore\(subtree\): pull ($pkg.name)"
    }
}

# Push subtree commits back to AURIS (or all AURIS subtrees).
def "main push" [
    package?: string # Optional package name; defaults to all AURIS packages
] {
    require-clean-tree
    let targets = (resolve-auris-targets $package)
    for pkg in $targets {
        ensure-remote $pkg
        print $"Pushing ($pkg.name) to ($pkg.remote)/($pkg.branch)..."
        ^git subtree push $"--prefix=($pkg.name)" $pkg.remote $pkg.branch
    }
}

# Split a package subtree into a standalone branch or exported git repository for submission.
def "main split" [
    package: string          # Package directory name to split
    --branch (-b): string    # Local branch name to create/update (default: split/<package>)
    --dest (-d): string      # Optional directory path to export a standalone git repository
] {
    let pkg = (find-package $package)
    let split_branch = if ($branch | is-empty) { $"split/($pkg.name)" } else { $branch }

    print $"Splitting ($pkg.name) into branch '($split_branch)'..."
    ^git subtree split $"--prefix=($pkg.name)" -b $split_branch

    if not ($dest | is-empty) {
        if ($dest | path exists) {
            error make { msg: $"Destination '($dest)' already exists." }
        }
        print $"Exporting standalone repository to ($dest)..."
        ^git init -b master $dest
        ^git -C $dest fetch (pwd) $split_branch
        ^git -C $dest reset --hard FETCH_HEAD
        print $"Standalone repository ready at ($dest)."
    }
}

# Clean makepkg build directories and package archives across all packages.
def "main clean" [] {
    for pkg in $PACKAGES {
        for sub in ["src", "pkg", "fprintd"] {
            let path = ($pkg.name | path join $sub)
            if ($path | path exists) {
                try { ^chmod -R u+rwX $path }
                rm -rf $path
                print $"Removed ($path)"
            }
        }
        let archives = (glob $"($pkg.name)/*.pkg.tar.*")
        for archive in $archives {
            rm -f $archive
            print $"Removed ($archive)"
        }
        let logs = (glob $"($pkg.name)/*.log")
        for log in $logs {
            rm -f $log
            print $"Removed ($log)"
        }
    }
}
