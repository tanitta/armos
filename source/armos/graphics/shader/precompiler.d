module armos.graphics.shader.precompiler;

// /++
// +/
// class Precpmpiler {
//     public{
//     }//public
//
//     private{
//     }//private
// }//class PreCpmpiler

import armos.graphics.shader.source;

auto precompile(in Source entryPoint, in Source[] searchable){
    Source expanded = new Source(entryPoint.rawText, entryPoint.name);
}
