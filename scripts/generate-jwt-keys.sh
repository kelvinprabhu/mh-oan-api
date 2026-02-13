#!/bin/bash

# generate-jwt-keys.sh - Production JWT key generation

set -e  # Exit on error

KEY_DIR="${1:-./keys}"
KEY_TYPE="${2:-rsa}"
KEY_SIZE="${3:-2048}"

# Create directory if it doesn't exist
mkdir -p "$KEY_DIR"

echo "Generating JWT keys in $KEY_DIR"
echo "Key type: $KEY_TYPE"

case "$KEY_TYPE" in
  rsa)
    echo "Generating RSA-$KEY_SIZE keys..."
    openssl genrsa -out "$KEY_DIR/jwt_private_key.pem" "$KEY_SIZE"
    openssl rsa -in "$KEY_DIR/jwt_private_key.pem" -pubout -out "$KEY_DIR/jwt_public_key.pem"
    ;;
  
  ecdsa|ec)
    CURVE="prime256v1"
    if [ "$KEY_SIZE" = "384" ]; then
      CURVE="secp384r1"
    elif [ "$KEY_SIZE" = "521" ]; then
      CURVE="secp521r1"
    fi
    echo "Generating ECDSA keys with curve $CURVE..."
    openssl ecparam -genkey -name "$CURVE" -noout -out "$KEY_DIR/jwt_private_key.pem"
    openssl ec -in "$KEY_DIR/jwt_private_key.pem" -pubout -out "$KEY_DIR/jwt_public_key.pem"
    ;;
  
  ed25519)
    echo "Generating Ed25519 keys..."
    openssl genpkey -algorithm ED25519 -out "$KEY_DIR/jwt_private_key.pem"
    openssl pkey -in "$KEY_DIR/jwt_private_key.pem" -pubout -out "$KEY_DIR/jwt_public_key.pem"
    ;;
  
  *)
    echo "Unknown key type: $KEY_TYPE"
    echo "Usage: $0 [key_dir] [rsa|ecdsa|ed25519] [key_size]"
    exit 1
    ;;
esac

# Set proper permissions (private key readable only by owner)
chmod 600 "$KEY_DIR/jwt_private_key.pem"
chmod 644 "$KEY_DIR/jwt_public_key.pem"

echo "✓ Keys generated successfully!"
echo "  Private key: $KEY_DIR/jwt_private_key.pem (permissions: 600)"
echo "  Public key:  $KEY_DIR/jwt_public_key.pem (permissions: 644)"

# Verify the keys
echo ""
echo "Verifying keys..."
if [ "$KEY_TYPE" = "rsa" ]; then
  openssl rsa -in "$KEY_DIR/jwt_private_key.pem" -check -noout && echo "✓ Private key is valid"
  openssl rsa -pubin -in "$KEY_DIR/jwt_public_key.pem" -noout -text > /dev/null && echo "✓ Public key is valid"
elif [ "$KEY_TYPE" = "ed25519" ]; then
  openssl pkey -in "$KEY_DIR/jwt_private_key.pem" -check -noout && echo "✓ Private key is valid"
  openssl pkey -pubin -in "$KEY_DIR/jwt_public_key.pem" -noout -text > /dev/null && echo "✓ Public key is valid"
else
  openssl ec -in "$KEY_DIR/jwt_private_key.pem" -check -noout && echo "✓ Private key is valid"
  openssl ec -pubin -in "$KEY_DIR/jwt_public_key.pem" -noout -text > /dev/null && echo "✓ Public key is valid"
fi

echo ""
echo "Key fingerprints:"
if [ "$KEY_TYPE" = "rsa" ]; then
  openssl rsa -in "$KEY_DIR/jwt_private_key.pem" -pubout -outform DER | sha256sum
else
  openssl pkey -in "$KEY_DIR/jwt_private_key.pem" -pubout -outform DER | sha256sum
fi
