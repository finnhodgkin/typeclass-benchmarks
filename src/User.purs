module User where

import Type.Proxy (Proxy)

type Users =
  { name :: String
  , created_events :: Proxy "event"
  , attending_events :: Proxy "event"
  , friends :: Proxy "user"
  }
