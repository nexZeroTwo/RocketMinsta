
textures/common/warpzone
{
    surfaceparm nolightmap
    // surfaceparm nonsolid // no, it must be solid like trigger
    surfaceparm trans
    surfaceparm nomarks
    {
        map textures/common/warpzone/trans.tga // fully transparent
        blendfunc blend
    }
    dp_camera
    dp_refract 1 1 1 1 // makes the camera render like a refraction
}

textures/common/camera
{
    surfaceparm nolightmap
    surfaceparm trans
    {
        map textures/common/warpzone/trans.tga // fully transparent
        blendfunc blend
    }
    dp_camera
}
