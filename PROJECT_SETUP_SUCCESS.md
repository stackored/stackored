# 🎉 Stackored Proje Kurulumu Tamamlandı!

## ✅ Başarıyla Eklenenler

### 📁 Project1 (PHP 8.2)

- **Domain**: http://project1.loc
- **PHP Version**: 8.2-fpm-alpine
- **Web Server**: Nginx
- **Files**:
  - ✅ `stackored.json` - Proje konfigürasyonu
  - ✅ `public/index.php` - Modern PHP info sayfası (mor tema)
  - ✅ `public/info.php` - Tam phpinfo()
  - ✅ `nginx.conf` - Nginx yapılandırması

### 📁 Project2 (PHP 8.3)

- **Domain**: http://project2.loc
- **PHP Version**: 8.3-fpm-alpine
- **Web Server**: Nginx
- **Files**:
  - ✅ `stackored.json` - Proje konfigürasyonu
  - ✅ `public/index.php` - Modern PHP info sayfası (pembe tema)
  - ✅ `public/info.php` - Tam phpinfo()
  - ✅ `nginx.conf` - Nginx yapılandırması

---

## 🐳 Çalışan Container'lar

```
✅ stackored-traefik        (Reverse Proxy)
✅ stackored-mysql          (MySQL 8.0)
✅ stackored-redis          (Redis 7.0)
✅ stackored-project1-php   (PHP 8.2-FPM)
✅ stackored-project1-web   (Nginx)
✅ stackored-project2-php   (PHP 8.3-FPM)
✅ stackored-project2-web   (Nginx)
```

---

## 🌐 Erişim için Gerekli Adım

### Hosts Dosyasını Güncelleyin

**macOS/Linux:**

```bash
sudo nano /etc/hosts
```

Aşağıdaki satırları ekleyin:

```
127.0.0.1  project1.loc
127.0.0.1  project2.loc
```

Veya otomatik script kullanın:

```bash
./cli/update-hosts.sh
```

**Alternatif: Manuel Ekleme**

```bash
echo "127.0.0.1  project1.loc" | sudo tee -a /etc/hosts
echo "127.0.0.1  project2.loc" | sudo tee -a /etc/hosts
```

---

## 🔗 Erişim URL'leri

Hosts dosyasını güncelledikten sonra:

- **Project 1**: http://project1.loc
- **Project 2**: http://project2.loc
- **Traefik Dashboard**: http://localhost:8080

### Test Sayfaları:

- http://project1.loc/info.php - Tam PHP bilgileri
- http://project2.loc/info.php - Tam PHP bilgileri

---

## 📊 Özellikler

### ✨ Multi-Version PHP

- Project1: PHP 8.2
- Project2: PHP 8.3
- Her proje kendi PHP versiyonunu kullanıyor!

### 🔀 Traefik Routing

- Otomatik domain-based routing
- `project1.loc` → project1-web container
- `project2.loc` → project2-web container

### 🗄️ Paylaşılan Servisler

- **MySQL**: localhost:3306 (root/root, database: stackored)
- **Redis**: localhost:6379

---

## 🛠️ Yönetim Komutları

### Servisleri Başlat

```bash
./cli/stackored up
```

### Servisleri Durdur

```bash
./cli/stackored down
```

### Durumu Görüntüle

```bash
./cli/stackored ps
```

### Logları İzle

```bash
./cli/stackored logs
./cli/stackored logs project1-php
./cli/stackored logs project1-web
```

### Yeniden Generate Et

Eğer `.env` değiştirirseniz veya yeni proje eklerseniz:

```bash
./cli/stackored generate
./cli/stackored up
```

---

## 🆕 Yeni Proje Ekleme

### 1. Proje Dizini Oluştur

```bash
mkdir -p projects/project3/public
```

### 2. stackored.json Oluştur

```json
{
  "name": "project3",
  "domain": "project3.loc",
  "php": {
    "version": "8.4",
    "extensions": [
      "pdo",
      "pdo_mysql",
      "mysqli",
      "gd",
      "curl",
      "zip",
      "mbstring"
    ]
  },
  "webserver": "nginx",
  "document_root": "public"
}
```

### 3. index.php Oluştur

```php
<?php phpinfo(); ?>
```

### 4. Generate ve Başlat

```bash
./cli/stackored generate
./cli/stackored up
```

### 5. Hosts Dosyasına Ekle

```bash
echo "127.0.0.1  project3.loc" | sudo tee -a /etc/hosts
```

---

## 🎨 Modern PHP Info Sayfaları

Her iki proje de modern, güzel tasarlanmış PHP info sayfalarına sahip:

- **Project1**: Mor/mavi gradyan tema
- **Project2**: Pembe/kırmızı gradyan tema

Sayfalar şunları gösteriyor:

- PHP versiyonu
- Server bilgileri
- Document root
- Stackored özellikleri
- Tam phpinfo() linki

---

## 🔍 Sorun Giderme

### Site Açılmıyor

1. Hosts dosyasını kontrol edin: `cat /etc/hosts | grep project`
2. Container'ları kontrol edin: `./cli/stackored ps`
3. Logları kontrol edin: `./cli/stackored logs project1-web`

### Port 80 Kullanımda

```bash
# Port 80'i kullanan servisi bulun
sudo lsof -i :80

# Stackored'ı yeniden başlatın
./cli/stackored down
./cli/stackored up
```

### Yeniden Başlatma

```bash
./cli/stackored restart
```

### Cache Temizleme

```bash
./cli/stackored down
docker system prune -a
./cli/stackored up
```

---

## 🎯 Başarıyla Tamamlanan İşlemler

✅ TLD_SUFFIX=loc eklendi (.env)
✅ Project1 için stackored.json oluşturuldu
✅ Project2 için stackored.json oluşturuldu
✅ Her proje için modern PHP info sayfaları oluşturuldu
✅ Nginx konfigürasyonları otomatik oluşturuldu
✅ Generator script güncellendi (proje tarama özelliği)
✅ Docker Compose dosyaları dinamik oluşturuldu
✅ PHP-FPM container'ları (8.2 ve 8.3) başlatıldı
✅ Nginx container'ları başlatıldı
✅ Traefik routing yapılandırıldı
✅ MySQL ve Redis servisleri çalışıyor

---

## 📝 Sonraki Adımlar

1. **Hosts dosyasını güncelleyin** (yukarıdaki talimatlar)
2. **Tarayıcıda test edin**: http://project1.loc
3. **Farklı PHP versiyonlarını görün**: http://project2.loc

**Artık her proje kendi PHP versiyonunda çalışıyor! 🎉**
