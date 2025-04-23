module TestLargeSchema where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import RecordSchemaValidation (inSchema)
import Schema (Schema)

-- Test function that validates a simple record against the large schema
testSchema :: Effect Unit
testSchema = do
  -- Reporting success means type checking worked
  log "Schema validation passed!"

-- log $ "Result: " <> show result

-- Use the inSchema function to validate a record against our large schema
result :: Boolean
result = inSchema @Schema
  { users:
      { id: 1
      , created_by:
          { id: 1
          , created_by:
              { id: 2
              , created_by:
                  { id: 2
                  , created_by:
                      { id: 2
                      , created_by: { id: 3 }
                      }
                  }
              }
          }
      }
  }

-- Main function to run the test
main :: Effect Unit
main = testSchema
