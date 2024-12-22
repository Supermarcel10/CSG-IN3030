module Project exposing (ukChoropleth, combinedDashboard)

import VegaLite exposing (..)
import ColumnLookup exposing (..)


-- DATA
topoJson : String
topoJson = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-EN_topo.json"

dataCsv : String
dataCsv = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-RM080-2021-1.csv"


-- TODO: Search through the data to see why so many authorities are missing

-- GRAPHS
ukChoropleth : Spec
ukChoropleth =
  let
    cfg =
      configure
      << configuration (coBackground "#06070E")

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
    , cfg []
    , geoData
    , ps []
    , trans []
    , proj
    , enc []
    , geoshape
      [ maStroke "#2B3264"
      , maStrokeWidth 0.1
      , maFill "#0C0E1D"
      ]
    ]


combinedDashboard : Spec
combinedDashboard =
    let
      desiredAuthority = "E06000001"

      cfg =
        configure
        << configuration (coView [ vicoStroke Nothing ])
        << configuration (coBackground "#06070E")
        << configuration
          (coText [ maColor "white" ])
        << configuration
          (coAxis [ axcoLabelColor "white", axcoTitleColor "white" ])
        << configuration
          (coLegend
            [ lecoLabelColor "white"
            , lecoTitleColor "white"
            ]
          )


      -- English Proficiency Pie Chart
      profTrans =
        transform
        << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
        << calculateAsProficiencyLabel

      profEnc =
        encoding
        << position Theta [ pName "count", pQuant ]
        << color
          [ mName "proficiency_label"
          , mLegend []
          , mScale [ scRange (raStrs ["#2a9d8f", "#e9c46a", "#e76f51"]) ]
          ]
        << tooltip
          [ tName "proficiency_label"
          , tNominal
          ]

      pieSpec =
        asSpec
          [ title "English Proficiency" [ tiColor "white", tiFontSize 16 ]
          , width 300
          , height 300
          , data
          , profTrans []
          , profEnc []
          , arc [ maStrokeWidth 0 ]
          ]


      -- Industry Qualification Bars
      qualTrans =
        transform
          << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
          << calculateAsQualificationLabel
          << calculateAsIndustryCode
          << calculateAsIndustryLabel
          << joinAggregate
            [ opAs opSum "count" "industry_total" ]
            [ wiGroupBy [ "industry_label" ] ]
          << calculateAs "datum.count/datum.industry_total * 100" "percentage"

      sortOrder =
        soCustom
          (strs
            [ "No qualifications"
            , "Level 1"
            , "Level 2"
            , "Level 3"
            , "Level 4"
            , "Other qualifications"
            ]
          )

      qualEnc =
        encoding
        << position X [ pName "count", pAggregate opSum, pTitle "Count" ]
        << position Y
          [ pName "industry_code"
          , pTitle "Industry"
          , pSort [ sortOrder ]
          ]
        << color
          [ mName "qualification_label"
          , mTitle "Qualifications"
          , mScale [ scRange (raStrs ["#e76f51", "#f4a261", "#e9c46a", "#2a9d8f", "#287271", "#AAAAAA"]) ]
          , mSort [ sortOrder ]
          ]
        << tooltips
          [ [ tName "industry_label", tTitle "Industry" ]
          , [ tName "qualification_label", tTitle "Qualification" ]
          , [ tName "count", tAggregate opSum, tTitle "Count" ]
          , [ tName "percentage", tFormat ".1f", tTitle "% of Industry" ]
          ]

      barsSpec =
        asSpec
          [ title "Industry Qualifications" [ tiColor "white", tiFontSize 16 ]
          , width 600
          , height 300
          , data
          , qualTrans []
          , qualEnc []
          , bar []
          ]


      -- Deprivation Stats
      depOverallTrans =
        transform
        << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
        << aggregate
          [ opAs opSum "count" "total_count" ]
          [ "deprivation" ]
        << joinAggregate
          [ opAs opSum "total_count" "grand_total" ]
          [ wiGroupBy [] ]
        << filter (fiExpr "datum.deprivation == 1")
        << calculateAs "datum.total_count / datum.grand_total * 100" "percent_deprived"

      depIndustryTrans =
        transform
        << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
        << aggregate
          [ opAs opSum "count" "industry_total" ]
          [ "industry", "deprivation" ]
        << joinAggregate
          [ opAs opSum "industry_total" "total_per_industry" ]
          [ wiGroupBy [ "industry" ] ]
        << filter (fiExpr "datum.deprivation == 1")
        << calculateAsIndustryCode
        << calculateAsIndustryLabel
        << calculateAs "datum.industry_total / datum.total_per_industry * 100" "percent_deprived"

      textEnc =
        encoding
        << text [ tName "percent_deprived", tFormat ".2f" ]

      textSpec =
        asSpec
          [ width 300
          , height 100
          , data
          , depOverallTrans []
          , textEnc []
          , textMark [ maColor "white", maSize 48, maAlign haCenter, maBaseline vaMiddle ]
          ]

      depBarsEnc =
        encoding
        << position X [ pName "percent_deprived", pQuant, pTitle "% in Deprivation" ]
        << position Y
          [ pName "industry_code"
          , pTitle "Industry"
          ]
        << color [ mStr "#e63946" ]
        << tooltips
          [ [ tName "industry_label", tTitle "Industry" ]
          , [ tName "percent_deprived", tFormat ".2f", tTitle "% in Deprivation" ]
          ]

      depBarsSpec =
        asSpec
          [ width 300
          , height 200
          , data
          , depIndustryTrans []
          , depBarsEnc []
          , bar []
          ]

      deprivationSpec =
        asSpec
          [ title "Deprivation Statistics" [ tiColor "white", tiFontSize 16 ]
          , vConcat [ textSpec, depBarsSpec ]
          ]

      res =
        resolve
        << resolution (reLegend [ ( chColor, reIndependent ) ])
        << resolution (reScale [ ( chColor, reIndependent ) ])
    in
    toVegaLite
      [ cfg []
      , res []
      , columns 2
      , concat [ pieSpec, barsSpec, deprivationSpec ]
      ]
