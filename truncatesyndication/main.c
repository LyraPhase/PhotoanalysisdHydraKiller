//
//  main.c
//  PhotoanalysisdHydraKiller
//
//  Created by James Cuzella on 5/19/26.
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <mach-o/dyld.h>


int main(int argc, const char *argv[]) {
    char binary_path[PATH_MAX];
    uint32_t size = sizeof(binary_path);

    // 1. Find the absolute path to this running compiled binary
    if (_NSGetExecutablePath(binary_path, &size) != 0) {
        perror("Failed to get executable path");
        return EXIT_FAILURE;
    }

    // 2. Resolve any symlinks to get the clean real path
    char real_binary_path[PATH_MAX];
    if (realpath(binary_path, real_binary_path) == NULL) {
        perror("Failed to resolve realpath");
        return EXIT_FAILURE;
    }

    // 3. Move up out of Contents/MacOS/ to Contents/
    // A standard macOS app bundle structure places the binary at:
    // HydraKillerLauncher.app/Contents/MacOS/hyrakiller_launcher
    char *last_slash = strrchr(real_binary_path, '/'); // strips binary name
    if (last_slash) *last_slash = '\0';
    last_slash = strrchr(real_binary_path, '/');       // strips "LaunchAgents"
    if (last_slash) *last_slash = '\0';
    last_slash = strrchr(real_binary_path, '/');       // strips "MacOS"
    if (last_slash) *last_slash = '\0';

    // 4. Construct the path to the Resources/ directory where the script lives
    char script_path[PATH_MAX];
    snprintf(script_path, sizeof(script_path), "%s/Resources/LaunchAgents/truncate_syndication_wal.sh", real_binary_path);
    printf("Launching script from path: %s\n", script_path);

    // 5. Build the arguments array for execv
    // argv[0] must be the script name, followed by any forwarded args, terminated by NULL
    char *exec_args[] = { "/bin/sh", script_path, NULL };

    // 6. Atomically replace this C process with the shell script execution context
    execv(exec_args[0], exec_args);

    // If execv returns, an error occurred
    perror("Failed to execute embedded shell script");
    return EXIT_FAILURE;
}
