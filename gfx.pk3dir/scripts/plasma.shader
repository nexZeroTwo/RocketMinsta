
textures/plasmabomb_ball_inner
{
    cull none
    deformVertexes wave 1 sin 0.1 0.25 0 1.5
    {
        map textures/plasmaglow.tga
        // tcMod rotate 95
        tcMod scale 0.5 0.34
        tcMod scroll 1 0.74
        tcGen environment
        blendfunc add
        rgbgen identity
    }
}

textures/plasmabomb_ball_outer
{
    cull none
    {
        map textures/pryaxe_balls_outer.tga
        tcMod rotate 41
        tcMod scale 2.3 3.2
        tcMod scroll 1.2 0.9
        tcGen environment
        blendfunc add
    }
}
