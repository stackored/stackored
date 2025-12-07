#!/bin/bash
###################################################################
# Stackored Self-Signed SSL Certificate Generator
###################################################################

CERT_DIR="core/certs"
DOMAIN="stackored.loc"
CA_NAME="stackored-ca"
CERT_NAME="stackored-wildcard"

echo "🔐 Generating Stackored SSL Certificates..."

# 1. Generate CA Private Key
echo "📝 Creating CA private key..."
openssl genrsa -out "$CERT_DIR/$CA_NAME.key" 4096

# 2. Generate CA Certificate
echo "📝 Creating CA certificate..."
openssl req -x509 -new -nodes \
  -key "$CERT_DIR/$CA_NAME.key" \
  -sha256 -days 3650 \
  -out "$CERT_DIR/$CA_NAME.crt" \
  -subj "/C=US/ST=Local/L=Local/O=Stackored/OU=Development/CN=Stackored CA"

# 3. Generate Wildcard Certificate Private Key
echo "📝 Creating wildcard certificate private key..."
openssl genrsa -out "$CERT_DIR/$CERT_NAME.key" 2048

# 4. Generate Certificate Signing Request (CSR)
echo "📝 Creating certificate signing request..."
openssl req -new \
  -key "$CERT_DIR/$CERT_NAME.key" \
  -out "$CERT_DIR/$CERT_NAME.csr" \
  -subj "/C=US/ST=Local/L=Local/O=Stackored/OU=Development/CN=*.$DOMAIN"

# 5. Create OpenSSL config for SAN (Subject Alternative Names)
cat > "$CERT_DIR/openssl.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.$DOMAIN
DNS.2 = $DOMAIN
EOF

# 6. Sign the certificate with CA
echo "📝 Signing certificate with CA..."
openssl x509 -req \
  -in "$CERT_DIR/$CERT_NAME.csr" \
  -CA "$CERT_DIR/$CA_NAME.crt" \
  -CAkey "$CERT_DIR/$CA_NAME.key" \
  -CAcreateserial \
  -out "$CERT_DIR/$CERT_NAME.crt" \
  -days 825 \
  -sha256 \
  -extfile "$CERT_DIR/openssl.cnf" \
  -extensions v3_req

# 7. Cleanup
rm "$CERT_DIR/$CERT_NAME.csr"
rm "$CERT_DIR/openssl.cnf"

echo "✅ SSL Certificates generated successfully!"
echo ""
echo "📁 Generated files:"
echo "   - $CERT_DIR/$CA_NAME.crt (CA Certificate - Import to browser)"
echo "   - $CERT_DIR/$CA_NAME.key (CA Private Key)"
echo "   - $CERT_DIR/$CERT_NAME.crt (Wildcard Certificate)"
echo "   - $CERT_DIR/$CERT_NAME.key (Wildcard Private Key)"
echo ""
echo "📌 Next steps:"
echo "   1. Import $CERT_DIR/$CA_NAME.crt to your browser/system"
echo "   2. Run: docker-compose -f stackored.yml -f docker-compose.dynamic.yml up -d"
echo "   3. Access: https://adminer.stackored.loc"
