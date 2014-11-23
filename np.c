/*
 * Copyright (c) 2013 Jan-Piet Mens <jpmens()gmail.com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of mosquitto nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include "base64.h"

#define DEFAULT_KEY_LEN  24
#define SEPARATOR        "$"
#define DEFAULT_SALT_LEN 12

#define USAGE() printUsage()

static char *progname;
int printUsage(void)
{
    return fprintf(stderr, "Usage: %s [-i iterations] [-p password] [-k key_length] [-s salt_length]\n", progname);
}

int main(int argc, char **argv)
{
    int iterations = 901, rc, saltlen, blen;
	char *salt, *b64;
	unsigned char key[128], saltbytes[128];
	char *pw1, *pw2, *password;
	int c;
	int prompt;
    int key_length = DEFAULT_KEY_LEN;
    int salt_length = DEFAULT_SALT_LEN;

    progname = argv[0];
	prompt = 1;

	while ((c = getopt(argc, argv, "i:p:k:s:")) != EOF) {
		switch (c) {
			case 'i':
				iterations = atoi(optarg);
				break;
			case 'p':
				pw1 = strdup(optarg);
				pw2 = strdup(optarg);	
				prompt = 0;
				break;
            case 'k':
                key_length = atoi(optarg);
                key_length = key_length > 128 ? 128 : key_length;
				break;
            case 's':
                salt_length = atoi(optarg);
                salt_length = salt_length > 128 ? 128 : salt_length;
				break;
			default:
				exit(USAGE());
		}
	}

	argc -= optind - 1;
	argv += optind - 1;

	if (argc != 1) {
		exit(USAGE());
	}

	if ( prompt ) {
		pw1 = strdup(getpass("Enter password: "));
		pw2 = getpass("Re-enter same password: ");
	}

	if (strcmp(pw1, pw2) != 0) {
		fprintf(stderr, "Passwords don't match!\n");
		return (1);
	}

	password = pw1;

	rc = RAND_bytes(saltbytes, salt_length);
	if (rc == 0) {
		fprintf(stderr, "Cannot get random bytes for salt!\n");
		return 2;
	}

	base64_encode(saltbytes, salt_length, &salt);
	saltlen = strlen(salt);

	PKCS5_PBKDF2_HMAC(password, strlen(password),
                (unsigned char *)salt, saltlen,
		iterations,
		EVP_sha256(), key_length, key);

	blen = base64_encode(key, key_length, &b64);
	if (blen > 0) {
		printf("PBKDF2$%s$%d$%s$%s\n",
			"sha256",
			iterations,
			salt,
			b64);
		
		free(b64);
	}

	free(password);
	return 0;
}
