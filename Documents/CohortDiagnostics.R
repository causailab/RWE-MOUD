library(tidyverse)
library(dplyr)
library(SqlRender)
library(remotes)
library(devtools)
library(DatabaseConnector)

library(CohortMethod)
library(Achilles)
library(SelfControlledCaseSeries)
library(SelfControlledCohort)
library(EvidenceSynthesis)
library(PatientLevelPrediction)
library(DeepPatientLevelPrediction)
library(Characterization)
library(Capr)
library(FeatureExtraction)
library(CohortDiagnostics)
library(ROhdsiWebApi)
library(Hydra)

library(docopt)

library(duckdb)
library(RSQLite)
library(DbDiagnostics)
library(htmltools)

exportFolder <- 'export'

CohortDiagnostics::executeDiagnostics(
  cohortDefinitionSet = cohortDefinitionSet,
  connectionDetails = connectionDetails,
  cohortTable = targetCohortTable,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cdmDatabaseSchema,
  exportFolder = exportFolder,
  databaseId = "", # human-readable database name
  minCellCount = 5
)

CohortDiagnostics::createMergedResultsFile(
  dataFolder = exportFolder, 
  sqliteDbPath = "MergedCohortDiagnosticsData.sqlite", # default working directory
  overwrite = TRUE
)

CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = "MergedCohortDiagnosticsData.sqlite")







