#!/usr/bin/env bash

###################################################################
# STACKORED UNINSTALLER
# Tüm container'ları, volume'ları ve kurulumu kaldırır
###################################################################

# Global sabitler
readonly STACKORED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Logger kütüphanesini yükle
source "$(dirname "${BASH_SOURCE[0]}")/lib/logger.sh"



echo -e "${RED}⚠️  STACKORED UNINSTALLER${NC}"
echo ""
echo "Bu işlem şunları kaldıracak:"
echo "  - Tüm Docker container'ları"
echo "  - Tüm Docker volume'ları (VERİLER SİLİNECEK!)"
echo "  - Docker network"
echo "  - Sistem geneli 'stackored' komutu"
echo ""
echo -e "${YELLOW}⚠️  DİKKAT: Tüm veritabanı verileri silinecek!${NC}"
echo ""
read -p "Devam etmek istiyor musunuz? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "İptal edildi."
    exit 0
fi

echo -e "${RED}[1/5]${NC} Container'lar durduruluyor..."
cd "$STACKORED_ROOT/stackored"
docker compose \
    -f stackored.yml \
    -f docker-compose.dynamic.yml \
    -f docker-compose.projects.yml \
    down 2>/dev/null || true

echo -e "${RED}[2/5]${NC} Volume'lar siliniyor..."
docker volume ls --format "{{.Name}}" | grep "stackored" | xargs -r docker volume rm 2>/dev/null || true

echo -e "${RED}[3/5]${NC} Network siliniyor..."
docker network rm stackored-net 2>/dev/null || true

echo -e "${RED}[4/5]${NC} Sistem komutu kaldırılıyor..."
sudo rm -f /usr/local/bin/stackored 2>/dev/null || true

echo -e "${RED}[5/5]${NC} Generated dosyalar siliniyor..."
rm -f "$STACKORED_ROOT/stackored/stackored.yml"
rm -f "$STACKORED_ROOT/stackored/docker-compose.dynamic.yml"
rm -f "$STACKORED_ROOT/stackored/docker-compose.projects.yml"
rm -f "$STACKORED_ROOT/stackored/core/traefik/traefik.yml"
rm -rf "$STACKORED_ROOT/stackored/core/traefik/dynamic/"
rm -rf "$STACKORED_ROOT/stackored/core/generated-configs/"

echo ""
echo -e "${GREEN}✔ Stackored başarıyla kaldırıldı!${NC}"
echo ""
echo "Kalan dosyalar:"
echo "  - Proje dosyaları (projects/)"
echo "  - SSL sertifikaları (core/certs/)"
echo "  - Konfigürasyon (.env)"
echo ""
echo "Bunları manuel olarak silebilirsiniz."
echo ""
