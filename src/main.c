/*
 * Copyright (c) 2016, Bertold Van den Bergh
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR DISTRIBUTOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdint.h>
#include <string.h>
#include <avr/io.h>
#include <util/delay.h>

#include "aes.h"

/*
 * Testvectors from http://www.inconteam.com/software-development/41-encryption/55-aes-test-vectors
 */
uint8_t aesTestInput[16] =  {0x6b,0xc1,0xbe,0xe2,0x2e,0x40,0x9f,0x96,0xe9,0x3d,0x7e,0x11,0x73,0x93,0x17,0x2a};
//AES-128 Testvector
uint8_t aes128TestKey[16] =    {0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c};
uint8_t aes128TestOutput[16] = {0x3a,0xd7,0x7b,0xb4,0x0d,0x7a,0x36,0x60,0xa8,0x9e,0xca,0xf3,0x24,0x66,0xef,0x97};
//AES-192 Testvector
uint8_t aes192TestKey[24] =    {0x8e,0x73,0xb0,0xf7,0xda,0x0e,0x64,0x52,0xc8,0x10,0xf3,0x2b,0x80,0x90,0x79,0xe5, \
                                0x62,0xf8,0xea,0xd2,0x52,0x2c,0x6b,0x7b};
uint8_t aes192TestOutput[16] = {0xbd,0x33,0x4f,0x1d,0x6e,0x45,0xf2,0x5f,0xf7,0x12,0xa2,0x14,0x57,0x1f,0xa5,0xcc};
//AES-256 Testvector
uint8_t aes256TestKey[32] =    {0x60,0x3d,0xeb,0x10,0x15,0xca,0x71,0xbe,0x2b,0x73,0xae,0xf0,0x85,0x7d,0x77,0x81, \
                                0x1f,0x35,0x2c,0x07,0x3b,0x61,0x08,0xd7,0x2d,0x98,0x10,0xa3,0x09,0x14,0xdf,0xf4};
uint8_t aes256TestOutput[16] = {0xf3,0xee,0xd1,0xbd,0xb5,0xd2,0xa0,0x3c,0x06,0x4b,0x5a,0x7e,0x3d,0xb1,0x81,0xf8};

int main()
{
    /* Init leds */
    DDRC |= _BV(PC0) | _BV(PC1);
    PORTC &=~ _BV(PC0);
    PORTC |= _BV(PC1);

    uint8_t expandedKey[240];
    uint8_t tmpOutput[16];
    uint16_t i;
    if(aes_expandKey (aes128TestKey, expandedKey, sizeof(expandedKey), AES_TYPE_128)) goto fail;
    for(i=0; i<2000; i++) {
        aes_encryptWithExpandedKey(tmpOutput, aesTestInput, expandedKey, AES_TYPE_128);
        if(memcmp(aes128TestOutput, tmpOutput, sizeof(tmpOutput))) goto fail;
        memset(tmpOutput, 0, sizeof(tmpOutput));
    }

    if(aes_expandKey (aes192TestKey, expandedKey, sizeof(expandedKey), AES_TYPE_192)) goto fail;
    for(i=0; i<2000; i++) {
        aes_encryptWithExpandedKey(tmpOutput, aesTestInput, expandedKey, AES_TYPE_192);
        if(memcmp(aes192TestOutput, tmpOutput, sizeof(tmpOutput))) goto fail;
        memset(tmpOutput, 0, sizeof(tmpOutput));
    }

    if(aes_expandKey (aes256TestKey, expandedKey, sizeof(expandedKey), AES_TYPE_256)) goto fail;
    for(i=0; i<2000; i++) {
        aes_encryptWithExpandedKey(tmpOutput, aesTestInput, expandedKey, AES_TYPE_256);
        if(memcmp(aes256TestOutput, tmpOutput, sizeof(tmpOutput))) goto fail;
        memset(tmpOutput, 0, sizeof(tmpOutput));
    }

    while(1) {
        PORTC &=~ _BV(PC1);
        _delay_ms(100);
        PORTC |= _BV(PC1);
        _delay_ms(100);
    }

fail:
    while(1) {
        PORTC &=~ _BV(PC1);
        _delay_ms(1000);
        PORTC |= _BV(PC1);
        _delay_ms(1000);
    }
    return 0;
}
