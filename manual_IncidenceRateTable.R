library(SqlRender)
library(DatabaseConnector)
library(ROhdsiWebApi)
library(CohortGenerator)
library(Achilles)
library(CohortDiagnostics)
library(Characterization)
library(FeatureExtraction)
library(CohortMethod)

library(Capr)
library(tidyverse)
library(knitr)
library(remotes)
library(devtools)
library(htmltools)



################## Create a function to output incidence rate table ############
createIncidenceRateTable <- function(studyPop, database_id) {
  # create subset of target and comparator dataframes
  target <- studyPop[studyPop$treatment == 1, ]
  comparator <- studyPop[studyPop$treatment == 0, ]
  
  # calculate incidence rate per 1000 person-years
  ir_target <- 1000 * (sum(target$outcomeCount) / (sum(target$timeAtRisk)/365))
  ir_comp <- 1000 * (sum(comparator$outcomeCount) / (sum(comparator$timeAtRisk)/365))
  
  incidence_rate <- data.frame(
    Cohort = c("methadone", "buprenorphne"), 
    Database = c(database_id, database_id), 
    Events = c(dim(target)[1], dim(comparator)[1]), 
    OutcomeCount = c(sum(target$outcomeCount), 
                     sum(comparator$outcomeCount)), 
    Person_Years = c(sum(target$timeAtRisk) / 365,
                     sum(comparator$timeAtRisk) / 365), 
    Incidence_per_1k_py = c(ir_target, ir_comp)
  )
  
  return(incidence_rate)
}



################## Covariate settings ##########################################
covariateSettings <- FeatureExtraction::createCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useDemographicsAgeGroup = TRUE,
  useDemographicsRace = TRUE,
  useDemographicsEthnicity = TRUE,
  useDemographicsIndexYear = FALSE, # exclude calendar year
  useDemographicsIndexMonth = FALSE, 
  useDemographicsPriorObservationTime = TRUE,
  useDemographicsPostObservationTime = TRUE,
  useDemographicsTimeInCohort = TRUE,
  useDemographicsIndexYearMonth = FALSE, 
  useCareSiteId = TRUE,
  useConditionOccurrenceAnyTimePrior = TRUE,
  useConditionOccurrenceLongTerm = TRUE,
  useConditionOccurrenceMediumTerm = TRUE,
  useConditionOccurrenceShortTerm = TRUE,
  useConditionOccurrencePrimaryInpatientAnyTimePrior = TRUE,
  useConditionOccurrencePrimaryInpatientLongTerm = TRUE,
  useConditionOccurrencePrimaryInpatientMediumTerm = TRUE,
  useConditionOccurrencePrimaryInpatientShortTerm = TRUE,
  useConditionEraAnyTimePrior = TRUE,
  useConditionEraLongTerm = TRUE,
  useConditionEraMediumTerm = TRUE,
  useConditionEraShortTerm = TRUE,
  useConditionEraOverlapping = TRUE,
  useConditionEraStartLongTerm = TRUE,
  useConditionEraStartMediumTerm = TRUE,
  useConditionEraStartShortTerm = TRUE,
  useConditionGroupEraAnyTimePrior = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useConditionGroupEraMediumTerm = TRUE,
  useConditionGroupEraShortTerm = TRUE,
  useConditionGroupEraOverlapping = TRUE,
  useConditionGroupEraStartLongTerm = TRUE,
  useConditionGroupEraStartMediumTerm = TRUE,
  useConditionGroupEraStartShortTerm = TRUE,
  useDrugExposureAnyTimePrior = TRUE,
  useDrugExposureLongTerm = TRUE,
  useDrugExposureMediumTerm = TRUE,
  useDrugExposureShortTerm = TRUE,
  useDrugEraAnyTimePrior = TRUE,
  useDrugEraLongTerm = TRUE,
  useDrugEraMediumTerm = TRUE,
  useDrugEraShortTerm = TRUE,
  useDrugEraOverlapping = TRUE,
  useDrugEraStartLongTerm = TRUE,
  useDrugEraStartMediumTerm = TRUE,
  useDrugEraStartShortTerm = TRUE,
  useDrugGroupEraAnyTimePrior = TRUE,
  useDrugGroupEraLongTerm = TRUE,
  useDrugGroupEraMediumTerm = TRUE,
  useDrugGroupEraShortTerm = TRUE,
  useDrugGroupEraOverlapping = TRUE,
  useDrugGroupEraStartLongTerm = TRUE,
  useDrugGroupEraStartMediumTerm = TRUE,
  useDrugGroupEraStartShortTerm = TRUE,
  useProcedureOccurrenceAnyTimePrior = TRUE,
  useProcedureOccurrenceLongTerm = TRUE,
  useProcedureOccurrenceMediumTerm = TRUE,
  useProcedureOccurrenceShortTerm = TRUE,
  useDeviceExposureAnyTimePrior = TRUE,
  useDeviceExposureLongTerm = TRUE,
  useDeviceExposureMediumTerm = TRUE,
  useDeviceExposureShortTerm = TRUE,
  useMeasurementAnyTimePrior = TRUE,
  useMeasurementLongTerm = TRUE,
  useMeasurementMediumTerm = TRUE,
  useMeasurementShortTerm = TRUE,
  useMeasurementValueAnyTimePrior = TRUE,
  useMeasurementValueLongTerm = TRUE,
  useMeasurementValueMediumTerm = TRUE,
  useMeasurementValueShortTerm = TRUE,
  useMeasurementRangeGroupAnyTimePrior = TRUE,
  useMeasurementRangeGroupLongTerm = TRUE,
  useMeasurementRangeGroupMediumTerm = TRUE,
  useMeasurementRangeGroupShortTerm = TRUE,
  useObservationAnyTimePrior = TRUE,
  useObservationLongTerm = TRUE,
  useObservationMediumTerm = TRUE,
  useObservationShortTerm = TRUE,
  useCharlsonIndex = TRUE,
  useDcsi = TRUE,
  useChads2 = TRUE,
  useChads2Vasc = TRUE,
  useHfrs = TRUE,
  useDistinctConditionCountLongTerm = TRUE,
  useDistinctConditionCountMediumTerm = TRUE,
  useDistinctConditionCountShortTerm = TRUE,
  useDistinctIngredientCountLongTerm = TRUE,
  useDistinctIngredientCountMediumTerm = TRUE,
  useDistinctIngredientCountShortTerm = TRUE,
  useDistinctProcedureCountLongTerm = TRUE,
  useDistinctProcedureCountMediumTerm = TRUE,
  useDistinctProcedureCountShortTerm = TRUE,
  useDistinctMeasurementCountLongTerm = TRUE,
  useDistinctMeasurementCountMediumTerm = TRUE,
  useDistinctMeasurementCountShortTerm = TRUE,
  useDistinctObservationCountLongTerm = TRUE,
  useDistinctObservationCountMediumTerm = TRUE,
  useDistinctObservationCountShortTerm = TRUE,
  useVisitCountLongTerm = TRUE,
  useVisitCountMediumTerm = TRUE,
  useVisitCountShortTerm = TRUE,
  useVisitConceptCountLongTerm = TRUE,
  useVisitConceptCountMediumTerm = TRUE,
  useVisitConceptCountShortTerm = TRUE,
  longTermStartDays = -365,
  mediumTermStartDays = -180,
  shortTermStartDays = -30,
  endDays = 0,
  includedCovariateConceptIds = c(),
  addDescendantsToInclude = TRUE,
  excludedCovariateConceptIds = c(
    # related drugs
    1103640, # methadone
    1133201, # buprenorphine
    1714319, # naltrexone
    1114220, # naloxone
    
    # large covariate weights (abs values >= 1)
    40161115, # Candida albicans allergenic extract
    19058274, # purified protein derivative of tuberculin
    
    # methadone metabolite
    40761529, # measurement of EDDP in urine
    3013830, # measurement of methadone [Presence] in Urine by Confirmatory method
    3036180 # measurement of methadone [Presence] in Urine
  ),
  addDescendantsToExclude = TRUE,
  includedCovariateIds = c()
)



################## Main outcome (OUD or overdose) ##############################
cohortMethodData <- CohortMethod::getDbCohortMethodData(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = targetDatabaseSchema,
  targetId = 1789418, # methadone cohort
  comparatorId = 1789423, # buprenorphine cohort
  outcomeIds = 1789470, # outcome cohort, restrict to the same visit occurrence
  exposureDatabaseSchema = targetDatabaseSchema,
  exposureTable = targetCohortTable,
  outcomeDatabaseSchema = targetDatabaseSchema,
  outcomeTable = targetCohortTable,
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE,
  removeDuplicateSubjects = "keep all", # keep everything so that the cohort size remain the same
  covariateSettings = covariateSettings
)
CohortMethod::saveCohortMethodData(cohortMethodData, "CohortData_IncidenceRate")
cohortMethodData <- CohortMethod::loadCohortMethodData("CohortData_IncidenceRate")
studyPop_main <- CohortMethod::createStudyPopulation(
  cohortMethodData = cohortMethodData, 
  outcomeId = 1789470, 
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE, 
  washoutPeriod = 0, 
  removeDuplicateSubjects = "keep all", 
  removeSubjectsWithPriorOutcome = FALSE, 
  minDaysAtRisk = 0,
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)
getAttritionTable(studyPop_main)

# output to csv
incidence_rate <- createIncidenceRateTable(studyPop_main, "WUSM_Datalake")
incidence_rate
write.csv(incidence_rate, "incidence_rate.csv")



################## OUD only ####################################################
cohortMethodData <- CohortMethod::getDbCohortMethodData(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = targetDatabaseSchema,
  targetId = 1789418, # methadone cohort
  comparatorId = 1789423, # buprenorphine cohort
  outcomeIds = 1789694, # outcome cohort, restrict to the same visit occurrence
  exposureDatabaseSchema = targetDatabaseSchema,
  exposureTable = targetCohortTable,
  outcomeDatabaseSchema = targetDatabaseSchema,
  outcomeTable = targetCohortTable,
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE,
  removeDuplicateSubjects = "keep all",
  covariateSettings = covariateSettings
)
CohortMethod::saveCohortMethodData(cohortMethodData, "IncidenceRate_OUD")
cohortMethodData <- CohortMethod::loadCohortMethodData("IncidenceRate_OUD")
studyPop_OUD <- CohortMethod::createStudyPopulation(
  cohortMethodData = cohortMethodData, 
  outcomeId = 1789694, 
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE, 
  washoutPeriod = 0, 
  removeDuplicateSubjects = "keep all", 
  removeSubjectsWithPriorOutcome = FALSE, 
  minDaysAtRisk = 0,
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)
getAttritionTable(studyPop_OUD)

incidence_rate_OUD_only <- createIncidenceRateTable(studyPop_OUD, "WUSM_Datalake")
incidence_rate_OUD_only
write.csv(incidence_rate_OUD_only, "incidence_rate_OUD_only.csv")



################## Opioid overdose only ########################################
cohortMethodData <- CohortMethod::getDbCohortMethodData(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = targetDatabaseSchema,
  targetId = 1789418, # methadone cohort
  comparatorId = 1789423, # buprenorphine cohort
  outcomeIds = 1789695, # outcome cohort, restrict to the same visit occurrence
  exposureDatabaseSchema = targetDatabaseSchema,
  exposureTable = targetCohortTable,
  outcomeDatabaseSchema = targetDatabaseSchema,
  outcomeTable = targetCohortTable,
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE,
  removeDuplicateSubjects = "keep all",
  covariateSettings = covariateSettings
)
CohortMethod::saveCohortMethodData(cohortMethodData, "IncidenceRate_OpioidOverdose")
cohortMethodData <- CohortMethod::loadCohortMethodData("IncidenceRate_OpioidOverdose")
studyPop_overdose <- CohortMethod::createStudyPopulation(
  cohortMethodData = cohortMethodData, 
  outcomeId = 1789695, 
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE, 
  washoutPeriod = 0, 
  removeDuplicateSubjects = "keep all", 
  removeSubjectsWithPriorOutcome = FALSE, 
  minDaysAtRisk = 0,
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)
getAttritionTable(studyPop_overdose)

incidence_rate_OpioidOverdose_only <- createIncidenceRateTable(studyPop_overdose, "WUSM_Datalake")
incidence_rate_OpioidOverdose_only
write.csv(incidence_rate_OUD_only, "incidence_rate_OpioidOverdose_only.csv")



















