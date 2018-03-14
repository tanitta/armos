module armos.graphics.gl.attribute;

import std.meta;
import std.variant;

import armos.graphics.gl.types;

alias AcceptableAttributeTypes = AliasSeq!(GlArithmeticTypes, GlVectorTypes);
alias Attribute = Algebraic!(AcceptableAttributeTypes);
