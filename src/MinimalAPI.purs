module MinimalAPI where

import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Prim.Row (class Cons)
import Prim.RowList (class RowToList, RowList, Nil, Cons)
import Prim.TypeError (class Fail, Text, Quote, Beside)
import Type.Proxy (Proxy)

newtype Schema = Schema
  { user_id :: Int
  , name :: String
  , email :: String
  , password :: String
  }

-- | Generic record deep comparison that handles nested records via RowList
nestedRecordWithin :: ∀ r1 @nt rl1 r2.
  RowToList r1 rl1 =>
  NestedRecordWithinRL rl1 r1 r2 =>
  Newtype nt (Record r2) =>
  { | r1 } -> Boolean
nestedRecordWithin _ = true

-- | The core type class that iterates through the fields
class NestedRecordWithinRL (rl :: RowList Type) (r1 :: Row Type) (r2 :: Row Type) | rl -> r1

-- | Base case: all fields have been processed
instance NestedRecordWithinRL Nil r1 r2

-- | Primary instance for checking each field
instance
  ( IsSymbol name
  , Cons name fieldType1 rest1 r1                   -- Field exists in r1
  , FieldExists name r2                            -- Field MUST exist in r2
  , CompareTypes name fieldType1 r2                -- Field types are compatible
  , NestedRecordWithinRL tail r1 r2                -- Check remaining fields
  ) => NestedRecordWithinRL (Cons name fieldType1 tail) r1 r2

-- | Class to ensure a field exists in the target record
class FieldExists (name :: Symbol) (r :: Row Type)

-- | Implementation that fails at compile time if field doesn't exist
instance Cons name ty tail r => FieldExists name r
else instance
  Fail (Beside (Text "Field '") (Beside (Quote name) (Text "' is missing in the target record"))) =>
  FieldExists name r

-- | Compare types between records - for nested records we do recursive check
class CompareTypes (name :: Symbol) (srcType :: Type) (targetRow :: Row Type)

-- | For primitive types (non-records), they must match exactly
instance
  ( IsSymbol name
  , Cons name targetType rest targetRow
  , TypesEqual name srcType targetType
  ) => CompareTypes name srcType targetRow

-- | Class to check if types are equal
class TypesEqual (name :: Symbol) (a :: Type) (b :: Type)

-- | They're equal if they're the same type
instance TypesEqual name a a
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget  -- Recursively check nested records
  ) => TypesEqual name (Record nestedSrc) (Record nestedTarget)
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget  -- Recursively check nested records
  , Newtype nt (Record nestedTarget)
  ) => TypesEqual name (Record nestedSrc) nt
else instance
  ( IsSymbol name
  , Newtype na (Record nestedSrc)
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget  -- Recursively check nested records
  ) => TypesEqual name na (Record nestedTarget)
else instance
  ( IsSymbol name
  , Newtype na (Record nestedSrc)
  , Newtype nb (Record nestedTarget)
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget  -- Recursively check nested records
  ) => TypesEqual name na nb
else instance
  ( IsSymbol name
  , Fail (Beside (Text "Type mismatch for field '") (Beside (Quote name) (Text "': incompatible types")))
  ) => TypesEqual name a b

test1 :: Boolean
test1 = nestedRecordWithin @Person { name: "Alice" }

test2 :: Boolean
test2 = nestedRecordWithin @Person
  { name: "Alice", address: { street: "123 Main St", city: "Boston", zip: "2323" } }

newtype Person = Person { name :: String, id :: Int, address :: Address  }
derive instance Newtype Person _
newtype Address = Address { street :: String, city :: String, zip :: String }
derive instance Newtype Address _

class SymbolToType (sym :: Symbol) (a :: Type)

instance SymbolToType "address" Address