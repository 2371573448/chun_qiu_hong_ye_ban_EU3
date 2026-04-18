xof 0303txt 0032
//
// DirectX file: D:\dick\eu3commongoods\New_Project\data\salt.x
//
// Converted by the PolyTrans geometry converter from Okino Computer Graphics, Inc.
// Date/time of export: 04/26/2007 13:19:37
//
// Bounding box of geometry = (-1.27966,0.181425,-1.89536) to (1.60871,1.25999,0.651108).


template Header {
 <3D82AB43-62DA-11cf-AB39-0020AF71E433>
 WORD major;
 WORD minor;
 DWORD flags;
}

template Vector {
  <3D82AB5E-62DA-11cf-AB39-0020AF71E433>
 FLOAT x;
 FLOAT y;
 FLOAT z;
}

template Coords2d {
  <F6F23F44-7686-11cf-8F52-0040333594A3>
 FLOAT u;
 FLOAT v;
}

template Matrix4x4 {
  <F6F23F45-7686-11cf-8F52-0040333594A3>
 array FLOAT matrix[16];
}

template ColorRGBA {
  <35FF44E0-6C7C-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
 FLOAT alpha;
}

template ColorRGB {
 <D3E16E81-7835-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
}

template IndexedColor {
 <1630B820-7842-11cf-8F52-0040333594A3>
DWORD index;
 ColorRGBA indexColor;
}

template Boolean {
 <4885AE61-78E8-11cf-8F52-0040333594A3>
WORD truefalse;
}

template Boolean2d {
 <4885AE63-78E8-11cf-8F52-0040333594A3>
Boolean u;
 Boolean v;
}

template MaterialWrap {
 <4885AE60-78E8-11cf-8F52-0040333594A3>
Boolean u;
 Boolean v;
}

template TextureFilename {
 <A42790E1-7810-11cf-8F52-0040333594A3>
 STRING filename;
}

template Material {
 <3D82AB4D-62DA-11cf-AB39-0020AF71E433>
 ColorRGBA faceColor;
 FLOAT power;
 ColorRGB specularColor;
 ColorRGB emissiveColor;
 [...]
}

template MeshFace {
 <3D82AB5F-62DA-11cf-AB39-0020AF71E433>
 DWORD nFaceVertexIndices;
 array DWORD faceVertexIndices[nFaceVertexIndices];
}

template MeshFaceWraps {
 <4885AE62-78E8-11cf-8F52-0040333594A3>
 DWORD nFaceWrapValues;
 Boolean2d faceWrapValues;
}

template MeshTextureCoords {
 <F6F23F40-7686-11cf-8F52-0040333594A3>
 DWORD nTextureCoords;
 array Coords2d textureCoords[nTextureCoords];
}

template MeshMaterialList {
 <F6F23F42-7686-11cf-8F52-0040333594A3>
 DWORD nMaterials;
 DWORD nFaceIndexes;
 array DWORD faceIndexes[nFaceIndexes];
 [Material]
}

template MeshNormals {
 <F6F23F43-7686-11cf-8F52-0040333594A3>
 DWORD nNormals;
 array Vector normals[nNormals];
 DWORD nFaceNormals;
 array MeshFace faceNormals[nFaceNormals];
}

template MeshVertexColors {
 <1630B821-7842-11cf-8F52-0040333594A3>
 DWORD nVertexColors;
 array IndexedColor vertexColors[nVertexColors];
}

template Mesh {
 <3D82AB44-62DA-11cf-AB39-0020AF71E433>
 DWORD nVertices;
 array Vector vertices[nVertices];
 DWORD nFaces;
 array MeshFace faces[nFaces];
 [...]
}

template FrameTransformMatrix {
 <F6F23F41-7686-11cf-8F52-0040333594A3>
 Matrix4x4 frameMatrix;
}

template Frame {
 <3D82AB46-62DA-11cf-AB39-0020AF71E433>
 [...]
}

Header {
	1; // Major version
	0; // Minor version
	1; // Flags
}

Material xof_default {
	0.400000;0.400000;0.400000;1.000000;;
	32.000000;
	0.700000;0.700000;0.700000;;
	0.000000;0.000000;0.000000;;
}

Material lambert15 {
	1.0;1.0;1.0;1.000000;;
	0.000000;
	0.000000;0.000000;0.000000;;
	0.000000;0.000000;0.000000;;
	TextureFilename {
		"salt.tga";
	}
}

// Top-most frame encompassing the 'World'
Frame Frame_World {
	FrameTransformMatrix {
		1.000000, 0.0, 0.0, 0.0, 
		0.0, 1.000000, 0.0, 0.0, 
		0.0, 0.0, -1.000000, 0.0, 
		0.0, 0.0, 0.0, 1.000000;;
	}

Frame Frame_salt {
	FrameTransformMatrix {
		1.000000, 0.0, 0.0, 0.0, 
		0.0, 1.000000, 0.0, 0.0, 
		0.0, 0.0, 1.000000, 0.0, 
		-28.370749, 0.0, 0.0, 1.000000;;
	}

// Original object name = "salt"
Mesh salt {
	23;		// 23 vertices
	29.445717;0.181425;-1.106941;,
	29.103195;0.181425;-1.865250;,
	28.271660;0.181425;-1.895355;,
	27.438221;0.181425;-1.179611;,
	27.091087;0.181425;-0.137297;,
	27.433613;0.181425;0.621010;,
	28.265148;0.181425;0.651108;,
	29.098587;0.181425;-0.064632;,
	28.838486;0.941727;-1.471069;,
	28.268402;1.017601;-0.622120;,
	27.757980;1.259995;0.137981;,
	28.571102;0.181425;0.293240;,
	28.571102;0.181425;0.293240;,
	29.116982;0.181425;-0.580849;,
	29.116982;0.181425;-0.580849;,
	29.979462;0.243629;-0.426208;,
	29.677826;0.243629;-0.651886;,
	29.413277;0.243629;-0.424706;,
	29.303101;0.243629;-0.093866;,
	29.411819;0.243629;0.146827;,
	29.724304;0.243629;0.099585;,
	29.940292;0.243629;-0.070802;,
	29.641022;0.541489;-0.194489;;

	21;		// 21 faces
	3;8,1,0;,
	3;8,2,1;,
	3;2,9,3;,
	3;8,9,2;,
	3;9,4,3;,
	3;9,10,4;,
	3;10,5,4;,
	3;10,6,5;,
	3;7,10,9;,
	3;10,7,12;,
	3;8,0,14;,
	3;10,11,6;,
	3;13,9,8;,
	3;9,13,7;,
	3;22,16,15;,
	3;22,17,16;,
	3;22,18,17;,
	3;22,19,18;,
	3;22,20,19;,
	3;22,21,20;,
	3;22,15,21;;

	MeshMaterialList {
		1;1;0;;
		{lambert15}
	}

	MeshNormals {
		23; // 23 normals
		-0.762778;0.628198;-0.153417;,
		-0.657605;0.753076;0.020791;,
		-0.571591;0.728653;-0.377292;,
		-0.532540;0.767148;-0.357612;,
		-0.490649;0.474774;0.730653;,
		-0.345661;0.677001;-0.649760;,
		-0.266518;0.807712;0.525899;,
		-0.053325;0.971515;-0.230902;,
		-0.042103;0.835687;-0.547590;,
		-0.021024;0.997069;0.073560;,
		0.073571;0.823019;0.563230;,
		0.281866;0.712840;0.642192;,
		0.325020;0.526558;0.785556;,
		0.439057;0.856929;-0.270005;,
		0.472857;0.529699;-0.704149;,
		0.493516;0.476766;0.727417;,
		0.556565;0.801769;-0.217721;,
		0.591197;0.733370;0.335640;,
		0.620662;0.681445;0.387828;,
		0.632461;0.554638;0.540713;,
		0.646613;0.686893;0.331769;,
		0.682510;0.702576;0.201416;,
		0.778211;0.627864;0.013219;;

		21;		// 21 faces
		3;13,14,22;,
		3;13,5,14;,
		3;5,7,3;,
		3;13,7,5;,
		3;7,0,3;,
		3;7,10,0;,
		3;10,4,0;,
		3;10,12,4;,
		3;20,10,7;,
		3;10,20,15;,
		3;13,22,18;,
		3;10,19,12;,
		3;21,7,13;,
		3;7,21,20;,
		3;9,8,16;,
		3;9,2,8;,
		3;9,1,2;,
		3;9,6,1;,
		3;9,11,6;,
		3;9,17,11;,
		3;9,16,17;;
	}  // End of Normals

	MeshTextureCoords {
		23; // 23 texture coords
		0.757086;0.182757;,
		0.500000;0.051351;,
		0.242914;0.182757;,
		0.136425;0.500000;,
		0.242914;0.817243;,
		0.500000;0.948649;,
		0.757086;0.817243;,
		0.863575;0.500000;,
		0.500000;0.193614;,
		0.500000;0.500000;,
		0.500000;0.774323;,
		0.810331;0.658622;,
		0.810331;0.658622;,
		0.818671;0.366227;,
		0.818671;0.366227;,
		0.691919;0.200111;,
		0.242914;0.182757;,
		0.136425;0.500000;,
		0.242914;0.817243;,
		0.500000;0.948649;,
		0.783709;0.737932;,
		0.863575;0.500000;,
		0.500000;0.560565;;
	}  // End of texture coords
} // End of Mesh
} // End of frame for 'salt'
} // End of "World" frame
