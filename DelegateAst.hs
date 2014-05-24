--
-- Abstract syntax tree for Delegate DSL
--

module DelegateAst
( Order(..)
, OrderLine(..)
, Product(..)
, ProductName
, Quantity
, Price(..)
, Period(..)
, TimeUnit(..)
) where

import qualified Data.List as L
import Text.ParserCombinators.ReadP

type ProductName = String
type Quantity    = Integer

data Order = Order [OrderLine]
    deriving (Eq, Read, Show)
data OrderLine = OrderLine (Product, Price, Period)
    deriving (Eq)
data Product = Product (ProductName, Quantity)
    deriving (Eq, Show, Read)
data Price = Price Integer
    deriving (Eq, Show, Read)
data Period = Period (Integer, TimeUnit)
    deriving (Eq, Show, Read)
data TimeUnit  = Months | Weeks | Days | Years
    deriving (Eq, Show, Read)

-- Eliminates leading spaces
token :: ReadP a -> ReadP a
token p = do { skipSpaces; p }

-- Parse a symbol
symbol :: String -> ReadP String
symbol s = token $ string s

-- Read an OrderLine
instance Read OrderLine where
    readsPrec _ = readP_to_S $
      do symbol "OrderLine"
         symbol "("
         product' <- readS_to_P reads :: ReadP Product
         symbol ","
         price' <- readS_to_P reads :: ReadP Price
         symbol ","
         period <- readS_to_P reads :: ReadP Period
         symbol ")"
         return $ OrderLine(product', price', period)

    readList = readP_to_S $
      do symbol "["
         lines' <- sepBy (readS_to_P reads) $ symbol ";"
         symbol "]"
         return lines'

-- Show an OrderLine
instance Show OrderLine where
    show (OrderLine (prod, price, period)) =
        "OrderLine(" ++
            show prod ++ "," ++
            show price ++ "," ++
            show period ++ 
        ")"

    showList lines' s =
        "[" ++
            L.intercalate "; " (map show lines') ++
        "]" ++ s
