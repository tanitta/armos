module armos.graphics.gl.types;

import std.meta;

alias GlArithmeticTypes = AliasSeq!(uint, int, float);
alias GlVectorTypes     = AliasSeq!(uint[1], int[1], float[1],
                                    uint[2], int[2], float[2],
                                    uint[3], int[3], float[3],
                                    uint[4], int[4], float[4]);
alias GlMatrixTypes     = AliasSeq!(float[2][2], float[3][3], float[4][4],
                                    float[2][3], float[3][2],
                                    float[2][4], float[4][2],
                                    float[3][4], float[4][3]);
