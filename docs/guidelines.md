Documentation Guidelines
========================
To ease with writing, reading, and utilizing (pseuso-)code documentation,
here defines some rules.
These rules shouldn't never be treated as 'hard' rule anyways,
as it could be continously evolved and
sometimes good idea is delivered by a momentum inspiration during writing.
However, it is still consindered to be useful to define here,
since it could be a reference for readers or be for helping future discussions.

## Character Encoding
It should be utf-8. It is considered to be most interoperable.

## Pseudo-code Conventions
For most part, the code should have javascript-like syntax.
Each function (or routine, whatever you call it) documentation consists of
3 sections of description.
Those 3 sections should be marked up with Markdown,
so that it gets more pretty if it is rendered as html,
without sacrificing readability of the raw text.

## 1.   declaration
The declaration starts with 3 or more underscores (_) to separate it from other ones,
followed by the line at 1st level heading with the syntax below.

```md
______________________________________
# $<bank>$<address> <namespace>.<name>
```
Where:
-   bank: per 8k-byte bank page number.
-   address: mapped address where the code begins execution.
-   namespace: see below.
-   name: whatever you choose to help with code reading and understanding.
#### namespaces
<details>

Namespace are currently defined as follows, but it is fine to define new ones:
-   field
-   field.world
-   field.floor
-   field.floor.event
-   field.floor.object
-   field.floor.chip

-   battle
-   battle.enemy
-   battle.enemy.gfx
-   battle.present

-   sound

-   util
</details>

## 2.   metadata
Then, any additional metadata, typically argument definitions but not limited to those,
should immediately follow the beginning of the declaration.
Any metadata notation should have its own heading, which is at 2nd level.

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
While `P` is available as a whole processor flags,
it may be more convenient to define its individual flags separately, like:
    `carry, zero, overflow` etc.
#### other variables
For variables live in other than the registers, it should be named after its address.
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

