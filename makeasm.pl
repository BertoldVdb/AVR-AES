#!/usr/bin/perl

#Copyright (c) 2016, Bertold Van den Bergh
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the author nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR DISTRIBUTOR BE LIABLE FOR ANY
#DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


use strict;

#Registers not used by GCC: r18-r27, r30-r31, r0, r1 (must be cleared)
#Extra registers we use: r2-r12

my @state_regs = ( "r18", "r19", "r20", "r21", "r22", "r23", "r24", "r12", "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7");
my @spare_regs = ("r8", "r9", "r10", "r11" ,"r25");

sub mixSingleColInternal{
	my ($regs_in, $spare_regs, $tmp_lpm, $a, $index, $makeXOR) = @_;

	print <<END;
	MOV r30, $spare_regs->[$a]
	LPM $tmp_lpm, Z
END

	if($makeXOR == 1){
		print "\tEOR $spare_regs->[0], $spare_regs->[2]\n";
	}

	print <<END;
	EOR $regs_in->[$a+$index], $tmp_lpm
	EOR $regs_in->[$a+$index], $spare_regs->[0]
END
}

# Generate mixCols for a single column
sub mixSingleCol{
	my ($regs_in, $spare_regs, $tmp_lpm, $index) = @_;
    
	print <<END;
	MOV $spare_regs->[0], $regs_in->[$index+0]
	EOR $spare_regs->[0], $regs_in->[$index+1]
	MOV $spare_regs->[1], $regs_in->[$index+1]
	EOR $spare_regs->[1], $regs_in->[$index+2]
	MOV $spare_regs->[2], $regs_in->[$index+2]
	EOR $spare_regs->[2], $regs_in->[$index+3]
	MOV $spare_regs->[3], $regs_in->[$index+3]
	EOR $spare_regs->[3], $regs_in->[$index+0]
END
	
	for(my $i=0;$i<4; $i++){
		mixSingleColInternal($regs_in, $spare_regs, $tmp_lpm, $i, $index, ($i==0));
	}
}

sub mixCols{
	print "aes_mixColumns:\n";
	print "\tLDI r31, hi8(aes_xtime)\n";
    my ($state_regs, $spare_regs, $tmp_lpm) = @_;
	for(my $i=0;$i<4; $i++){
		mixSingleCol($state_regs, $spare_regs, $tmp_lpm, 4*$i);
	}
	print "\tRET\n\n";
}


sub aesSboxShift{
	my ($state_regs, $spare_regs, $tmp_lpm, @elements) = @_;
	my $numElements = scalar(@elements);
	if($numElements>1){
		print "\tMOV $spare_regs->[0], $state_regs->[@elements[$numElements-1]]\n";
	}
	for(my $i=0; $i<$numElements; $i++){
		if($numElements>1 && $i==$numElements-1){
			print "\tMOV r30, $spare_regs->[0]\n";
		}else{
			print "\tMOV r30, $state_regs->[@elements[$i]]\n";
		}
		print "\tLPM $state_regs->[@elements[($i-1)%$numElements]], Z\n";
	}	
}

sub aesSbox{
	my ($state_regs, $spare_regs, $tmp_reg) = @_;
	print "aes_subBytesShiftRows:\n";
	print "\tLDI r31, hi8(aes_sbox)\n";
	#First row is simply the Sbox, no shift
	for(my $i=0;$i<4;$i++){
		aesSboxShift(\@state_regs, \@spare_regs, $tmp_reg, (4*$i));
	}
	#Shift by one
	aesSboxShift(\@state_regs, \@spare_regs, $tmp_reg, (0+1, 4+1, 8+1, 12+1));
	#Shift by two
	aesSboxShift(\@state_regs, \@spare_regs, $tmp_reg, (0+2,8+2));
	aesSboxShift(\@state_regs, \@spare_regs, $tmp_reg, (4+2,12+2));
	#shift by three
	aesSboxShift(\@state_regs, \@spare_regs, $tmp_reg, (12+3, 8+3, 4+3, 0+3));
	print "\tRET\n\n";
}

sub aesRoundKey{
	my ($state_regs, $tmp_reg) = @_;
	print "aes_roundKey:\n";
	for(my $i=0; $i<16; $i++){
		print "\tLD $tmp_reg, X+\n";	
		print "\tEOR $state_regs->[$i], $tmp_reg\n";
	}
	print "\tRET\n\n";
}


sub aesLoadStoreBlock{
	my ($state_regs, $store) = @_;
	if($store == 2){
		for(my $i=15;$i>=0;$i--){
			print "\tST -Y, $state_regs->[$i]\n";
		}
	}elsif($store == 1){
		for(my $i=0;$i<16;$i++){
			print "\tST Y+, $state_regs->[$i]\n";
		}
	}elsif($store == 0){
		for(my $i=0;$i<16;$i++){
			print "\tLD $state_regs->[$i], Y+\n";
		}
	}
}

#Function is called with two pointers, blockIO, keyI
sub aesEncryptWithExpandedKey{
	my ($state_regs,$spare_regs) = @_;
	#in r20 we have the number of rounds
	#In r23:r22 we have the pointer to the expanded key. This should be placed in X
	#In r25:r24 we have the pointer to the block. It is moved to Y
	print <<END;
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
	MOV $spare_regs->[4], r18
END
	aesLoadStoreBlock($state_regs, 0);
	print <<END;
	RCALL aes_roundKey
aes_encLoop:
	RCALL aes_subBytesShiftRows
	RCALL aes_mixColumns
	RCALL aes_roundKey
	DEC $spare_regs->[4]
	BRNE aes_encLoop
	RCALL aes_subBytesShiftRows
	RCALL aes_roundKey
	POP r28
	POP r29
END
	aesLoadStoreBlock($state_regs, 1);
	print <<END;
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

END
}

print <<END;
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
END

mixCols(\@state_regs, \@spare_regs, "r30");
aesSbox(\@state_regs, \@spare_regs, "r30");
aesRoundKey(\@state_regs, "r30");
aesEncryptWithExpandedKey(\@state_regs,\@spare_regs);
