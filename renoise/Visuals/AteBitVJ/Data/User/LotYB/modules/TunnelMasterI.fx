#include "System/Modules/user_shader_defines.fxh"

float4 PS(PS_INPUT inp) : SV_Target
{
    // return float4(
    //     frac(g_vecDisplaySize*.5),// works
    //     0,
    //     1);

    return float4(
        frac(g_fFloat1 + g_fSeconds),
        frac(g_fBeats + g_fSecondsVisible),
        frac(g_fBars + g_fSecondsActive),
        1);

    // return float4(
    //     frac(g_fSeconds*.5),
    //     frac(g_fSecondsVisible*.5),
    //     frac(g_fSecondsActive*.5),
    //     1);
}
