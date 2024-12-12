module Project exposing (ukChoropleth)

import VegaLite exposing (..)



-- DATA
topoJson : String
topoJson = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-EN_topo.json"

dataCsv : String
dataCsv = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-RM080-2021-1.csv"



-- GRAPHS
ukChoropleth : Spec
ukChoropleth =
  let
    geographyData =
      dataFromUrl topoJson
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