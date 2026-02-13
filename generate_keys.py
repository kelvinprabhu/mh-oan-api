from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
import os

def generate_keys():
    print("Generating 2048-bit RSA keys...")
    
    # Generate private key
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )

    # Serialize private key to PEM format
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

    # Write private key to file
    with open('jwt_private_key.pem', 'wb') as f:
        f.write(pem)
    print(f"Private key saved to: {os.path.abspath('jwt_private_key.pem')}")

    # Generate public key
    public_key = private_key.public_key()
    
    # Serialize public key to PEM format
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    # Write public key to file
    with open('jwt_public_key.pem', 'wb') as f:
        f.write(pem)
    print(f"Public key saved to: {os.path.abspath('jwt_public_key.pem')}")

if __name__ == "__main__":
    generate_keys()
