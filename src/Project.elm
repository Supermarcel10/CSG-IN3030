module Project exposing (ukChoropleth)

import VegaLite exposing (..)



-- DATA
topoJson : String
topoJson = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-EN_topo.json"

dataCsv : String
dataCsv = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-RM080-2021-1.csv"


-- TODO: Search through the data to see why so many authorities are missing
-- TODO: Add zooming interaction
-- TODO: Add selection

-- GRAPHS
ukChoropleth : Spec
ukChoropleth =
  let
    geoData =
      dataFromUrl topoJson
      [ topojsonFeature "lad" ]

    csvData =
      dataFromUrl dataCsv []

    trans =
      transform
        << lookup "id"
          csvData
          "authority_id"
          (luFields
            [ "authority_name"
            , "english_proficiency"
            , "industry"
            , "qualification"
            , "deprivation"
            , "count"
            ])

    proj =
      projection
        [ prType transverseMercator
        , prRotate 2 0 0
        ]

    enc =
      encoding
      << color
        [ mName "count"
        , mNominal
        , mLegend []
        ]
      << tooltip
        [ tName "id"
        , tNominal
        ]
  in
  toVegaLite
    [ width 800
    , height 1000
    , geoData
    , trans []
    , proj
    , enc []
    , geoshape
      [ maStroke "white"
      , maStrokeWidth 0.1
      ]
    ]