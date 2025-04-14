module MinimalAPI where

import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Prim.Row (class Cons)
import Prim.RowList (class RowToList, RowList, Nil, Cons)
import Prim.TypeError (class Fail, Text, Quote, Beside)
import Type.Proxy (Proxy)

-- | Generic record deep comparison that handles nested records via RowList
inSchema :: ∀ r1 @nt rl1 r2.
  RowToList r1 rl1 =>
  NestedRecordWithinRL rl1 r1 r2 =>
  Newtype nt (Record r2) =>
  { | r1 } -> Boolean
inSchema _ = true

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
  , SymbolToType  targetType sym
  , TypesEqual name sourceType targetType
  ) => TypesEqual name sourceType (Proxy sym)
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget
  ) => TypesEqual name (Record nestedSrc) (Record nestedTarget)
else instance
  ( IsSymbol name
  , RowToList nestedSrc rlSrc
  , NestedRecordWithinRL rlSrc nestedSrc nestedTarget
  , Newtype nt (Record nestedTarget)
  ) => TypesEqual name (Record nestedSrc) nt
else instance
  ( IsSymbol name
  , Fail (Beside (Text "Type mismatch for field ") (Beside (Quote name) (Beside (Text ". Incompatible types ") (Beside (Quote a) (Beside (Text " and ") (Quote b))))))
  ) => TypesEqual name a b

class SymbolToType (a :: Type) (sym :: Symbol)   | sym -> a

newtype Schema = Schema
  { users :: Users
  , events :: Events
  , events2 :: Events2
  , events3 :: Events3
  }
derive instance Newtype Schema _

newtype Users = Users
  { name :: String
  , created_events :: Proxy "event"
  , attending_events :: Proxy "event"
  , friends :: Proxy "user"
  }
derive instance Newtype Users _
instance SymbolToType  Users  "user"

newtype Events = Events
  { name :: String
  , created_by :: Proxy "user"
  , attendees :: Proxy "user"
  }
derive instance Newtype Events _
-- instance SymbolToType  Events  "event"

newtype Events2 = Events2
  { name :: String
  , created_by :: Proxy "user"
  , attendees :: Proxy "user"
  }
derive instance Newtype Events2 _
-- instance SymbolToType  Events2  "event2"

newtype Events3 = Events3
  { name :: String
  , created_by :: Proxy "user"
  , attendees :: Proxy "user"
  }
derive instance Newtype Events3 _
-- instance SymbolToType  Events3  "event3"