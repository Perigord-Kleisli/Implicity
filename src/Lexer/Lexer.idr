module Lexer.Lexer

import Generics.Derive
import Text.Lexer

%language ElabReflection

export
data ImpliTokenKind
  = ITString 
  | ITInt
  | ITFloat
  | ITOParen
  | ITCParen
  | ITOperator
  | ITIdentifier
  | ITIgnore
%runElab derive "ImpliTokenKind" [Generic,Meta,Eq,Show]

Interpolation ImpliTokenKind where
  interpolate = show

export
ImpliToken : Type
ImpliToken = Token ImpliTokenKind

export
Show ImpliToken where
  show (Tok kind text) = "(Tok kind: \{kind} Text: \"\{text}\")"

TokenKind ImpliTokenKind where
  TokType ITString = String
  TokType ITIdentifier = String
  TokType ITOperator = String
  TokType ITInt = Int
  TokType ITFloat = Double
  TokType _ = ()

  tokValue ITString s = s
  tokValue ITIdentifier s = s
  tokValue ITOperator s = s
  tokValue ITInt n = fromMaybe 9999 $ parseInteger n
  tokValue ITFloat n = fromMaybe 9999.1 $ parseDouble n
  tokValue ITOParen _ = ()
  tokValue ITCParen _ = ()
  tokValue ITIgnore _ = ()

export
tokenMap : TokenMap ImpliToken
tokenMap = toTokenMap [
    (spaces, ITIgnore)
  , (intLit <+> is '.' <+> digits, ITFloat)
  , (intLit, ITInt)
  , (stringLit, ITString)
  , (lower <+> many alphas, ITIdentifier)
  , (symbols, ITOperator)
  ]

data LexerError = L

export
lexer : String -> Either LexerError (List (WithBounds ImpliToken))
lexer str = case lex tokenMap str of
    (tokens, _, _, "") => Right tokens
    _ => Left ?todo
