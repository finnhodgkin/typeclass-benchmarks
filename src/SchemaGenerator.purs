module SchemaGenerator where

import Prelude

import Data.Array (range)
import Data.String (joinWith)
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (writeTextFile)

-- | Generate a large schema file with the given number of event and user types
generateLargeSchema :: Int -> Effect Unit
generateLargeSchema count = do
  let
    -- Generate the schema wrapper that contains all types
    schemaContents = genSchemaType count
    -- Build the full file contents
    fileContents = joinWith "\n\n" $
      [ moduleHeader
      , schemaContents
      ]

  -- for (range 1 count) \num ->
  --   writeTextFile UTF8 ("src/Tables/Users" <> show num <> ".purs") (genUserType num)

  -- Write to the output file
  writeTextFile UTF8 "src/LargeSchema.purs" $ fileContents <> (joinWith "\n\n" $ range 1 5000 # map \num -> genUserType num)
  log $ "Generated schema with " <> show count <> " event types and " <> show count <> " user types."

-- | Module header with imports
moduleHeader :: String
moduleHeader = """module LargeSchema where

import Data.Newtype (class Newtype)
import RecordSchemaValidation (class SymbolToType)
import Type.Proxy (Proxy)
"""

-- | Generate the main Schema type that references all other types
genSchemaType :: Int -> String
genSchemaType count =
  "newtype Schema = Schema\n" <>
  "  { " <> (joinWith "\n  , " $ fieldsArray) <> "\n" <>
  "  }\n" <>
  "derive instance Newtype Schema _\n"
  <> relationshipInstances
  where
    relationshipInstances = joinWith "" $
     range 1 count # map \i -> "derive instance Newtype Users" <> show i <> " _\n"
    fieldsArray =
      [ "users1 :: Proxy \"Users1\"" ] <>
      (map (\i -> "users" <> show i <> " :: Proxy \"Users" <> show i <> "\"") (range 2 5000))

-- | Generate a user type with a specific number
genUserType :: Int -> String
genUserType num =
  """newtype Users""" <> show num <> " = Users" <> show num <> "\n" <>
  "  { name :: String\n" <>
  "  , email :: String\n" <>
  "  , age :: Int\n" <>
  "  , friends :: Proxy \"Users1\"" <>
  "  }\n"


-- | Main function to generate different sizes of schemas
main :: Int -> Effect Unit
main count = do
  -- Generate schema with 10 types
  generateLargeSchema count