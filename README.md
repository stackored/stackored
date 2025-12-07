# Stackored - Shell Script Tabanlı Generator

## ✅ Başarıyla Kuruldu!

Stackored artık **PHP gerektirmeden** çalışıyor. Shell script tabanlı generator sayesinde dinamik Docker Compose dosyalarını oluşturabilirsiniz.

---

## 🚀 Hızlı Başlangıç

### 1. Docker Compose Dosyalarını Oluştur

```bash
./cli/stackored generate
```

Bu komut:

- `stackored.yml` - Base compose (Traefik + Network)
- `docker-compose.dynamic.yml` - Aktif servisleri içeren dinamik compose

dosyalarını `.env` ayarlarınıza göre oluşturur.

### 2. Sistemi Başlat

```bash
./cli/stackored up
```

### 3. Durumu Kontrol Et

```bash
./cli/stackored ps
```

### 4. Logları İzle

```bash
./cli/stackored logs        # Tüm servisler
./cli/stackored logs traefik # Sadece Traefik
```

### 5. Sistemi Durdur

```bash
./cli/stackored down
```

---

## 📦 Servis Ekleme

`.env` dosyasını düzenleyerek servisleri aktif edebilirsiniz:

```bash
# MySQL eklemek için
ENABLE_MYSQL=true

# Redis eklemek için
ENABLE_REDIS=true

# PostgreSQL eklemek için
ENABLE_POSTGRES=true
```

Sonra generator'ı tekrar çalıştırın:

```bash
./cli/stackored generate
./cli/stackored up
```

---

## 🌐 Erişim Noktaları

- **Traefik Dashboard**: http://localhost:8080
- **Web (HTTP)**: http://localhost:80
- **Web (HTTPS)**: https://localhost:443

### Aktif Edilebilecek Servisler:

| Servis        | .env Değişkeni              | Varsayılan Port        |
| ------------- | --------------------------- | ---------------------- |
| MySQL         | `ENABLE_MYSQL=true`         | 3306                   |
| Redis         | `ENABLE_REDIS=true`         | 6379                   |
| PostgreSQL    | `ENABLE_POSTGRES=true`      | 5432                   |
| MongoDB       | `ENABLE_MONGO=true`         | 27017                  |
| Memcached     | `ENABLE_MEMCACHED=true`     | 11211                  |
| RabbitMQ      | `ENABLE_RABBITMQ=true`      | 5672, 15672 (UI)       |
| Elasticsearch | `ENABLE_ELASTICSEARCH=true` | 9200, 9300             |
| Mailhog       | `ENABLE_MAILHOG=true`       | 1025 (SMTP), 8025 (UI) |

---

## 🔧 Değişiklikler

### PHP Dependency Kaldırıldı ✅

- ❌ **Eski**: PHP + Composer gerekiyordu
- ✅ **Yeni**: Sadece Bash + Docker yeterli

### Generator Shell Script'e Dönüştürüldü

- Dosya: `cli/generate.sh`
- `.env` dosyasını okur
- Template'leri işler
- Docker Compose dosyalarını dinamik oluşturur

### Traefik Konfigürasyonu Düzeltildi

- `core/traefik/traefik.yml` - HTTP section birleştirildi
- YAML syntax hataları giderildi

---

## 📝 Workflow

```
┌─────────────┐
│   .env      │ → Konfigürasyon
└──────┬──────┘
       │
       ↓
┌─────────────────┐
│  generate.sh    │ → Generator (Shell Script)
└──────┬──────────┘
       │
       ├──→ stackored.yml (Base)
       └──→ docker-compose.dynamic.yml (Dinamik Servisler)

       ↓
┌─────────────────┐
│  docker-compose │ → İki dosyayı merge eder
└──────┬──────────┘
       │
       ↓
    ✅ Çalışan Stack
```

---

## 🐛 Sorun Giderme

### Port Çakışması

Eğer port 80/443/8080 kullanılıyorsa:

```bash
./cli/stackored down
# Çakışan servisleri durdurun
sudo lsof -i :80
./cli/stackored up
```

### Network Hatası

```bash
docker network rm stackored-net
./cli/stackored generate  # Network'ü yeniden oluşturur
./cli/stackored up
```

### Container Yeniden Başlatma

```bash
./cli/stackored restart
```

---

## 🎯 Sonraki Adımlar

1. **Proje Ekle**: `projects/` dizinine yeni projeler ekleyin
2. **Template Geliştir**: `core/templates/` içinde yeni template'ler oluşturun
3. **Servis Genişlet**: `cli/generate.sh` içine yeni servisler ekleyin

---

## 📚 Dökümantasyon

- `CHANGELOG.md` - Değişiklik geçmişi
- `CONTRIBUTING.md` - Katkıda bulunma rehberi
- `stackored.yml` (root) - Global konfigürasyon

---

## ✨ Artık PHP Gerektirmiyor!

Stackored artık tamamen Docker tabanlı ve platform bağımsız çalışıyor.

**Kurulu sistem:**

- ✅ Traefik Reverse Proxy
- ✅ Docker Network (stackored-net)
- ✅ Dinamik Servis Yönetimi
- ✅ Shell Script Generator

**Geliştirici:** PHP bağımlılığı kaldırıldı, Shell script ile çalışıyor 🚀
