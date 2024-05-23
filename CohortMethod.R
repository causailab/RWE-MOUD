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

############################ Covariate Settings ################################
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



############################ Create cohort method data #########################
cohortMethodData <- CohortMethod::getDbCohortMethodData(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = targetDatabaseSchema,
  targetId = 1789418, # methadone cohort
  comparatorId = 1789423, # buprenorphine cohort
  outcomeIds = 1789470, # outcome cohort
  exposureDatabaseSchema = targetDatabaseSchema,
  exposureTable = targetCohortTable,
  outcomeDatabaseSchema = targetDatabaseSchema,
  outcomeTable = targetCohortTable,
  firstExposureOnly = TRUE,
  restrictToCommonPeriod = FALSE,
  removeDuplicateSubjects = "remove all",
  covariateSettings = covariateSettings
)
CohortMethod::saveCohortMethodData(cohortMethodData, "CohortMethodData.zip")

cohortMethodData <- CohortMethod::loadCohortMethodData("CohortMethodData.zip")
studyPop <- CohortMethod::createStudyPopulation(
  cohortMethodData = cohortMethodData, 
  outcomeId = 1789470, 
  firstExposureOnly = TRUE,
  restrictToCommonPeriod = FALSE, 
  washoutPeriod = 0, 
  removeDuplicateSubjects = "remove all", 
  removeSubjectsWithPriorOutcome = FALSE, 
  minDaysAtRisk = 2,
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)
getAttritionTable(studyPop)



############################ Calculate propensity score ########################
ps <- createPs(cohortMethodData = cohortMethodData, population = studyPop, 
               stopOnError = FALSE)
saveRDS(ps, "ps.rds")
ps <-readRDS("ps.rds")

computePsAuc(ps)
CohortMethod::computeEquipoise(ps)

plotPs(ps, scale = "preference", 
       showCountsLabel = TRUE, 
       showAucLabel = TRUE, 
       showEquiposeLabel = TRUE)

getPsModel(ps, cohortMethodData)

trimmedPop <- trimByPsToEquipoise(ps)
plotPs(trimmedPop, ps, scale = "preference")

stratifiedPop <- stratifyByPs(ps, numberOfStrata = 5)
plotPs(stratifiedPop, ps, scale = "preference")



############################ Match on propensity score #########################
matchedPop <- matchOnPs(
  ps, 
  caliper = 0.2, 
  caliperScale = "standardized logit", 
  maxRatio = 1)
plotPs(matchedPop, ps)

getAttritionTable(matchedPop)
drawAttritionDiagram(matchedPop) 

# Evaluate covariate balance
balance <- computeCovariateBalance(matchedPop, cohortMethodData)
plotCovariateBalanceScatterPlot(
  balance, 
  showCovariateCountLabel = TRUE, 
  showMaxLabel = TRUE)

plotCovariateBalanceOfTopVariables(balance)

table_1 <- createCmTable1(balance)
write.csv(table_1, "Table_1.csv", row.names=FALSE)

getGeneralizabilityTable(balance)

# Follow-up and Power
CohortMethod::computeMdrr(population = studyPop, 
                          modelType = "cox",
                          alpha = 0.05,
                          power = 0.8,
                          twoSided = TRUE)

CohortMethod::computeMdrr(population = matchedPop, 
                          modelType = "cox", 
                          alpha = 0.05, 
                          power = 0.8, 
                          twoSided = TRUE)

getFollowUpDistribution(population = matchedPop)
plotFollowUpDistribution(population = matchedPop)

# Fitting a simple outcome model 
outcomeModel_matched <- fitOutcomeModel(
  population = matchedPop, 
  modelType = "cox", 
  stratified = TRUE)
outcomeModel_matched

# Add covariates to outcome data
outcomeModel <- fitOutcomeModel(
  population = matchedPop, 
  cohortMethodData = cohortMethodData, 
  modelType = "cox", 
  stratified = TRUE, 
  useCovariates = TRUE)
outcomeModel

plotKaplanMeier(matchedPop, includeZero = FALSE)


















