Config = {}

Config.Cams = {
  -- ============================================================
  -- Helikopter
  -- ============================================================
  ['polmav'] = {
    name = 'HelikopterCamV2',
    nightVision = true,
    thermalVision = true,
    normal = true,

    relativeCoords = vector4(
      0.0,  -- -links / +rechts
      2.6,  -- +vor / -zurück
      -1.0, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['buzzard'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      2.3,  -- +vor / -zurück
      -0.4, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['buzzard2'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      2.3,  -- +vor / -zurück
      -0.4, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['frogger'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      3.0,  -- +vor / -zurück
      -0.4, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['frogger2'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      3.0,  -- +vor / -zurück
      -0.4, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['maverick'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      3.8,  -- +vor / -zurück
      -0.6, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['maverick2'] = {
    name = 'HelikopterCamV2',
    nightVision = false,
    thermalVision = false,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      3.8,  -- +vor / -zurück
      -0.6, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },

  -- ============================================================
  -- Flugzeuge
  -- ============================================================

  ['raiju'] = {
    name = 'HelikopterCamV2',
    nightVision = true,
    thermalVision = true,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      7.0,  -- +vor / -zurück
      -0.5, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
  ['hydra'] = {
    name = 'HelikopterCamV2',
    nightVision = true,
    thermalVision = true,
    normal = true,

    relativeCoords = vector4(
      0.0, -- -links / +rechts
      6.0,  -- +vor / -zurück
      -1.0, -- -hoch / +runter
      0.0
    ),

    min_fov = 2.0, -- Klein also reinzoomen
    max_fov = 30.0, -- Groß also rauszomen

    min_pitch = -50.0,
    max_pitch = 50.0,

    min_rot = -180.0,
    max_rot = 180.0,
  },
}