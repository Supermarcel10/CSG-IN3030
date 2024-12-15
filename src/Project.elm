module Project exposing (ukChoropleth, englishProfPie, industryQualificationBars, deprivationStats)

import VegaLite exposing (..)
import ColumnLookup exposing (..)


-- DATA
topoJson : String
topoJson = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-EN_topo.json"

dataCsv : String
dataCsv = "https://media.githubusercontent.com/media/Supermarcel10/CSG-IN3030/refs/heads/main/data/minified-RM080-2021-1.csv"


-- TODO: Search through the data to see why so many authorities are missing
-- TODO: Add selection

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


englishProfPie : Spec
englishProfPie =
  let
  -- TODO: Add interaction with this
      desiredAuthority = "E06000001"

      cfg =
        configure
        << configuration (coView [ vicoStroke Nothing ])
        << configuration (coBackground "#06070E")

      data =
        dataFromUrl dataCsv []

      trans =
        transform
        << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
        << calculateAsProficiencyLabel

      enc =
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
    in
    toVegaLite
    [ cfg []
    , data
    , trans []
    , enc []
    , arc [ maStrokeWidth 0 ]
    ]


industryQualificationBars : Spec
industryQualificationBars =
  let
  -- TODO: Add interaction with this
    desiredAuthority = "E06000001"

    cfg =
      configure
      << configuration (coBackground "#06070E")
      << configuration (coTitle [ ticoColor "white" ])
      << configuration (coView [ vicoStroke Nothing ])
      << configuration (coAxis [ axcoTitleColor "white", axcoLabelColor "white" ])
      << configuration (coLegend [ lecoTitleColor "white", lecoLabelColor "white" ])
      << configuration (coHeader [ hdLabelColor "white" ])

    trans =
      transform
      << filter (fiExpr ("datum.authority_id == '" ++ desiredAuthority ++ "'"))
      << calculateAs 
        """
        datum.qualification == 0 ? 'No qualifications' :
        datum.qualification == 1 ? 'Level 1' :
        datum.qualification == 2 ? 'Level 2' :
        datum.qualification == 3 ? 'Level 3' :
        datum.qualification == 4 ? 'Level 4' :
        'Other qualifications'
        """
        "qualification_label"
      << calculateAs
        """
        datum.industry == 1 ? 'A, B, D, E' :
        datum.industry == 2 ? 'C' :
        datum.industry == 3 ? 'F' :
        datum.industry == 4 ? 'G, I' :
        datum.industry == 5 ? 'H, J' :
        datum.industry == 6 ? 'K, L, M, N' :
        datum.industry == 7 ? 'O, P, Q' :
        'R, S, T, U, Other'
        """
        "industry_code"
      << calculateAs
        """
        datum.industry == 1 ? 'Agriculture, Energy & Water' :
        datum.industry == 2 ? 'Manufacturing' :
        datum.industry == 3 ? 'Construction' :
        datum.industry == 4 ? 'Distribution & Hospitality' :
        datum.industry == 5 ? 'Transport & Communication' :
        datum.industry == 6 ? 'Financial, Real Estate, Professional & Administrative Activities' :
        datum.industry == 7 ? 'Public Administration, Education & Health' :
        'Other'
        """
        "industry_label"
      << joinAggregate 
        [ opAs opSum "count" "industry_total" ]
        [ wiGroupBy [ "industry_label" ] ]
      << calculateAs "datum.count/datum.industry_total * 100" "percentage"

    sortOrder =
      soCustom 
        ( strs 
          [ "No qualifications"
          , "Level 1"
          , "Level 2"
          , "Level 3"
          , "Level 4"
          , "Other qualifications"
          ]
        )

    data =
      dataFromUrl dataCsv []

    enc =
      encoding
      << position X [ pName "count", pAggregate opSum, pTitle "Count" ]
      << position Y
        [ pName "industry_label"
        , pTitle "Industry"
        , pSort [ sortOrder ]
        ]
      << color
        [ mName "industry_code"
        , mTitle "Qualifications"
        , mScale [ scRange (raStrs ["#e76f51", "#f4a261", "#e9c46a", "#2a9d8f", "#287271", "#aaaaaa"]) ]
        , mSort [ sortOrder ]
        ]
      << tooltips
        [ [ tName "qualification_label", tTitle "Qualification" ]
        , [ tName "count", tAggregate opSum, tTitle "Count" ]
        , [ tName "percentage", tFormat ".1f", tTitle "% of Industry" ]
        ]
  in
  toVegaLite
  [ data
  , cfg []
  , trans []
  , enc []
  , bar []
  ]


deprivationStats : Spec
deprivationStats =
    let
        desiredAuthority = "E06000001"

        -- Calculate total percentage in deprivation
        overallTrans =
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


        -- Transform for industry breakdown
        industryTrans =
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


        -- Overall percentage text
        textEnc =
          encoding
          << text [ tName "percent_deprived", tFormat ".2f" ]

        textSpec =
          asSpec
            [ dataFromUrl dataCsv []
            , overallTrans []
            , textEnc []
            , textMark [ maColor "white", maSize 48, maAlign haCenter, maBaseline vaMiddle ]
            ]


        -- Industry breakdown bars
        barsEnc =
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

        barsSpec =
          asSpec
            [ dataFromUrl dataCsv []
            , industryTrans []
            , barsEnc []
            , bar []
            ]

    in
    toVegaLite
      [ vConcat
        [ textSpec
        , barsSpec
        ]
      , standardConfig
      ]
