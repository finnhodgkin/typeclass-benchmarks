module LargeSchema where

import Data.Newtype (class Newtype)
import MinimalAPI (class SymbolToType)
import Type.Proxy (Proxy)


newtype Schema = Schema
  { users1 :: Proxy "user1"
  , users2 :: Proxy "user2"
  , users3 :: Proxy "user3"
  , users4 :: Proxy "user4"
  , users5 :: Proxy "user5"
  , users6 :: Proxy "user6"
  , users7 :: Proxy "user7"
  , users8 :: Proxy "user8"
  , users9 :: Proxy "user9"
  , users10 :: Proxy "user10"
  , events1 :: Proxy "event1"
  , events2 :: Proxy "event2"
  , events3 :: Proxy "event3"
  , events4 :: Proxy "event4"
  , events5 :: Proxy "event5"
  , events6 :: Proxy "event6"
  , events7 :: Proxy "event7"
  , events8 :: Proxy "event8"
  , events9 :: Proxy "event9"
  , events10 :: Proxy "event10"
  }
derive instance Newtype Schema _