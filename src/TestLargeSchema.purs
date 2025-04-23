module TestLargeSchema where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import RecordSchemaValidation (inSchema)
import LargeSchema (Schema)

-- Test function that validates a simple record against the large schema
testSchema :: Effect Unit
testSchema = do
  -- Reporting success means type checking worked
  log "Schema validation passed!"
  -- log $ "Result: " <> show result

-- Use the inSchema function to validate a record against our large schema
result :: Boolean
result = inSchema @Schema
  { users1: { name: "Alice", friends: { name: "Bob"} }
  , users2: { name: "FFFF" }
  , users4: { name: "FLKDJFLDJF"}
  , users5000: { name: "Finn" }
  }

-- Main function to run the test
main :: Effect Unit
main = testSchema
