#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/core_names.h>
#include <openssl/evp.h>

void handleErrors(void) {
    ERR_print_errors_fp(stderr);
    abort();
}

EVP_PKEY* loadPublicKey(const char* filename) {
    FILE* fp = fopen(filename, "r");
    if (fp == NULL) {
        perror("Unable to open public key file");
        exit(1);
    }
    EVP_PKEY* pkey = PEM_read_PUBKEY(fp, NULL, NULL, NULL);
    fclose(fp);
    if (pkey == NULL) {
        handleErrors();
    }
    return pkey;
}

EVP_PKEY* loadPrivateKey(const char* filename) {
    FILE* fp = fopen(filename, "r");
    if (fp == NULL) {
        perror("Unable to open private key file");
        exit(1);
    }
    EVP_PKEY* pkey = PEM_read_PrivateKey(fp, NULL, NULL, NULL);
    fclose(fp);
    if (pkey == NULL) {
        handleErrors();
    }
    return pkey;
}

int main(void) {
    const char* publicKeyFile = "public_pkcs1_key.pem";
    const char* privateKeyFile = "private_pkcs1_key.pem";

    // Load public and private keys
    EVP_PKEY* publicKey = loadPublicKey(publicKeyFile);
    EVP_PKEY* privateKey = loadPrivateKey(privateKeyFile);

    // Message to be encrypted
    unsigned char plaintext[] = "Hello, RSA!";
    unsigned char ciphertext[256]; // Adjust size as needed
    unsigned char decryptedtext[256]; // Adjust size as needed

    EVP_PKEY_CTX* ctx;
    size_t outlen;

    // Encrypt the plaintext
    ctx = EVP_PKEY_CTX_new(publicKey, NULL);
    if (!ctx) handleErrors();
    if (EVP_PKEY_encrypt_init(ctx) <= 0) handleErrors();
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING) <= 0) handleErrors();
    if (EVP_PKEY_encrypt(ctx, NULL, &outlen, plaintext, strlen((char*)plaintext)) <= 0) handleErrors();
    if (EVP_PKEY_encrypt(ctx, ciphertext, &outlen, plaintext, strlen((char*)plaintext)) <= 0) handleErrors();
    EVP_PKEY_CTX_free(ctx);

    // Decrypt the ciphertext
    ctx = EVP_PKEY_CTX_new(privateKey, NULL);
    if (!ctx) handleErrors();
    if (EVP_PKEY_decrypt_init(ctx) <= 0) handleErrors();
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING) <= 0) handleErrors();
    if (EVP_PKEY_decrypt(ctx, NULL, &outlen, ciphertext, outlen) <= 0) handleErrors();
    if (EVP_PKEY_decrypt(ctx, decryptedtext, &outlen, ciphertext, outlen) <= 0) handleErrors();
    EVP_PKEY_CTX_free(ctx);

    // Null-terminate the decrypted text
    decryptedtext[outlen] = '\0';

    // Print results
    printf("Plaintext: %s\n", plaintext);
    printf("Ciphertext: ");
    for (size_t i = 0; i < outlen; i++) {
        printf("%02x", ciphertext[i]);
    }
    printf("\nDecrypted text: %s\n", decryptedtext);

    // Free the EVP_PKEY structures
    EVP_PKEY_free(publicKey);
    EVP_PKEY_free(privateKey);

    return 0;
}

// gcc -o rsa_example main.c $(pkg-config --cflags --libs openssl)
// ./rsa_example