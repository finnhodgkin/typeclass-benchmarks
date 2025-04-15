module Schema where

import Data.Newtype (class Newtype)
import RecordSchemaValidation (class SymbolToType)
import Type.Proxy (Proxy)
import User (Users)

instance SymbolToType Schema Users "user"
newtype Schema = Schema
  { users :: Proxy "user"
  }
derive instance Newtype Schema _