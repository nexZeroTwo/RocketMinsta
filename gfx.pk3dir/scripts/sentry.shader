
sentry_flow
{
    deformVertexes wave 1 sin 0.1 0.2 0 1.5
    {
        map textures/sentry_flow.tga
        tcMod scale 3.5 1.0
        tcMod scroll 0.5 3
        blendfunc add
        rgbGen lightingDiffuse
    }
}
