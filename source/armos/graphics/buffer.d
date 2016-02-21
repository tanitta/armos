module armos.graphics.buffer;

import derelict.opengl3.gl;
import armos.graphics.vao;

/++
+/
class Buffer {
	public{
		
		/++
			BufferTypeを指定して初期化します．
		+/
		this(in BufferType bufferType){
			glGenBuffers(1, cast(uint*)&_id);
			_bufferType = bufferType;
		}
		
		~this(){
			glDeleteBuffers(1, cast(uint*)&_id);
		}

		/++
		+/
		void begin(){
			if(_rootVao){
				_rootVao.begin;
			}
			
			int savedID;
			glGetIntegerv(cast(GLenum)bindingEnum(_bufferType), &savedID);
			_savedIDs ~= savedID;
			glBindBuffer(_bufferType, _id);
		}

		/++
		+/
		void end(){
			import std.range;
			glBindBuffer(_bufferType, _savedIDs[$-1]);
			if (_savedIDs.length == 0) {
				assert(0, "stack is empty");
			}else{
				_savedIDs.popBack;
			}
			
			if(_rootVao){
				_rootVao.end;
			}
		}
		
		/++
		+/
		void set(Array)(Array array, in BufferUsageFrequency freq, in BufferUsageNature nature){
			begin;
				glBufferData(_bufferType, Array[0].sizeof, array.ptr, usageEnum(freq, nature));
			end;
		}

		/++
		+/
		void vao(Vao o){
			_rootVao = o;
		}
		
	}//public

	private{
		int _id;
		int[] _savedIDs;
		BufferType _bufferType;
		Vao _rootVao;
	}//private
}//class Vbo

/++
+/
enum BufferType{
	Array             = GL_ARRAY_BUFFER,              /// Vertex attributes
	AtomicCounter     = GL_ATOMIC_COUNTER_BUFFER,     /// Atomic counter storage
	CopyRead          = GL_COPY_READ_BUFFER,          /// Buffer copy source
	CopyWrite         = GL_COPY_WRITE_BUFFER,         /// Buffer copy destination
	DispatchIndirect  = GL_DISPATCH_INDIRECT_BUFFER,  /// Indirect compute dispatch commands
	DrawIndirect      = GL_DRAW_INDIRECT_BUFFER,      /// Indirect command arguments
	ElementArray      = GL_ELEMENT_ARRAY_BUFFER,      /// Vertex array indices
	PixelPack         = GL_PIXEL_PACK_BUFFER,         /// Pixel read target
	PixelUnpack       = GL_PIXEL_UNPACK_BUFFER,       /// Texture data source
	Query             = GL_QUERY_BUFFER,              /// Query result buffer
	ShaderStorage     = GL_SHADER_STORAGE_BUFFER,     /// Read-write storage for shaders
	Texture           = GL_TEXTURE_BUFFER,            /// Texture data buffer
	TransformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER, /// Transform feedback buffer
	Uniform           = GL_UNIFORM_BUFFER,            /// Uniform block storage
}

private GLenum bindingEnum(in BufferType bufferType){
	GLenum bindingType;
	switch (bufferType) {
		case BufferType.Array:
				bindingType =  GL_ARRAY_BUFFER_BINDING;
					break;
		case BufferType.AtomicCounter:
				bindingType = GL_ATOMIC_COUNTER_BUFFER_BINDING;
					break;
		case BufferType.CopyRead:
				bindingType = GL_COPY_READ_BUFFER_BINDING;
					break;
		case BufferType.CopyWrite:
				bindingType = GL_COPY_WRITE_BUFFER_BINDING;
					break;
		case BufferType.DispatchIndirect:
				bindingType = GL_DISPATCH_INDIRECT_BUFFER_BINDING;
					break;
		case BufferType.DrawIndirect:
				bindingType = GL_DRAW_INDIRECT_BUFFER_BINDING;
					break;
		case BufferType.ElementArray:
				bindingType = GL_ELEMENT_ARRAY_BUFFER_BINDING;
					break;
		case BufferType.PixelPack:
				bindingType = GL_PIXEL_PACK_BUFFER_BINDING;
					break;
		case BufferType.PixelUnpack:
				bindingType = GL_PIXEL_UNPACK_BUFFER_BINDING;
					break;
		case BufferType.Query:
				bindingType = GL_QUERY_BUFFER_BINDING;
					break;
		case BufferType.ShaderStorage:
				bindingType = GL_SHADER_STORAGE_BUFFER_BINDING;
					break;
		case BufferType.Texture:
				bindingType = GL_TEXTURE_BUFFER_BINDING;
					break;
		case BufferType.TransformFeedback:
				bindingType = GL_TRANSFORM_FEEDBACK_BUFFER_BINDING;
					break;
		case BufferType.Uniform:
				bindingType = GL_UNIFORM_BUFFER_BINDING;
					break;
		default : assert(0, "invalid value");
	}
	return bindingType;
}

/++
Bufferの更新頻度を表すenumです．
+/
enum BufferUsageFrequency{
	Stream,  /// 読み込みも書き込みも一度のみ
	Static,  /// 書き込みが一度だけで，読み込みは何度も行われる
	Dynamic, /// 何度も読み書きが行われる
}

/++
Bufferの読み書きの方法を表すenumです．
+/
enum BufferUsageNature{
	Draw, /// アプリケーション側から書き込まれ，OpenGLが描画のために読み込む
	Read, /// OpenGL側で書き込まれ，アプリケーション側で読み込む
	Copy, /// OpenGL側で書き込まれ，描画に用いられる
}

private static GLenum[BufferUsageNature][BufferUsageFrequency] usageEnumsTable(){
	GLenum[BufferUsageNature][BufferUsageFrequency] enums;
	enums[BufferUsageFrequency.Stream][BufferUsageNature.Draw] = GL_STREAM_DRAW;
	enums[BufferUsageFrequency.Stream][BufferUsageNature.Read] = GL_STREAM_READ;
	enums[BufferUsageFrequency.Stream][BufferUsageNature.Copy] = GL_STREAM_COPY;

	enums[BufferUsageFrequency.Static][BufferUsageNature.Draw] = GL_STATIC_DRAW;
	enums[BufferUsageFrequency.Static][BufferUsageNature.Read] = GL_STATIC_READ;
	enums[BufferUsageFrequency.Static][BufferUsageNature.Copy] = GL_STATIC_COPY;

	enums[BufferUsageFrequency.Dynamic][BufferUsageNature.Draw] = GL_DYNAMIC_DRAW;
	enums[BufferUsageFrequency.Dynamic][BufferUsageNature.Read] = GL_DYNAMIC_READ;
	enums[BufferUsageFrequency.Dynamic][BufferUsageNature.Copy] = GL_DYNAMIC_COPY;
	return enums;
};
static unittest{
	static assert(usageEnumsTable[BufferUsageFrequency.Static][BufferUsageNature.Draw] == GL_STATIC_DRAW);
}

private GLenum usageEnum(in BufferUsageFrequency freq, in BufferUsageNature nature){
	return usageEnumsTable[freq][nature];
}
