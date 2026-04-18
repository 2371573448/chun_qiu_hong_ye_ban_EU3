#include "terrain.h"

#define BRIGHTNESS 0.05 //-0.03
#define CONTRAST 1.0
#define DESATURATION 0.3


#define SEA_FLOOR_ALT 0.0

#define FOW_SIZE_X 1024
#define FOW_SIZE_Y 512
texture BorderDirectionTex < string ResourceName = "BorderDirection.dds"; >;	// Borders texture
texture BorderTex < string ResourceName = "BorderDirection.dds"; >;	// Borders texture
texture OverlayTex;


float4x4 WorldMatrix		: World; 
float4x4 ViewMatrix		: View; 
float4x4 ProjectionMatrix	: Projection; 
float4x4 AbsoluteWorldMatrix;
float3	 LightDirection;
float	 vAlpha;
float	 Selection;



float	BorderWidth;
float	BorderHeight;





sampler OverlayTexture  =
sampler_state
{
    Texture = <OverlayTex>;
    MinFilter = Linear; //Point;
    MagFilter = Linear; //Point;
    MipFilter = Linear; //None;
    AddressU = Wrap;
    AddressV = Wrap;
};






sampler BorderDirectionTexture  =
sampler_state
{
    Texture = <BorderDirectionTex>;
    MinFilter = Linear;
    MagFilter = Point;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler BorderTexture  =
sampler_state
{
    Texture = <BorderTex>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_INPUT
{
    float2 vPosition  : POSITION;
    int2 vProvinceId : TEXCOORD0;
};

struct VS_BORDER_INPUT
{
	int4 vPositionBorderLookup : POSITION;
	float4 vBorderOffsetColor : COLOR0;
};


struct VS_OUTPUT
{
    float4  vPosition : POSITION;
    float3  vTexCoord0 : TEXCOORD0;	// third beein' lightIntensity
    float2  vTexCoord1 : TEXCOORD1;
    float2  vColorTexCoord : TEXCOORD2;

    float2  vBorderTexCoord0 : TEXCOORD3;
    float2  vBorderTexCoord1 : TEXCOORD4;

    float2  vTerrainTexCoord : TEXCOORD5;

    float2 vProvinceIndexCoord  : TEXCOORD6;
    float4 vBorderOffsetColor : COLOR0;
    
    
};

struct VS_MAP_OUTPUT
{
    float4  vPosition : POSITION;
    float3  vTexCoord0 : TEXCOORD0;	// third beein' lightIntensity
    float2  vTexCoord1 : TEXCOORD1;
    float2  vColorTexCoord : TEXCOORD2;
	float2	vProvinceId : TEXCOORD3;
    float2  vTerrainTexCoord : TEXCOORD4; 
    float4	vTerrainIndexColor : TEXCOORD5;
};

///////	//////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////
// Map vertex shaders
///////////////////////////////////////////////////////////////////////////////////////

VS_MAP_OUTPUT VertexShader_Map_General(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;

	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);


	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );

	///////New Stuff

	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/vXStretch, WorldY/vYStretch );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	//Out.vColorTexCoord.xy = float2( WorldX, WorldY );
	
	WorldX =  WorldPosition.x / MapWidth *( ColorMapWidth / ColorMapTextureWidth );
	WorldY =  WorldPosition.z / MapHeight * ( ColorMapHeight / ColorMapTextureHeight );
	Out.vTexCoord1.xy = float2( WorldX , WorldY );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	
	//// End new stuff


	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;
	
	return Out;
}

VS_MAP_OUTPUT VertexShader_Map_General_Low(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;

	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);

	//float3 VertexNormal = mul( v.vNormal, WorldMatrix );
	//float3 direction = normalize( LightDirection );
	//Out.vTexCoord0.xy = v.vTexCoord;
	//Out.vTexCoord0.z = max( dot( VertexNormal, -direction ), 0.5f );
	//Out.vTexCoord1  = v.vTexCoord;
	//Out.vProvinceIndexCoord = v.vProvinceIndexCoord;

	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );

	///////New Stuff

	//Out.vBorderOffsetColor = v.vBorderOffsetColor;

	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( 20.0f * WorldX/ MapWidth, 8.0f * WorldY/ MapHeight );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	//Out.vColorTexCoord.xy = float2( WorldX, WorldY );
	

	WorldX =  WorldPosition.x / MapWidth *( ColorMapWidth / ColorMapTextureWidth );
	WorldY =  WorldPosition.z / MapHeight * ( ColorMapHeight / ColorMapTextureHeight );
	Out.vTexCoord1.xy = float2( WorldX , WorldY );
	
	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	
	//// End new stuff


	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;

	return Out;
}

VS_MAP_OUTPUT VertexShader_Map(const VS_INPUT v )
{
	VS_MAP_OUTPUT Out = (VS_MAP_OUTPUT)0;
	
	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);

	Out.vProvinceId = v.vProvinceId;

	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );
	
	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/16.0, WorldY/16.0 );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	
	WorldX =  WorldPosition.x / MapWidth *( ColorMapWidth / ColorMapTextureWidth );
	WorldY =  WorldPosition.z / MapHeight * ( ColorMapHeight / ColorMapTextureHeight );
	Out.vTexCoord1.xy = float2( WorldX , WorldY );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;		
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);
	return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
// Map fragment shaders
///////////////////////////////////////////////////////////////////////////////////////


float4 PixelShader_Map2_0_General( VS_MAP_OUTPUT v ) : COLOR
{
	
	TILE_STRUCT s;
    s.vTexCoord0 = v.vTexCoord0;
    s.vColorTexCoord = v.vColorTexCoord;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
    
    float4 TerrainColor = GenerateTiles( s );
 	
    float GreyT = dot( TerrainColor.rgb, GREYIFY ) * 0.25 + 0.4; 
		
	float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
  
	float4 Color1 = tex2D( GeneralTexture, vProvinceUV );
	float4 Color2 = tex2D( GeneralTexture2, vProvinceUV );
	
	float vColor = tex2D( StripesTexture, v.vTerrainTexCoord * 0.5 ).a;
	float4 Color = lerp(Color1, Color2, vColor);
	Color.rgb += Color1.a * Selection * 0.3 - 0.4;
	Color.rgb =  (1 - 2 * (1.0 - GreyT) * (1 - Color.rgb));
	Color.rgb = lerp( Color.rgb, Grey, 0.5  );
	
	Color.rgb *= COLOR_LIGHTNESS;

	return Color;
}


float4 PixelShader_Map2_0_General_Low( VS_MAP_OUTPUT v ) : COLOR
{
    float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
   	float4 Color1 = tex2D( GeneralTexture, vProvinceUV );
	float4 Color2 = tex2D( GeneralTexture2, vProvinceUV );

	float vColor = tex2D( StripesTexture, v.vTerrainTexCoord * 0.5 ).a;
	float4 Color = Color2 * vColor + Color1 * ( 1.0 - vColor );
	Color.rgb += Color1.a * Selection  * 0.5 - 0.7;
	float4 OverlayColor = tex2D( OverlayTexture, v.vColorTexCoord );
	float4 OutColor = 1;
	
	OutColor.rgb = OverlayColor.g < .5 ? (2 * OverlayColor.g * Color.rgb) : (1 - 2 * (1 - OverlayColor.g) * (1 - Color.rgb));

	OutColor.rgb = lerp( Grey, OutColor.rgb, 0.5);

	OutColor.rgb *= COLOR_LIGHTNESS;
	
	return OutColor;
}


float4 PixelShader_Map2_0( VS_MAP_OUTPUT v ) : COLOR
{
	
    TILE_STRUCT s;
    s.vTexCoord0 = v.vTexCoord0;
    s.vColorTexCoord = v.vColorTexCoord;
    s.vTerrainIndexColor = v.vTerrainIndexColor;
 
    float4 OutColor = GenerateTiles( s );
    OutColor.rgb = ApplyColorMap( OutColor.rgb, v.vTexCoord1.xy );
	float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
 
	float4 Color1 = tex2D( GeneralTexture, vProvinceUV );
	// SNOW
	OutColor.rgb = ApplySnow( OutColor.rgb, Color1.rgb );
	OutColor.rgb = lerp( OutColor.rgb, float3( ( 1.8 + Selection)* 0.3, ( 1.8 + Selection ) * 0.3, 0.5 ), Color1.a * 0.5 * ( Selection *0.5 + 0.5 ));

	return OutColor;
}



///////////////////////////////////////////////////////////////////////////////////////
// Border shader
/////////////////////////////////////////////////////////////////////////////////
struct VS_BORDER_OUTPUT
{
    float4  vPosition : POSITION;
    float4  vUV_ProvUV : TEXCOORD0;
    float4 vBorderOffsetColor : TEXCOORD1; 
};

#define MAX_HALF_SIZE 1000.0f
#define HALF_PIXEL 0.5f
#define BORDER_PADDING_OFFSET 0.02f;

VS_BORDER_OUTPUT VertexShader_Map_Border(const VS_BORDER_INPUT v )
{
	VS_BORDER_OUTPUT Out;
	
	float2 vSign = sign( v.vPositionBorderLookup.xy );
	Out.vUV_ProvUV.xy = saturate( vSign );
	Out.vUV_ProvUV.x *= 1.0f - 2 * BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.x += BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.x *= 0.8 / 32;
	Out.vUV_ProvUV.y *= 0.25f - 2 * BORDER_PADDING_OFFSET;
	Out.vUV_ProvUV.y += BORDER_PADDING_OFFSET;
	
	vSign *= -MAX_HALF_SIZE;
	vSign += HALF_PIXEL + v.vPositionBorderLookup.xy;
	float4 vPosition = float4( vSign.x , LAND_ALT + 0.02, vSign.y, 1 ); // Increase z slightly to remove z-fighting
	
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);

	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);
	
	Out.vUV_ProvUV.zw = v.vPositionBorderLookup.zw;
	Out.vBorderOffsetColor = v.vBorderOffsetColor;
	
	return Out;
}

#define BORDERLOOKUP_SIZE 512.0f

float4 PixelShader_Map2_0_Border( VS_BORDER_OUTPUT v ) : COLOR
{
	// Do some magic to transform the position to usable uv-coordinates
	float2 TexCoord = v.vUV_ProvUV.xy;
	
	float2 BorderUV = v.vUV_ProvUV.zw + 0.5f;
	BorderUV /= BORDERLOOKUP_SIZE;
	
	float4 BorderTypeColor = tex2D( BorderDirectionTexture, BorderUV );
	
	float2 TexCoord2 = TexCoord;
	float2 TexCoord3 = TexCoord;
	
	TexCoord.x += (v.vBorderOffsetColor.b * BorderTypeColor.b) + (BorderTypeColor.a * (1.0 - BorderTypeColor.b));
	TexCoord.y += BorderTypeColor.a * BorderTypeColor.b;
	float4 ProvinceBorder = tex2D( BorderTexture, TexCoord );
	
	TexCoord2.x += BorderTypeColor.r;
	TexCoord2.y += 0.25;
	float4 CountryBorder = tex2D( BorderTexture, TexCoord2 );
		
	TexCoord3.x += v.vBorderOffsetColor.a * BorderTypeColor.b + BorderTypeColor.g;
	TexCoord3.y += 0.5;
	TexCoord3.y += (BorderTypeColor.a * BorderTypeColor.b);
	
	float4 DiagBorder = tex2D( BorderTexture, TexCoord3 );

	ProvinceBorder.rgb *= ProvinceBorder.a;
	CountryBorder.rgb *= CountryBorder.a;
	DiagBorder.rgb *= DiagBorder.a;

	float4 OutColor = 0;
	
	OutColor.rgb = ProvinceBorder.rgb*ProvinceBorder.a;
	OutColor.a = max( ProvinceBorder.a, CountryBorder.a );
	OutColor.a = max( OutColor.a, DiagBorder.a );
	
	OutColor.rgb = CountryBorder.rgb * CountryBorder.a + OutColor.rgb*( 1.0f - CountryBorder.a );
	OutColor.rgb = max( OutColor.rgb, DiagBorder.rgb );

	return OutColor;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique TerrainShader_Graphical
{
	pass p0
	{
		VertexShader = compile vs_1_1 VertexShader_Map();
		PixelShader = compile ps_2_0 PixelShader_Map2_0();
	}
}

technique TerrainShader_General
{
	pass p0
	{
		VertexShader = compile vs_1_1 VertexShader_Map_General();
		PixelShader = compile ps_2_0 PixelShader_Map2_0_General();
	}
}

technique TerrainShader_General_Low
{
	pass p0
	{
		VertexShader = compile vs_1_1 VertexShader_Map_General_Low();
		PixelShader = compile ps_2_0 PixelShader_Map2_0_General_Low();
	}
}

technique TerrainShader_Border
{
	pass p0
	{
		ALPHABLENDENABLE = True;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		
		VertexShader = compile vs_1_1 VertexShader_Map_Border();
		PixelShader = compile ps_2_0 PixelShader_Map2_0_Border();
	}
}



