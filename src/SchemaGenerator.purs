module SchemaGenerator where

import Prelude

import Data.Array (range)
import Data.FoldableWithIndex (forWithIndex_)
import Data.String (joinWith)
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (writeTextFile)

-- | Generate a large schema file with the given number of event and user types
generateLargeSchema :: Int -> Effect Unit
generateLargeSchema count = do
  let
    -- Generate a series of event types with sequential numbering
    eventDefs = map genEventType (range 1 count)
    -- Generate a series of user types with sequential numbering
    userDefs = map genUserType (range 1 count)
    -- Generate the schema wrapper that contains all types
    schemaContents = genSchemaType count
    -- Build the full file contents
    fileContents = joinWith "\n\n" $
      [ moduleHeader
      , schemaContents
      ]

  forWithIndex_ userDefs \num ->
    writeTextFile UTF8 ("src/Tables/Users" <> show (num + 1) <> ".purs")
  forWithIndex_ eventDefs \num ->
    writeTextFile UTF8 ("src/Tables/Events" <> show (num + 1) <> ".purs")

  -- Write to the output file
  writeTextFile UTF8 "src/LargeSchema.purs" fileContents
  log $ "Generated schema with " <> show count <> " event types and " <> show count <> " user types."

-- | Module header with imports
moduleHeader :: String
moduleHeader = """module LargeSchema where

import Data.Newtype (class Newtype)
import MinimalAPI (class SymbolToType)
import Type.Proxy (Proxy)
"""

-- | Generate the main Schema type that references all other types
genSchemaType :: Int -> String
genSchemaType count =
  "newtype Schema = Schema\n" <>
  "  { " <> (joinWith "\n  , " $ fieldsArray) <> "\n" <>
  "  }\n" <>
  "derive instance Newtype Schema _"
  where
    fieldsArray =
      [ "users1 :: Proxy \"user1\"" ] <>
      (map (\i -> "users" <> show i <> " :: Proxy \"user" <> show i <> "\"") (range 2 count)) <>
      (map (\i -> "events" <> show i <> " :: Proxy \"event" <> show i <> "\"") (range 1 count))

-- | Generate an event type with a specific number
genEventType :: Int -> String
genEventType num =
  "module Events" <> show num <> " where\n" <>
  "\n" <>
  """import Data.Newtype (class Newtype)
import MinimalAPI (class SymbolToType)
import Type.Proxy (Proxy)
newtype Events""" <> show num <> " = Events" <> show num <> "\n" <>
  "  { name :: String\n" <>
  "  , description :: String\n" <>
  "  , location :: String\n" <>
  "  , created_by :: Proxy \"user" <> genRandomNum num <> "\"\n" <>
  "  , attendees :: Proxy \"user" <> genRandomNum num <> "\"\n" <>
  "  , sponsors :: Proxy \"user" <> genRandomNum num <> "\"\n" <>
  "  , related_events :: Proxy \"event" <> genRandomNum num <> "\"\n" <>
  "  }\n" <>
  "derive instance Newtype Events" <> show num <> " _\n" <>
  "instance SymbolToType Events" <> show num <> " \"event" <> show num <> "\""

-- | Generate a user type with a specific number
genUserType :: Int -> String
genUserType num =
  "module Users" <> show num <> " where\n" <>
  "\n" <>
  """import Data.Newtype (class Newtype)
import MinimalAPI (class SymbolToType)
import Type.Proxy (Proxy)
newtype Users""" <> show num <> " = Users" <> show num <> "\n" <>
  "  { name :: String\n" <>
  "  , email :: String\n" <>
  "  , age :: Int\n" <>
  "  , created_events :: Proxy \"event" <> genRandomNum num <> "\"\n" <>
  "  , attending_events :: Proxy \"event" <> genRandomNum num <> "\"\n" <>
  "  , friends :: Proxy \"user" <> genRandomNum num <> "\"\n" <>
  "  , followed_events :: Proxy \"event" <> genRandomNum num <> "\"\n" <>
  "  }\n" <>
  "derive instance Newtype Users" <> show num <> " _\n" <>
  "instance SymbolToType Users" <> show num <> " \"user" <> show num <> "\""

-- | Generate a random number within range for random relationships
genRandomNum :: Int -> String
genRandomNum seed =
  -- Use a simple random number formula based on the seed
  show $ (seed * 73 `mod` seed + 1)

-- | Main function to generate different sizes of schemas
main :: Effect Unit
main = do
  -- Generate schema with 10 types
  generateLargeSchema 10