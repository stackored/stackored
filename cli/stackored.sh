#!/usr/bin/env bash

# Resolve symlink to get actual script path
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
STACKORED_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd)"

COMMAND=$1
shift

case "$COMMAND" in
    generate)
        bash "$STACKORED_ROOT/stackored/cli/generate.sh" "$@"
        ;;

    up)
        docker compose \
            -f "$STACKORED_ROOT/stackored/stackored.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml" \
            up -d
        ;;

    down)
        docker compose \
            -f "$STACKORED_ROOT/stackored/stackored.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml" \
            down
        ;;

    restart)
        docker compose \
            -f "$STACKORED_ROOT/stackored/stackored.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml" \
            restart
        ;;

    ps)
        docker compose \
            -f "$STACKORED_ROOT/stackored/stackored.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml" \
            ps
        ;;

    logs)
        docker compose \
            -f "$STACKORED_ROOT/stackored/stackored.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml" \
            -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml" \
            logs -f "$@"
        ;;

    doctor)
        bash "$STACKORED_ROOT/stackored/cli/support/doctor.sh"
        ;;

    project)
        SUBCOMMAND=$1
        shift
        case "$SUBCOMMAND" in
            create)
                php "$STACKORED_ROOT/stackored/cli/support/project-create.php" "$@"
                ;;
            *)
                echo "Stackored Project Komutları:"
                echo "  stackored project create <project-name>"
                exit 1
                ;;
        esac
        ;;

    *)
        echo "Stackored CLI"
        echo ""
        echo "Kullanılabilir komutlar:"
        echo "  stackored generate              → dynamic compose üretir"
        echo "  stackored up                    → tüm sistemi ayağa kaldırır"
        echo "  stackored down                  → sistemi kapatır"
        echo "  stackored restart               → servisleri yeniden başlatır"
        echo "  stackored ps                    → çalışan servisleri listeler"
        echo "  stackored logs [srv]            → logları izler"
        echo "  stackored doctor                → sistem sağlık kontrolü"
        echo "  stackored project create <name> → yeni proje oluşturur"
        echo ""
        exit 1
        ;;
esac
