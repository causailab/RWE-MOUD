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

library(R6)
library(pool)
library(OhdsiShinyModules)


################################################################################
################################################################################
############################ Start of input ####################################

connectionDetails <- DatabaseConnector::createConnectionDetails(
  connectionString = "your_string",
  dbms = "your_dbms",
  user = "user_name",
  password = "super_secret", 
  pathToDriver = "local/path/to/JDBCdriver")

conn <- DatabaseConnector::connect(connectionDetails)
cdmDatabaseSchema <- "" # the fully qualified database schema name of the CDM
targetCohortTable <- "" # cohort table name
targetDatabaseSchema <- ""
tempDatabaseSchema <- "" # user determine if this step is necessary
vocabularyDatabaseSchema <- ""
cdmSourceName <- "" # a human readable name for your CDM source
cdmVersion <- "" # the CDM version you are targeting. Currently supports 5.2, 5.3, and 5.4

exportFolder <- "C:/Users/fanr/Desktop/Project/OUD" # define your output folder location

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI" # change it if you are using a different URL

########################## End of input ########################################
################################################################################
################################################################################






outputfolder <- paste0(exportFolder, "/output", cdmSourceName)


############################ Generate cohort ###################################
baseUrl <- "http://api.ohdsi.org:80/WebAPI" 

cohortIds <- c(1790262, # buprenorphine exposure
               1790261, # methadone exposure
               1790263, # naltrexone exposure
               
               1789470, # main outcome (OUD or opioid overdose)
               1789694, # OUD outcome only
               1789695) # opioid overdose outcome only

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = 'cohort')

CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = cdmDatabaseSchema,
  incremental = TRUE # if TRUE, then will not generate if these tables already exist
)

CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema, 
  cohortDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet,
  incremental = FALSE, 
  stopOnError = FALSE
)


############################ Cohort diagnostics ################################
sqliteOutputPath <- paste0(outputfolder, '/MergedCohortDiagnosticsData.sqlite')

CohortDiagnostics::executeDiagnostics(
  cohortDefinitionSet = cohortDefinitionSet,
  connectionDetails = connectionDetails,
  cohortTable = targetCohortTable,
  cohortDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cdmDatabaseSchema,
  exportFolder = outputfolder,
  databaseId = cdmSourceName, # a human readable database name
  minCellCount = 5
)

CohortDiagnostics::createMergedResultsFile(
  dataFolder = outputfolder, # summarize the data / tables in this folder
  sqliteDbPath = sqliteOutputPath, # create a SQLITE file in the above directory
  overwrite = TRUE
)

CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = sqliteOutputPath) # visualize with R Shiny



############################ Covariate Settings ################################
# Covariate setting 1, excluded 4 MOUDs
covariateSettings1 <- FeatureExtraction::createDefaultCovariateSettings(
  excludedCovariateConceptIds = c(
    1133201, # buprenorphine
    1103640, # methadone
    1714319, # naltrexone
    1114220 # naloxone
  ), 
  addDescendantsToExclude = TRUE
)

# Covariate Settings 2, excluded 4 MOUDs, calendar year, care site id, and 3 measurements of methadone metabolites 
covariateSettings2 <- FeatureExtraction::createCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useDemographicsAgeGroup = TRUE,
  useDemographicsRace = TRUE,
  useDemographicsEthnicity = TRUE,
  useDemographicsIndexYear = FALSE, ########### year
  useDemographicsIndexMonth = FALSE, ########### month
  useDemographicsPriorObservationTime = TRUE,
  useDemographicsPostObservationTime = TRUE,
  useDemographicsTimeInCohort = TRUE,
  useDemographicsIndexYearMonth = FALSE, ########### year month
  useCareSiteId = FALSE, ########### care site
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
  addDescendantsToInclude = TRUE, # turn to FALSE? 
  excludedCovariateConceptIds = c(
    1133201, # buprenorphine
    1103640, # methadone
    1714319, # naltrexone
    1114220, # naloxone
    
    # methadone metabolite
    40761529, # measurement of EDDP in urine
    3013830, # measurement of methadone [Presence] in Urine by Confirmatory method
    3036180 # measurement of methadone [Presence] in Urine
  ),
  addDescendantsToExclude = TRUE,
  includedCovariateIds = c()
)


################################################################################
####################### Running Multiple Analyses at once ######################
################################################################################

negativeConceptSetId <- 1884087
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = negativeConceptSetId,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) %>%
  rename(outcomeConceptId = "conceptId",
         cohortName = "conceptName") %>%
  mutate(cohortId = row_number() + 1000) # can change to 2000 or so


#### Generate negative outcome cohorts 
CohortGenerator::generateNegativeControlOutcomeCohorts(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cdmDatabaseSchema,
  cohortTable = getCohortTableNames()$cohortTable,
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
  occurrenceType = "all",
  incremental = FALSE,
  detectOnDescendants = FALSE
)

### Create exposure-outcome pairs 

#### Main Outcome
primaryOutcomeOfInterest <- CohortMethod::createOutcome( 
  outcomeId = 1789470, # main outcome
  outcomeOfInterest = TRUE,
  trueEffectSize = NA
)

#### OUD only outcome
secondaryOutcomeOfInterest1 <- CohortMethod::createOutcome( 
  outcomeId = 1789694, # OUD only outcome cohort Id
  outcomeOfInterest = TRUE, 
  trueEffectSize = NA
)

#### Opioid Overdose only outcome
secondaryOutcomeOfInterest2 <- CohortMethod::createOutcome( 
  outcomeId = 1789695, # Opioid Overdose only outcome cohort Id
  outcomeOfInterest = TRUE, 
  trueEffectSize = NA
)

negativeControlIds <- negativeControlOutcomeCohortSet$cohortId
negativeControlOutcomes <- lapply(
  negativeControlIds,
  function(outcomeId) CohortMethod::createOutcome(outcomeId = outcomeId,
                                                  outcomeOfInterest = FALSE,
                                                  trueEffectSize = 1)
)

################################################################################

## 1. buprenorphine, methadone, primary outcome
tcos_BupMethPrimary <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790261, # methadone
  outcomes = append(list(primaryOutcomeOfInterest), # 1789470
                    negativeControlOutcomes)
)
bupMethPrimaryList <- list(tcos_BupMethPrimary)

## 2. buprenorphine, naltrexone, primary outcome
tcos_BupNalPrimary <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(primaryOutcomeOfInterest), # 1789470
                    negativeControlOutcomes)
)
bupNalPrimaryList <- list(tcos_BupNalPrimary)

## 3. methadone, naltrexone, primary outcome
tcos_MethNalPrimary <- createTargetComparatorOutcomes(
  targetId = 1790261, # methadone
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(primaryOutcomeOfInterest), # 1789470
                    negativeControlOutcomes)
)
methNalPrimaryList <- list(tcos_MethNalPrimary)

################################################################################

## 4. buprenorphine, methadone, secondary outcome 1
tcos_BupMethSec1 <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790261, # methadone
  outcomes = append(list(secondaryOutcomeOfInterest1), # 1789694, OUD only
                    negativeControlOutcomes)
)
bupMethSec1List <- list(tcos_BupMethSec1)

## 5. buprenorphine, naltrexone, secondary outcome 1
tcos_BupNalSec1 <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(secondaryOutcomeOfInterest1), # 1789694, OUD only
                    negativeControlOutcomes)
)
bupNalSec1List <- list(tcos_BupNalSec1)

## 6. methadone, naltrexone, secondary outcome 1
tcos_MethNalSec1 <- createTargetComparatorOutcomes(
  targetId = 1790261, # methadone
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(secondaryOutcomeOfInterest1), # 1789694, OUD only
                    negativeControlOutcomes)
)
methNalSec1List <- list(tcos_MethNalSec1)

################################################################################

## 7. buprenorphine, methadone, secondary outcome 2
tcos_BupMethSec2 <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790261, # methadone
  outcomes = append(list(secondaryOutcomeOfInterest2), # 1789695, Opioid Overdose only
                    negativeControlOutcomes)
)
bupMethSec2List <- list(tcos_BupMethSec2)

## 8. buprenorphine, naltrexone, secondary outcome 2
tcos_BupNalSec2 <- createTargetComparatorOutcomes(
  targetId = 1790262, # buprenorphine
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(secondaryOutcomeOfInterest2), # 1789695, Opioid Overdose only
                    negativeControlOutcomes)
)
bupNalSec2List <- list(tcos_BupNalSec2)

## 9. methadone, naltrexone, secondary outcome 2
tcos_MethNalSec2 <- createTargetComparatorOutcomes(
  targetId = 1790261, # methadone
  comparatorId = 1790263, # naltrexone
  outcomes = append(list(secondaryOutcomeOfInterest1), # 1789695, Opioid Overdose only
                    negativeControlOutcomes)
)
methNalSec2List <- list(tcos_MethNalSec2)

################################################################################
######################### Make a list 9 tcos for looping #######################
################################################################################

targetComparatorOutcomesLists <- list(
  bupMethPrimaryList, bupNalPrimaryList, methNalPrimaryList, # primary outcome
  bupMethSec1List, bupNalSec1List, methNalSec1List, # secondary outcome 1
  bupMethSec2List, bupNalSec2List, methNalSec2List) # secondary outcome 2


################################################################################
######################### Cohort Method Data Settings ##########################
################################################################################

# With default covariate settings
getDbCmDataArgs1 <- CohortMethod::createGetDbCohortMethodDataArgs(
  firstExposureOnly = TRUE,
  removeDuplicateSubjects = "remove all",
  restrictToCommonPeriod = FALSE, 
  studyStartDate = "",
  studyEndDate = "",
  covariateSettings = covariateSettings1 # default covariate settings
)

# With manual covariate settings
getDbCmDataArgs2 <- CohortMethod::createGetDbCohortMethodDataArgs(
  firstExposureOnly = TRUE,
  removeDuplicateSubjects = "remove all",
  restrictToCommonPeriod = FALSE, 
  studyStartDate = "",
  studyEndDate = "",
  covariateSettings = covariateSettings2 # manual (excluded calendar year, care site, methadone metabolites)
)
################################################################################
################################################################################

# create study population arguments
createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
  removeSubjectsWithPriorOutcome = FALSE,
  minDaysAtRisk = 2, # filtered 1 day at risk
  riskWindowStart = 0,
  startAnchor = "cohort start",
  riskWindowEnd = 30,
  endAnchor = "cohort end"
)

# create propensity score model arguments
createPsArgs <- CohortMethod::createCreatePsArgs(stopOnError = FALSE) 

# create matching arguments
matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(caliper = 0.2, 
                                                   caliperScale = "standardized logit", 
                                                   maxRatio = 1)

# create covariate balance arguments
computeSharedCovBalArgs <- CohortMethod::createComputeCovariateBalanceArgs()

computeCovBalArgs <- CohortMethod::createComputeCovariateBalanceArgs(
  covariateFilter = getDefaultCmTable1Specifications()
)

# create outcome model arguments
fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(
  modelType = "cox",
  stratified = TRUE
)

##################### Define the analysis ######################################

# Analysis 1 with default covariate settings
cmAnalysis1 <- CohortMethod::createCmAnalysis(
  analysisId = 1,
  description = "OUD, default covariate settings",
  getDbCohortMethodDataArgs = getDbCmDataArgs1, # default covariate settings
  createStudyPopArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  matchOnPsArgs = matchOnPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs # cox, stratified
)

# Analysis 2 with manual covariate settings
cmAnalysis2 <- CohortMethod::createCmAnalysis(
  analysisId = 2,
  description = "OUD, manual covariate settings",
  getDbCohortMethodDataArgs = getDbCmDataArgs2, # manual covariate settings 
  createStudyPopArgs = createStudyPopArgs,
  createPsArgs = createPsArgs,
  matchOnPsArgs = matchOnPsArgs,
  computeSharedCovariateBalanceArgs = computeSharedCovBalArgs,
  computeCovariateBalanceArgs = computeCovBalArgs,
  fitOutcomeModelArgs = fitOutcomeModelArgs # cox, stratified
)

cmAnalysisList <- list(cmAnalysis1, # default covariate settings 
                       cmAnalysis2) # manual covariate settings

# save to local and load
CohortMethod::saveCmAnalysisList(cmAnalysisList, "RWEMOUD_cmAnalysisList")
# load
cmAnalysisList <- CohortMethod::loadCmAnalysisList("RWEMOUD_cmAnalysisList")


################################################################################
##################### Create a list of 9 output folders ########################
################################################################################

# Primary outcome
folder1 <- paste0(outputfolder, "/bupMethPrimaryFolder")
folder2 <- paste0(outputfolder, "/bupNalPrimaryFolder")
folder3 <- paste0(outputfolder, "/methNalPrimaryFolder")

# Secondary outcome 1
folder4 <- paste0(outputfolder, "/bupMethSec1Folder")
folder5 <- paste0(outputfolder, "/bupNalSec1Folder")
folder6 <- paste0(outputfolder, "/methNalSec1Folder")

# Secondary outcome 2
folder7 <- paste0(outputfolder, "/bupMethSec2Folder")
folder8 <- paste0(outputfolder, "/bupNalSec2Folder")
folder9 <- paste0(outputfolder, "/methnalSec2Folder")

folders <- list(folder1, folder2, folder3, # primary outcome
                folder4, folder5, folder6, # secondary outcome 1
                folder7, folder8, folder9) # secondary outcome 2


################################################################################
################################################################################


multiThreadingSettings <- createDefaultMultiThreadingSettings(parallel::detectCores())

######## Write the results by looping over 9 target-comparator-outcome pairs ###
resultList <- list()

for (i in 1:9) {
  result <- runCmAnalyses(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema, 
    tempEmulationSchema = cdmDatabaseSchema,
    exposureDatabaseSchema = cdmDatabaseSchema,
    exposureTable = targetCohortTable,
    outcomeDatabaseSchema = cdmDatabaseSchema,
    outcomeTable = targetCohortTable,
    outputFolder = folders[[i]], # folder 1 - 9
    cmAnalysisList = cmAnalysisList,
    targetComparatorOutcomesList = targetComparatorOutcomesLists[[i]], # list 1 - 9
    multiThreadingSettings = multiThreadingSettings
  )
  resultList[[i]] <- result
}

################################################################################
####################### Compile results ########################################
################################################################################

result <- readRDS(file.path(folder, "outcomeModelReference.rds"))



################################################################################
############################## Export result ###################################
################################################################################

for (folder in folders) {
  CohortMethod::exportToCsv(
    folder,
    exportFolder = file.path(folder, "export"), # folder 1 - 9, create a folder called 'export' in the given directory
    databaseId = cdmSourceName,
    minCellCount = 5,
    maxCores = parallel::detectCores()
  )
}
## Please compress the output folders obtained above (those with CSVs) to a zip file. 

# Evidence Synthesis to synthesize results

getResultsDataModelSpecifications() # what does it do? 

# If want to visualize, un-comment the below codes and run. 
########################### Create Cohort Tables ###############################
# cohorts <- data.frame(
#   cohortId = c(
#     1790262, # buprenorphine
#     1790261, # methadone
#     1789263, # naltrexone
#     1789470, # primary outcome
#     1789694, # secondary outcome 1
#     1789695), # secondary outcome 2
#   cohortName = c(
#     "Buprenorphine exposure",
#     "Methadone exposure",
#     "Primary outcome outcome, OUD or opioid overdose hospitalization", 
#     "Secondary outcome 1, OUD only", 
#     "Secondary outcome 2, opioid overdose only"
#   )
# )

########################## Create SQLITE File ##################################
# for (i in 1:9) {
#   insertExportedResultsInSqlite(
#     sqliteFileName = file.path(folders[[i]], "myResults.sqlite"), 
#     exportFolder = file.path(folders[[i]], "export"), 
#     cohorts = cohorts
#   )
# }


########################## Visualize using R Shiny #############################
# launchResultsViewerUsingSqlite(
#   sqliteFileName = file.path(folder, "myResults.sqlite")
# )

# results: sample size, % in equipoise, HR+95CI, RR/logRR+seLogRR, EASE, attrition














