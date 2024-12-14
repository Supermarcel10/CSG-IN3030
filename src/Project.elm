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
    ps =
      params
        << param "scale" [ paValue (num 8000), paBind (ipRange [ inName "Scale", inMin 8000, inMax 40000, inStep 1000 ]) ]
        << param "cenLambda" [ paValue (num -1), paBind (ipRange [ inName "Center λ", inMin -3.7, inMax 0.5, inStep 0.05 ]) ]
        << param "cenPhi" [ paValue (num 53), paBind (ipRange [ inName "Center 𝜙", inMin 50.5, inMax 55.5, inStep 0.05 ]) ]

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
        , prCenterExpr "cenLambda" "cenPhi"
        , prNumExpr "scale" prScale
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
    , ps []
    , trans []
    , proj
    , enc []
    , geoshape
      [ maStroke "white"
      , maStrokeWidth 0.1
      ]
    ]