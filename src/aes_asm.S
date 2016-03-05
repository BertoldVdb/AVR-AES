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
aes_mixColumns:
LDI r31, hi8(aes_xtime)
MOV r8, r18
EOR r8, r19
MOV r9, r19
EOR r9, r20
MOV r10, r20
EOR r10, r21
MOV r11, r21
EOR r11, r18
MOV r30, r8
LPM r30, Z
EOR r8, r10
EOR r18, r30
EOR r18, r8
MOV r30, r9
LPM r30, Z
EOR r19, r30
EOR r19, r8
MOV r30, r10
LPM r30, Z
EOR r20, r30
EOR r20, r8
MOV r30, r11
LPM r30, Z
EOR r21, r30
EOR r21, r8
MOV r8, r22
EOR r8, r23
MOV r9, r23
EOR r9, r24
MOV r10, r24
EOR r10, r12
MOV r11, r12
EOR r11, r22
MOV r30, r8
LPM r30, Z
EOR r8, r10
EOR r22, r30
EOR r22, r8
MOV r30, r9
LPM r30, Z
EOR r23, r30
EOR r23, r8
MOV r30, r10
LPM r30, Z
EOR r24, r30
EOR r24, r8
MOV r30, r11
LPM r30, Z
EOR r12, r30
EOR r12, r8
MOV r8, r0
EOR r8, r1
MOV r9, r1
EOR r9, r2
MOV r10, r2
EOR r10, r3
MOV r11, r3
EOR r11, r0
MOV r30, r8
LPM r30, Z
EOR r8, r10
EOR r0, r30
EOR r0, r8
MOV r30, r9
LPM r30, Z
EOR r1, r30
EOR r1, r8
MOV r30, r10
LPM r30, Z
EOR r2, r30
EOR r2, r8
MOV r30, r11
LPM r30, Z
EOR r3, r30
EOR r3, r8
MOV r8, r4
EOR r8, r5
MOV r9, r5
EOR r9, r6
MOV r10, r6
EOR r10, r7
MOV r11, r7
EOR r11, r4
MOV r30, r8
LPM r30, Z
EOR r8, r10
EOR r4, r30
EOR r4, r8
MOV r30, r9
LPM r30, Z
EOR r5, r30
EOR r5, r8
MOV r30, r10
LPM r30, Z
EOR r6, r30
EOR r6, r8
MOV r30, r11
LPM r30, Z
EOR r7, r30
EOR r7, r8
RET

aes_subBytesShiftRows:
LDI r31, hi8(aes_sbox)
MOV r30, r18
LPM r18, Z
MOV r30, r22
LPM r22, Z
MOV r30, r0
LPM r0, Z
MOV r30, r4
LPM r4, Z
MOV r8, r5
MOV r30, r19
LPM r5, Z
MOV r30, r23
LPM r19, Z
MOV r30, r1
LPM r23, Z
MOV r30, r8
LPM r1, Z
MOV r8, r2
MOV r30, r20
LPM r2, Z
MOV r30, r8
LPM r20, Z
MOV r8, r6
MOV r30, r24
LPM r6, Z
MOV r30, r8
LPM r24, Z
MOV r8, r21
MOV r30, r7
LPM r21, Z
MOV r30, r3
LPM r7, Z
MOV r30, r12
LPM r3, Z
MOV r30, r8
LPM r12, Z
RET

aes_roundKey:
LD r30, X+
EOR r18, r30
LD r30, X+
EOR r19, r30
LD r30, X+
EOR r20, r30
LD r30, X+
EOR r21, r30
LD r30, X+
EOR r22, r30
LD r30, X+
EOR r23, r30
LD r30, X+
EOR r24, r30
LD r30, X+
EOR r12, r30
LD r30, X+
EOR r0, r30
LD r30, X+
EOR r1, r30
LD r30, X+
EOR r2, r30
LD r30, X+
EOR r3, r30
LD r30, X+
EOR r4, r30
LD r30, X+
EOR r5, r30
LD r30, X+
EOR r6, r30
LD r30, X+
EOR r7, r30
RET

.global aes_encryptWithExpandedKey
aes_encryptWithExpandedKey:
PUSH r2
PUSH r3
PUSH r4
PUSH r5
PUSH r6
PUSH r7
PUSH r8
PUSH r9
PUSH r10
PUSH r11
PUSH r12
PUSH r28
PUSH r29
PUSH r25
PUSH r24
MOVW r26, r20
MOVW r28, r22
MOV r25, r18
LD r18, Y+
LD r19, Y+
LD r20, Y+
LD r21, Y+
LD r22, Y+
LD r23, Y+
LD r24, Y+
LD r12, Y+
LD r0, Y+
LD r1, Y+
LD r2, Y+
LD r3, Y+
LD r4, Y+
LD r5, Y+
LD r6, Y+
LD r7, Y+
RCALL aes_roundKey
aes_encLoop:
RCALL aes_subBytesShiftRows
RCALL aes_mixColumns
RCALL aes_roundKey
DEC r25
BRNE aes_encLoop
RCALL aes_subBytesShiftRows
RCALL aes_roundKey
POP r28
POP r29
ST Y+, r18
ST Y+, r19
ST Y+, r20
ST Y+, r21
ST Y+, r22
ST Y+, r23
ST Y+, r24
ST Y+, r12
ST Y+, r0
ST Y+, r1
ST Y+, r2
ST Y+, r3
ST Y+, r4
ST Y+, r5
ST Y+, r6
ST Y+, r7
POP r29
POP r28
POP r12
POP r11
POP r10
POP r9
POP r8
POP r7
POP r6
POP r5
POP r4
POP r3
POP r2
CLR r1
RET

