#define FOW_SIZE_X 1024
#define FOW_SIZE_Y 512

#define X_OFFSET 0.52
#define Y_OFFSET 0.52


float4x4 WorldViewProjectionMatrix; 
float4x4 WorldMatrix;
float4x4 ViewProjectionMatrix;
float3	CameraPosition;
float	Time;

struct VS_INPUT_TI
{
   float4 position_uv			: POSITION;
};

struct VS_OUTPUT_TI
{
   float4 position				: POSITION;
	float2 WorldTexture			: TEXCOORD1;
};

texture FOWTex < string name = "Base.tga"; >;
texture OverlayTex < string name = "Base.tga"; >;
texture CloudTex < string name = "Base.tga"; >;

sampler FOWTexture  =
sampler_state
{
   Texture = <FOWTex>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = None;
   AddressU = Wrap;
   AddressV = Wrap;
};

sampler Overlay  =
sampler_state
{
   Texture = <OverlayTex>;
   MinFilter = Linear; //Point;
   MagFilter = Point;
   MipFilter = Linear;
   AddressU = Wrap;
   AddressV = Wrap;
};


sampler Cloud  =
sampler_state
{
   Texture = <CloudTex>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
   AddressU = Wrap;
   AddressV = Wrap;
};

float3 FowColor = float3( 0, 0, 0.05 );
float3 TiColor = float3( 0.75, 0.70, 0.5 );

VS_OUTPUT_TI VertexShader_TI(const VS_INPUT_TI IN )
{
	VS_OUTPUT_TI OUT;
	float2 pos = IN.position_uv.xy;
	pos -= CameraPosition.xz;
	OUT.position = mul( float4(pos.x, 0.0, pos.y, 1.0), ViewProjectionMatrix );
	OUT.WorldTexture.xy = IN.position_uv.zw;
	return OUT;
}

float4 PixelShader_TIFar( const VS_OUTPUT_TI v ) : COLOR
{
	float2 WorldTexUV = v.WorldTexture;
	WorldTexUV += 0.5 / float2( FOW_SIZE_X, FOW_SIZE_Y );
	float xoffset = X_OFFSET / FOW_SIZE_X;
	float yoffset = Y_OFFSET / FOW_SIZE_Y;

	float2 FOWTI  = tex2D( FOWTexture, WorldTexUV ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( -xoffset, yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( xoffset, yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( -xoffset, -yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( xoffset, -yoffset) ).ba;
	FOWTI.r /= 5;
	FOWTI.r -= 0.2;
	FOWTI.r *= 1.2;
	FOWTI.g -= 1.5;
	FOWTI.g *= 2;
	FOWTI = saturate( FOWTI );
	FOWTI.r = saturate( FOWTI.g + FOWTI.r ) * saturate( FOWTI.g * 20.0f ) ;
	


	float4 TI = float4(  TiColor, FOWTI.g );
	float2 OverlayUV = float2( v.WorldTexture.x * 20.0f, v.WorldTexture.y * 8.0f );
	float4 overlay = tex2D( Overlay, OverlayUV );
	float3 overlay_mask = overlay < .5;
	
	TI.rgb = overlay_mask * (2 * overlay.rgb * TI.rgb) + ( 1.0f - overlay_mask )*(1 - 2 * (1 - overlay.rgb) * (1 - TI.rgb));
	
	float4 Fow =float4( FowColor, FOWTI.r*0.6);

	float4 OutColor = lerp( Fow, TI, FOWTI.g );
	return OutColor;
}

float4 PixelShader_TINear( const VS_OUTPUT_TI v ) : COLOR
{
	float2 WorldTexUV = v.WorldTexture;
	WorldTexUV += 0.5 / float2( FOW_SIZE_X, FOW_SIZE_Y);
	float xoffset = X_OFFSET / FOW_SIZE_X;
	float yoffset = Y_OFFSET / FOW_SIZE_Y;

	float2 FOWTI  = tex2D( FOWTexture, WorldTexUV ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( -xoffset, yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( xoffset, yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( -xoffset, -yoffset) ).ba;
	FOWTI	+= tex2D( FOWTexture, WorldTexUV + float2( xoffset, -yoffset) ).ba;
	FOWTI.r /= 5;
	FOWTI.r -= 0.2;
	FOWTI.r *= 1.2;
	FOWTI.g -= 1.5;
	FOWTI.g *= 2;
	FOWTI = saturate( FOWTI );
	FOWTI.r = saturate( FOWTI.g + FOWTI.r );


	float2 OverlayUV = float2( v.WorldTexture.x * 20.0f, v.WorldTexture.y * 8.0f );
		
	float4 Fow = float4( FowColor, FOWTI.r*0.6);

	float4 TI = float4(  TiColor, FOWTI.g );
	float4 overlay = tex2D( Overlay, OverlayUV );
	float3 overlay_mask = overlay < .5;
	
	TI.rgb = overlay_mask * (2 * overlay.rgb * TI.rgb) + ( 1.0f - overlay_mask )*(1 - 2 * (1 - overlay.rgb) * (1 - TI.rgb));

	float4 OutColor = lerp( Fow, TI, FOWTI.g);

	return OutColor;
}

////////////////
technique TerraIncognitaFar
{
	pass p0
	{
		ALPHATESTENABLE = True;
		ALPHABLENDENABLE = True;
		ZEnable = False;
		ZWriteEnable = False;

		VertexShader = compile vs_2_0 VertexShader_TI();
		PixelShader = compile ps_2_0 PixelShader_TIFar();
	}
}

technique TerraIncognitaNear
{
	pass p0
	{
		ALPHATESTENABLE = True;
		ALPHABLENDENABLE = True;
		ZEnable = False;
		ZWriteEnable = False;

		VertexShader = compile vs_2_0 VertexShader_TI();
		PixelShader = compile ps_2_0 PixelShader_TINear();
	}
}

