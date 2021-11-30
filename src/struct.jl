using StaticArrays

import Base: propertynames, getproperty, setproperty!

struct RayVector2 <: FieldVector{2, Cfloat}
    x::Cfloat
    y::Cfloat
end

struct RayVector3 <: FieldVector{3, Cfloat}
    x::Cfloat
    y::Cfloat
    z::Cfloat
end

struct RayVector4 <: FieldVector{4, Cfloat}
    x::Cfloat
    y::Cfloat
    z::Cfloat
    w::Cfloat
end

const RayQuaternion = RayVector4

rayvector(v::Vararg{<:Real, 2}) = RayVector2(v)
rayvector(v::Vararg{<:Real, 3}) = RayVector3(v)
rayvector(v::Vararg{<:Real, 4}) = RayVector4(v)

const RayMatrix = SMatrix{4, 4, Cfloat, 16}
const RayMatrix2x2 = SMatrix{2, 2, Cfloat, 4}

mutable struct RayCamera3D
    #position::RayVector3  # Camera position
    position_x::Cfloat
    position_y::Cfloat
    position_z::Cfloat

    # target::RayVector3    # Camera target it looks-at
    target_x::Cfloat
    target_y::Cfloat
    target_z::Cfloat

    # up::RayVector3        # Camera up vector (rotation over its axis)
    up_x::Cfloat
    up_y::Cfloat
    up_z::Cfloat

    fovy::Cfloat          # Camera field-of-view apperture in Y (degrees) in perspective,
                          #   used as near plane width in orthographic
    projection::Cint      # Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
end

const RayCamera = RayCamera3D

RayCamera3D(position::RayVector3, target::RayVector3, up::RayVector3, fovy, projection) =
    RayCamera3D(position..., target..., up..., fovy, projection)

RayCamera3D(position, target, up, fovy, projection) =
    RayCamera3D(RayVector3(position), RayVector3(target), RayVector3(up), fovy, projection)

@inline function propertynames(x::RayCamera3D, private::Bool=false)
    if private
        return fieldnames(RayCamera3D)
    else
        return (:position, :target, :up, :fovy, :projection)
    end
end

@inline function getproperty(x::RayCamera3D, name::Symbol)
    if name == :position
        return rayvector(
            getfield(x, :position_x),
            getfield(x, :position_y),
            getfield(x, :position_z),
        )
    elseif name == :target
        return rayvector(
            getfield(x, :target_x),
            getfield(x, :target_y),
            getfield(x, :target_z),
        )
    elseif name == :up
        return rayvector(
            getfield(x, :up_x),
            getfield(x, :up_y),
            getfield(x, :up_z),
        )
    else
        return getfield(x, name)
    end
end

@inline function setproperty!(x::RayCamera3D, name::Symbol, v)
    if name == :position
        vv = RayVector3(v)
        setfield!(x, :position_x, vv.x)
        setfield!(x, :position_y, vv.y)
        setfield!(x, :position_z, vv.z)
        return vv
    elseif name == :target
        vv = RayVector3(v)
        setfield!(x, :target_x, vv.x)
        setfield!(x, :target_y, vv.y)
        setfield!(x, :target_z, vv.z)
        return vv
    elseif name == :up
        vv = RayVector3(v)
        setfield!(x, :up_x, vv.x)
        setfield!(x, :up_y, vv.y)
        setfield!(x, :up_z, vv.z)
        return vv
    else
        return setfield!(x, name, convert(fieldtype(RayCamera3D, name), v))
    end
end


mutable struct RayCamera2D
    # offset::RayVector2  # Camera offset (displacement from target)
    offset_x::Cfloat
    offset_y::Cfloat

    # target::RayVector2  # Camera target (rotation and zoom origin)
    target_x::Cfloat
    target_y::Cfloat

    rotation::Cfloat    # Camera rotation in degrees
    zoom::Cfloat        # Camera zoom (scaling), should be 1.0f by default
end

RayCamera2D(offset::RayVector2, target::RayVector2, rotation, zoom) = RayCamera2D(offset..., target..., rotation, zoom)

RayCamera2D(offset, target, rotation, zoom) = RayCamera2D(RayVector2(offset), RayVector2(target), rotation, zoom)

@inline function propertynames(x::RayCamera2D, private::Bool=false)
    if private
        return fieldnames(RayCamera2D)
    else
        return (:offset, :target, :rotation, :zoom)
    end
end


@inline function getproperty(x::RayCamera2D, name::Symbol)
    if name == :offset
        return rayvector(
            getfield(x, :offset_x),
            getfield(x, :offset_y),
        )
    elseif name == :target
        return rayvector(
            getfield(x, :target_x),
            getfield(x, :target_y),
        )
    else
        return getfield(x, name)
    end
end

@inline function setproperty!(x::RayCamera2D, name::Symbol, v)
    if name == :offset
        vv = RayVector2(v)
        setfield!(x, :offset_x, vv.x)
        setfield!(x, :offset_y, vv.y)
        return vv
    elseif name == :target
        vv = RayVector2(v)
        setfield!(x, :target_x, vv.x)
        setfield!(x, :target_y, vv.y)
        return vv
    else
        return setfield!(x, name, convert(fieldtype(RayCamera2D, name), v))
    end
end


struct RayRectangle
    x::Cfloat        # Rectangle top-left corner position x
    y::Cfloat        # Rectangle top-left corner position y
    width::Cfloat    # Rectangle width
    height::Cfloat   # Rectangle height
end

RayRectangle(p::RayVector2, width, height) = RayRectangle(p..., width, height)


struct RayImage
    data::Ptr{Cvoid}         # Image raw data
    width::Cint              # Image base width
    height::Cint             # Image base height
    mipmaps::Cint            # Mipmap levels, 1 by default
    format::Cint             # Data format (PixelFormat type)
end

struct RayTexture
    id::Cuint        # OpenGL texture id
    width::Cint      # Texture base width
    height::Cint     # Texture base height
    mipmaps::Cint    # Mipmap levels, 1 by default
    format::Cint     # Data format (PixelFormat type)
end

const RayTexture2D = RayTexture
const RayTextureCubemap = RayTexture

struct RayRenderTexture
    id::Cuint                # OpenGL framebuffer object id
    texture::RayTexture      # Color buffer attachment texture
    depth::RayTexture        # Depth buffer attachment texture
end

const RayRenderTexture2D = RayRenderTexture

struct RayNPatchInfo
    source::RayRectangle     # Texture source rectangle
    left::Cint               # Left border offset
    top::Cint                # Top border offset
    right::Cint              # Right border offset
    bottom::Cint             # Bottom border offset
    layout::Cint             # Layout of the n-patch: 3x3, 1x3 or 3x1
end

struct RayGlyphInfo
   value::Cint              # Character value (Unicode)
   offsetX::Cint            # Character offset X when drawing
   offsetY::Cint            # Character offset Y when drawing
   advanceX::Cint           # Character advance position X
   image::RayImage          # Character image data
end

struct RayFont
    baseSize::Cint                 # Base size (default chars height)
    glyphCount::Cint               # Number of glyph characters
    glyphPadding::Cint             # Padding around the glyph characters
    texture::RayTexture            # Texture atlas containing the glyphs
    recs::Ptr{RayRectangle}        # Rectangles in texture for the glyphs
    glyphs::Ptr{RayGlyphInfo}      # Glyphs info data
end

struct RayMesh
    vertexCount::Cint        # Number of vertices stored in arrays
    triangleCount::Cint      # Number of triangles stored (indexed or not)

    # Vertex attributes data
    vertices::Ptr{Cfloat}        # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords::Ptr{Cfloat}       # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2::Ptr{Cfloat}      # Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals::Ptr{Cfloat}         # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents::Ptr{Cfloat}        # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors::Ptr{Cuchar}          # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices::Ptr{Cuchar}         # Vertex indices (in case vertex data comes indexed)

    # Animation vertex data
    animVertices::Ptr{Cfloat}    # Animated vertex positions (after bones transformations)
    animNormals::Ptr{Cfloat}     # Animated normals (after bones transformations)
    boneIds::Ptr{Cuchar}         # Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights::Ptr{Cfloat}     # Vertex bone weight, up to 4 bones influence by vertex (skinning)

    # OpenGL identifiers
    vaoId::Cuint                 # OpenGL Vertex Array Object id
    vboId::Ptr{Cuint}            # OpenGL Vertex Buffer Objects id (default vertex data)
end

struct RayShader
    id::Cuint                    # Shader program id
    locs::Ptr{Cint}              # Shader locations array (RL_MAX_SHADER_LOCATIONS)
end

struct RayMaterialMap
    texture::RayTexture        # Material map texture
    color::RayColor            # Material map color
    value::Cfloat              # Material map value
end

struct RayMaterial
    shader::RayShader                # Material shader
    maps::Ptr{RayMaterialMap}        # Material maps array (MAX_MATERIAL_MAPS)
    params::NTuple{4, Cfloat}        # Material generic parameters (if required)
end

struct RayTransform
    translation::RayVector3     # Translation
    rotation::RayQuaternion     # Rotation
    scale::RayVector3           # Scale
end

struct RayBoneInfo
    name::NTuple{32, Cchar}          # Bone name
    parent::Cint                     # Bone parent
end

struct RayModel
    transform::RayMatrix              # Local transform matrix

    meshCount::Cint                   # Number of meshes
    materialCount::Cint               # Number of materials
    meshes::Ptr{RayMesh}              # Meshes array
    materials::Ptr{RayMaterial}       # Materials array
    meshMaterial::Ptr{Cint}           # Mesh material number

    # Animation data
    boneCount::Cint                   # Number of bones
    bones::Ptr{RayBoneInfo}           # Bones information (skeleton)
    bindPose::Ptr{RayTransform}       # Bones base transformation (pose)
end

struct RayModelAnimation
    boneCount::Cint                # Number of bones
    frameCount::Cint               # Number of animation frames
    bones::Ptr{RayBoneInfo}        # Bones information (skeleton)
    # Transform **framePoses        # Poses array by frame
    framePoses::Ptr{Ptr{RayTransform}}        # Poses array by frame
end

struct Ray
    position::RayVector3        # Ray position (origin)
    direction::RayVector3       # Ray direction
end

struct RayCollision
    hit::Bool                  # Did the ray hit something?
    distance::Cfloat           # Distance to nearest hit
    point::RayVector3          # Point of nearest hit
    normal::RayVector3         # Surface normal of hit
end

struct RayBoundingBox
    min::RayVector3     # Minimum vertex box-corner
    max::RayVector3     # Maximum vertex box-corner
end

struct RayWave
    frameCount::Cuint      # Total number of frames (considering channels)
    sampleRate::Cuint      # Frequency (samples per second)
    sampleSize::Cuint      # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels::Cuint        # Number of channels (1-mono, 2-stereo, ...)
    data::Ptr{Cvoid}       # Buffer data pointer
end

struct RayAudioStream
    # rAudioBuffer *buffer;       // Pointer to internal data used by the audio system
    buffer::Ptr{Cvoid}

    sampleRate::Cuint    # Frequency (samples per second)
    sampleSize::Cuint    # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels::Cuint      # Number of channels (1-mono, 2-stereo, ...)
end

struct RaySound
    stream::RayAudioStream         # Audio stream
    frameCount::Cuint              # Total number of frames (considering channels)
end

struct RayMusic
    stream::RayAudioStream        # Audio stream
    frameCount::Cuint             # Total number of frames (considering channels)
    looping::Bool                 # Music looping enable

    ctxType::Cint                 # Type of music context (audio filetype)
    ctxData::Ptr{Cvoid}           # Audio context data, depends on type
end

struct RayVrDeviceInfo
    hResolution::Cint                        # Horizontal resolution in pixels
    vResolution::Cint                        # Vertical resolution in pixels
    hScreenSize::Cfloat                      # Horizontal size in meters
    vScreenSize::Cfloat                      # Vertical size in meters
    vScreenCenter::Cfloat                    # Screen center in meters
    eyeToScreenDistance::Cfloat              # Distance between eye and display in meters
    lensSeparationDistance::Cfloat           # Lens separation distance in meters
    interpupillaryDistance::Cfloat           # IPD (distance between pupils) in meters
    lensDistortionValues::NTuple{4, Cfloat}  # Lens distortion constant parameters
    chromaAbCorrection::NTuple{4, Cfloat}    # Chromatic aberration correction parameters
end

struct RayVrStereoConfig
    projection::NTuple{2, RayMatrix}           # VR projection matrices (per eye)
    viewOffset::NTuple{2, RayMatrix}           # VR view offset matrices (per eye)
    leftLensCenter::NTuple{2, Cfloat}          # VR left lens center
    rightLensCenter::NTuple{2, Cfloat}         # VR right lens center
    leftScreenCenter::NTuple{2, Cfloat}        # VR left screen center
    rightScreenCenter::NTuple{2, Cfloat}       # VR right screen center
    scale::NTuple{2, Cfloat}                   # VR distortion scale
    scaleIn::NTuple{2, Cfloat}                 # VR distortion scale in
end

struct RayGuiStyleProp
    controlId::Cushort
    propertyId::Cushort
    propertyValue::Cint
end

const PHYSAC_MAX_VERTICES = 24

struct RayPhysicsVertexData
    vertexCount::Cuint                                 # Vertex count (positions and normals)
    positions::NTuple{PHYSAC_MAX_VERTICES, RayVector2} # Vertex positions vectors
    normals::NTuple{PHYSAC_MAX_VERTICES, RayVector2}   # Vertex normals vectors
end

struct RayPhysicsShape
    type::PhysicsShapeType                      # Shape type (circle or polygon)
    # body::Ptr{RayPhysicsBodyData}
    body::Ptr{Cvoid}                            # Shape physics body data pointer
    vertexData::RayPhysicsVertexData            # Shape vertices data (used for polygon shapes)
    radius::Cfloat                              # Shape radius (used for circle shapes)
    transform::RayMatrix2x2                     # Vertices transform matrix 2x2
end

struct RayPhysicsBodyData
    id::Cuint                            # Unique identifier
    enabled::Bool                        # Enabled dynamics state (collisions are calculated anyway)
    position::RayVector2                 # Physics body shape pivot
    velocity::RayVector2                 # Current linear velocity applied to position
    force::RayVector2                    # Current linear force (reset to 0 every step)
    angularVelocity::Cfloat              # Current angular velocity applied to orient
    torque::Cfloat                       # Current angular force (reset to 0 every step)
    orient::Cfloat                       # Rotation in radians
    inertia::Cfloat                      # Moment of inertia
    inverseInertia::Cfloat               # Inverse value of inertia
    mass::Cfloat                         # Physics body mass
    inverseMass::Cfloat                  # Inverse value of mass
    staticFriction::Cfloat               # Friction when the body has not movement (0 to 1)
    dynamicFriction::Cfloat              # Friction when the body has movement (0 to 1)
    restitution::Cfloat                  # Restitution coefficient of the body (0 to 1)
    useGravity::Bool                     # Apply gravity force to dynamics
    isGrounded::Bool                     # Physics grounded on other body state
    freezeOrient::Bool                   # Physics rotation constraint
    shape::RayPhysicsShape               # Physics body shape information (type, radius, vertices, transform)
end

struct RayPhysicsManifoldData
    id::Cuint                            # Unique identifier
    bodyA::Ptr{RayPhysicsBodyData}       # Manifold first physics body reference
    bodyB::Ptr{RayPhysicsBodyData}       # Manifold second physics body reference
    penetration::Cfloat                  # Depth of penetration from collision
    normal::RayVector2                   # Normal direction vector from 'a' to 'b'
    contacts::NTuple{2, RayVector2}      # Points of contact during collision
    contactsCount::Cuint                 # Current collision number of contacts
    restitution::Cfloat                  # Mixed restitution during collision
    dynamicFriction::Cfloat              # Mixed dynamic friction during collision
    staticFriction::Cfloat               # Mixed static friction during collision
end
