# 🚀 Stackored - Docker Tabanlı Geliştirme Ortamı Yönetim Sistemi

<div align="center">

**Modern, Esnek ve Güçlü Docker-based Development Stack Manager**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker)](https://www.docker.com/)
[![Traefik](https://img.shields.io/badge/Traefik-Reverse_Proxy-24A1C1?logo=traefikproxy)](https://traefik.io/)
[![Bash](https://img.shields.io/badge/Bash-3.x+-4EAA25?logo=gnubash)](https://www.gnu.org/software/bash/)

</div>

---

## 📋 İçindekiler

1. [Proje Hakkında](#-proje-hakkında)
2. [Temel Özellikler](#-temel-özellikler)
3. [Mimari ve Yapı](#-mimari-ve-yapı)
4. [Sistem Gereksinimleri](#-sistem-gereksinimleri)
5. [Hızlı Kurulum](#-hızlı-kurulum)
6. [Detaylı Kullanım](#-detaylı-kullanım)
7. [Konfigürasyon Sistemi](#-konfigürasyon-sistemi)
8. [Generator Sistemi](#-generator-sistemi)
9. [Desteklenen Servisler](#-desteklenen-servisler)
10. [Proje Yönetimi](#-proje-yönetimi)
11. [Traefik ve Routing](#-traefik-ve-routing)
12. [SSL/TLS Yapılandırması](#-ssltls-yapılandırması)
13. [CLI Komutları](#-cli-komutları)
14. [Gelişmiş Özellikler](#-gelişmiş-özellikler)
15. [Sorun Giderme](#-sorun-giderme)
16. [Katkıda Bulunma](#-katkıda-bulunma)

---

## 🎯 Proje Hakkında

**Stackored**, modern web geliştirme projeleriniz için Docker tabanlı, tamamen özelleştirilebilir ve modüler bir geliştirme ortamı yönetim sistemidir. PHP bağımlılığı olmadan, tamamen **Pure Bash** ile yazılmış generator sayesinde istediğiniz servisleri dinamik olarak yönetebilirsiniz.

### 🎭 Neden Stackored?

- ✅ **PHP Bağımlılığı Yok**: Tamamen Bash tabanlı, platform bağımsız
- ✅ **Tek Ağ Mimarisi**: Tüm servisler aynı Docker ağında, kolay iletişim
- ✅ **Traefik Entegrasyonu**: Otomatik reverse proxy, SSL/TLS desteği
- ✅ **Modüler Yapı**: İstediğiniz servisleri .env ile kolayca aktif/pasif edin
- ✅ **Multi-Project**: Birden fazla PHP projesini farklı versiyonlarla yönetin
- ✅ **Template Sistemi**: Kolay genişletilebilir, özelleştirilebilir
- ✅ **Zero-Config**: Varsayılan ayarlarla hemen çalışır
- ✅ **Production Ready**: Güvenli, test edilmiş konfigürasyonlar

---

## ✨ Temel Özellikler

### 🔧 Generator Sistemi
- **Pure Bash Generator**: PHP gerektirmeyen, hızlı ve güvenilir
- **Envsubst Entegrasyonu**: Template değişkenlerini otomatik işleme
- **Dinamik Compose Üretimi**: .env değişikliklerine göre otomatik dosya oluşturma
- **Akıllı Volume Yönetimi**: Sadece aktif servislerin volume'larını oluşturma

### 🌐 Traefik Reverse Proxy
- **Otomatik Route Keşfi**: Docker labelları üzerinden otomatik routing
- **SSL/TLS Desteği**: Self-signed ve Let's Encrypt sertifika desteği
- **HTTP → HTTPS Yönlendirme**: Otomatik güvenli protokol yönlendirme
- **Dashboard**: Web tabanlı monitoring ve yönetim arayüzü
- **Dynamic Config**: Çalışma anında route güncelleme

### 🗄️ Veritabanı Yönetimi
- **MySQL 8.0**: InnoDB, utf8mb4 optimizasyonlu
- **MariaDB 10.6**: MySQL alternatifi, yüksek performans
- **PostgreSQL 14**: İlişkisel veritabanı, ACID uyumlu
- **MongoDB 5.0**: NoSQL, document-based
- **Cassandra**: Dağıtık NoSQL
- **Percona**: MySQL fork, enterprise özellikleri
- **CouchDB**: Document store, REST API
- **Couchbase**: Distributed NoSQL

### ⚡ Cache ve Queue Sistemleri
- **Redis 7.0**: Key-value store, cache, pub/sub
- **Memcached 1.6**: Yüksek performanslı memory cache
- **RabbitMQ 3**: Message queue, AMQP protokolü
- **Apache ActiveMQ**: JMS uyumlu message broker
- **Kafka**: Dağıtık event streaming
- **NATS**: Lightweight messaging system

### 🔍 Arama ve İndeksleme
- **Elasticsearch 8.11**: Full-text search, analytics
- **Kibana 8.11**: ES için görselleştirme arayüzü
- **Meilisearch**: Hızlı, typo-tolerant arama
- **Solr**: Apache Lucene tabanlı arama motoru

### 📊 Monitoring ve Analiz
- **Grafana**: Metrik görselleştirme ve dashboard
- **Netdata**: Gerçek zamanlı sistem monitoring
- **SonarQube**: Kod kalitesi ve güvenlik analizi
- **Sentry**: Hata izleme ve raporlama
- **Logstash**: Log toplama ve işleme

### 🛠️ Geliştirici Araçları
- **MailHog**: Email yakalama ve test aracı
- **PhpMyAdmin**: MySQL/MariaDB web arayüzü
- **Adminer**: Hafif veritabanı yönetim arayüzü
- **PhpPgAdmin**: PostgreSQL web yönetimi
- **PhpMongo**: MongoDB web arayüzü
- **Composer**: PHP bağımlılık yöneticisi
- **Selenium**: Browser otomasyon testi

### 🏗️ Application Servers
- **Tomcat**: Java servlet container
- **Kong**: API Gateway ve mikroservis yönetimi

---

## 🏛️ Mimari ve Yapı

### 📐 Üç Katmanlı Docker Compose Sistemi

Stackored, Docker Compose'un merge özelliğini kullanarak üç farklı katmandan oluşur:

```
┌─────────────────────────────────────────────────────────┐
│                  stackored.yml                          │
│              (Base Layer - Traefik)                     │
│  • Traefik Reverse Proxy                                │
│  • stackored-net Network (172.30.0.0/16)                │
│  • Temel routing ve SSL yapılandırması                  │
└─────────────────────────────────────────────────────────┘
                         ↓ merge
┌─────────────────────────────────────────────────────────┐
│           docker-compose.dynamic.yml                    │
│         (Services Layer - Infrastructure)               │
│  • Veritabanları (MySQL, PostgreSQL, MongoDB...)        │
│  • Cache sistemleri (Redis, Memcached)                  │
│  • Message Queues (RabbitMQ, Kafka, ActiveMQ)           │
│  • Search Engines (Elasticsearch, Meilisearch)          │
│  • Monitoring Araçları (Grafana, Kibana, Netdata)       │
│  • QA Araçları (SonarQube, Sentry)                      │
│  • Application Servers (Tomcat, Kong)                   │
│  • Developer Tools (MailHog, Adminer, PhpMyAdmin)       │
└─────────────────────────────────────────────────────────┘
                         ↓ merge
┌─────────────────────────────────────────────────────────┐
│         docker-compose.projects.yml                     │
│          (Projects Layer - Applications)                │
│  • PHP-FPM Containers (project-name-php)                │
│  • Nginx/Apache Containers (project-name-web)           │
│  • Traefik routing labels                               │
│  • Project-specific volumes                             │
└─────────────────────────────────────────────────────────┘
                         ↓
              ✅ Tam Entegre Stack
```

### 🔄 Generator Workflow

Generator, `.env` dosyasındaki ayarlara göre Docker Compose dosyalarını dinamik olarak oluşturur:

```bash
┌─────────────┐
│   .env      │  → Konfigürasyon kaynağı
│             │     - MYSQL_ENABLE=true
│             │     - REDIS_ENABLE=true
└──────┬──────┘     - RABBITMQ_ENABLE=true
       │
       ↓
┌──────────────────────────────────────────────────┐
│     cli/stackored-generate.sh                    │
│     (Pure Bash Generator)                        │
│                                                  │
│  1. load_env()           → .env yükle           │
│  2. process_template()   → Template işle        │
│  3. include_module()     → Modül ekle           │
│  4. generate_*()         → Compose üret         │
└──────┬───────────────────────────────────────────┘
       │
       ├──→ stackored.yml              (Base)
       │    • Traefik configuration
       │    • Network definition
       │
       ├──→ docker-compose.dynamic.yml (Services)
       │    • Enabled services only
       │    • Auto-generated volumes
       │
       ├──→ docker-compose.projects.yml (Projects)
       │    • PHP-FPM containers
       │    • Nginx/Apache containers
       │
       └──→ core/traefik/routes.yml    (Routes)
            • Dynamic service routes
            • TLS configuration
```

### 🌐 Network Mimarisi

Tüm servisler tek bir Docker bridge network üzerinde çalışır:

```
stackored-net (172.30.0.0/16)
├── 172.30.0.1 (Gateway)
├── Traefik (Reverse Proxy)
├── MySQL (stackored-mysql)
├── Redis (stackored-redis)
├── RabbitMQ (stackored-rabbitmq)
├── Elasticsearch (stackored-elasticsearch)
├── Project1-PHP (project1-php)
├── Project1-Web (project1-web)
└── ... (diğer servisler)

İletişim:
→ Proje → PHP-FPM (project1-php:9000)
→ PHP → MySQL (stackored-mysql:3306)
→ PHP → Redis (stackored-redis:6379)
→ External → Traefik → Nginx → PHP
```

---

## 💻 Sistem Gereksinimleri

### Minimum Gereksinimler
- **Docker**: 20.10+
- **Docker Compose**: 2.0+ (v2 syntax)
- **Bash**: 3.2+ (macOS varsayılan)
- **Disk**: 10GB+ boş alan
- **RAM**: 4GB+ (servis sayısına bağlı)

### Önerilen Sistem
- **Docker**: 24.0+
- **RAM**: 8GB+
- **Disk**: 20GB+ SSD
- **CPU**: 4+ cores

### Platform Desteği
- ✅ **Linux**: Ubuntu 20.04+, Debian 11+, CentOS 8+
- ✅ **macOS**: 11+ (Big Sur ve üzeri)
- ✅ **Windows**: WSL2 üzerinden

---

## 🚀 Hızlı Kurulum

### 1. Projeyi Klonlayın

```bash
git clone https://github.com/your-username/stackored.git
cd stackored
```

### 2. CLI'yi Kurun (Opsiyonel)

```bash
cd stackored
./cli/install.sh
```

Bu komut `stackored` CLI'sini `/usr/local/bin/` dizinine sembolik link olarak ekler.

### 3. Konfigürasyonu Düzenleyin

```bash
# .env dosyasını düzenleyin
nano .env

# Temel ayarlar
DEFAULT_TLD_SUFFIX=stackored.loc
MYSQL_ENABLE=true
REDIS_ENABLE=true
POSTGRES_ENABLE=false
```

### 4. Docker Compose Dosyalarını Üretin

```bash
./cli/stackored generate
```

**Generator şunları yapar:**
- ✅ `.env` dosyasını okur
- ✅ `stackored.yml` oluşturur (Base)
- ✅ `docker-compose.dynamic.yml` oluşturur (Servisler)
- ✅ `docker-compose.projects.yml` oluşturur (Projeler)
- ✅ `core/traefik/routes.yml` oluşturur (Routing)
- ✅ `stackored-net` network'ü oluşturur

### 5. Servisleri Başlatın

```bash
./cli/stackored up
```

Bu komut üç compose dosyasını merge ederek tüm stack'i başlatır:

```bash
docker compose \
  -f stackored.yml \
  -f docker-compose.dynamic.yml \
  -f docker-compose.projects.yml \
  up -d
```

### 6. Durumu Kontrol Edin

```bash
./cli/stackored ps
```

### 7. Hosts Dosyasını Güncelleyin (Opsiyonel)

```bash
./cli/update-hosts.sh
```

Veya manuel olarak `/etc/hosts` dosyanıza ekleyin:

```
127.0.0.1  traefik.stackored.loc
127.0.0.1  adminer.stackored.loc
127.0.0.1  phpmyadmin.stackored.loc
127.0.0.1  project1.loc
127.0.0.1  project2.loc
```

---

## 📖 Detaylı Kullanım

### CLI Komutları

#### `generate` - Compose Dosyalarını Üret

```bash
./cli/stackored generate
```

**Ne Yapar:**
- `.env` dosyasını okur
- Template dosyalarını işler
- ENABLE_* değişkenlerine göre servisleri ekler
- Volume tanımlarını otomatik oluşturur
- Traefik route'larını üretir
- Projects dizinini tarar ve proje container'ları oluşturur

**Çıktı:**
```
[INFO] Stackored Generator (Bash - No PHP!)
[INFO] Loading environment...
[INFO] Generating traefik config...
[OK] Generated traefik config
[INFO] Generating traefik routes...
[INFO] Including: MYSQL_ENABLE
[INFO] Including: REDIS_ENABLE
[OK] Generated docker-compose.dynamic.yml
[INFO] Processing project: project1
[OK] Generated docker-compose.projects.yml
[OK] Generation completed!
```

#### `up` - Servisleri Başlat

```bash
./cli/stackored up
```

Tüm compose dosyalarını merge ederek detached modda başlatır.

#### `down` - Servisleri Durdur

```bash
./cli/stackored down
```

Tüm container'ları durdurur ve kaldırır. Volume'lar korunur.

#### `restart` - Servisleri Yeniden Başlat

```bash
./cli/stackored restart
```

Tüm container'ları yeniden başlatır.

#### `ps` - Çalışan Servisleri Listele

```bash
./cli/stackored ps
```

**Örnek Çıktı:**
```
NAME                      IMAGE                     STATUS
stackored-traefik         traefik:latest            Up 10 minutes
stackored-mysql           mysql:8.0                 Up 10 minutes
stackored-redis           redis:7.0                 Up 10 minutes
project1-php              php:8.2-fpm               Up 10 minutes
project1-web              nginx:alpine              Up 10 minutes
```

#### `logs` - Logları İzle

```bash
# Tüm servisler
./cli/stackored logs

# Belirli bir servis
./cli/stackored logs mysql
./cli/stackored logs traefik
./cli/stackored logs project1-php

# Follow modunda (gerçek zamanlı)
./cli/stackored logs -f mysql
```

#### `doctor` - Sistem Sağlık Kontrolü

```bash
./cli/stackored doctor
```

Sistem gereksinimlerini ve yapılandırmayı kontrol eder.

---

## ⚙️ Konfigürasyon Sistemi

### .env Dosya Yapısı

`.env` dosyası modüler bölümlere ayrılmıştır:

#### 1. Traefik Ayarları

```bash
# Global domain suffix
DEFAULT_TLD_SUFFIX=stackored.loc

# SSL/TLS
TRAEFIK_ENABLE_SSL=true
TRAEFIK_REDIRECT_TO_HTTPS=true

# Let's Encrypt (sadece public domain için)
TRAEFIK_ENABLE_LETSENCRYPT=false
TRAEFIK_EMAIL=admin@stackored.local
```

**Notlar:**
- `DEFAULT_TLD_SUFFIX`: Tüm servislerde kullanılacak domain soneki
- Let's Encrypt, `.loc` veya `.localhost` gibi local domainlerle **ÇALIŞMAZ**
- Self-signed sertifika için `./cli/generate-ssl-certs` komutunu kullanın

#### 2. Varsayılan Proje Ayarları

```bash
DEFAULT_PHP_VERSION=8.2
DEFAULT_WEBSERVER=nginx
DEFAULT_DOCUMENT_ROOT=public
```

Bu ayarlar, `stackored.json` içinde tanımlanmamış projeler için kullanılır.

#### 3. Veritabanı Ayarları

##### MySQL

```bash
MYSQL_ENABLE=true
MYSQL_VERSION=8.0
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=stackored
MYSQL_USER=stackored
MYSQL_PASSWORD=stackored
```

**Bağlantı:**
- Host: `stackored-mysql` (container içinden)
- Host: `localhost:3306` (host'tan)
- Root: `root` / `root`
- User: `stackored` / `stackored`

##### PostgreSQL

```bash
POSTGRES_ENABLE=true
POSTGRES_VERSION=14
POSTGRES_PASSWORD=root
POSTGRES_DB=stackored
POSTGRES_USER=stackored
```

**Bağlantı:**
- Host: `stackored-postgres`
- Port: `5432`
- Database: `stackored`
- User: `stackored` / `root`

##### MongoDB

```bash
MONGO_ENABLE=true
MONGO_VERSION=5.0
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD=root
```

**Connection String:**
```
mongodb://root:root@stackored-mongo:27017/stackored?authSource=admin
```

#### 4. Cache Ayarları

##### Redis

```bash
REDIS_ENABLE=true
REDIS_VERSION=7.0
REDIS_PASSWORD=
```

**Bağlantı:**
- Host: `stackored-redis`
- Port: `6379`
- Password: (boş - opsiyonel)

##### Memcached

```bash
MEMCACHED_ENABLE=true
MEMCACHED_VERSION=1.6
MEMCACHED_MEMORY=256
MEMCACHED_CONNECTIONS=1024
MEMCACHED_THREADS=4
```

**Bağlantı:**
- Host: `stackored-memcached`
- Port: `11211`

#### 5. Message Queue Ayarları

##### RabbitMQ

```bash
RABBITMQ_ENABLE=true
RABBITMQ_VERSION=3
RABBITMQ_URL=rabbitmq
RABBITMQ_DEFAULT_USER=admin
RABBITMQ_DEFAULT_PASS=admin
```

**Erişim:**
- AMQP: `amqp://admin:admin@stackored-rabbitmq:5672/`
- Management UI: `http://rabbitmq.stackored.loc` (Traefik üzerinden)
- Direct: `http://localhost:15672`

##### Apache ActiveMQ

```bash
ACTIVEMQ_ENABLE=true
ACTIVEMQ_VERSION=latest
ACTIVEMQ_URL=activemq
ACTIVEMQ_ADMIN_USER=admin
ACTIVEMQ_ADMIN_PASSWORD=admin

# Port Konfigürasyonu (conflict önleme)
HOST_PORT_ACTIVEMQ_OPENWIRE=61616
HOST_PORT_ACTIVEMQ_AMQP=5673      # RabbitMQ conflict
HOST_PORT_ACTIVEMQ_STOMP=61613
HOST_PORT_ACTIVEMQ_MQTT=1883
HOST_PORT_ACTIVEMQ_WS=61614
HOST_PORT_ACTIVEMQ_UI=8161
```

**Erişim:**
- Web Console: `http://activemq.stackored.loc`
- Direct: `http://localhost:8161`
- Login: `admin` / `admin`

##### Kafka

```bash
KAFKA_ENABLE=false
KAFKA_VERSION=latest
HOST_PORT_KAFKA=9094
HOST_PORT_KAFKA_EXTERNAL=29094
```

**Kafka UI (Kafbat):**
```bash
KAFBAT_ENABLE=true
KAFBAT_VERSION=latest
KAFBAT_URL=kafbat
KAFBAT_CLUSTER_NAME=stackored-kafka
KAFBAT_KAFKA_BOOTSTRAP=stackored-kafka:9092
```

#### 6. Arama ve Analitik

##### Elasticsearch

```bash
ELASTICSEARCH_ENABLE=true
ELASTICSEARCH_VERSION=8.11.3
ES_JAVA_OPTS=-Xms1g -Xmx1g
ELASTIC_SECURITY=false
```

**Erişim:**
- HTTP: `http://stackored-elasticsearch:9200`
- Transport: `stackored-elasticsearch:9300`
- Health: `curl http://localhost:9200/_cluster/health`

##### Kibana

```bash
KIBANA_ENABLE=true
KIBANA_VERSION=8.11.3
KIBANA_URL=kibana
KIBANA_ELASTICSEARCH_HOSTS=http://stackored-elasticsearch:9200
```

**Erişim:**
- Web: `http://kibana.stackored.loc`
- Direct: `http://localhost:5601`

##### Meilisearch

```bash
MEILISEARCH_ENABLE=true
MEILISEARCH_VERSION=latest
MEILISEARCH_URL=meilisearch
MEILISEARCH_MASTER_KEY=stackored-master-key-change-me
```

**API Erişim:**
```bash
curl http://localhost:7700/health \
  -H "Authorization: Bearer stackored-master-key-change-me"
```

#### 7. Monitoring ve QA

##### Grafana

```bash
GRAFANA_ENABLE=true
GRAFANA_VERSION=latest
GRAFANA_URL=grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
```

**Erişim:**
- Web: `http://grafana.stackored.loc`
- Login: `admin` / `admin`

##### Netdata

```bash
NETDATA_ENABLE=true
NETDATA_VERSION=latest
NETDATA_URL=netdata
```

**Erişim:**
- Dashboard: `http://netdata.stackored.loc`
- Direct: `http://localhost:19999`

##### SonarQube

```bash
SONARQUBE_ENABLE=true
SONARQUBE_VERSION=latest
SONARQUBE_URL=sonarqube
SONARQUBE_ADMIN_USER=admin
SONARQUBE_ADMIN_PASSWORD=admin
```

**Erişim:**
- Web: `http://sonarqube.stackored.loc`
- Direct: `http://localhost:9000`
- Default Login: `admin` / `admin`

##### Sentry

```bash
SENTRY_ENABLE=true
SENTRY_VERSION=latest
SENTRY_URL=sentry
SENTRY_ADMIN_EMAIL=admin@stackored.local
SENTRY_ADMIN_PASSWORD=admin
SENTRY_SECRET_KEY=stackored-sentry-secret-key-change-me
SENTRY_DB_PASSWORD=sentry
```

**Not:** Sentry kendi Redis ve PostgreSQL instance'larını oluşturur:
- `sentry-redis`
- `sentry-postgres`

#### 8. Developer Tools

##### MailHog

```bash
MAILHOG_ENABLE=true
MAILHOG_VERSION=latest
MAILHOG_URL=mailhog
```

**Kullanım:**
- SMTP: `stackored-mailhog:1025`
- Web UI: `http://mailhog.stackored.loc`
- Direct: `http://localhost:8025`

**PHP Konfigürasyonu:**
```ini
sendmail_path = "/usr/sbin/sendmail -S stackored-mailhog:1025"
```

##### Tools Container (PhpMyAdmin, Adminer, vb.)

```bash
TOOLS_CONTAINER_ENABLE=true
TOOLS_CONTAINER_URL=toolstest

# Individual tool URLs
ADMINER_ENABLE=true
ADMINER_URL=adminer

PHPMYADMIN_ENABLE=true
PHPMYADMIN_URL=phpmyadmin

PHPPGADMIN_ENABLE=true
PHPPGADMIN_URL=phppgadmin

PHPMONGO_ENABLE=true
PHPMONGO_URL=phpmongo

OPCACHE_ENABLE=true
OPCACHE_URL=opcache
```

**Erişim:**
- Adminer: `http://adminer.stackored.loc`
- PhpMyAdmin: `http://phpmyadmin.stackored.loc`
- PhpPgAdmin: `http://phppgadmin.stackored.loc`

#### 9. Application Servers

##### Tomcat

```bash
TOMCAT_ENABLE=true
TOMCAT_VERSION=latest
TOMCAT_URL=tomcat
TOMCAT_ADMIN_USER=admin
TOMCAT_ADMIN_PASSWORD=admin
HOST_PORT_TOMCAT=8081
```

**Erişim:**
- Manager: `http://tomcat.stackored.loc/manager`
- Direct: `http://localhost:8081`

##### Kong API Gateway

```bash
KONG_ENABLE=true
KONG_VERSION=latest
KONG_URL=kong
KONG_ADMIN_URL=kong-admin
KONG_DATABASE=off  # DB-less mode
```

**Erişim:**
- Proxy: `http://localhost:8000`
- Admin API: `http://localhost:8001`
- Admin UI: `http://kong-admin.stackored.loc`

#### 10. Docker ve Network Ayarları

```bash
DOCKER_DEFAULT_NETWORK=stackored-net
DOCKER_PRUNE_ON_REBUILD=false
DOCKER_FORCE_RECREATE=true
DOCKER_REMOVE_ORPHANS=true
```

#### 11. Host System Mappings

```bash
HOST_USER_ID=1000
HOST_GROUP_ID=1000
HOST_TIMEZONE=Europe/Istanbul
```

Bu ayarlar container içindeki user/group ID'lerini host ile eşleştirir.

#### 12. Port Mappings

Bazı servisler için custom port tanımlamaları:

```bash
HOST_PORT_POSTGRES=5433      # PostgreSQL (conflict önleme)
HOST_PORT_PERCONA=3308       # Percona (MySQL conflict)
HOST_PORT_ADMINER=8082       # Adminer
HOST_PORT_KAFKA=9094         # Kafka
HOST_PORT_KAFKA_EXTERNAL=29094
```

---

## 🔨 Generator Sistemi

### Generator Nasıl Çalışır?

`cli/stackored-generate.sh` dosyası, tüm Stackored sisteminin kalbidir. Pure Bash ile yazılmıştır ve aşağıdaki işlemleri gerçekleştirir:

#### 1. Environment Loading (`load_env`)

```bash
load_env() {
    log_info "Loading environment..."
    [ ! -f "$ROOT_DIR/.env" ] && { log_error ".env not found"; exit 1; }
    set -a
    source "$ROOT_DIR/.env"
    set +a
}
```

- `.env` dosyasını kontrol eder
- `set -a` ile tüm değişkenleri export eder
- `source` ile değişkenleri yükler

#### 2. Template Processing (`process_template`)

```bash
process_template() {
    local template_file=$1
    [ ! -f "$template_file" ] && return 1

    # {{ VAR }} → ${VAR} dönüşümü
    # {{ VAR | default('x') }} → ${VAR:-x} dönüşümü
    sed -e 's/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*}}/${\1}/g' \
        -e "s/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*|[[:space:]]*default('\([^']*\)')[[:space:]]*}}/\${\1:-\2}/g" \
        "$template_file" | envsubst
}
```

**Template Syntax:**
- `{{ MYSQL_VERSION }}` → Basit değişken
- `{{ MYSQL_ROOT_PASSWORD | default('root') }}` → Varsayılan değerle

**Dönüşüm Adımları:**
1. Template sözdizimini `envsubst` uyumlu hale getirir
2. `envsubst` komutuyla değişkenleri değerlendirir
3. İşlenmiş içeriği döndürür

#### 3. Module Inclusion (`include_module`)

```bash
include_module() {
    local enable_var=$1        # Örn: MYSQL_ENABLE
    local template_path=$2     # Örn: database/mysql/docker-compose.mysql.tpl
    local full_path="$ROOT_DIR/core/templates/$template_path"

    # ENABLE değişkenini kontrol et
    eval "local enabled=\${${enable_var}:-false}"

    if [ "$enabled" = "true" ] && [ -f "$full_path" ]; then
        log_info "Including: $enable_var"

        # Template'i işle ve compose dosyasına ekle
        process_template "$full_path" | \
            awk '...'  # Formatting ve filtreleme

        echo ""
    fi
}
```

**Akıllı Filtreleme:**
- Comment satırlarını (`#`) atlar
- `services:` başlığını duplike etmez
- `volumes:` bölümünü ana dosyaya taşır
- Indentationu düzeltir

#### 4. Dynamic Compose Generation (`generate_dynamic_compose`)

```bash
generate_dynamic_compose() {
    log_info "Generating docker-compose.dynamic.yml..."

    local output="$ROOT_DIR/docker-compose.dynamic.yml"
    echo "services:" > "$output"
    echo "" >> "$output"

    # Her kategori için modülleri dahil et
    include_module "MYSQL_ENABLE" "database/mysql/docker-compose.mysql.tpl" >> "$output"
    include_module "REDIS_ENABLE" "cache/redis/docker-compose.redis.tpl" >> "$output"
    # ... diğer servisler

    # Volume section ekle
    echo "volumes:" >> "$output"
    # ... volume tanımları
}
```

#### 5. Traefik Route Generation (`generate_traefik_routes`)

```bash
generate_traefik_routes() {
    log_info "Generating traefik routes..."

    local output="$ROOT_DIR/core/traefik/routes.yml"

    cat > "$output" <<EOF
http:
  routers:
EOF

    # Her aktif servis için router ekle
    add_router_if_enabled "RABBITMQ_ENABLE" "rabbitmq" "RABBITMQ_URL" >> "$output"
    add_router_if_enabled "MAILHOG_ENABLE" "mailhog" "MAILHOG_URL" >> "$output"
    # ...

    # Services section
    cat >> "$output" <<EOF

  services:
EOF

    add_service_if_enabled "RABBITMQ_ENABLE" "rabbitmq" "15672" >> "$output"
    # ...
}
```

**Router Format:**
```yaml
rabbitmq:
  rule: "Host(`rabbitmq.stackored.loc`)"
  entryPoints:
    - websecure
  service: rabbitmq
  tls: {}
```

**Service Format:**
```yaml
rabbitmq:
  loadBalancer:
    servers:
      - url: "http://stackored-rabbitmq:15672"
```

#### 6. Project Generation (`generate_projects`)

```bash
generate_projects() {
    log_info "Generating project containers..."

    local output="$ROOT_DIR/docker-compose.projects.yml"
    local projects_dir="$ROOT_DIR/projects"

    echo "services:" > "$output"

    # Her proje dizinini tara
    for project_path in "$projects_dir"/*; do
        [ ! -d "$project_path" ] && continue

        local project_name=$(basename "$project_path")
        local project_json="$project_path/stackored.json"

        # stackored.json yoksa atla
        [ ! -f "$project_json" ] && continue

        # JSON parse (grep + cut ile)
        local php_version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | head -1 | cut -d'"' -f4)
        local web_server=$(grep -o '"webserver"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | cut -d'"' -f4)
        local project_domain=$(grep -o '"domain"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | cut -d'"' -f4)

        # PHP container oluştur
        cat >> "$output" <<EOF
  ${project_name}-php:
    image: "php:${php_version:-8.2}-fpm"
    container_name: "${project_name}-php"
    volumes:
      - ${project_path}:/var/www/html
    networks:
      - ${DOCKER_DEFAULT_NETWORK}
EOF

        # Web server container oluştur
        if [ "$web_server" = "nginx" ]; then
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "nginx:alpine"
    container_name: "${project_name}-web"
    volumes:
      - ${project_path}:/var/www/html
      - ${project_path}/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - ${DOCKER_DEFAULT_NETWORK}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${project_name}.rule=Host(\`${project_domain}\`)"
      - "traefik.http.routers.${project_name}.entrypoints=websecure"
      - "traefik.http.routers.${project_name}.tls=true"
      - "traefik.http.services.${project_name}.loadbalancer.server.port=80"
    depends_on:
      - ${project_name}-php
EOF
        fi
    done
}
```

### Template Dizin Yapısı

```
core/templates/
├── database/
│   ├── mysql/
│   │   ├── docker-compose.mysql.tpl
│   │   └── my.cnf.tpl
│   ├── postgres/
│   │   ├── docker-compose.postgres.tpl
│   │   └── postgres.conf.tpl
│   └── mongo/
│       ├── docker-compose.mongo.tpl
│       └── mongo.conf.tpl
├── cache/
│   ├── redis/
│   │   ├── docker-compose.redis.tpl
│   │   └── redis.conf
│   └── memcached/
│       └── docker-compose.memcached.tpl
├── messaging/
│   ├── rabbitmq/
│   │   └── docker-compose.rabbitmq.tpl
│   └── kafka/
│       └── docker-compose.kafka.tpl
└── ...
```

### Template Örneği

**`core/templates/database/mysql/docker-compose.mysql.tpl`:**

```yaml
###################################################################
# STACKORED MYSQL COMPOSE TEMPLATE
###################################################################

services:
  mysql:
    image: "mysql:{{ MYSQL_VERSION }}"
    container_name: "stackored-mysql"
    restart: unless-stopped

    environment:
      MYSQL_ROOT_PASSWORD: "{{ MYSQL_ROOT_PASSWORD | default('root') }}"
      MYSQL_DATABASE: "{{ MYSQL_DATABASE | default('stackored') }}"
      MYSQL_USER: "{{ MYSQL_USER | default('stackored') }}"
      MYSQL_PASSWORD: "{{ MYSQL_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-mysql-data:/var/lib/mysql
      - ./core/templates/database/mysql/my.cnf:/etc/mysql/conf.d/stackored.cnf:ro

    command: >
      mysqld
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --skip-character-set-client-handshake

ports:
- "{{ HOST_PORT_MYSQL | default('3306') }}:3306"

networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-mysql-data:
```

**İşlendikten Sonra (`docker-compose.dynamic.yml`):**

```yaml
  mysql:
    image: "mysql:8.0"
    container_name: "stackored-mysql"
    restart: unless-stopped

    environment:
      MYSQL_ROOT_PASSWORD: "root"
      MYSQL_DATABASE: "stackored"
      MYSQL_USER: "stackored"
      MYSQL_PASSWORD: "stackored"

    volumes:
      - stackored-mysql-data:/var/lib/mysql
      - ./core/templates/database/mysql/my.cnf:/etc/mysql/conf.d/stackored.cnf:ro

    command: >
      mysqld
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --skip-character-set-client-handshake

    ports:
      - "3306:3306"

    networks:
      - "stackored-net"
```

---

## 📦 Desteklenen Servisler

### Tam Liste

| Kategori | Servis | Versiyon | Port(lar) | Container Adı |
|----------|--------|----------|-----------|---------------|
| **Veritabanları** |
| | MySQL | 8.0 | 3306 | stackored-mysql |
| | MariaDB | 10.6 | 3307 | stackored-mariadb |
| | PostgreSQL | 14 | 5432 | stackored-postgres |
| | MongoDB | 5.0 | 27017 | stackored-mongo |
| | Cassandra | latest | 9042 | stackored-cassandra |
| | Percona | latest | 3308 | stackored-percona |
| | CouchDB | latest | 5984 | stackored-couchdb |
| | Couchbase | latest | 8091-8096 | stackored-couchbase |
| **Cache** |
| | Redis | 7.0 | 6379 | stackored-redis |
| | Memcached | 1.6 | 11211 | stackored-memcached |
| **Message Queues** |
| | RabbitMQ | 3 | 5672, 15672 | stackored-rabbitmq |
| | Apache ActiveMQ | latest | 61616, 8161 | stackored-activemq |
| | Kafka | latest | 9092, 9094 | stackored-kafka |
| | NATS | latest | 4222, 8222 | stackored-nats |
| **Search** |
| | Elasticsearch | 8.11.3 | 9200, 9300 | stackored-elasticsearch |
| | Kibana | 8.11.3 | 5601 | stackored-kibana |
| | Meilisearch | latest | 7700 | stackored-meilisearch |
| | Solr | latest | 8983 | stackored-solr |
| **Monitoring** |
| | Grafana | latest | 3001 | stackored-grafana |
| | Netdata | latest | 19999 | stackored-netdata |
| | Logstash | 8.11.3 | 5044, 9600 | stackored-logstash |
| **QA** |
| | SonarQube | latest | 9000 | stackored-sonarqube |
| | Sentry | latest | 9001 | stackored-sentry |
| | Blackfire | latest | - | stackored-blackfire |
| **App Servers** |
| | Tomcat | latest | 8081 | stackored-tomcat |
| | Kong | latest | 8000, 8001 | stackored-kong |
| **Dev Tools** |
| | MailHog | latest | 1025, 8025 | stackored-mailhog |
| | Selenium | latest | 4444 | stackored-selenium |
| | Ngrok | latest | 4040 | stackored-ngrok |
| **Admin Tools** |
| | Tools Container | custom | 80 | stackored-tools |
| | Adminer | latest | - | (via tools) |
| | PhpMyAdmin | latest | - | (via tools) |
| | PhpPgAdmin | latest | - | (via tools) |
| | PhpMongo | latest | - | (via tools) |

---

## 🗂️ Proje Yönetimi

### Proje Dizin Yapısı

```
projects/
├── project1/
│   ├── stackored.json      # Proje konfigürasyonu
│   ├── nginx.conf          # Nginx yapılandırması
│   ├── public/             # Document root
│   │   └── index.php
│   ├── src/
│   ├── vendor/
│   └── composer.json
├── project2/
│   ├── stackored.json
│   ├── nginx.conf
│   └── ...
└── project3/
    └── ...
```

### stackored.json Yapısı

Her proje `stackored.json` dosyasında tanımlanır:

```json
{
  "name": "project1",
  "domain": "project1.loc",
  "php": {
    "version": "8.2",
    "extensions": [
      "pdo",
      "pdo_mysql",
      "mysqli",
      "gd",
      "curl",
      "zip",
      "mbstring",
      "intl",
      "redis"
    ]
  },
  "webserver": "nginx",
  "document_root": "public"
}
```

**Alan Açıklamaları:**

| Alan | Tip | Açıklama | Varsayılan |
|------|-----|----------|------------|
| `name` | string | Proje adı (container prefix) | - |
| `domain` | string | Erişim domaini | `{name}.{DEFAULT_TLD_SUFFIX}` |
| `php.version` | string | PHP versiyonu (7.4, 8.0, 8.1, 8.2, 8.3, 8.4) | `DEFAULT_PHP_VERSION` |
| `php.extensions` | array | PHP extension listesi | `[]` |
| `webserver` | string | Web server (nginx/apache) | `DEFAULT_WEBSERVER` |
| `document_root` | string | Belge kök dizini | `DEFAULT_DOCUMENT_ROOT` |

### Proje Ekleme

#### 1. Manuel Proje Oluşturma

```bash
# Proje dizini oluştur
mkdir -p projects/myproject/public

# stackored.json oluştur
cat > projects/myproject/stackored.json << 'EOF'
{
  "name": "myproject",
  "domain": "myproject.loc",
  "php": {
    "version": "8.2",
    "extensions": ["pdo_mysql", "redis"]
  },
  "webserver": "nginx",
  "document_root": "public"
}
EOF

# nginx.conf oluştur
cat > projects/myproject/nginx.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass myproject-php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Test index.php
cat > projects/myproject/public/index.php << 'EOF'
<?php
phpinfo();
EOF
```

#### 2. Generator'ı Çalıştır

```bash
./cli/stackored generate
```

Generator otomatik olarak:
- ✅ `myproject-php` container'ını oluşturur (PHP 8.2 FPM)
- ✅ `myproject-web` container'ını oluşturur (Nginx)
- ✅ Traefik routing labels ekler
- ✅ Volume mount'ları yapılandırır

#### 3. Servisleri Yeniden Başlat

```bash
./cli/stackored down
./cli/stackored up
```

#### 4. Hosts Dosyasına Ekle

```bash
echo "127.0.0.1  myproject.loc" | sudo tee -a /etc/hosts
```

#### 5. Tarayıcıda Aç

```
http://myproject.loc
```

veya SSL aktifse:

```
https://myproject.loc
```

### Nginx Konfigürasyonu

#### Laravel/Symfony Projesi

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php index.html;

    # Laravel routing
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPM
    location ~ \.php$ {
        fastcgi_pass PROJECT_NAME-php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;

        # Laravel specific
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }

    # Security
    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### WordPress Projesi

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html;

    # WordPress permalinks
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # PHP-FPM
    location ~ \.php$ {
        fastcgi_pass PROJECT_NAME-php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }

    # WordPress admin
    location /wp-admin {
        try_files $uri $uri/ /wp-admin/index.php;
    }

    # Deny access
    location ~ /\.ht {
        deny all;
    }

    location ~* /(?:uploads|files)/.*\.php$ {
        deny all;
    }

    # Cache static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        log_not_found off;
    }
}
```

### PHP Extensions Yükleme

Varsayılan PHP-FPM imajları minimal extension'larla gelir. Ekstra extension'lar için custom Dockerfile gerekir:

#### Custom PHP Dockerfile

```bash
mkdir -p projects/myproject/.docker
```

**`projects/myproject/.docker/Dockerfile`:**

```dockerfile
FROM php:8.2-fpm

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    mysqli \
    gd \
    zip \
    intl \
    opcache \
    bcmath

# Redis extension (PECL)
RUN pecl install redis && docker-php-ext-enable redis

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PHP configuration
COPY .docker/php.ini /usr/local/etc/php/conf.d/stackored.ini

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
```

**`projects/myproject/.docker/php.ini`:**

```ini
; Performance
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=1

; Upload
upload_max_filesize=64M
post_max_size=64M

; Memory
memory_limit=512M

; Timezone
date.timezone=Europe/Istanbul

; Error reporting
display_errors=On
error_reporting=E_ALL

; Session
session.gc_maxlifetime=86400
```

**stackored.json'ı güncelle:**

```json
{
  "name": "myproject",
  "domain": "myproject.loc",
  "php": {
    "dockerfile": ".docker/Dockerfile",
    "version": "8.2"
  },
  "webserver": "nginx",
  "document_root": "public"
}
```

### Proje Arasında Servis İletişimi

Tüm container'lar `stackored-net` networkünde olduğu için birbirleriyle container adlarıyla iletişim kurabilir:

**PHP'den MySQL'e bağlanma:**

```php
<?php
$host = 'stackored-mysql';  // Container adı
$port = 3306;
$dbname = 'stackored';
$user = 'stackored';
$pass = 'stackored';

try {
    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
        $user,
        $pass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
    echo "Bağlantı başarılı!";
} catch (PDOException $e) {
    echo "Bağlantı hatası: " . $e->getMessage();
}
```

**Laravel .env:**

```env
DB_CONNECTION=mysql
DB_HOST=stackored-mysql
DB_PORT=3306
DB_DATABASE=stackored
DB_USERNAME=stackored
DB_PASSWORD=stackored

REDIS_HOST=stackored-redis
REDIS_PASSWORD=null
REDIS_PORT=6379

QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

---

## 🌐 Traefik ve Routing

### Traefik Yapılandırması

Stackored, Traefik v2+ kullanarak otomatik reverse proxy ve routing sağlar.

#### Traefik Entrypoints

```yaml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https    # SSL aktifse

  websecure:
    address: ":443"
    http:
      tls: {}
```

**Davranış:**
- `:80` → HTTP trafiği
- `:443` → HTTPS trafiği (SSL aktifse)
- HTTP → HTTPS otomatik yönlendirme (`TRAEFIK_REDIRECT_TO_HTTPS=true` ise)

#### Dynamic Configuration

Traefik, route'ları iki kaynaktan alır:

1. **Docker Labels** (Projeler için)
2. **File Provider** (`core/traefik/dynamic/routes.yml` - Servisler için)

**Docker Labels Örneği:**

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.project1.rule=Host(`project1.loc`)"
  - "traefik.http.routers.project1.entrypoints=websecure"
  - "traefik.http.routers.project1.tls=true"
  - "traefik.http.services.project1.loadbalancer.server.port=80"
```

**File Provider Örneği (`routes.yml`):**

```yaml
http:
  routers:
    rabbitmq:
      rule: "Host(`rabbitmq.stackored.loc`)"
      entryPoints:
        - websecure
      service: rabbitmq
      tls: {}

    mailhog:
      rule: "Host(`mailhog.stackored.loc`)"
      entryPoints:
        - websecure
      service: mailhog
      tls: {}

  services:
    rabbitmq:
      loadBalancer:
        servers:
          - url: "http://stackored-rabbitmq:15672"

    mailhog:
      loadBalancer:
        servers:
          - url: "http://stackored-mailhog:8025"
```

### Traefik Dashboard

Traefik dashboard'u insecure modda çalışır (geliştirme ortamı için):

**Erişim:**
```
http://localhost:8080
```

**Dashboard Özellikleri:**
- ✅ Aktif router'ları görüntüleme
- ✅ Service health durumu
- ✅ Middleware yapılandırması
- ✅ Real-time metrics
- ✅ Request/response detayları

### Custom Routes Ekleme

Yeni bir servis için custom route eklemek:

#### 1. Template Oluştur

**`core/templates/myservice/docker-compose.myservice.tpl`:**

```yaml
services:
  myservice:
    image: "myservice:latest"
    container_name: "stackored-myservice"
    restart: unless-stopped
    ports:
      - "8080:8080"
    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
```

#### 2. .env'e Ekle

```bash
MYSERVICE_ENABLE=true
MYSERVICE_URL=myservice
```

#### 3. Generator'a Ekle

**`cli/stackored-generate.sh`** içinde:

```bash
# generate_dynamic_compose fonksiyonuna ekle
include_module "MYSERVICE_ENABLE" "myservice/docker-compose.myservice.tpl" >> "$output"
```

```bash
# generate_traefik_routes fonksiyonuna ekle
add_router_if_enabled "MYSERVICE_ENABLE" "myservice" "MYSERVICE_URL" >> "$output"
add_service_if_enabled "MYSERVICE_ENABLE" "myservice" "8080" >> "$output"
```

#### 4. Generate ve Restart

```bash
./cli/stackored generate
./cli/stackored down
./cli/stackored up
```

---

## 🔐 SSL/TLS Yapılandırması

### Self-Signed Sertifika Oluşturma

Local geliştirme için self-signed sertifika:

```bash
./cli/generate-ssl-certs
```

**Bu komut şunları oluşturur:**
- `core/certs/stackored-ca.crt` - CA sertifikası (tarayıcıya import edilecek)
- `core/certs/stackored-ca.key` - CA private key
- `core/certs/stackored-wildcard.crt` - Wildcard sertifika (`*.stackored.loc`)
- `core/certs/stackored-wildcard.key` - Wildcard private key

### CA Sertifikası Import Etme

#### macOS

```bash
sudo security add-trusted-cert -d \
  -r trustRoot \
  -k /Library/Keychains/System.keychain \
  core/certs/stackored-ca.crt
```

#### Ubuntu/Debian

```bash
sudo cp core/certs/stackored-ca.crt /usr/local/share/ca-certificates/stackored-ca.crt
sudo update-ca-certificates
```

#### Windows

1. `stackored-ca.crt` dosyasına çift tıklayın
2. "Install Certificate" → "Local Machine"
3. "Place all certificates in the following store"
4. "Trusted Root Certification Authorities" seçin
5. "Finish"

#### Firefox

1. Preferences → Privacy & Security → Certificates → View Certificates
2. Authorities tab → Import
3. `stackored-ca.crt` dosyasını seçin
4. "Trust this CA to identify websites" işaretleyin

### Let's Encrypt (Production)

**UYARI:** Let's Encrypt, `.loc`, `.localhost`, veya özel TLD'lerle **ÇALIŞMAZ**. Sadece public domainler için geçerlidir.

#### .env Konfigürasyonu

```bash
TRAEFIK_ENABLE_SSL=true
TRAEFIK_ENABLE_LETSENCRYPT=true
TRAEFIK_EMAIL=admin@example.com
DEFAULT_TLD_SUFFIX=example.com
```

#### Traefik Configuration

Generator otomatik olarak Let's Encrypt konfigürasyonunu ekler:

```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

#### DNS Kayıtları

Domain'inizi sunucunuza yönlendirin:

```
A    @                 1.2.3.4
A    *.stackored       1.2.3.4
A    traefik           1.2.3.4
A    project1          1.2.3.4
```

---

## 🎛️ CLI Komutları

### Tam Komut Listesi

```bash
./cli/stackored <command> [options]
```

| Komut | Açıklama | Örnek |
|-------|----------|-------|
| `generate` | Compose dosyalarını üret | `./cli/stackored generate` |
| `up` | Servisleri başlat | `./cli/stackored up` |
| `down` | Servisleri durdur | `./cli/stackored down` |
| `restart` | Servisleri yeniden başlat | `./cli/stackored restart` |
| `ps` | Çalışan servisleri listele | `./cli/stackored ps` |
| `logs [service]` | Logları görüntüle | `./cli/stackored logs mysql` |
| `doctor` | Sistem kontrolü | `./cli/stackored doctor` |

### Global Kurulum (Opsiyonel)

CLI'yi sistem geneline kurmak için:

```bash
./cli/install.sh
```

Bu, `/usr/local/bin/stackored` sembolik linkini oluşturur. Artık herhangi bir dizinden:

```bash
stackored generate
stackored up
stackored ps
```

### Docker Compose Komutları

Stackored CLI, Docker Compose wrapper'ıdır. Manuel Docker Compose komutları da çalışır:

```bash
# Manuel up
docker compose \
  -f stackored.yml \
  -f docker-compose.dynamic.yml \
  -f docker-compose.projects.yml \
  up -d

# Belirli servisleri başlat
docker compose \
  -f stackored.yml \
  -f docker-compose.dynamic.yml \
  -f docker-compose.projects.yml \
  up -d mysql redis

# Force recreate
docker compose \
  -f stackored.yml \
  -f docker-compose.dynamic.yml \
  -f docker-compose.projects.yml \
  up -d --force-recreate

# Belirli servisi rebuild
docker compose \
  -f stackored.yml \
  -f docker-compose.dynamic.yml \
  -f docker-compose.projects.yml \
  up -d --build project1-php
```

---

## 🚀 Gelişmiş Özellikler

### Environment Override

Farklı ortamlar için farklı `.env` dosyaları:

```bash
# Development
cp .env .env.development

# Production
cp .env .env.production

# Kullanım
cp .env.production .env
./cli/stackored generate
./cli/stackored up
```

### Docker Compose Override

Kişisel ayarlarınız için override dosyası:

**`docker-compose.override.yml`:**

```yaml
services:
  mysql:
    ports:
      - "33060:3306"  # Custom port
    environment:
      MYSQL_SLOW_QUERY_LOG: 1

  project1-php:
    volumes:
      - ./custom-php.ini:/usr/local/etc/php/conf.d/custom.ini:ro
```

Docker Compose otomatik olarak override dosyasını merge eder.

### Custom Networks

Birden fazla network kullanma:

```yaml
services:
  sensitive-service:
    networks:
      - stackored-net
      - private-net

networks:
  private-net:
    driver: bridge
    internal: true  # Internet'e çıkış yok
```

### Health Checks

Container sağlık kontrolü:

```yaml
services:
  mysql:
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

### Resource Limits

Container kaynak sınırları:

```yaml
services:
  elasticsearch:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          memory: 2G
```

### Backup ve Restore

#### MySQL Backup

```bash
# Backup
docker exec stackored-mysql mysqldump \
  -u root -proot \
  --all-databases \
  --single-transaction \
  --quick \
  --lock-tables=false \
  > backup.sql

# Restore
docker exec -i stackored-mysql mysql \
  -u root -proot \
  < backup.sql
```

#### PostgreSQL Backup

```bash
# Backup
docker exec stackored-postgres pg_dumpall \
  -U stackored \
  > backup.sql

# Restore
docker exec -i stackored-postgres psql \
  -U stackored \
  < backup.sql
```

#### Volume Backup

```bash
# MySQL volume backup
docker run --rm \
  -v stackored-mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mysql-backup.tar.gz /data
```

---

## 🔧 Sorun Giderme

### Port Çakışması

**Hata:**
```
Error: bind: address already in use
```

**Çözüm:**

```bash
# Portu kullanan process'i bul
sudo lsof -i :80
sudo lsof -i :3306

# Process'i durdur
sudo kill -9 <PID>

# Veya .env'de custom port kullan
HOST_PORT_MYSQL=33060
```

### Network Hatası

**Hata:**
```
network stackored-net not found
```

**Çözüm:**

```bash
# Network'ü manuel oluştur
docker network create stackored-net

# Veya generator'ı çalıştır
./cli/stackored generate
```

### Container Başlatılamıyor

**Hata:**
```
Container stackored-mysql exited with code 1
```

**Çözüm:**

```bash
# Logları kontrol et
docker logs stackored-mysql

# Volume'ı temizle (DİKKAT: Veri kaybı!)
docker volume rm stackored-mysql-data

# Yeniden başlat
./cli/stackored up
```

### Traefik Route Çalışmıyor

**Kontrol Listesi:**

1. Container'ın `stackored-net` networkünde olduğunu doğrulayın:
```bash
docker inspect project1-web | grep stackored-net
```

2. Traefik labels'ını kontrol edin:
```bash
docker inspect project1-web | grep traefik
```

3. Traefik dashboard'da route'u kontrol edin:
```
http://localhost:8080
```

4. Hosts dosyasını kontrol edin:
```bash
cat /etc/hosts | grep project1.loc
```

### SSL Sertifika Hatası

**Hata:**
```
NET::ERR_CERT_AUTHORITY_INVALID
```

**Çözüm:**

1. CA sertifikasını import edin (yukarıdaki SSL bölümüne bakın)
2. Tarayıcıyı yeniden başlatın
3. Cache'i temizleyin

### Performance Sorunları

#### Yavaş Disk I/O

macOS Docker Desktop için:

```bash
# docker-compose.override.yml
services:
  project1-web:
    volumes:
      - ./projects/project1:/var/www/html:delegated  # delegated flag
```

#### Yüksek Memory Kullanımı

```bash
# Docker Desktop → Preferences → Resources
# Memory: 8GB+ ayarlayın
```

#### CPU Throttling

```bash
# Servisleri kademeli başlatın
docker compose up -d traefik mysql redis
sleep 5
docker compose up -d elasticsearch kibana
sleep 5
docker compose up -d projects
```

### Generator Hataları

**Hata:**
```
envsubst: command not found
```

**Çözüm:**

```bash
# macOS
brew install gettext
brew link --force gettext

# Ubuntu/Debian
sudo apt-get install gettext

# CentOS/RHEL
sudo yum install gettext
```

---

## 📊 Monitoring ve Logging

### Log Yapılandırması

#### JSON Logging

**docker-compose.override.yml:**

```yaml
services:
  mysql:
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

#### Syslog

```yaml
services:
  mysql:
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://logstash.stackored.loc:5000"
        tag: "mysql"
```

### Netdata Monitoring

Netdata otomatik olarak tüm container'ları izler:

```
http://netdata.stackored.loc
```

**Özellikler:**
- CPU, RAM, Disk kullanımı
- Network trafiği
- Container metrikleri
- Real-time graphs

### Grafana + Prometheus

#### Prometheus Ekleme

**`core/templates/monitoring/prometheus/docker-compose.prometheus.tpl`:**

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: stackored-prometheus
    volumes:
      - ./core/templates/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - stackored-net

volumes:
  prometheus-data:
```

**`core/templates/monitoring/prometheus/prometheus.yml`:**

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'traefik'
    static_configs:
      - targets: ['stackored-traefik:8080']

  - job_name: 'mysql'
    static_configs:
      - targets: ['stackored-mysql-exporter:9104']
```

---

## 🤝 Katkıda Bulunma

### Development Setup

```bash
# Fork ve clone
git clone https://github.com/YOUR_USERNAME/stackored.git
cd stackored

# Feature branch
git checkout -b feature/amazing-feature

# Değişikliklerinizi yapın
# ...

# Test edin
./cli/stackored generate
./cli/stackored up

# Commit
git add .
git commit -m "feat: Add amazing feature"

# Push
git push origin feature/amazing-feature
```

### Yeni Servis Ekleme

1. **Template oluştur:**
```bash
mkdir -p core/templates/category/servicename
nano core/templates/category/servicename/docker-compose.servicename.tpl
```

2. **.env'e değişkenler ekle:**
```bash
SERVICENAME_ENABLE=false
SERVICENAME_VERSION=latest
```

3. **Generator'a ekle (`cli/stackored-generate.sh`):**
```bash
include_module "SERVICENAME_ENABLE" "category/servicename/docker-compose.servicename.tpl" >> "$output"
```

4. **Test et:**
```bash
SERVICENAME_ENABLE=true
./cli/stackored generate
./cli/stackored up
```

### Commit Convention

```
feat: Yeni özellik
fix: Bug düzeltme
docs: Dokümantasyon
style: Kod formatı
refactor: Kod iyileştirme
test: Test ekleme
chore: Build/config değişiklikleri
```

---

## 📄 Lisans

MIT License - Detaylar için [LICENSE.md](LICENSE.md) dosyasına bakın.

---

## 🙏 Teşekkürler

- [Docker](https://www.docker.com/)
- [Traefik](https://traefik.io/)
- [Tüm açık kaynak projeler](https://github.com)

---

## 📞 Destek ve İletişim

- **Issues**: [GitHub Issues](https://github.com/your-username/stackored/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/stackored/discussions)
- **Wiki**: [GitHub Wiki](https://github.com/your-username/stackored/wiki)

---

<div align="center">

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

Made with ❤️ by Stackored Contributors

</div>
