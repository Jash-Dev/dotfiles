(define (approx-16-9? w h)
  ;; Returns #t if width:height is roughly 16:9
  (let* (
         ;; |w*9 - h*16|  ≈ 0 for real 16:9
         (diff (abs (- (* w 9) (* h 16))))
        )
    ;; Tolerance: tweak this if you like.
    ;; 1000 here is "loose but practical" for big images.
    (< diff 1000)
  )
)

(define (batch-process-levels pattern outdir)
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
      (let* (
             (filename (car filelist))
             (image    (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
             (drawable (car (gimp-image-get-active-layer image)))
             (w        (gimp-image-width image))
             (h        (gimp-image-height image))
            )

        ;; -------- Levels ----------
        ;; Adjust these to taste:
        ;; black=10, white=245, midtone=0.95
        (gimp-levels drawable HISTOGRAM-VALUE 10 245 0.95 0 255)

        ;; -------- Conditional resize ----------
        ;; Only resize if the image is ~16:9
        (if (approx-16-9? w h)
            (gimp-image-scale image 3840 2160)
        )

        ;; -------- Save ----------
        (let* ((outfile (string-append outdir "/" (basename filename))))
          (gimp-file-save RUN-NONINTERACTIVE image drawable outfile outfile))

        (gimp-image-delete image))

      (set! filelist (cdr filelist)))))

