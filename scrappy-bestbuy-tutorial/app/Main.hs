{-# LANGUAGE ScopedTypeVariables #-}

module Main where

-- import Scrappy.Requests

import Control.Concurrent (forkIO, killThread, threadDelay)
import Control.Concurrent.Async (waitCatch, withAsync)
import qualified Control.Exception as X (SomeException, try) 
import Control.Monad ((<=<), forever, void, when)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Either (isLeft)
import Data.Semigroup ((<>))
import Data.Maybe (fromMaybe)

import Text.Parsec ((<|>), try)
import Text.CSV

import Scrappy.Requests (getHtml')
import Scrappy.Scrape (ScraperT, scrape)
import Scrappy.Elem.ChainHTML (contains', containsFirst) 
import Scrappy.Elem.SimpleElemParser (el)
import Scrappy.Elem.Types (getHrefEl, innerHtmlFull, Elem')


-- Delete when Names are updated
-- hacks -----

contains = contains' 

type Elem = Elem'

---------------










data MyType = Price String
            | InStock String 
            | ProductName String  


data Product = 
  Product { name :: String 
          , price :: String 
          , inStock :: String
          } deriving Show 


url :: String
url = "https://www.bestbuy.ca/en-ca/collection/graphics-cards-with-nvidia-chipset/349221"

isInStock :: ScraperT (Elem String)
isInStock = el "a" [("class", "container_1DAvI")] 

prodPrice :: ScraperT (Elem String)
prodPrice = el "div" [("class", "price_2j8lL medium_1n4Qn")] `containsFirst` p 
  where 
    p = el "div" [] 

prodName :: ScraperT (Elem String)
prodName = el "div" [("class", "productItemName_3IZ3c")] 

target :: ScraperT MyType
target =  
  (fmap (InStock . innerHtmlFull) $ try isInStock) 
  <|> (fmap (Price . innerHtmlFull) $ try prodPrice) 
  <|> (fmap (ProductName . innerHtmlFull) $ try prodName)

myScraper :: ScraperT Product
myScraper = do    
   let shell = el "a" [("class", "link_3hcyN")]   
   ((ProductName n):(Price p):(InStock i):[]) <- shell `contains` target   
   pure $ Product n p i
 
scrapeBestBuy :: IO [Product]
scrapeBestBuy = do 
  html <- getHtml' url 
  let products = flip scrape html myScraper
  pure $ fromMaybe [] products

toCSV :: [Product] -> CSV 
toCSV ((Product n p i):products) = [n,p,i] : toCSV products 
toCSV [] = [] 

main' :: IO ()
main' = do 
  products <- scrapeBestBuy 
  writeFile "products.csv" $ printCSV $ toCSV products  

main :: IO ()
main = do
  let oneDay = 1000000 * 60 * 60 * 24 
  _ <- worker oneDay main'
  pure () 



















-- from Rhyolite.Concurrent


-- | Perform a supervised operation with delays in between, on a separate thread. Return an IO action for killing the thread.
worker :: (MonadIO m)
       => Int -- ^ Delay between operations, in microseconds
       -> IO a -- ^ Operation to perform
       -> m (IO ())
worker = taggedWorker ""

-- | Perform a tagged, supervised operation with delays in between, on a separate thread. Return an IO action for killing the thread.
taggedWorker
  :: MonadIO m
  => String -- ^ Tag for this worker: displayed in error messages
  -> Int
  -> IO a
  -> m (IO ())
taggedWorker tag delay x = return . killThread <=< liftIO . forkIO . supervise tag . void . forever $
  x >> threadDelay delay

-- | Runs an action forever, restarting it if it dies.
supervise :: Show a => String -> IO a -> IO ()
supervise tag a = forever $ withAsync a $ \child -> do
  let msgPrefix = if null tag then "supervise: " else "supervise: " <> tag <> ": "
  result <- waitCatch child
  printResult :: Either X.SomeException () <- X.try $ putStrLn $ msgPrefix <> "child terminated with " <> show result <> "; restarting"
  threadDelay 1000000
  when (isLeft printResult) $ putStrLn $ msgPrefix <> "note: an exception was encountered when printing the previous result"



