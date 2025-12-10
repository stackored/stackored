#!/usr/bin/env bash

# Resolve symlink to get actual script path
readonly SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
readonly STACKORED_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd)"

# Docker Compose dosya yolları - tek yerde tanımla
readonly COMPOSE_FILES=(
    -f "$STACKORED_ROOT/stackored/stackored.yml"
    -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml"
    -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml"
)


COMMAND=$1
shift

case "$COMMAND" in
    generate)
        bash "$STACKORED_ROOT/stackored/cli/generate.sh" "$@"
        ;;

    up)
        docker compose "${COMPOSE_FILES[@]}" up -d
        ;;

    down)
        docker compose "${COMPOSE_FILES[@]}" down
        ;;

    restart)
        docker compose "${COMPOSE_FILES[@]}" restart
        ;;

    ps)
        docker compose "${COMPOSE_FILES[@]}" ps
        ;;

    logs)
        docker compose "${COMPOSE_FILES[@]}" logs -f "$@"
        ;;

    doctor)
        bash "$STACKORED_ROOT/stackored/cli/support/doctor.sh"
        ;;

    # TODO: project create komutu Bash ile yeniden yazılacak
    # PHP bağımlılığı kaldırıldı
    # project)
    #     SUBCOMMAND=$1
    #     shift
    #     case "$SUBCOMMAND" in
    #         create)
    #             echo "Bu özellik şu anda devre dışı (PHP bağımlılığı kaldırıldı)"
    #             echo "Manuel olarak projects/ dizininde proje oluşturabilirsiniz"
    #             exit 1
    #             ;;
    #         *)
    #             echo "Stackored Project Komutları:"
    #             echo "  stackored project create <project-name>"
    #             exit 1
    #             ;;
    #     esac
    #     ;;

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
        echo ""
        exit 1
        ;;
esac
