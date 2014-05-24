--
-- Parser for Delegate DSL.
-- This parser uses the ReadP monadic parser-combinator library and implements lexing and
-- parsing of the Delegate DSL into the DelegateAst types defined in DelegateAst.hs.
--
-- For information on ReadP, see:
-- (http://hackage.haskell.org/package/base-4.7.0.0/docs/Text-ParserCombinators-ReadP.html)
--

module DelegateParser
( parseString
, parseFile
) where

import DelegateAst
import Text.ParserCombinators.ReadP
import Data.Char

data Error = Error deriving (Show, Read, Eq)

-- Parse a string
parseString :: String -> Either Error Order
parseString s = 
    case readP_to_S order s of
        (e:[]) -> Right $ fst e
        _ -> Left Error

-- Parse a file
parseFile :: FilePath -> IO (Either Error Order)
parseFile fp = do s <- readFile fp
                  return $ parseString s

-- Eliminate leading spaces
token :: ReadP a -> ReadP a
token p = do { skipSpaces; p }

-- Parse a symbol
symbol :: String -> ReadP String
symbol s = token $ string s

-- Check if character is a digit in the range [0-9]
isDigit :: Char -> Bool
isDigit c = ord c >= 48 && ord c <= 57

-- Parse an Integer
integer :: ReadP Integer
integer = token $ do int <- munch DelegateParser.isDigit
                     return $ read int

-- Parse a TimeUnit
timeUnit :: ReadP TimeUnit
timeUnit =
    token $ choice [ do {symbol "Months"; return Months},
                     do {symbol "Weeks"; return Weeks}, 
                     do {symbol "Days"; return Days} ]

-- Parse a period constraint
period :: ReadP Period
period = do symbol "If"
            symbol "OutOfStock"
            symbol "Wait"
            duration <- integer
            unit <- timeUnit
            return $ Period (duration, unit)

-- Parse a Price in an OrderLine
price :: ReadP Price
price = token $ do price' <- integer
                   return $ Price price'

-- Parse a ProductName
productName :: ReadP ProductName
productName = token $ do char '"'
                         name <- munch (/= '"')
                         char '"'
                         return name

-- Parse a Product in an OrderLine
product :: ReadP Product
product = do name <- productName
             quantity <- integer
             symbol "Units"
             return $ Product (name, quantity)

-- Parse an OrderLine
orderLine :: ReadP OrderLine
orderLine = do symbol "add"
               productAst <- DelegateParser.product
               symbol "At"
               priceAst <- price
               periodAst <- period
               return $ OrderLine (productAst, priceAst, periodAst)

-- Parse an Order
order :: ReadP Order
order = do symbol "order"
           symbol "{"
           lines' <- many orderLine
           symbol "}"
           skipSpaces
           eof
           return $ Order lines'
