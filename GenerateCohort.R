library(SqlRender)
library(DatabaseConnector)
library(CohortMethod)
library(Achilles)
library(Characterization)
library(FeatureExtraction)

library(knitr)
library(remotes)
library(devtools)

# Connect to database
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
tempDatabaseSchema <- ""
vocabularyDatabaseSchema <- ""
cdmSourceName <- "" # a human readable name for your CDM source
cdmVersion <- "" # the CDM version you are targeting. Currently supports 5.2, 5.3, and 5.4

# Generate cohort
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

cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = 'cohort')

CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = cdmDatabaseSchema,
  incremental = TRUE
)

CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = cdmDatabaseSchema, 
  cohortDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet,
  incremental = FALSE, 
  stopOnError = FALSE
)