module armos.graphics.gl.attribute;

import std.meta;
import std.variant;

import armos.graphics.gl.types;

alias AcceptableAttributeTypes = AliasSeq!(GlArithmeticTypes, GlArmosVectorTypes);
alias Attribute = Algebraic!(AcceptableAttributeTypes);
