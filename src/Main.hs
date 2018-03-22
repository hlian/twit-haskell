{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import           Control.Monad.Trans (liftIO)
import qualified Data.IORef as Ref
import qualified Data.Map as Map
import           Network.HTTP.Types.Status (Status(..))

import           Data.Aeson hiding (json)
import           GHC.Generics
import           Web.Scotty

data TweetModel =
  TweetModel { tweetUser :: String
             , tweetContent :: String
             } deriving (Generic)

data TweetAPI =
  TweetAPI { tweetID :: Maybe Int
           , tweetUser :: String
           , tweetContent :: String
           , tweetReplies :: Maybe [TweetAPI]
           } deriving (Generic)

instance ToJSON TweetAPI where
  toEncoding = genericToEncoding (defaultOptions { fieldLabelModifier = drop (length ("tweet" :: String)) })

instance FromJSON TweetAPI where
  parseJSON = genericParseJSON (defaultOptions { fieldLabelModifier = drop (length ("tweet" :: String)) })

main :: IO ()
main = do
  (counter :: Ref.IORef Int) <- Ref.newIORef 0
  (db :: Ref.IORef (Map.Map Int TweetModel)) <- Ref.newIORef Map.empty
  scotty 3000 $ do
    get "/echo/:text" $ do
      (echo :: String) <- param "text"
      json echo

    post "/tweets" $ do
      input@TweetAPI{..} <- jsonData
      newID <- liftIO $ Ref.readIORef counter
      let model = TweetModel tweetUser tweetContent
      liftIO $ Ref.modifyIORef' db (Map.insert newID model)
      liftIO $ Ref.modifyIORef' counter (+1)
      json (input { tweetID = Just newID, tweetReplies = Just [] })

    get "/tweets" $ do
      tweets <- liftIO $ Ref.readIORef db
      json [TweetAPI (Just tweetID) tweetUser tweetContent (Just []) | (tweetID, TweetModel{..}) <- Map.toList tweets]

    get "/tweets/:id" $ do
      tweets <- liftIO $ Ref.readIORef db
      (getID :: Int) <- param "id"
      case Map.lookup getID tweets of
        Just TweetModel{..} ->
          json (TweetAPI (Just getID) tweetUser tweetContent (Just []))
        Nothing -> do
          status (Status 400 "bad news")
          json ("bad news" :: String)
