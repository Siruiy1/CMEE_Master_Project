import cryptography as cryptography

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend

with open("C://Users//DELL//Documents//Oracle//Key//demokey", "rb") as key_file:
    private_key = serialization.load_pem_private_key(
        key_file.read(),
        password=None,
        backend=default_backend()
    )

if isinstance(private_key, rsa.RSAPrivateKey):
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )

    with open("C://Users//DELL//Documents//Oracle//Key//demokey_rsa.pem", "wb") as output_file:
        output_file.write(pem)
