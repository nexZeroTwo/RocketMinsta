
sentry_flow
{
    deformVertexes wave 1 sin 0.1 0.2 0 1.5
    {
        map textures/sentry_flow.tga
        tcMod scale 3.5 1.0
        tcMod scroll 0.5 3
        blendfunc add
        rgbGen identityLighting
    }
}

sentry_ball_outer
{
    cull none
    {
        map textures/pryaxe_balls_outer.tga
        tcMod rotate 41
        tcMod scale 2.3 3.2
        tcMod scroll 1.2 0.9
        tcGen environment
        blendfunc add
        rgbGen identityLighting
    }
}
