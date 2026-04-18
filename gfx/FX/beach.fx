#include "terrain.h"

float4x4	WorldMatrix		: World; 
float4x4	ViewMatrix		: View; 
float4x4	ProjectionMatrix	: Projection; 
float4x4	AbsoluteWorldMatrix;
float2		QuadSize;
float		Selection;
///////////////////////////////////////////////////////////////////////////////////////
// Beach shader
///////////////////////////////////////////////////////////////////////////////////////

struct VS_INPUT_BEACH
{
    float2 vPosition  : POSITION;
    int2 vProvinceId : TEXCOORD0;
};

struct VS_OUTPUT_BEACH
{
    float4  vPosition : POSITION;
    float2  vColorTexCoord : TEXCOORD0;
    float2  vTexCoord0 : TEXCOORD1;
    float2	vTexCoord1  : TEXCOORD2;
    
    float2 vTerrainTexCoord : TEXCOORD5;
    float2 vTerrainIndexColor : TEXCOORD6;
    float2 vProvinceId			: TEXCOORD3;
 };

VS_OUTPUT_BEACH VertexShader_Beach(const VS_INPUT_BEACH v )
{
	float4 vPosition = float4( v.vPosition.x, LAND_ALT, v.vPosition.y, 1 );
	
	VS_OUTPUT_BEACH Out;
	float4x4 WorldView = mul(WorldMatrix, ViewMatrix);
	float3 P = mul(vPosition, (float4x3)WorldView);
	Out.vPosition  = mul(float4(P, 1), ProjectionMatrix);

	float4 WorldPosition = mul( vPosition, AbsoluteWorldMatrix );
		
	float WorldX = WorldPosition.x;
	float WorldY = WorldPosition.z;
	
	Out.vColorTexCoord.xy = float2( WorldX/vXStretch, WorldY/vYStretch );
	Out.vTexCoord0.xy = float2( WorldX, WorldY );
	
	WorldX =  WorldPosition.x / MapWidth * ( ColorMapWidth / ColorMapTextureWidth );
	WorldY =  WorldPosition.z / MapHeight * ( ColorMapHeight / ColorMapTextureHeight );
	Out.vTexCoord1.xy = float2( WorldX , WorldY );

	Out.vTerrainIndexColor.x = ((WorldPosition.x - TerrainIndexOffsetX) + X_MAGIC ) / TerrainIndexSizeX;
	Out.vTerrainIndexColor.y = ((WorldPosition.z - TerrainIndexOffsetY) + Y_MAGIC ) / TerrainIndexSizeY;
	
	Out.vTerrainIndexColor = clamp(Out.vTerrainIndexColor,0.0,1.0);

	float2 TerrainCoord = WorldPosition.xz;
	TerrainCoord += 0.5;
	TerrainCoord /= 8.0;
	Out.vTerrainTexCoord  = TerrainCoord;

	Out.vProvinceId = v.vProvinceId;

	return Out;
}


float4 PixelShader_Beach_General( VS_OUTPUT_BEACH v ) : COLOR
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


float4 PixelShader_Beach_General_Low( VS_OUTPUT_BEACH v ) : COLOR
{
	float2 vProvinceUV = v.vProvinceId + 0.5f;
    vProvinceUV /= PROVINCE_LOOKUP_SIZE;
 
	float4 Color = tex2D( GeneralTexture, vProvinceUV );
	float4 OutColor;
	OutColor.rgb = Color.rgb;
	OutColor.a = 1;
	OutColor.rgb = lerp( Grey, float3(OutColor.r,OutColor.g,OutColor.b), 0.5);

	return OutColor;
}




float4 PixelShader_Beach( VS_OUTPUT_BEACH v ) : COLOR
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
	OutColor.rgb = ApplySnow( OutColor.rgb, Color1.rgb );
	OutColor.rgb = lerp( OutColor.rgb, float3( ( 1.8 + Selection)* 0.3, ( 1.8 + Selection ) * 0.3, 0.5 ), Color1.a * 0.5 * ( Selection *0.5 + 0.5 ));
 
	return OutColor;
}


technique BeachShader_Graphical
{
	pass p0
	{			
		VertexShader = compile vs_1_1 VertexShader_Beach();
		PixelShader = compile ps_2_0 PixelShader_Beach();
	}
}


technique BeachShader_General
{
	pass p0
	{					
		VertexShader = compile vs_1_1 VertexShader_Beach();
		PixelShader = compile ps_2_0 PixelShader_Beach_General();
	}
}

technique BeachShader_General_Low
{
	pass p0
	{
		VertexShader = compile vs_1_1 VertexShader_Beach();
		PixelShader = compile ps_2_0 PixelShader_Beach_General_Low();
	}
}
