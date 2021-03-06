#lang bitml

(debug-mode)

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "022c3afb0b654d3c2b0e2ffdcf941eaf9b6c2f6fcf14672f86f7647fa7b817af30")
(participant "C" "03e969a9e8080b7515d4bbeaf253978b33226dd3c4fbc987d9b67fb2e5380cca9f")
(participant "D" "033ed7a4e8386a38333d6b7db03f532edece48ef3160688d73091644ecf0754910")

; C = committer, x = secret, Pi = other players
(define (TC C x y P1 P2 P3)
  (choice
   (revealif (x y) (pred (and (between x 0 1) (between y 0 1))) (withdraw C))
   (after 10 (split (4 -> (withdraw P1)) (4 -> (withdraw P2)) (4 -> (withdraw P3)))))
  )

(define (Round1)
  (choice
   (revealif (a1 b1) (pred (= a1 b1))
             (choice
              (revealif (c1 d1) (pred (= c1 d1)) (ref (Round2 "A" a2 "C" c2)))
              (revealif (c1 d1) (pred (!= c1 d1)) (ref (Round2 "A" a2 "D" d2)))
              (after 20 (split (1 -> (withdraw "A")) (1 -> (withdraw "B")) (1 -> (withdraw "C")) (1 -> (withdraw "D"))))))
   (revealif (a1 b1) (pred (!= a1 b1))
             (choice
              (revealif (c1 d1) (pred (= c1 d1)) (ref (Round2 "B" b2 "C" c2)))
              (revealif (c1 d1) (pred (!= c1 d1)) (ref (Round2 "B" b2 "D" d2)))
              (after 20 (split (1 -> (withdraw "A")) (1 -> (withdraw "B")) (1 -> (withdraw "C")) (1 -> (withdraw "D"))))))
   (after 15 (split (1 -> (withdraw "A")) (1 -> (withdraw "B")) (1 -> (withdraw "C")) (1 -> (withdraw "D"))))))

(define (Round2 P1 x1 P2 x2)
  (choice
   (revealif (x1 x2) (pred (= x1 x2)) (withdraw P1))
   (revealif (x1 x2) (pred (!= x1 x2)) (withdraw P2))
   (after 20 (split (2 -> (withdraw P1)) (2 -> (withdraw P2))))
   )
  )

(contract (pre
           (deposit "A" 13 "txA@0")(deposit "B" 13 "txB@0")(deposit "C" 13 "txC@0")(deposit "D" 13 "txD@0")
           (secret "A" a1 "c51b66bced5e4491001bd702669770dccf440982") (secret "A" a2 "f9292914bfd27c426a23465fc122322abbdb63b7")
           (secret "B" b1 "9804ebb0fc4a8329981dd33aaff32b6cb579580a") (secret "B" b2 "18ed15665ab53ba8f4c965748e8a657cf40ee3f2")
           (secret "C" c1 "183c86e0a286ac99ad8cf5c4cde36511181ffbd5") (secret "C" c2 "ded836a730cdeca5223f2609747074585f933aa8")
           (secret "D" d1 "14f06dde2fa12bd359ea0847de296f7b66a0f93f") (secret "D" d2 "7249ab836ec75abf7756aec7528812a86a9f23df"))
         
          (split
           (12 -> (ref (TC "A" a1 a2 "B" "C" "D")))
           (12 -> (ref (TC "B" b1 b2 "A" "C" "D")))
           (12 -> (ref (TC "C" c1 c2 "A" "B" "D")))
           (12 -> (ref (TC "D" d1 d2 "A" "B" "C")))
           (4 -> (ref (Round1))))

          #;(check-liquid
           (strategy "A" (do-reveal a1))
           (strategy "A" (do-reveal a2)))
          )