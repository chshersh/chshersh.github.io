---
title: Dead simple Haskell Travis settings for cabal and stack
description: Travis CI settings for Haskell projects with cabal and stack
tags: haskell, cabal, stack, travis, ci
---

Here comes the body of the post itself

```haskell
{- | This module defines prettyprinter for 'ElmDefinition' type.
and exports the function to represent it in the convenient way.
-}

module Elm.Print
       ( prettyShowDefinition
       ) where

import Data.List.NonEmpty (NonEmpty ((:|)))
import Data.Text (Text)

import Elm.Ast (ElmAlias (..), ElmConstructor (..), ElmDefinition (..), ElmPrim (..),
                ElmRecordField (..), ElmType (..), TypeName (..), TypeRef (..), getConstructorNames,
                isEnum)

import qualified Data.Text as T


{- | Pretty shows Elm types.

TODO: more docs later
-}
prettyShowDefinition :: ElmDefinition -> Text
prettyShowDefinition = T.pack . show . elmDoc

elmDoc :: ElmDefinition -> Doc ann
elmDoc = \case
    DefAlias elmAlias -> elmAliasDoc elmAlias
    DefType elmType -> elmTypeDoc elmType
    DefPrim _ -> emptyDoc

-- | Pretty printer for type reference.
elmTypeRefDoc :: TypeRef -> Doc ann
elmTypeRefDoc = \case
    RefPrim elmPrim -> elmPrimDoc elmPrim
    RefCustom (TypeName typeName) -> pretty typeName

{- | Pretty printer for primitive Elm types. This pretty printer is used only to
display types of fields.
-}
elmPrimDoc :: ElmPrim -> Doc ann
elmPrimDoc = \case
    ElmUnit -> "()"
    ElmNever -> "Never"
    ElmBool -> "Bool"
    ElmChar -> "Char"
    ElmInt -> "Int"
    ElmFloat -> "Float"
    ElmString -> "String"
    ElmMaybe ref -> "Maybe" <+> elmTypeRefDoc ref
    ElmResult refA refB -> "Result" <+> elmTypeRefDoc refA <+> elmTypeRefDoc refB
    ElmPair refA refB -> lparen <> elmTypeRefDoc refA  <> comma <+> elmTypeRefDoc refB <> rparen
    ElmList ref -> "List" <+> elmTypeRefDoc ref

{- | Pretty printer for Elm aliases:

@
type alias User =
    { userHeh : String
    , userMeh : Int
    }
@
-}
elmAliasDoc :: ElmAlias -> Doc ann
elmAliasDoc ElmAlias{..} = nest 4 $
    vsep $ ("type alias" <+> pretty elmAliasName <+> equals)
         : fieldsDoc elmAliasFields
  where
    fieldsDoc :: NonEmpty ElmRecordField -> [Doc ann]
    fieldsDoc (fstR :| rest) =
        lbrace <+> recordFieldDoc fstR
      : map ((comma <+>) . recordFieldDoc) rest
     ++ [rbrace]

    recordFieldDoc :: ElmRecordField -> Doc ann
    recordFieldDoc ElmRecordField{..} =
            pretty elmRecordFieldName
        <+> colon
        <+> elmTypeRefDoc elmRecordFieldType

{- | Pretty printer for Elm types with one or more constructors:

@
type Status a
    = Foo String Int
    | Bar a
    | Baz
@

If the type is Enum this function will add enum specific functions:

type Status
    = Approved
    | Yoyoyo
    | Wow

showStatus : Status -> String
showStatus x = case x of
    Approved -> "Approved"
    Yoyoyo -> "Yoyoyo"
    Wow -> "Wow"

readStatus : String -> Maybe Status
readStatus x = case x of
    "Approved" -> Just Approved
    "Yoyoyo" -> Just Yoyoyo
    "Wow" -> Just Wow
    _ -> Nothing

universeStatus : List Status
universeStatus = [Approved, Yoyoyo, Wow]
-}
elmTypeDoc :: ElmType -> Doc ann
elmTypeDoc t@ElmType{..} =
    nest 4 ( vsep $ ("type" <+> pretty elmTypeName <> sepVars)
                  : constructorsDoc elmTypeConstructors
           )
    <> enumFuncs
  where
    sepVars :: Doc ann
    sepVars = case elmTypeVars of
        []   -> emptyDoc
        vars -> space <> sep (map pretty vars)

    constructorsDoc :: NonEmpty ElmConstructor -> [Doc ann]
    constructorsDoc (fstC :| rest) =
        equals <+> constructorDoc fstC
        : map ((pipe <+>) . constructorDoc) rest

    constructorDoc :: ElmConstructor -> Doc ann
    constructorDoc ElmConstructor{..} = sep $
        pretty elmConstructorName : map elmTypeRefDoc elmConstructorFields

    enumFuncs :: Doc ann
    enumFuncs =
        if isEnum t
        then vsep $ map (line <>) [elmEnumShowDoc t, elmEnumReadDoc t, elmEnumUniverse t]
        else emptyDoc

elmEnumShowDoc :: forall ann . ElmType -> Doc ann
elmEnumShowDoc t@ElmType{..} =
    line
    -- function type
    <> (showName <+> colon <+> pretty elmTypeName <+> arrow <+> "String")
    <> line
    -- function body
    <> nest 4
        ( vsep $ (showName <+> "x" <+> equals <+> "case x of")
        -- pattern matching
        : map patternMatch (getConstructorNames t)
        )
  where
    showName :: Doc ann
    showName = "show" <> pretty elmTypeName

    patternMatch :: Text -> Doc ann
    patternMatch (pretty -> c) = c <+> arrow <+> dquotes c
```

## Overview

**Mou**, the missing Markdown editor for *web developers*.

### Syntax

#### Strong and Emphasize

**strong** or __strong__ ( Cmd + B )

*emphasize* or _emphasize_ ( Cmd + I )

**Sometimes I want a lot of text to be bold.
Like, seriously, a _LOT_ of text**

#### Blockquotes

> Right angle brackets &gt; are used for block quotes.

#### Links and Email

An email <example@example.com> link.

Simple inline link <http://chenluois.com>, another inline link [Smaller](http://smallerapp.com), one more inline link with title [Resize](http://resizesafari.com "a Safari extension").

A [reference style][id] link. Input id, then anywhere in the doc, define the link with corresponding id:

[id]: http://mouapp.com "Markdown editor on Mac OS X"

Titles ( or called tool tips ) in the links are optional.

#### Images

An inline image ![Smaller icon](http://smallerapp.com/favicon.ico "Title here"), title is optional.

A ![Resize icon][2] reference style image.

[2]: http://resizesafari.com/favicon.ico "Title"

#### Inline code and Block code

Inline code are surround by `backtick` key. To create a block code:

  Indent each line by at least 1 tab, or 4 spaces.
    var Mou = exactlyTheAppIwant;

####  Ordered Lists

Ordered lists are created using "1." + Space:

1. Ordered list item
2. Ordered list item
3. Ordered list item

#### Unordered Lists

Unordered list are created using "*" + Space:

* Unordered list item
* Unordered list item
* Unordered list item

Or using "-" + Space:

- Unordered list item
- Unordered list item
- Unordered list item

#### Hard Linebreak

End a line with two or more spaces will create a hard linebreak, called `<br />` in HTML. ( Control + Return )
Above line ended with 2 spaces.

#### Horizontal Rules

Three or more asterisks or dashes:

***

---

- - - -

#### Headers

Setext-style:

This is H1
==========

This is H2
----------

atx-style:

# This is H1
## This is H2
### This is H3
#### This is H4
##### This is H5
###### This is H6

### Extra Syntax

#### Footnotes

Footnotes work mostly like reference-style links. A footnote is made of two things: a marker in the text that will become a superscript number; a footnote definition that will be placed in a list of footnotes at the end of the document. A footnote looks like this:

That's some text with a footnote.[^1]

[^1]: And that's the footnote.

#### Strikethrough

Wrap with 2 tilde characters:

~~Strikethrough~~

#### Fenced Code Blocks

Start with a line containing 3 or more backticks, and ends with the first line with the same number of backticks:

```
Fenced code blocks are like Stardard Markdown’s regular code
blocks, except that they’re not indented and instead rely on
a start and end fence lines to delimit the code block.
```
