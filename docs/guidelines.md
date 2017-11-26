Documentation Guidelines
========================
To ease with writing, reading, and utilizing (pseuso-)code documentation,
here defines some rules.
These rules shouldn't never be treated as 'hard' rule anyways,
as it could be continously evolved and
sometimes good idea is delivered by a momentum inspiration during writing.
However, it is still consindered to be useful to define them here,
since it could be a reference for readers or be for helping future discussions.

## Character Encoding
It should be `utf-8`. It is considered to be most interoperable.

## File Format
As of writing (2017-11-23), I have chosen to use pandoc dialect Markdown.
The reason why not use GitHub-flavored one ('gfm') is just I wanted to have metadata (such as author or title) easily fed into pandoc to generate compiled documentation in html format.

## Pseudo-code Conventions
For most part, the code should have javascript-like syntax.
Each function (or routine, whatever you call it) documentation consists of
3 sections of description.
Those 3 sections are encouraged to be marked up with Markdown,
so that it gets more pretty if it is rendered as html,
without sacrificing readability of the raw text.

## 1.   declaration
The declaration starts with 3 or more underscores (_) to separate it from other ones,
followed by the line at 1st level heading with the syntax below.

```md
______________________________________
# $<bank>:<address> <namespace>.<name>
```
Where:
-   bank: per 8k-byte bank page number.
-   address: mapped address where the code begins execution.
-   namespace: see below.
-   name: whatever you choose to help with code reading and understanding.

#### namespaces
Namespace are currently defined as follows, but it is fine to add new ones.
Basically 1st level ones should specify a 'mode' it denotes, where 'mode' represents in-game facets.
As these 1st level namespaces act as prefix and therefore will apper in every definition,
it should be named as short as possible.

Currently the 1st level namespace is not defined for those not related to a particular game mode,
such as functions do just mathmatics. This is done to consindering these functions' generality nature and roles.
Other possibilities include giving it a very short name, such as: 'sys', 'std'.

If it found to be there are enough amount of functions within a category that as a whole achieves a particular goal,
it is good to define 2nd level namespaces.

##### 1st level namespaces:

-   field : generic field-mode related functions
    this ns is in consideration to divide into 2 separate category:
        world / floor
-   menu : generic menu-mode related functions
-   battle : generic battle-mode related functions
-   sound : sound driver functions
-   ppud : ppu driver functions

## 2.   metadata and notes
Then, any additional metadata, typically argument definitions but not limited to,
should immediately follow the beginning of the declaration.
Any metadata notation should have its own heading, which is at 3rd level.

## 3.   code
Once the declaration and metadata have completed, the code secion will follow.
You may surround the code with markup "```" and may also add a heading immediately before it.

The code here would be good to be written in javascript-like syntax as possible,
so that the syntax highlighting works well to help understanding.
The langauge should have enough capability to express the original code's intention.

In addition to the above, it would also be good to define some basic rules to name variables:
### variable names
#### registers
The 6502 registers will have the same name in the (pseudo-)code.
So the following one character variables represent these:
    `A, X, Y, P, S`.
#### processor flags
While `P` is available as a whole processor flags register,
it may be more convenient to define its individual flags separately, like:
    `carry, zero, overflow` etc.
#### other variables
For variables which live in other than the registers, it should be named after its address.
Aliases are fine, but its assignment should be explicit.

## example
Wrapping up the above as a whole, an example documentation will like the below:

### 1st part (function declaration)
```md
________________________________________
# $2f$a38c battle.enemy.gfx.load_pattern()
<details>
```

### 2nd part (metadata or additional notes you'd like to mention about the function)
```md
## preserved:
+   u8      x
## args:
+   u8      x       : group_index
+   u8[4]   $7d6b   : enemy_id
+   u8      $7d7b   : enemy_graphics_layout_id
```

### 3rd part (the code)
```md
## code:
    ```js
    {
        if ( $7d6b[group_index] == 0xff ) {
            return;
        }
        x <<= 1;
        if ( $7d7b == 0x09 ) {
            battle.enemy.gfx.load_pattern_for_layout9(x);  //$a3ab
        } else {
            battle.enemy.gfx.load_pattern(x);  //$a42e
        }   
    }
    ```
</details>
```

