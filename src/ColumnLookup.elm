module ColumnLookup exposing (..)

import VegaLite exposing (..)



calculateAsQualificationLabel : List LabelledSpec -> List LabelledSpec
calculateAsQualificationLabel =
  calculateAs
    """
    datum.qualification == 0 ? 'No qualifications' :
    datum.qualification == 1 ? 'Level 1' :
    datum.qualification == 2 ? 'Level 2' :
    datum.qualification == 3 ? 'Level 3' :
    datum.qualification == 4 ? 'Level 4' :
    'Other qualifications'
    """
    "qualification_label"

calculateAsIndustryCode : List LabelledSpec -> List LabelledSpec
calculateAsIndustryCode =
  calculateAs
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

calculateAsIndustryLabel : List LabelledSpec -> List LabelledSpec
calculateAsIndustryLabel =
  calculateAs
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

calculateAsProficiencyLabel : List LabelledSpec -> List LabelledSpec
calculateAsProficiencyLabel =
  calculateAs
    """
    datum.english_proficiency == 1 ? 'Main language is English' :
    datum.english_proficiency == 2 ? 'Main language not English: Can speak English very well' :
    'Main language not English: Cannot speak English well or at all'
    """
    "proficiency_label"
