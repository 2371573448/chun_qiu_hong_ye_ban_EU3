_0.dds through _10.dds are used for the terrain. (this will change to a more dynamic way of doin' things later on..)

The dds files are in the format DXT1, which is a compressed RGB with one bit alpha (for masking ).
Here you can find a good plugin for Photoshop:
http://developer.nvidia.com/object/photoshop_dds_plugins.html

The textures are 64x64. They consist of a 40x40 square in the center which maps over a "pixel" in the terrain/province-map, and a border of 12 pixels that is masked off, or not if you want something to "leak" into sorounding squares.

Right now some stuff has some simple masking, but nothing elaborate.