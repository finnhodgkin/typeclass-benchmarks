module Users where

import Prelude

import Data.Newtype (class Newtype)
import MinimalAPI (class SymbolToType)
import Type.Proxy (Proxy(..))

newtype Users = Users
  { name :: String
  , created_events :: Proxy "event"
  , attending_events :: Proxy "event"
  , friends :: Proxy "user"
  }
derive instance Newtype Users _