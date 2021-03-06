#lang bitml

(debug-mode)

(verification-only)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")

(contract
 (pre
  (deposit "A" 3 "txA@0")(secret "A" a "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b")
  (deposit "B" 3 "txB@0")(secret "B" b "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"))
         
 (split
  (2 -> (choice
         (revealif (b) (pred (between b 0 1)) (withdraw "B"))
         (after 700000 (withdraw "A"))))
  (2 -> (choice
         (revealif (a) (pred (between a 0 1)) (withdraw "A"))
         (after 700000 (withdraw "B"))))
  (2 -> (choice
         (revealif (a b) (pred (= a b)) (withdraw "A"))
         (revealif (a b) (pred (!= a b)) (withdraw "B"))
         (split (1 -> (withdraw "A")) (1 -> (withdraw "B"))))))

 (check "A" has-at-least 2
        (secrets ((a 1) (b 0)) ((a 1) (b 1)) ((a 1) (b 2)))
        (strategy "A" (do-reveal a)))

 (check "B" has-at-least 2
        (secrets ((b 1) (a 0)) ((b 1) (a 1)) ((b 1) (a 2)))
        (strategy "B" (do-reveal b)))
        
 (check-liquid))