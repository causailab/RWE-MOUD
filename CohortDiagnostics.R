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

# Connect to database
connectionDetails <- DatabaseConnector::createConnectionDetails(
  connectionString = "your_string",
  dbms = "your_dbms",
  user = "user_name",
  password = "super_secret", 
  pathToDriver = "local/path/to/JDBCdriver")

conn <- DatabaseConnector::connect(connectionDetails)
cdmDatabaseSchema <- "" # the fully qualified database schema name of the CDM
targetCohortTable <- "cohort" # cohort table name
targetDatabaseSchema <- ""
tempDatabaseSchema <- ""
vocabularyDatabaseSchema <- ""
cdmSourceName <- "" # a human readable name for your CDM source
cdmVersion <- "" # the CDM version you are targeting. Currently supports 5.2, 5.3, and 5.4

# Create cohort definition set
baseUrl <- "http://api.ohdsi.org:80/WebAPI"
cohortIds <- c(1789418, # methadone exposure
               1789423, # buprenorphine exposure
               1789470, # main outcome (OUD or opioid overdose)
               1789694, # OUD outcome only
               1789695  # opioid overdose outcome only
)

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

# Cohort diagnostics
exportFolder <- 'choose/your/local/export/folder'

CohortDiagnostics::executeDiagnostics(
  cohortDefinitionSet = cohortDefinitionSet,
  connectionDetails = connectionDetails,
  cohortTable = targetCohortTable,
  cohortDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cdmDatabaseSchema,
  exportFolder = exportFolder,
  databaseId = "", # a human readable database name
  minCellCount = 5
)

CohortDiagnostics::createMergedResultsFile(
  dataFolder = exportFolder, 
  sqliteDbPath = "MergedCohortDiagnosticsData.sqlite", 
  overwrite = TRUE
)

CohortDiagnostics::launchDiagnosticsExplorer(sqliteDbPath = "MergedCohortDiagnosticsData.sqlite")







