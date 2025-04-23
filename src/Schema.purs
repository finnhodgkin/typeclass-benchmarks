module Schema where

import Data.Newtype (class Newtype)

newtype Schema = Schema
  { users :: User
  }
derive instance Newtype Schema _

newtype User = User { created_by :: User, id :: Int }
derive instance Newtype User _
