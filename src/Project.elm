module Project exposing (ukChoropleth)

import VegaLite exposing (..)



-- DATA
localAuthorityData : String
localAuthorityData = "https://martinjc.github.io/UK-GeoJSON/json/eng/topo_lad.json"



-- GRAPHS
ukChoropleth : Spec
ukChoropleth =
  let
    geographyData =
      dataFromUrl localAuthorityData
      [ topojsonFeature "lad" ]

    projectionSettings =
      projection
        [ prType transverseMercator
        , prRotate 2 0 0
        ]

    encodingSettings =
      encoding
      << color
        [ mName "id"
        , mNominal
        ]
  in
  toVegaLite
    [ width 800
    , height 1000
    , geographyData
    , projectionSettings
    , encodingSettings []
    , geoshape []
    ]