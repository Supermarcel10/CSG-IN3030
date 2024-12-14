module ColumnLookup exposing (..)



getEnglishProficiency : Int -> Maybe String
getEnglishProficiency value =
    case value of
        1 -> Just "Main language is English (English or Welsh in Wales)"
        2 -> Just "Main language is not English (English or Welsh in Wales)"
        3 -> Just "Main language is not English (English or Welsh in Wales): Cannot speak English or cannot speak English well"
        _ -> Nothing


getIndustry : Int -> Maybe String
getIndustry value =
    case value of
        1 -> Just "A, B, D, E Agriculture, energy and water"
        2 -> Just "C Manufacturing"
        3 -> Just "F Construction"
        4 -> Just "G, I Distribution, hotels and restaurants"
        5 -> Just "H, J Transport and communication"
        6 -> Just "K, L, M, N Financial, real estate, professional and administrative activities"
        7 -> Just "O, P, Q Public administration, education and health"
        8 ->  Just "R, S, T, U Other"
        _ -> Nothing


getQualification : Int -> Maybe String
getQualification value =
    case value of
        0 -> Just "No qualifications"
        1 -> Just "Level 1 and entry level qualifications: 1 to 4 GCSEs grade A* to C, Any GCSEs at other grades, O levels or CSEs (any grades), 1 AS level, NVQ level 1, Foundation GNVQ, Basic or Essential Skills"
        2 -> Just "Level 2 qualifications: 5 or more GCSEs (A* to C or 9 to 4), O levels (passes), CSEs (grade 1), School Certification, 1 A level, 2 to 3 AS levels, VCEs, Intermediate or Higher Diploma, Welsh Baccalaureate Intermediate Diploma, NVQ level 2, Intermediate GNVQ, City and Guilds Craft, BTEC First or General Diploma, RSA Diploma"
        3 -> Just "Level 3 qualifications: 2 or more A levels or VCEs, 4 or more AS levels, Higher School Certificate, Progression or Advanced Diploma, Welsh Baccalaureate Advance Diploma, NVQ level 3; Advanced GNVQ, City and Guilds Advanced Craft, ONC, OND, BTEC National, RSA Advanced Diploma"
        4 -> Just "Level 4 qualifications or above: degree (BA, BSc), higher degree (MA, PhD, PGCE), NVQ level 4 to 5, HNC, HND, RSA Higher Diploma, BTEC Higher level, professional qualifications (for example, teaching, nursing, accountancy)"
        5 -> Just "Other: apprenticeships, vocational or work-related qualifications, other qualifications achieved in England or Wales, qualifications achieved outside England or Wales (equivalent not stated or unknown)"
        _ ->  Nothing


getDeprivation : Int -> Maybe String
getDeprivation value =
    case value of
        0 -> Just "Household is not deprived in the employment dimension"
        1 -> Just "Household is deprived in the employment dimension"
        _ -> Nothing