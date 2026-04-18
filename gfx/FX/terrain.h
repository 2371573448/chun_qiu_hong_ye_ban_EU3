// Common terrain structs / textures / functions shared by several shaders
#define LAND_ALT 0.35

//Change these when changing num tiles....
const float NUM_TILES = 1.0/8.0;
//const float NUM_TILES_Y = 1.0/8.0;


//32.0 = 64 textures    16.0 = 256 textures
#define NUM_TERRAINS_FACTOR 32.0 //NUM_TILES_X * 256.0 / Num Terrains?
#define TILE_STRETCH_FACTOR 8.0
#define TILE_STRETCH_DIVIDE 0.125 //1.0 / TILE_STRETCH_FACTOR
#define XY_CLAMP 0.125

#define X_OFFSET 0.5
#define Z_OFFSET 0.5
#define X_MAGIC 1.0f
#define Y_MAGIC 0.0f

const float3 GREYIFY = float3( 0.212671, 0.715160, 0.072169 );
#define COLOR_VALUE 0.9
#define COLOR_LIGHTNESS 1.5

float4 White = float4( 0.8, 0.8, 0.8, 1 );
float4 Grey = float4( 0.6, 0.6, 0.6, 1 );
float4 FowColor = float4( 0.2, 0.2, 0.2, 1 );
#define PROVINCE_LOOKUP_SIZE 256.0f

const float vXStretch = 16; //higher gives textures more stretch change both values
const float vYStretch = 16;
//////////////////////////////////////////////////////////////////////////
// Constants
float	ColorMapHeight;
float	ColorMapWidth;
float	ColorMapTextureHeight;
float	ColorMapTextureWidth;
float	MapWidth;
float	MapHeight;
float TerrainIndexOffsetX;
float TerrainIndexOffsetY;
float TerrainIndexSizeX;
float TerrainIndexSizeY;

//////////////////////////////////////////////////////////////////////////
// Textures
texture QuadIndexTex < string ResourceName = "Base.tga"; >;		// Base texture
texture ColorTex < string ResourceName = "Base.tga"; >;		// Base texture
texture NoiseTex < string ResourceName = "Base.tga"; >;		// Base texture
texture TextureSheetTex < string ResourceName = "Base.tga"; >;		// Base texture
texture GeneralTex < string ResourceName = "Color.dds"; >;		// Color texture
texture General2Tex < string ResourceName = "Color.dds"; >;		// Terrain Alpha Mask
texture StripeTex < string ResourceName = "TerraIncog.dds"; >;

//////////////////////////////////////////////////////////////////////////
// Samplers
sampler QuadIndexTexture  =
sampler_state
{
	Texture = <QuadIndexTex>;
	MinFilter = Point; //Linear;
	MagFilter = Point; //Linear;
	MipFilter = None;
	AddressU = Mirror;
	AddressV = Mirror;
};


sampler ColorTexture  =
sampler_state
{
	Texture = <ColorTex>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Wrap;
	AddressV = Wrap;
};

sampler NoiseTexture  =
sampler_state
{
	Texture = <NoiseTex>;
	MinFilter = Linear; //Point;
	MagFilter = Linear; //Point;
	MipFilter = Linear; //None;
	AddressU = Wrap;
	AddressV = Wrap;
};

sampler TextureSheet  =
sampler_state
{
	Texture = <TextureSheetTex>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
};

sampler StripesTexture  =
sampler_state
{
	Texture = <StripeTex>;
	MinFilter = Linear; //Point;
	MagFilter = Linear; //Point;
	MipFilter = None;
	AddressU = Wrap;
	AddressV = Wrap;
};

// used for political, religious etc etc..
sampler GeneralTexture  =
sampler_state
{
	Texture = <GeneralTex>;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
};

sampler GeneralTexture2  =
sampler_state
{
	Texture = <General2Tex>;
	MinFilter = Point;
	MagFilter = Point;
	MipFilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
};

//////////////////////////////////////////////////////////////////////////
// Functions
struct TILE_STRUCT
{
	float2  vTexCoord0 : TEXCOORD0;
	float2  vColorTexCoord : TEXCOORD2;
	float2 vTerrainIndexColor : COLOR0;
};


float4 GenerateTiles( TILE_STRUCT v )
{
	float4 IndexColor = tex2D( QuadIndexTexture, v.vTerrainIndexColor.xy ); //Coordinates for for quad texture of index colors

	float2 noisecoord = v.vTexCoord0+0.5;
	float3 noisy = tex2D(NoiseTexture, noisecoord ).rgb;

	IndexColor *= 256.0; //size of colorbyte

	float4 IndexCoordX = fmod(IndexColor, NUM_TERRAINS_FACTOR); //x coord in tiles sheet
	IndexCoordX = trunc(IndexCoordX);
	float4 vIndexCoordX = IndexCoordX / NUM_TERRAINS_FACTOR;

	float4 IndexCoordY = IndexColor / NUM_TERRAINS_FACTOR; //y coord in tiles sheet
	IndexCoordY = trunc(IndexCoordY);
	float4 vIndexCoordY = IndexCoordY * NUM_TILES;

	float2 TexCoord = v.vColorTexCoord + 0.5;
	TexCoord = frac( TexCoord ); // 0 => 1 range.. only thing we need is the decimal part.
	TexCoord.x = 1.0 - TexCoord.x;

	float2 PixelTexCoord = v.vTexCoord0;
	PixelTexCoord = frac( PixelTexCoord ); // 0 => 1 range.. only thing we need is the decimal part.

	TexCoord.xy *= NUM_TILES;
	//TexCoord.y *= NUM_TILES_Y;

	TexCoord.xy = clamp( TexCoord.xy, 0.001, XY_CLAMP );
	//TexCoord.y = clamp( TexCoord.y, 0.001, Y_CLAMP );

	float2 uvThis;
	uvThis.x = vIndexCoordX.x;
	uvThis.y = vIndexCoordY.x;

	float4 LeftTerrain = tex2D( TextureSheet, TexCoord + uvThis );

	uvThis.x = vIndexCoordX.y;
	uvThis.y = vIndexCoordY.y;

	float4 UpLeftTerrain = tex2D( TextureSheet, TexCoord + uvThis );

	uvThis.x = vIndexCoordX.z;
	uvThis.y = vIndexCoordY.z;

	float4 Terrain = tex2D( TextureSheet, TexCoord + uvThis ); //->left

	//return Terrain;	
	uvThis.x = vIndexCoordX.w;
	uvThis.y = vIndexCoordY.w;

	float4 UpTerrain = tex2D( TextureSheet, TexCoord + uvThis ); //->upleft

	float4 x1 = lerp( LeftTerrain, Terrain, saturate( PixelTexCoord.x + noisy.x)  );
	float4 x2 = lerp( UpLeftTerrain, UpTerrain, saturate( PixelTexCoord.x + noisy.y) );
	float4 y1 = lerp( x1,x2, saturate( PixelTexCoord.y + noisy.z)  );

	return y1;
}

float3 ApplyColorMap( float3 Color, float2 vColorUV )
{
	float3 ColorColor = tex2D( ColorTexture, vColorUV ).rgb; //Coordinates for colormap
	return ( Color*2.0f + ColorColor )/3.0f;
}
float3 ApplySnow( float3 Color, float3 Snow )
{
	Color.rgb += Snow.b * Color.b;
	Color.rgb = lerp( Color.rgb, float3( 0.8, 0.8, 1.0 ), Snow.r );
	return Color;
}