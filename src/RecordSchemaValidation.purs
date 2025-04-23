module RecordSchemaValidation where

import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Prim.Row (class Cons)
import Prim.RowList (class RowToList, RowList, Nil, Cons)
import Prim.TypeError (class Fail, Text, Quote, Beside)
import Type.Proxy (Proxy)

-- | Generic record deep comparison that handles nested records via RowList
inSchema :: ∀ r1 @schema rl1 r2.
  RowToList r1 rl1 =>
  NestedRecordWithinRL rl1 r1 r2 schema =>
  Newtype schema (Record r2) =>
  { | r1 } -> Boolean
inSchema _ = true

-- | The core type class that iterates through the fields
class NestedRecordWithinRL (rl :: RowList Type) (r1 :: Row Type) (r2 :: Row Type) (schema :: Type)  | rl -> r1

-- | Base case: all fields have been processed
instance NestedRecordWithinRL Nil r1 r2 schema

-- | Primary instance for checking each field
instance
  ( IsSymbol name
  , Cons name fieldType1 rest1 r1
  , FieldExists name r2
  , CompareTypes name fieldType1 r2 schema
  , NestedRecordWithinRL tail r1 r2 schema
  ) => NestedRecordWithinRL (Cons name fieldType1 tail) r1 r2 schema

-- | Class to ensure a field exists in the target record
class FieldExists (name :: Symbol) (r :: Row Type)

-- | Implementation that fails at compile time if field doesn't exist
instance Cons name ty tail r => FieldExists name r
else instance
  Fail (Beside (Text "Field '") (Beside (Quote name) (Text "' is missing in the target record"))) =>
  FieldExists name r

-- | Compare types between records - for nested records we do recursive check
class CompareTypes (name :: Symbol) (srcType :: Type) (targetRow :: Row Type) (schema :: Type)

-- | For primitive types (non-records), they must match exactly
instance
  ( IsSymbol name
  , Cons name targetType rest targetRow
  , TypesEqual name srcType targetType schema
  ) => CompareTypes name srcType targetRow schema

-- | Class to check if types are equal
class TypesEqual (name :: Symbol) (a :: Type) (b :: Type) (schema :: Type)
-- | They're equal if they're the same type
instance TypesEqual name a a schema
else instance
  ( IsSymbol name
  , SymbolToType schema targetType sym
  , TypesEqual name sourceType targetType schema
  ) => TypesEqual name sourceType (Proxy sym) schema
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget schema
  ) => TypesEqual name (Record nestedSrc) (Record nestedTarget) schema
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget schema
  , Newtype ty (Record nestedTarget)
  ) => TypesEqual name (Record nestedSrc) ty schema
else instance
  ( IsSymbol name
  , Fail (Beside (Text "Type mismatch for field ") (Beside (Quote name) (Beside (Text ". Incompatible types ") (Beside (Quote a) (Beside (Text " and ") (Quote b))))))
  ) => TypesEqual name a b schema

class SymbolToType (schema :: Type) (a :: Type) (sym :: Symbol) | schema sym -> a, sym -> a
