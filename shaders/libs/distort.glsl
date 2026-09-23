const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

vec3 warpShadowClipPos(vec3 clipPos) {
    float warp = length(clipPos.xy) + 0.1;
    clipPos.xy /= warp;
    clipPos.z *= 0.5;
    return clipPos;
}